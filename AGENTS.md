# AGENTS.md

## Repo Intent
- This repository is a sandbox for testing GitHub Actions behavior, runner environments, and small automation ideas.
- Most meaningful changes land in `.github/workflows/`; the only other recurring code paths are `Dockerfile`, `.circleci/config.yml`, and `scripts/repository-dispatch-trigger.sh`.
- `README.md` is intentionally minimal. Derive behavior from workflow files and git history, not from project docs.

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
- The current repo convention uses `owenthereal/action-upterm@v1` for interactive debug sessions instead of `mxschmitt/action-tmate`.
- For Homebrew workflows, keep the shared env guardrails unless the task is explicitly about changing them: `HOMEBREW_DEVELOPER`, `HOMEBREW_NO_AUTO_UPDATE`, `HOMEBREW_NO_ANALYTICS`, `HOMEBREW_NO_BUILD_ERROR_ISSUES`, `HOMEBREW_ARM64_TESTING`, `HOMEBREW_NO_INSTALL_CLEANUP`, `HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK`, and `HOMEBREW_NO_INSTALL_FROM_API`.
- If you touch Linux ARM Homebrew bootstrap logic, inspect `.github/workflows/scripts/install_homebrew.sh` instead of re-implementing the setup inline.
- If you update a workflow pattern that also appears in commented examples, update the commented template too when it is clearly intended as a copy/paste starting point.

## Validation
- Install repo tools first when needed:
  - `mise install`
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
- Repo-wide `actionlint` is not currently clean. It reports pre-existing warnings in `check-helm.yml`, `chenrui-dev.yml`, `hurl.yml`, `release.yml`, and `steps-condition-test.yml`. Treat those as baseline unless the task is specifically lint cleanup.

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
