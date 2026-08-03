# Sanitisation change log

Every edit made to the original notebooks, by file and original cell index.
No hyperparameter, prompt, matrix construction, propagation rule, or
parsing/retry rule was touched. Only paths, secrets, Colab plumbing, and
stale comments changed.

Additionally, in **every** notebook: stored cell outputs and execution counts
were cleared, and the `metadata.colab` / `metadata.accelerator` blocks were
removed (the GPU type is documented in the README instead).

Manual edits not captured by the patch scripts:

- `01_matrix_preprocessor.ipynb` markdown cells 0 and 25: example paths rewritten
  to `$SDG_ROOT/sdggraph/...` and to an `os.path.join(GRAPH_DIR, ...)` snippet.
- `02_pipeline_*.ipynb` header markdown: one sentence referring to the old data
  folder by name reworded to "under the data root".
- `artifacts/sdg_interaction_matrix_v3_2.json`: six keys added under `stats`
  (`n_series_total_api`, `n_series_boolean_excluded`, `n_series_direction_uncertain`,
  `n_series_used`, `series_accounting_note`, `un_database_release`).
  `matrix_W`, `matrix_signed` and `n_pairs` verified byte-identical to the original.

## 01_matrix_preprocessor.ipynb

| orig. cell | change |
|---|---|
| 3 | Drive mount + hardcoded DRIVE_DIR replaced by path bootstrap; DRIVE_DIR = GRAPH_DIR |
| 4 | EXTRACT_DIR and CACHED_CSV moved from /content to $SDG_ROOT/_cache; scratch dir created |
| 6 | Error text no longer assumes Google Drive |

## 02_pipeline_gemma.ipynb

| orig. cell | change |
|---|---|
| 3 | DELETED: Colab notebook-autosave cell (searched /content/drive/MyDrive; no effect on results) |
| 5 | Drive mount, hardcoded DRIVE_ROOT/GRAPH_DIR, rm -rf /content/drive, Colab-only HF token and network-only NVFP4 patch all replaced: path bootstrap + env-first token + vendored-patch-with-raise + VLLM_LOG in RESULTS_DIR |
| 7 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 8 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 10 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 15 | stale "four matrices"/"four-way"/v4 wording corrected |
| 16 | stale "four matrices"/"four-way"/v4 wording corrected |
| 25 | stale "four matrices"/"four-way"/v4 wording corrected |
| 27 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 29 | stale "four matrices"/"four-way"/v4 wording corrected |
| 31 | shell !grep of /content/vllm_server.log -> python tail of VLLM_LOG |

## 02_pipeline_mistral.ipynb

| orig. cell | change |
|---|---|
| 1 | DELETED scratch cell: '!curl ipinfo.io' |
| 2 | DELETED scratch cell: '#!colab new --gpu G4 -s my_blackwell_ses' |
| 3 | DELETED scratch cell: '#!nvidia-smi' |
| 6 | DELETED: Colab notebook-autosave cell (searched /content/drive/MyDrive; no effect on results) |
| 8 | Drive mount, hardcoded DRIVE_ROOT/GRAPH_DIR, rm -rf /content/drive, Colab-only HF token and network-only NVFP4 patch all replaced: path bootstrap + env-first token + vendored-patch-with-raise + VLLM_LOG in RESULTS_DIR |
| 10 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 13 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 15 | stale "four matrices"/"four-way"/v4 wording corrected |
| 16 | stale "four matrices"/"four-way"/v4 wording corrected |
| 27 | stale "four matrices"/"four-way"/v4 wording corrected |
| 31 | stale "four matrices"/"four-way"/v4 wording corrected |
| 32 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 36 | shell !grep of /content/vllm_server.log -> python tail of VLLM_LOG |

## 02_pipeline_qwen.ipynb

| orig. cell | change |
|---|---|
| 3 | DELETED: Colab notebook-autosave cell (searched /content/drive/MyDrive; no effect on results) |
| 5 | Drive mount, hardcoded DRIVE_ROOT/GRAPH_DIR, rm -rf /content/drive, Colab-only HF token and network-only NVFP4 patch all replaced: path bootstrap + env-first token + vendored-patch-with-raise + VLLM_LOG in RESULTS_DIR |
| 7 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 9 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 14 | stale "four matrices"/"four-way"/v4 wording corrected |
| 15 | stale "four matrices"/"four-way"/v4 wording corrected |
| 24 | stale "four matrices"/"four-way"/v4 wording corrected |
| 26 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 29 | stale "four matrices"/"four-way"/v4 wording corrected |
| 31 | shell !grep of /content/vllm_server.log -> python tail of VLLM_LOG |

## 02_pipeline_mixtral.ipynb

| orig. cell | change |
|---|---|
| 3 | DELETED: Colab notebook-autosave cell (searched /content/drive/MyDrive; no effect on results) |
| 5 | Drive mount, hardcoded DRIVE_ROOT/GRAPH_DIR, rm -rf /content/drive, Colab-only HF token and network-only NVFP4 patch all replaced: path bootstrap + env-first token + vendored-patch-with-raise + VLLM_LOG in RESULTS_DIR |
| 7 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 10 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 15 | stale "four matrices"/"four-way"/v4 wording corrected |
| 16 | stale "four matrices"/"four-way"/v4 wording corrected |
| 25 | stale "four matrices"/"four-way"/v4 wording corrected |
| 27 | hardcoded cache/results paths -> DATA_CACHE/DRIVE_ROOT joins; OpenAlex mailto from $OPENALEX_MAILTO |
| 29 | stale "four matrices"/"four-way"/v4 wording corrected |
| 31 | shell !grep of /content/vllm_server.log -> python tail of VLLM_LOG |

## 03_compare_ablate.ipynb

| orig. cell | change |
|---|---|
| 1 | Drive mount + hardcoded ROOT replaced by path bootstrap; missing-file check added so the cell reports rather than raising when a backbone has not been run |
| 3 | second Drive mount and duplicate DRIVE_ROOT/DATA_CACHE definitions removed (both now come from the bootstrap in cell 1) |
| 11 | DRIVE_ROOT.replace(...) string surgery -> GRAPH_DIR; OpenAlex mailto from $OPENALEX_MAILTO |
| 34 | DRIVE_ROOT.replace(...) string surgery -> GRAPH_DIR; OpenAlex mailto from $OPENALEX_MAILTO |
| 35 | DRIVE_ROOT.replace(...) string surgery -> GRAPH_DIR; OpenAlex mailto from $OPENALEX_MAILTO |
