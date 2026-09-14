# Release manifest

## In this repository

| Path | What |
|---|---|
| `notebooks/01_matrix_preprocessor.ipynb` | Matrix A from UN indicators; Figure 2 |
| `notebooks/02_pipeline_{gemma,mistral,qwen,mixtral}.ipynb` | LLM stages, matrices A–G, Table 3, baselines B1–B4, doc methods |
| `notebooks/03_compare_ablate.ipynb` | Tables 3–6, ablations, McNemar, diagnostics 1–3, Aurora co-occurrence matrix, split export |
| `artifacts/sdg_interaction_matrix_v3_2.json` | Released goal-level matrix A (+ per-country matrices, coverage counts) |
| `artifacts/un_sdg_series_descriptions.json` | 713 UN series descriptions, release 2026.Q1.G.01 |
| `artifacts/sdg_interaction_matrix_v3_2.png` | Figure 2 as rendered |
| `artifacts/sdg_direction_uncertain_for_review.csv` | The 216 UN series excluded as direction-unclassifiable |
| `artifacts/predictions/*.npz` | Raw LLM predictions, all four backbones (16 arrays, 0.5 MB) |
| `artifacts/splits/*` | Evaluation splits: ordered DOI lists, manifests with per-abstract SHA-256, goal and target labels |
| `artifacts/results/cross_model_comparison_v5/*.csv` | Every table and diagnostic in the paper, as written by notebook 03 |
| `artifacts/data_cache/*.parquet` | OpenAlex abstract cache as fetched 2026-05-05, so the results reproduce without a re-fetch |
| `artifacts/data_cache/sbert_target_matrix_169.npy` | Matrix C (SBERT cosine on target descriptors, median-centred) |
| `artifacts/data_cache/keyword_matrix_169_methods_v2_0.0.npy` | Matrix F (Jaccard on stopword-filtered content tokens) |
| `artifacts/data_cache/target_descriptors_169.json` | The 169 UN target descriptions from which C and F are built |
| `artifacts/data_cache/entities_*.json` | Cached LLM entity extractions for the doc_entities stream |
| `config.yaml`, `requirements.txt`, `scripts/check_no_private_paths.sh` | Setup and release gate |
| `LICENSE`, `NOTICE` | Apache-2.0 full text; attribution for the vendored vLLM patch and the OpenAlex cache |

Matrices B, D, E and G are not shipped as files: B inherits A by goal, D is a
weighted mix of B and C, E is the three-valued 5 P taxonomy, and G is drawn from
`np.random.RandomState(42)`. All four are reconstructed deterministically by
notebook 02 from A and C.

## Release checklist

| Item | Status |
|---|---|
| `vendor/gemma4_patched.py` + sha256 in `NOTICE` | done — Apache-2.0, redistribution permitted |
| `artifacts/splits/` | done — 13 files, all three fingerprints verified |
| `artifacts/results/` | done — 9 CSVs backing every table in the paper |
| `artifacts/data_cache/` | done — abstract cache, matrices C and F, target descriptors, entity caches |
| Aurora versioned DOI, OpenAlex snapshot date, UN archive sha256 | done — recorded in README §2 |
| `repository-code` in `CITATION.cff` | done |
| Zenodo DOI in README §7 and in the paper | done — README cites the concept DOI 10.5281/zenodo.22726654; the paper cites the version DOI of the release behind its numbers |

## Not shipped, by design

- `sdg_data/` — the local data root, gitignored
- Aurora label set — fetched at runtime from `10.5281/zenodo.5224005` (v1.1)
- `SDG_UN_data.zip` — user-supplied, ~239 MB, see README §2
- SBERT model weights — fetched from Hugging Face at runtime
