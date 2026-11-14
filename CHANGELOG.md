# Changelog

## 1.1.0 — third review round (2026-11-13)

Nothing that produced a published number has changed: no prompt,
hyperparameter, matrix construction, propagation rule, parsing rule or
evaluation routine was modified. `04_revision_analyses.ipynb` checks this
directly: before it reports anything, its reproduction gate recomputes the v6
values to 1e-6.

### Added
- `notebooks/04_revision_analyses.ipynb`: post-hoc analyses requested by the
  reviewer (CPU only, no LLM calls): the LLM's increment over retrieval-only
  with bootstrap intervals and McNemar tests; interventional retrieval controls
  (shuffled pool labels, random neighbours, similarity rank bands); a
  labelled-pool size curve; the increment by stratum; and supervised
  logistic-regression baselines trained on the same pool labels. Output goes to
  `cross_model_comparison_v7/`.
- SBERT embedding cache for the val, test and pool splits, keyed by split
  fingerprint, written by notebook 04.
- `notebooks/05_query_ablation.ipynb`: query-vocabulary ablation (R1.4). Removes
  every term of Aurora's v5.0 queries from the texts and reruns the
  label-learning methods, against a control that removes the same number of
  other words. Writes only to a new folder per run.
- `artifacts/aurora_queries_v5/`: the Aurora v5.0 queries (CC BY 4.0), copied
  unchanged from the Aurora sdg-queries repository at commit 9acd03d.
- `artifacts/results/cross_model_comparison_v7/`: the published outputs of
  notebook 04.

### Fixed
- `01_matrix_preprocessor.ipynb`: removed two Colab-only cells that hard-coded
  `/content/drive/MyDrive/sdg-llm-graph/...` and bypassed the root resolver.
  The series-description copy now runs after the path cell and derives every
  path from the resolved root.
- `02_pipeline_*.ipynb`: the Aurora download used a hard-coded `/tmp/aurora_dl`;
  it now uses the platform temp directory (`tempfile.gettempdir()`). The
  behaviour is otherwise identical.
- `scripts/check_no_private_paths.sh`: the patterns used basic-regex escapes
  (`\+`, `\{20,\}`) under `grep -E`, so the hard-coded-path and token checks
  never matched. It now uses extended-regex syntax, fixes the `--include` /
  `--exclude` order, and adds explicit checks for hard-coded paths in code and
  config files.
- README: the headline numbers now match the v6 results behind the paper
  (0.5286 → 0.6116, retrieval-only 0.5821); previously they quoted
  pre-unification values.
- MANIFEST: v6 is identified as the results set behind the paper.

## 1.0.1

Release cited in the second-round revision.
