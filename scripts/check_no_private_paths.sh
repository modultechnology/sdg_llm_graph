#!/usr/bin/env bash
# Fails if anything that looks like a private path or a secret is about to ship.
# Run this before every commit and before uploading the release archive.
#
# All patterns are POSIX extended regular expressions (grep -E): use +, {n,}
# and (a|b) unescaped. (Earlier versions used basic-regex escapes such as \+
# and \{20,\} under -E, which silently matched nothing.)
set -uo pipefail
cd "$(dirname "$0")/.."

# Order matters in GNU grep: --include must precede --exclude, otherwise files
# matching neither (README.md, say) are scanned anyway.
EXCLUDES=(--exclude-dir=.git --exclude-dir=sdg_data --exclude-dir=_cache
          --exclude='check_no_private_paths.sh' --exclude='*_VERIFY_*')

# 1. Secrets and private identifiers: checked in every text file.
SECRET_PATTERNS=(
  'modulcolab'
  'sk-ant-[A-Za-z0-9_-]+'
  'hf_[A-Za-z0-9]{20,}'
  'AKIA[0-9A-Z]{16}'
  "userdata\.get\(['\"]ANTHROPIC"
)

# 2. Hard-coded paths: checked in code and config only (README and docs may
#    describe the default Drive layout in prose). Every path must derive from
#    the resolved root; the one allowed literal is the generic Colab default
#    '/content/drive/MyDrive/sdg-llm-graph' itself, inside the resolver.
PATH_PATTERNS=(
  '/content/drive/MyDrive/[A-Za-z0-9_.-]+/'      # anything below a Drive folder
  '/content/(sample_data|[a-z_]+\.(csv|json|npy|npz|parquet|zip))'
  '/Users/[A-Za-z0-9._-]+/'
  '/home/[a-z][a-z0-9_-]*/'
  '[A-Za-z]:\\\\(Users|Documents)'
  "['\"]/tmp/"
)
CODE_INCLUDES=(--include='*.ipynb' --include='*.py' --include='*.sh'
               --include='*.yaml' --include='*.yml' --include='*.cfg')

FAIL=0
scan() {   # $1 = label, $2 = pattern, rest = extra grep args
  local label="$1" pat="$2"; shift 2
  local hits
  hits=$(grep -rInE --binary-files=without-match "$@" "${EXCLUDES[@]}" -- "$pat" . 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "FAIL  $label: $pat"
    echo "$hits" | cut -c1-220 | sed 's/^/      /'
    FAIL=1
  fi
}

for pat in "${SECRET_PATTERNS[@]}"; do scan 'secret' "$pat"; done
for pat in "${PATH_PATTERNS[@]}";   do scan 'hard-coded path' "$pat" "${CODE_INCLUDES[@]}"; done

# A Drive folder other than the generic default (any depth, code and config only)
drive=$(grep -rInoE "${CODE_INCLUDES[@]}" "${EXCLUDES[@]}" \
          '/content/drive/MyDrive/[A-Za-z0-9_.<>-]+' . 2>/dev/null \
        | grep -vE ':/content/drive/MyDrive/sdg-llm-graph$' || true)
if [ -n "$drive" ]; then
  echo "FAIL  hard-coded path: Drive folder other than the default sdg-llm-graph"
  echo "$drive" | sed 's/^/      /'
  FAIL=1
fi

# Bare email addresses outside the documented placeholder
emails=$(grep -rIoE "${EXCLUDES[@]}" \
          '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' . 2>/dev/null \
        | grep -v 'example\.com\|example\.org\|@[Ww]n\.T\|@Wp\.T' || true)
if [ -n "$emails" ]; then
  echo "WARN  email addresses found (check these are meant to be public):"
  echo "$emails" | sed 's/^/      /'
fi

# Executed notebook outputs (they can carry paths in printed logs)
outs=$(python3 - <<'PY'
import json, glob
bad = []
for p in sorted(glob.glob('notebooks/*.ipynb')):
    nb = json.load(open(p, encoding='utf-8'))
    n = sum(1 for c in nb['cells'] if c['cell_type'] == 'code' and c.get('outputs'))
    if n:
        bad.append(f'{p}: {n} cells with stored output')
print('\n'.join(bad))
PY
)
if [ -n "$outs" ]; then
  echo "WARN  notebooks still carry outputs:"
  echo "$outs" | sed 's/^/      /'
fi

# Verification copies are gitignored by design, but say so out loud.
vfiles=$(ls notebooks/*_VERIFY_*.ipynb 2>/dev/null || true)
if [ -n "$vfiles" ]; then
  echo "NOTE  verification copies present (gitignored, do not ship):"
  echo "$vfiles" | sed 's/^/      /'
fi

if [ "$FAIL" -eq 0 ]; then
  echo "PASS  no private paths or secrets found."
fi
exit $FAIL
