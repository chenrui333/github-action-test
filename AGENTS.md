# AGENTS.md

## Repo Intent
- This repository is a sandbox for testing GitHub Actions behavior, runner environments, and small automation ideas.
- Most meaningful changes land in `.github/workflows/`; the only other recurring code paths are `Dockerfile` and `scripts/repository-dispatch-trigger.sh`.
- `README.md` describes setup and experiment groups. Derive exact behavior from workflows, git history, and current run evidence.

## File Map
- `.github/workflows/brew-regression.yml` and `.github/workflows/brew-regression-build.yml` are the highest-churn files in repo history.
- `.github/workflows/brew-debug.yml` is the main scratchpad for runner-specific Homebrew debugging and still contains commented template jobs that are intentionally kept around.
- `.github/workflows/docker.yml` and `Dockerfile` drive the container image build/push flow.
- `.github/workflows/repository-dispatch.yml` is paired with `scripts/repository-dispatch-trigger.sh`.
- `.github/workflows/labeler.yml` is the workflow; `.github/labeler.yml` is the label rules config.
- `.github/renovate.json5` and `.github/zizmor.yml` matter whenever you change action versions, digests, or templated expressions.
- `mise.toml` is the repo-local tool manifest for workflow linting and related CLI checks.

## GitHub Context
- Open issues are mostly background context rather than an active roadmap. The current set is dominated by automation artifacts such as the Renovate dependency dashboard and an old ZAP baseline report, plus a small number of feature ideas.
- Open PRs are mostly long-lived workflow experiments, especially around `brew-debug` and runner coverage.
- Before editing `brew-debug` or adding runner experiments, inspect open PRs so you do not duplicate work or reuse an active branch name.
- Do not close, force-push, retarget, or clean up open PR branches unless the user explicitly asks.

## Workflow Editing Rules
- Keep trigger blast radius small. Prefer `workflow_dispatch`, `branches`, and `paths` filters over broad `push` triggers whenever behavior allows it.
- Preserve explicit `permissions:` blocks and keep them minimal. Only add write scopes when the job truly needs them.
- Preserve `actions/checkout` with `persist-credentials: false` unless a workflow intentionally commits, pushes, or deletes refs.
- Preserve pinned action SHAs and inline Renovate annotations (`# renovate: ...`) so Renovate can continue updating versions and digests cleanly.
- Use SHA-pinned `owenthereal/action-upterm` for new interactive jobs. Keep debug sessions separate from credential-bearing jobs; old PRs may still use tmate.
- For Homebrew workflows, keep the shared env guardrails unless the task is explicitly about changing them: `HOMEBREW_DEVELOPER`, `HOMEBREW_NO_AUTO_UPDATE`, `HOMEBREW_NO_ANALYTICS`, `HOMEBREW_NO_BUILD_ERROR_ISSUES`, `HOMEBREW_ARM64_TESTING`, `HOMEBREW_NO_INSTALL_CLEANUP`, `HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK`, and `HOMEBREW_NO_INSTALL_FROM_API`.
- If you touch Linux ARM Homebrew bootstrap logic, inspect `.github/workflows/scripts/install_homebrew.sh` instead of re-implementing the setup inline.
- If you update a workflow pattern that also appears in commented examples, update the commented template too when it is clearly intended as a copy/paste starting point.

## Validation
- Install repo tools with `mise install`; run the canonical suite with `mise run check`.
- Run `mise run links` separately for network-dependent checks of all Markdown links.
- For every changed workflow file, run YAML linting with the repo config:
  - `yamllint -c .yamllint .github/workflows/<file>.yml`
- Run targeted workflow linting:
  - `actionlint .github/workflows/<file>.yml`
- For shell scripts, run:
  - `bash -n path/to/script.sh`
- For Dockerfile changes, run:
  - `docker build .`
- Always run:
  - `git diff --check`
- `.yamlfmt` excludes `.github/workflows/**`, so do not expect `yamlfmt` to reformat workflow YAML for you.
- `mise.toml` currently manages `actionlint`, `lychee`, `shellcheck`, `yamllint`, and `zizmor`.
- Repo-wide actionlint and ShellCheck are clean. Do not add broad exclusions for experiments.
- `steps-condition-test.yml` was removed in March 2026; do not carry its old lint baseline forward.
- Zizmor runs offline by default; the only configured exception is closed-PR cleanup, which never checks out PR code.
- `setup-homebrew` clears `HOMEBREW_NO_INSTALL_FROM_API` outside core repositories. Explicitly restore it for steps that must use the Git tap, and ensure `core: true` creates that tap.
- A successful interactive job is not a formula test; cancellation is not a bootstrap failure. Inspect individual steps and preserve expired-log uncertainty.

## Commit And Review Norms
- Recent human commits use short imperative subjects. Bot updates use Renovate-style `chore(deps): ...` subjects.
- Use scoped conventional commit subjects for manual changes, for example `chore(tooling): ...`, `docs(agents): ...`, or `style(workflows): ...`.
- Keep manual changes narrowly scoped and split unrelated workflow edits into separate commits.
- Prefer more granular commits when the changes are independently reviewable. Tool manifests, lint config, docs updates, and workflow formatting fixes should usually land in separate commits.
- Check branch state before editing. If the user explicitly asks to land directly, committing on `main` is acceptable in this repo; otherwise avoid assuming.
- Use `gh` for live repo state because auth is already configured locally. Useful commands:
  - `gh pr list --state open`
  - `gh issue list --state open`
  - `gh pr view <number>`
  - `gh run list`
