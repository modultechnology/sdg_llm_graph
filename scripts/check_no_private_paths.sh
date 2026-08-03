#!/usr/bin/env bash
# Fails if anything that looks like a private path or a secret is about to ship.
# Run this before every commit and before uploading the release archive.
set -uo pipefail
cd "$(dirname "$0")/.."

PATTERNS=(
  'modulcolab'
  'MyDrive/[A-Za-z0-9_-]\+/'      # any MyDrive subfolder that is not the generic default
  'sk-ant-'
  'hf_[A-Za-z0-9]\{20,\}'
  'userdata.get('"'"'ANTHROPIC'
  'AKIA[0-9A-Z]\{16\}'
)

FAIL=0
for pat in "${PATTERNS[@]}"; do
  # config.yaml is user-editable and gitignored in its local form; scan it anyway
  hits=$(grep -rInE --binary-files=without-match \
           --exclude-dir=.git --exclude-dir=sdg_data --exclude-dir=_cache \
           --exclude='check_no_private_paths.sh' --exclude='*_VERIFY_*' \
           "$pat" . 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "FAIL  pattern: $pat"
    echo "$hits" | sed 's/^/      /'
    FAIL=1
  fi
done

# Bare email addresses outside the documented placeholder
emails=$(grep -rIoE --exclude-dir=.git --exclude-dir=sdg_data \
          --exclude='check_no_private_paths.sh' --exclude='*_VERIFY_*' \
          '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' . 2>/dev/null \
        | grep -v 'example\.com\|example\.org\|@[Ww]n\.T\|@Wp\.T' || true)
if [ -n "$emails" ]; then
  echo "WARN  email addresses found (check these are meant to be public):"
  echo "$emails" | sed 's/^/      /'
fi

# Executed notebook outputs (they can carry paths in printed logs)
outs=$(python3 - <<'PY'
import json, glob, sys
bad=[]
for p in glob.glob('notebooks/*.ipynb'):
    nb=json.load(open(p))
    n=sum(1 for c in nb['cells'] if c['cell_type']=='code' and c.get('outputs'))
    if n: bad.append(f'{p}: {n} cells with stored output')
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
