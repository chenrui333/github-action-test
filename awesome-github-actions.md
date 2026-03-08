# awesome-github-actions

Curated actions and patterns worth reusing across repos. This is meant to be a short picker, not an exhaustive catalog.

Default building blocks like `actions/checkout` and `actions/cache` are intentionally omitted unless there is something notable about them. Prefer pinned SHAs plus Renovate annotations in real workflows.

## Pick By Repo Shape

- Docs and content repos: `lycheeverse/lychee-action`, `crate-ci/typos`, `calibreapp/image-actions`, `tmcw/notfoundbot`
- Container repos: `docker/setup-qemu-action`, `docker/setup-buildx-action`, `docker/login-action`, `docker/build-push-action`, `softprops/action-gh-release`
- Language repos: `actions/setup-go` or `actions/setup-java`, plus `actions/labeler` and `actions/github-script`
- Infra and debug-heavy repos: `owenthereal/action-upterm`, `Homebrew/actions/setup-homebrew`, `timheuer/base64-to-file`, `softprops/diffset`

## Debugging And Manual Ops

- [owenthereal/action-upterm](https://github.com/owenthereal/action-upterm): interactive shell access to a live runner. This is the preferred debug-session action in this repo instead of `tmate`. Example here: `.github/workflows/credentials.yml`.
- [Homebrew/actions/setup-homebrew](https://github.com/Homebrew/actions/tree/main/setup-homebrew): reliable Homebrew bootstrap for CI, especially useful when testing Linux ARM or custom tap flows. Examples here: `.github/workflows/brew-regression.yml`, `.github/workflows/brew-regression-build.yml`.
- [timheuer/base64-to-file](https://github.com/timheuer/base64-to-file): decode a base64 secret into an on-disk file when a tool expects file-based credentials. Example here: `.github/workflows/credentials.yml`.
- [softprops/diffset](https://github.com/softprops/diffset): produce changed-file lists between refs so jobs can scope work or build small matrices.

## Repo Hygiene

- [lycheeverse/lychee-action](https://github.com/lycheeverse/lychee-action): link checking for docs, markdown, and simple site repos. Example here: `.github/workflows/link-checker.yml`.
- [crate-ci/typos](https://github.com/crate-ci/typos): fast typo detection with low setup cost.
- [calibreapp/image-actions](https://github.com/calibreapp/image-actions): image compression for content-heavy repos. Example here: `.github/workflows/compress-images.yml`.
- [tmcw/notfoundbot](https://github.com/tmcw/notfoundbot): automated outbound-link repair and cleanup when stale URLs accumulate.
- [actions/labeler](https://github.com/actions/labeler): keep PR triage cheap by auto-applying labels from path rules. Example here: `.github/workflows/labeler.yml`.

## Build, Release, And Packaging

- [docker/setup-qemu-action](https://github.com/docker/setup-qemu-action): required when building multi-arch images from GitHub-hosted runners. Examples here: `.github/workflows/docker.yml`, `.github/workflows/release.yml`.
- [docker/setup-buildx-action](https://github.com/docker/setup-buildx-action): turns on Buildx features and better multi-platform builds. Examples here: `.github/workflows/docker.yml`, `.github/workflows/release.yml`.
- [docker/login-action](https://github.com/docker/login-action): registry authentication without hand-rolled shell glue. Examples here: `.github/workflows/docker.yml`, `.github/workflows/release.yml`.
- [docker/build-push-action](https://github.com/docker/build-push-action): standard Docker image build and push step. Examples here: `.github/workflows/docker.yml`, `.github/workflows/release.yml`.
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release): create GitHub releases when a repo wants lightweight release automation without a larger release framework.

## Language And Repo Automation

- [actions/setup-go](https://github.com/actions/setup-go): consistent Go toolchain setup. Example here: `.github/workflows/lang-go.yml`.
- [actions/setup-java](https://github.com/actions/setup-java): standard Java setup, especially useful when Maven, Gradle, or matrix JDK testing is needed. Example here: `.github/workflows/lang-java.yml`.
- [actions/github-script](https://github.com/actions/github-script): quick GitHub API automation without maintaining a separate CLI script. Examples here: `.github/workflows/display-github-context.yml`, `.github/workflows/clean-up-closed-prs.yml`.

## Legacy Or Situational

- [softprops/turnstyle](https://github.com/softprops/turnstyle): serialize workflow runs in older repos that do not already use native `concurrency`. Useful mainly as a compatibility tool now.
