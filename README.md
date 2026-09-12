# Neighbours and Graphs: LLM-Based SDG Classification of Research Abstracts

Code and artefacts for the paper. Everything is driven by notebooks; there is no
package to install beyond `requirements.txt`.

The headline result: on a 10 000-paper Aurora test set, an SBERT K-nearest-neighbour
post-correction lifts goal-level macro-F1 from 0.5359 (target-LLM aggregated) to
0.6088 on the Gemma 4 backbone, while none of seven SDG–SDG interaction matrices
beats the same baseline under label propagation.

---

## 1. Setup

### On Google Colab (how the paper's runs were done)

Upload a notebook to Colab and press **Run All**. There is nothing to configure
and no shell commands to type. The first path cell mounts your Drive and creates
this layout (the folder name is the default; override it with `SDG_ROOT` below):

```
MyDrive/sdg-llm-graph/
  sdggraph/
  aurora_sdg_graph_full/
```

Everything the notebooks read or write lives under that one folder. The `!pip`
cells inside each notebook install what they need, so `requirements.txt` is only
for local runs.

**To use a different Drive folder** — for example one that already holds caches
from an earlier run — add a cell *above* the path cell:

```python
import os
os.environ['SDG_ROOT'] = '/content/drive/MyDrive/<your-existing-folder>'
```

The layout beneath it must match the tree above. Nothing else changes.

**Before running notebook 1**, put the UN archive in Drive at
`MyDrive/sdg-llm-graph/sdggraph/SDG_UN_data.zip` (drag and drop in the Drive web
UI is fine). **Before running notebook 2 on Gemma**, put `gemma4_patched.py` at
`MyDrive/sdg-llm-graph/vendor/gemma4_patched.py` — the notebook looks there as
well as in a local `vendor/` directory. Set `HF_TOKEN` in Colab Secrets (key icon,
notebook access ON); `OPENALEX_MAILTO` can go in Secrets too or be left at its
placeholder.

### Locally

```bash
pip install -r requirements.txt
export SDG_ROOT=/somewhere/with/space   # or edit root: in config.yaml
jupyter lab notebooks/
```

`config.yaml` is read only when it sits next to the notebook or one directory up,
which is the case for a local checkout and not on Colab. The resolution order is
always: `$SDG_ROOT` → `config.yaml` → Drive (Colab) → `./sdg_data`.

## 2. What you must supply yourself

| Item | Where it goes | Why it isn't here |
|---|---|---|
| UN SDG Indicators archive, 17 Excel files | `<root>/sdggraph/SDG_UN_data.zip` | ~239 MB; redistribution terms unverified |
| HuggingFace read token | `export HF_TOKEN=hf_...` | secret |
| Contact email for the OpenAlex polite pool | `export OPENALEX_MAILTO=you@org` | identifies *you*, not us |

The Aurora label set and OpenAlex abstracts are fetched automatically, and
`00_release_assets.ipynb` fetches `vendor/gemma4_patched.py` for you.

**Aurora label set.** The pipeline notebooks download
`10.5281/zenodo.5224005` — "DOI's with SDG labels on Target level | 1.4M
research articles (2009-2020)", version 1.1. That is the *versioned* DOI, so
re-runs get the same deposit; the concept DOI `10.5281/zenodo.5205672` always
resolves to the latest version and is deliberately not used here. Note this is a
different deposit from the Aurora search queries (`10.5281/zenodo.4883250`),
which this work does not use.

**OpenAlex abstracts.** Abstracts are reconstructed from the OpenAlex inverted
index at fetch time. The cache behind the published results was built on
**2026-05-05**. OpenAlex is versionless, so a later fetch may return a revised
abstract for some DOIs; the test-split DOI list is pinned by the SHA-1
fingerprints below, so the *set* of papers is reproducible even when the text is
not byte-identical. The cache itself is committed under `artifacts/data_cache/`,
so the published numbers reproduce without any re-fetch.

| split | n | SHA-1 fingerprint of the ordered DOI list |
|---|---|---|
| test | 10,000 | `4c5581303537` |
| validation | 200 | `b212c22b4951` |
| neighbour pool | 3,054 | `c8ffa1517ecc` |

**UN archive provenance.** The matrix shipped in `artifacts/` was built from
release `2026.Q1.G.01` of the UN Global SDG Indicators Database. Record the
`sha256` of your own copy in this table when you download it, so future re-runs
can tell whether they got the same snapshot:

| file | release | sha256 | downloaded |
|---|---|---|---|
| `SDG_UN_data.zip` | 2026.Q1.G.01 | `cd8d139ee20f178290e856708f9d95855dd7b01c6365e2675fd5ce60fcf0d060` | 2026-08-03 |

## 3. Run order

| # | Notebook | Hardware | Time | Produces |
|---|---|---|---|---|
| 0 | `00_release_assets.ipynb` | CPU | seconds | Fetches the vLLM patch, writes `NOTICE`, checksums inputs. Run once. |
| 1 | `01_matrix_preprocessor.ipynb` | CPU | ~5 min | Matrix A, Figure 2 |
| 2 | `02_pipeline_<backbone>.ipynb` | Blackwell GPU | ~3 GPU-h each | Stage 1+2 LLM probabilities, matrices A–G, Table 3, baselines B1–B4 |
| 3 | `03_compare_ablate.ipynb` | CPU | minutes | Tables 3–6, K×λ ablation, McNemar, the three diagnostics, split export |

Notebook 2 exists in four copies, one per backbone (`gemma`, `mistral`, `qwen`,
`mixtral`). They are near-identical — the model is chosen by `ACTIVE_MODEL` from
a registry — **except `02_pipeline_mistral.ipynb`, whose Stage-1 and Stage-2 cells
diverge** (a re-run with a cleared cache). They are shipped separately rather than
merged so that each file is what actually ran.

Notebook 3 reads the cached probabilities written by notebook 2, so once the
caches exist it re-runs on a CPU-only Colab runtime (or a laptop) in minutes.

## 4. Reproducibility, honestly

**Tier A — post-correction replay (CPU, minutes, exact).** Given the cached raw
LLM probabilities, notebook 3 reproduces Tables 4–7 deterministically with
`SEED=42` under NumPy 1.26.

**Tier B — full LLM re-run (GPU, ~3 h per backbone, approximate).** vLLM's CUDA
reductions are not bit-deterministic even at `temperature=0`; parse differences
affect <0.5 % of papers and macro-F1 reproduces to within ±0.001.

**Matrix A is a third case.** Its Spearman correlations are computed by a
hand-rolled float32 GPU routine, which is not bit-identical across GPUs, drivers,
or a CPU fallback, and whose rank-tie handling differs slightly from
`scipy.stats.spearmanr`. **The shipped `artifacts/sdg_interaction_matrix_v3_2.json`
is normative**; a local rebuild should agree closely but is not guaranteed
bit-exact.

**The raw LLM predictions ship with this repository.** All four backbones'
goal- and target-level probability arrays are committed under
`artifacts/predictions/` as compressed `.npz` — 16 arrays, 31.6 MB raw,
0.5 MB packaged, verified `array_equal` against the originals. That means
Tables 4-7 can be reproduced with no GPU, no external download, and no
credentials: see "Reproducing the results in five minutes" below.

**Series accounting for matrix A.** 713 series retrieved → 19 dropped as
Boolean/dummy → 216 dropped because the direction-of-progress classifier could
not assign a sign confidently → **478 series** entered the analysis. Uncertain
series are excluded rather than defaulted, since a wrong sign inverts a synergy
into a trade-off. The excluded list is
`artifacts/sdg_direction_uncertain_for_review.csv`; `DIRECTION_OVERRIDES` in
notebook 1 is the hook for feeding expert corrections back in, and is empty in
the released configuration — which is the configuration that produced the
published matrix.

**This release has been verified against the published results.** After the
path refactor, `01_matrix_preprocessor.ipynb` rebuilt matrix A from the same UN
archive and reproduced `artifacts/sdg_interaction_matrix_v3_2.json` **exactly**
(max absolute difference 0.0 across all 289 cells; indicator-pair coverage
counts identical). `03_compare_ablate.ipynb`, run against the cached LLM
predictions, reproduced every value of Tables 4 and 6 to four decimal places —
twelve comparisons across four backbones, largest deviation 0.0000. The
`02_pipeline_*` notebooks were not re-executed; they share the same edit set,
recorded cell by cell in `SANITISATION_DIFF.md`, and no hyperparameter, prompt,
matrix construction, propagation rule, or parsing rule was modified in any
notebook.

**One configuration note.** The doc-methods cell in notebook 2 defaults to
`DOC_NEIGHBOURS_K = 20` and `PER_GOAL_LAMBDA = True`. The paper's canonical
setting is K = 50 with a single global λ; that comes from the sweep in notebook 3,
not from these defaults. The mismatch is expected.

## 4b. Reproducing the results in five minutes

No GPU, no API key, no data download.

```bash
git clone https://github.com/modultechnology/sdg_llm_graph && cd sdg_llm_graph
pip install -r requirements.txt
export SDG_ROOT=$(pwd)/sdg_data
mkdir -p sdg_data/aurora_sdg_graph_full
cp -r artifacts/predictions artifacts/data_cache artifacts/splits \
      sdg_data/aurora_sdg_graph_full/
jupyter lab notebooks/03_compare_ablate.ipynb
```

`03_compare_ablate.ipynb` reads the committed `.npz` predictions and recomputes
the per-document methods, the K x lambda ablation, the McNemar tests, and the
three diagnostics of section 7.5. Runs on a laptop in minutes.

The three cells at the end of that notebook — split export, corpus prevalence,
and the per-goal breakdown — additionally read
`data_cache/abstracts_full.parquet` and `data_cache/aurora_multilabel_full.parquet`,
both copied by the command above.

Notebooks `01` and `02` are only needed to regenerate the inputs from scratch:
`01` rebuilds matrix A from the UN archive, `02` re-runs the LLM stages on a
Blackwell GPU. Neither is required to check the published numbers.

## 5. The Gemma NVFP4 patch

The Gemma 4 26B-A4B NVFP4 build is a community quantisation. vLLM's Gemma 4
`expert_params_mapping` does not map NVFP4 scale keys (`.weight_scale`,
`.weight_scale_2`, `.input_scale`) onto FusedMoE parameter names, so the
checkpoint will not load without a replacement for
`vllm/model_executor/models/gemma4.py` (vLLM issue #38912). `needs_nvfp4_patch`
is set for **`gemma4-26b` only** — the primary backbone behind every headline
number. Mistral, Qwen3 and Mixtral use `compressed-tensors` or plain FP8 and are
unaffected.

`00_release_assets.ipynb` downloads the file to `vendor/gemma4_patched.py`. The
pipeline notebooks prefer that vendored copy, fall back to the upstream URL, and
**raise** if neither works — booting an unpatched vLLM silently changes model
behaviour.

The file is Apache-2.0, derived from vLLM's own Gemma 4 implementation, and is
redistributed here under the same licence with attribution in `NOTICE`.

| file | sha256 | retrieved |
|---|---|---|
| `vendor/gemma4_patched.py` | `26d4748c74de9e24a5600e19c53e671ff0d0e5d6143f29c8c54b679e4f455977` | 2026-08-03 |

**Revision caveat.** The original runs fetched this file from the model
repository's `main` branch at execution time and did not archive it, so the
exact revision used then cannot be established. The vendored copy is what `main`
served on the date recorded in `NOTICE`, which may differ from the revision used
during the original runs. Anyone reproducing from scratch should pin a commit
hash rather than `main`. NVIDIA later published an official
`nvidia/Gemma-4-26B-A4B-NVFP4` checkpoint (2026-05-01), which avoids the patch
entirely but is a different checkpoint and would give different numbers.

## 6. Repository hygiene

Contributors and anyone preparing an updated release should run:

```bash
bash scripts/check_no_private_paths.sh
```

It fails on private paths and credentials, warns on stray email addresses and on
notebooks carrying executed outputs, and flags any `*_VERIFY_*` notebook. Those
are local working copies with a hardcoded data root; they are gitignored and are
not part of the release.

`.gitignore` also excludes `sdg_data/`, `sdggraph/` and `aurora_sdg_graph_full/`,
which appear inside a working copy once the notebooks run and hold the UN archive
and the caches. Check `git status` before committing.

**Provenance status.** Every input is pinned: the UN archive by release tag and
sha256 (section 2), the Aurora label set by versioned Zenodo DOI (section 2), the
OpenAlex fetch by date (section 2), the vLLM patch by sha256 (section 5), and the
evaluation split by SHA-1 fingerprint. The one thing outside our control is
OpenAlex itself, which is versionless: a re-fetch may return revised abstracts
for some DOIs. That affects regeneration from scratch only — reproducing the
published tables from the committed predictions (section 4b) is unaffected.

## 7. Citing

Archived release: https://doi.org/10.5281/zenodo.XXXXXXX

See `CITATION.cff`. Licence: Apache-2.0 — full text in `LICENSE`, attribution for
the vendored vLLM patch and the OpenAlex abstract cache in `NOTICE`. The Aurora
label set, OpenAlex metadata, and the UN Indicators Database carry their own
terms.