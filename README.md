# GitHub Actions sandbox

A laboratory for GitHub Actions behavior, hosted runners, Homebrew CI/debugging,
and small repository automation and container experiments. These are experiments,
not production-ready reusable workflows. Older tool versions and commented jobs
may preserve a specific reproduction.

> Review triggers, permissions, credentials, inputs, and action pins before copying
> these workflows into production repositories.

## Find an experiment

| Area | Files / purpose |
| --- | --- |
| Homebrew and runners | `brew-regression*.yml` test bottled/source formula installs; `brew-debug.yml` is a branch-based scratchpad; `check-helm.yml` and `display-github-context.yml` inspect hosted images. |
| Events and APIs | `delete-event.yml`, `workflow-dispatch.yml`, and `repository-dispatch.yml` demonstrate event data and cross-job environment behavior. |
| Automation | Labeling, closed-PR branch cleanup, image compression, and page archival in `.github/workflows/`. |
| Containers | [Dockerfile](Dockerfile), `docker.yml` (main-branch publication), and `release.yml` (release publication). |
| Tools and HTTP | `lang-*.yml` probe tool versions; [hurl/](hurl/) holds HTTP fixtures, including historical response assertions. Scheduled website checks are advisory. |
| Maintenance | [mise.toml](mise.toml), `lint.yml`, `link-checker.yml`, and [Renovate config](.github/renovate.json5). |
| Helpers | [scripts/](scripts/) contains the dispatch client; [workflow scripts](.github/workflows/scripts/) contains the historical Linux Homebrew bootstrap. |

Workflow filenames above are in [.github/workflows/](.github/workflows/).
See [awesome-github-actions.md](awesome-github-actions.md) for the action picker and
[AGENTS.md](AGENTS.md) for coding-agent invariants.

## Local setup and checks

Install Git, Bash, and [mise](https://mise.jdx.dev/getting-started.html).
Linux and macOS are the supported local check environments; Windows users can use WSL.
Homebrew is not required to validate the repository.

```bash
git clone https://github.com/chenrui333/github-action-test.git
cd github-action-test
mise install
mise run check
```

`check` runs actionlint (including embedded shell), YAML linting, ShellCheck, Bash
syntax checks, zizmor, local Markdown links, and `git diff --check`. It does not
execute experiments or require GitHub authentication. No workflow is excluded from
structural checks. Review and narrowly document any intentional future lint fixture.

```bash
mise run links  # external links too; requires network access
mise current   # show installed tool versions
```

`zizmor` runs offline by default. Its regular policy has one scoped exception for
closed-PR cleanup, which runs no PR code. For deeper review use
`mise exec -- zizmor --no-ignores --persona auditor .`; additional findings require
judgment and are not automatically defects. Docker changes also require
`docker build .` with a running Docker daemon.

## Run an experiment

Install and authenticate the [GitHub CLI](https://cli.github.com/), then inspect the
workflow before dispatching it:

```bash
gh workflow list
gh workflow view brew-regression.yml --yaml
gh workflow run brew-regression.yml -f formula=hello
gh run list --workflow brew-regression.yml
gh run watch <run-id>
```

Manual dispatch requires repository write access and the workflow on the default
branch. `brew-debug.yml` intentionally keeps commented templates: inspect existing
runner PRs before enabling a job on a branch. Record the runner, image version,
commands, observation, and exit criteria in the PR; a cancelled interactive session
is not evidence that Homebrew is broken.

The repository-dispatch helper uses `gh` authentication without putting a token in
process arguments. Preview its fixed payload before sending the event:

```bash
./scripts/repository-dispatch-trigger.sh --dry-run
./scripts/repository-dispatch-trigger.sh
```

Do not put credentials into dispatch payloads: these experiments display event data.
The credential-file workflow verifies decoding without printing file content.

## Maintenance

### Container dependencies

The [Dockerfile](Dockerfile) pins Terraform, Conftest, goimports, and Debian unzip.
[Renovate](.github/renovate.json5) reads the comments immediately above their
`ARG ..._VERSION` declarations and opens update PRs. Keep each annotation next to
its version when editing the Dockerfile. Tool release versions retain prerelease
suffixes so Renovate can distinguish stable releases from prereleases.

OPA is bundled inside the upstream Conftest binary. Update `CONFTEST_VERSION` to
update Conftest and its bundled OPA together; there is no separate OPA pin in this
image. Check the [Conftest release notes](https://github.com/open-policy-agent/conftest/releases)
for the bundled OPA version.

The unzip annotation uses the Debian `trixie` suite to match the Go base image.
Review this suite when the base image changes distribution. Debian package
revisions are preserved, including suffixes such as `+deb13u1`; these updates skip
the release-age delay because Debian package indexes do not supply release dates.

Docker PR checks build for `linux/amd64` and `linux/arm64`, verify downloaded
checksums, and execute Terraform, Conftest (which reports its OPA version), and
goimports. The main-branch build publishes the resulting image after a merge.

### Repository upkeep

See the [September 2026 audit](docs/maintenance-audit-2026-09-05.md) for workflow
classification, runner compatibility, security findings, and proposed PR dispositions.

Keep triggers narrow, pin actions to immutable SHAs, use minimal job permissions,
and disable checkout credential persistence unless a job deliberately pushes.
Preserve useful reproductions and historical fixtures; investigate history before
removing unusual code. Run checks and keep changes in small signed-off commits.
