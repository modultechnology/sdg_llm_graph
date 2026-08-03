# Release manifest

## In this repository

| Path | What |
|---|---|
| `notebooks/01_matrix_preprocessor.ipynb` | Matrix A from UN indicators; Figure 2 |
| `notebooks/02_pipeline_{gemma,mistral,qwen,mixtral}.ipynb` | LLM stages, matrices A–G, Table 3, baselines B1–B4, doc methods |
| `notebooks/03_compare_ablate.ipynb` | Tables 4–7, ablations, McNemar, diagnostics 1–3, Aurora co-occurrence matrix |
| `artifacts/sdg_interaction_matrix_v3_2.json` | Released goal-level matrix A (+ per-country matrices, coverage counts) |
| `artifacts/un_sdg_series_descriptions.json` | 713 UN series descriptions, release 2026.Q1.G.01 |
| `artifacts/sdg_interaction_matrix_v3_2.png` | Figure 2 as rendered |
| `artifacts/predictions/*.npz` | Raw LLM predictions, all four backbones (16 arrays, 0.5 MB) |
| `config.yaml`, `requirements.txt`, `scripts/check_no_private_paths.sh` | Setup and release gate |
| `LICENSE`, `NOTICE` | Apache-2.0 full text; attribution for the vendored vLLM patch |

## Still to add before release

| Item | Owner | Note |
|---|---|---|
| `vendor/gemma4_patched.py` + sha256 | you | needs Mario Iseli's OK to redistribute |
| `artifacts/sdg_direction_uncertain_for_review.csv` | you | the 216 excluded series; referenced by README §4 and paper §4.1 |
| `SDG_Direction_Review_for_Colleague.md` | you | instructions doc that accompanies the CSV |
| Aurora Zenodo **versioned** DOI | you | not the concept DOI — pin the exact version used |
| OpenAlex snapshot date | you | abstracts were fetched over a date range; record it |
| UN archive sha256 + download date | you | release tag 2026.Q1.G.01 already known |
| `repository-code` / `<repo-url>` placeholders | you | in README and CITATION.cff |

## Not shipped, by design

- `sdg_data/` — the data root, gitignored
- Aurora label set, OpenAlex abstracts — fetched at runtime from their sources
- `SDG_UN_data.zip` — user-supplied, see README §2
