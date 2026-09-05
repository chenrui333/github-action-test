# Repository maintenance audit — 2026-09-05

## Scope and starting state

Audited all 20 tracked workflows, configuration, scripts, Dockerfile, HTTP fixtures,
tracked documentation, git history, all eight pre-existing open PRs, all three open
issues, and retained Actions run metadata. Initial HEAD was `2c5750c`, on clean
`main`, equal to `origin/main`; the repository is public and permits squash merges
only. Worktrunk was unavailable, so isolated Git worktrees were used. No existing
experiment branch was edited, closed, merged, force-pushed, or retargeted.

The repository is a useful sandbox with well-maintained executable action pins,
but its documentation, credential experiment, event interpolation, dependency
extraction, and validation entry point needed attention. Age alone did not justify
removing any fixture. Changes are split into reviewable PRs; pending changes are
not equivalent to deployed fixes.

## Findings and delivery

| Severity | Finding and evidence | Action |
| --- | --- | --- |
| P0 | `credentials.yml` decoded an AWS secret and `cat` printed it; the preceding debug session shared the credential-bearing job. Base64 masking does not guarantee decoded content masking. No retained runs were returned. | #753 removes the debug session, verifies without content, sets mode 600, and always removes the file. No credential values or secret settings were retrieved. Historical exposure is unknown, not proven. |
| P1 | Dispatch inputs and deleted refs were inserted into shell source; Helm outputs were inserted into JavaScript. Existing zizmor ignores concealed these. Dispatch/delete require privileged event producers, so this is not evidence of arbitrary fork-PR write-token execution. | #753 treats values as data; removes resolved ignores. |
| P1 | `toJSON(github)` includes the token-bearing context even if logs normally mask it. | #753 logs event context instead. Event payloads remain visible by design; never send secrets in them. |
| P1 | Helm diagnostic had the context workflow's name and path trigger. Windows paths were embedded in JavaScript strings. Fork tokens cannot post comments. | #753 fixes name/trigger, environment transport, and fork comment guard. |
| P1 | `setup-homebrew` clears `HOMEBREW_NO_INSTALL_FROM_API` via `GITHUB_ENV`; Linux regression jobs did not explicitly request core. | #755 requests `core: true`, restores the variable after setup, and bounds source jobs. |
| P1 | ARMv7 container publication selected ARM64 binaries. Conftest 0.58.0 publishes no ARMv7 archive. Image builds did not execute installed binaries, so green publication did not detect this. |  #757 limits publication to amd64/arm64, selects `TARGETARCH`, fails unknown architectures, checks Terraform and Conftest downloads, and bounds downloads. |
| P1 | Renovate requests rebase automerge in a squash-only repository. Its Docker regex matches `ENV` but versions use `ARG`; dashboard #35 lists neither Terraform nor Conftest. | #758 uses squash and extracts both ARG/ENV; accepts upstream versions with or without `v`. |
| P1 | README was a heading; agent guidance listed fixed/deleted lint failures. | #754 provides onboarding, canonical checks, experiment map, and current agent guidance. |
| P2 | No tracked workflow validation CI; only two current actionlint style findings and two standalone shell quoting findings remained. | #753/#754 fix them without exclusions, add mise tasks and narrow CI. |
| P2 | Eight runner PRs mostly enable a platform-specific shell without a purpose/body/exit criterion. #657 and #642 have byte-identical diffs. | #756 adds manual diagnostics; triage and proposed metadata below preserve useful distinctions. |
| P2 | Homebrew label rule references deleted `brew.yml`. Image compression defaults to committing with a read-only token. | Follow-up recommendations below; do not grant writes mechanically. |

The five highest-value improvements are credential/input safety; reproducible
checks and CI; useful README/accurate agent guidance; restoring Homebrew Git-tap
semantics with reusable diagnostics; and container/dependency correctness.

## Workflow inventory

`R` means contents read. Write scopes below are job-local except the original
release workflow. Dates are latest retained pre-audit runs, not proof of recent
human use. Dependency-only commits do not establish active experiment use.

| Workflow | Trigger / runners | Purpose and category | Permissions | Last retained use / assessment |
| --- | --- | --- | --- | --- |
| archive-page | Daily/manual; Ubuntu 24.04 | Wayback archival utility | R | Sep 5 success; curl lacks HTTP failure detection and timeout. Keep utility; avoid automatic retries of archive submissions without considering duplicate side effects. |
| brew-debug | PR to main; Ubuntu 24.04 placeholder | Branch scratchpad; commented Linux/macOS jobs | R | Sep 5 placeholder success; branch PRs contain real sessions. Broad PR trigger is intentional. |
| brew-regression | Manual formula; macOS 14/15 ARM, 15 Intel, Ubuntu 24.04 | Bottled formula regression utility | R | Aug 15 2025 failures; logs old. Validate formula input already rejects options/metacharacters. Git-tap correction in #755. |
| brew-regression-build | Same matrix/manual | Source-build regression utility | R | Mar 30 failure; retained failure logs unavailable. Do not infer current formula failure from this. |
| check-helm | Path-scoped PR; 10 Linux/macOS/Windows labels | Runner experiment | R + PR write | Apr 10 success; copied trigger and JS transport fixed in #753. |
| chenrui-dev | Hourly/manual; Ubuntu 24.04 | Advisory site utility | R | Sep 5 green; `continue-on-error` deliberately makes availability advisory. |
| clean-up-closed-prs | Closed PR target; Ubuntu 24.04 | Repository mutation automation | contents write | Sep 5 skipped on merged PR. Same-repo, non-default head only; no checkout/untrusted execution. Closing an experiment may delete its branch automatically. |
| compress-images | Image-path PR; Ubuntu 24.04 | Image automation experiment | R | No retained runs. Default commit/comment mode needs writes; currently cannot reliably publish edits. No images tracked. |
| credentials | Manual; Ubuntu 24.04 | Secret-to-file experiment | R | No retained runs. Content logging/debug removed; 10-minute bound. |
| delete-event | Delete branch/tag; Ubuntu 24.04 | Event fixture | R | Sep 5 success. Broad event is the experiment; now safely displays ref data. |
| display-github-context | Path-scoped PR; 10 runner labels | Runner/event experiment | R + PR write | Apr 10 success; event data still deliberately displayed; token-bearing full context removed. |
| docker | Main push, Docker paths; Ubuntu 24.04 | Multiarch DockerHub/GHCR publisher | R; external registry tokens | Sep 3 success. External PAT policy untouched; ARMv7 correctness fixed in container PR #757. |
| hurl | Hourly/manual/main paths; Ubuntu 24.04 | Historical HTTP response fixtures/advisory utility | R | Sep 5 green despite assertion failures in logs. Preserve exact fixtures; green does not mean assertions passed. |
| labeler | PR; Ubuntu 24.04 | Maintenance automation | R + PR write | Sep 5 success. Homebrew path rule is stale; forks may lack write token. |
| lang-go | Manual/main workflow path; ubuntu-latest | Version-resolution experiment | R | Jul 22 success. Old versions and Go RC intentionally reference setup-go issue #524; retain. Cache warning possible without go.sum, not a build failure. |
| lang-java | Manual/main workflow path; Ubuntu/macOS aliases + Intel | Tool/version runner matrix | R | Aug 27 success. Keep historical JDK versions; `latest` intentionally follows images. |
| link-checker | Docs-path PR/manual; Ubuntu 24.04 | Maintenance utility | R | Jul 22 success. #754 expands all Markdown coverage; network checks remain separate. |
| release | Published release; Ubuntu 24.04 | GHCR publication experiment | R + packages write | Nov 16 2025 success predates March release rewrite. #757 scopes package write to job; no cancellation mid-publication. |
| repository-dispatch | `trigger-event`; Ubuntu 24.04, two dependent jobs | Payload/cross-job environment fixture | R | No retained runs. Two jobs are intentional; client now uses gh/stdin and fails HTTP errors. |
| workflow-dispatch | Manual inputs; Ubuntu 24.04 | Input/default fixture | R | No retained runs. Input strings preserved, transported via env. |

New `lint.yml` in #754 runs all structural checks with R, no persistent checkout
credentials, a 15-minute timeout, and cancellation of superseded runs. New manual
`runner-diagnostics.yml` in #756 has R, a 60-minute job bound, explicit runner
choices, optional source test, and optional actor-restricted Upterm (five-minute
connection wait). Manual diagnostics deliberately do not cancel another active
investigation or cache core.

History confirms `brew-regression.yml` (256 path occurrences) and
`brew-regression-build.yml` (246) dominate all-ref churn, followed by Dockerfile
(150). Old `brew.yml`/`homebrew.yml` names appear only historically. The Hurl,
release, site-spacing and steps-condition lint baseline was repaired in March
2026; `steps-condition-test.yml` was deleted in `1f456ad`.

## Security review

All executable actions on the original main use full 40-character SHAs. Fifteen
unique pins were resolved in their expected GitHub repositories; every annotated
version tag matched its SHA and no repository was archived. This verifies
provenance metadata, not a complete audit of every third-party implementation.
Homebrew's untagged SHA is valid but online zizmor reports stale-action-refs for
its two uses. Commented templates and old PRs contained mutable tags; #756 pins
templates, while legacy branches remain unchanged. The new mise action pin was
also resolved from its v3 ref and its action definition inspected.

All original checkouts explicitly disable credential persistence. Exceptions
remain in old PRs (#449/#639), not the audited main tree. No `write-all`, deprecated
workflow commands, or broad privileged PR-code execution path was found. Cleanup
is the only `pull_request_target`, guarded to closed same-repo non-default heads
and running API-only code. The exact dangerous-trigger ignore is retained.

Comments consume PR write; cleanup consumes contents write; releases consume
packages write. Original `contents: read` is conservative rather than mathematically
minimal in jobs without checkout. Image compression is underprivileged for its
default behavior. Docker's external GHCR token may be broader than necessary, but
its scopes and package ownership were not inspected or changed. `GITHUB_TOKEN`
could replace it only after confirming package access. No OIDC scope is needed.

Baseline regular zizmor: no visible findings, **17 ignored and 51 persona-suppressed**.
After #753: no visible findings, **1 ignored and 47 persona-suppressed**. An explicit
no-ignore auditor run was also reviewed: remaining groups are concurrency/naming,
legitimate write scopes, repository-level secret usage, cleanup's deliberate
trigger, and static Java matrix interpolation. Online review additionally flags
untagged Homebrew refs. Persona suppression is tool policy, not new repository
exclusions. No remaining demonstrated P0 path was found in the patched tree;
unknown historical credential exposure and external secret scopes remain limits.

## Runner compatibility

Verified against [GitHub's current runner reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
and [macOS 14 retirement notice](https://github.com/actions/runner-images/issues/13518).
An image label is not a promise of fixed software versions; record ImageOS and
ImageVersion in a reproduction. Public standard runners are available without
larger-runner provisioning.

| Label | OS / architecture | Current status and use | Recommendation |
| --- | --- | --- | --- |
| ubuntu-22.04 | Ubuntu 22.04 x64 | Standard public/private; context/Helm and #642/#657 | Valid reproduction target. |
| ubuntu-22.04-arm | Ubuntu 22.04 ARM64 | Standard public/private; context/Helm and #449/#639 | Valid; ARM Homebrew now officially supported. |
| ubuntu-24.04 | Ubuntu 24.04 x64 | Standard; most utilities | Keep. |
| ubuntu-24.04-arm | Ubuntu 24.04 ARM64 | Standard; context/Helm | Keep. |
| ubuntu-latest | Currently Ubuntu 24.04 x64 | Go/Java version probes | Keep where image migration is intentional. |
| macos-14 | macOS 14 ARM64 | Available but deprecated since Jul 6; retirement Nov 2, 2026; October brownouts | Preserve old-OS reproductions for now; remove from routine coverage before retirement. |
| macos-14-large | macOS 14 Intel larger runner | Comment only; same retirement; paid/provisioned availability | Not a free standard-runner substitute. |
| macos-14-xlarge | macOS 14 ARM larger runner | Comment only; same retirement | Same. |
| macos-15 | macOS 15 ARM64 | Standard; regression/context/Helm, #636 | Keep. |
| macos-15-intel | macOS 15 x64 | Standard; regression/context/Helm/Java, #622 | Keep. |
| macos-26 | macOS 26 ARM64 | Generally available since Feb 26, 2026; #558/context/Helm | Valid, not a preview-only workaround. |
| macos-26-intel | macOS 26 x64 | Current standard label, not currently used | Optional future coverage, not needed for audit. |
| macos-latest | Currently macOS 26 ARM64 | Java | Keep migration intentionally observable. |
| macos-14-arm / macos-15-arm / macos-26-arm | Not documented standard labels | PR titles/job names use “arm”; actual runs-on uses unsuffixed labels | Do not turn descriptive titles into runner labels. |
| windows-2022 / windows-2025 | Windows Server x64 | Standard; context/Helm | Valid. |

Existing “macos-14 is arm runner” comments are correct for the standard label;
“-large” is Intel. The stale Ubuntu Homebrew-removal comment overstates permanent
image behavior and is replaced in templates. No blanket runner upgrade was made.

## Homebrew design and PR overlap

Regression workflows preserve the eight shared environment guardrails: developer
commands, no automatic update/analytics/error-issue creation, ARM testing marker,
no cleanup/dependent upgrade checking, and Git-tap installs. The ARM testing marker
is retained for reproducibility; its presence does not establish modern ARM support.
`brew update` is deliberate even with automatic updates disabled.

[Homebrew support tiers](https://docs.brew.sh/Support-Tiers) now include Linux ARM64
under supported configurations. The [pinned setup action](https://github.com/Homebrew/actions/blob/fc695c54c2032716dd4cedd007489c8e32fc8a5d/setup-homebrew/main.sh)
handles Linux and both macOS architectures, installs when brew is absent, computes
tap paths from brew, and exports PATH for later steps. The correct prefix differs
between Intel macOS, Apple Silicon, and Linux; the new diagnostic asks brew instead
of hard-coding a working directory before setup.

The custom installer is **not needed for ordinary modern bootstrap**. It remains
as a historical clone/symlink fixture: it assumes a fresh runner, is not idempotent,
and its exported PATH does not persist into later Actions steps. Its old commented
caller also assumed core existed before running setup; #756 fixes that caller's
working directory. No executable main workflow calls it, and #449's current head
removed its call. Keeping the file is intentional, not an endorsement of copying it.

**#639 does not fully supersede #449: both test different behavior.** #449 began as
an ARM formula/bootstrap investigation but now only checks out and opens an ARM
shell without bootstrap or assertions. #639 provides a useful automated modern
setup/core/source-build path with cache reuse. It supersedes the need for custom
bootstrap for routine ARM source checks, but does not reproduce a raw-image shell.
Neither currently replaces the other's exact behavior on main.

For #639, both old and current setup sources explicitly unset the Git-tap variable;
the review calling its per-command assignments redundant is incorrect. Existing
core directories are fetched/reset rather than blindly cloned, so pre-restoration
is supported in source. The Linux path is consistent with the default prefix.
However, a fixed per-PR cache key is immutable, so an updated tap is not saved after
an exact hit. PR merge-ref cache scope also prevents the suggested `base_ref` key
alone from making caches shareable across PRs. Add a refresh component and measure
cold/warm time before deciding the cache pays for itself. The successful February
run has expired logs (HTTP 410); no cache-hit/miss claim can be verified from it.

`brew-debug.yml` remains the right place for reproductions tied to branch/PR events
or old bootstrap behavior. Routine platform choice should use #756 after it lands
and receives real hosted validation. Inputs can drive `runs-on`; this is supported
by [GitHub workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax).
A single selected runner avoids launching an expensive matrix for every shell.
The diagnostic records the original environment before setup but its optional shell
is post-setup; that distinction preserves #449's possible raw-image value.

## Open PR triage

All eight bodies, diffs, commit lists, reviews, inline review comments, checks and
branch divergence were inspected. All modify only `brew-debug.yml`. Seven bodies
are empty; #639 is the only explicit assertion-driven description. Counts below
compare against `454a161` after the security merge and will drift.

| PR | Created / updated | Draft; behind/ahead | Runner / bootstrap / commands | Checks and review | Overlap / unique value | Primary disposition / next step |
| --- | --- | --- | --- | --- | --- | --- |
| #449 | 2025-03-19 / 2026-03-02 | Yes; 110/3 | Ubuntu 22.04 ARM; checkout v4 + Upterm v1; no current installer call | Conflicted; old shell check success; no reviews | Raw runner shell differs from #639's installed environment; no source-build assertion | **KEEP AS EXPERIMENT**. Describe raw-image purpose; pin actions/disable credentials, bound shell before another run. |
| #558 | 2025-10-04 / 2026-08-15 | Yes; 12/6 | macOS 26 ARM; brew update in assumed core path + Upterm | Mergeable; debug cancelled; no reviews | Same pattern as #636/#644 on distinct OS; no unique commands | **REPLACE WITH GENERALIZED TEST**. Validate #756 on macOS 26, then preserve an image/run result before closure. |
| #622 | 2026-01-17 / 2026-01-17 | No; 134/1 | macOS 15 Intel; brew update + mutable tmate v3 | Conflicted on refresh; debug cancelled; overview review only | Intel prefix is unique environment, not unique logic | **REPLACE WITH GENERALIZED TEST**. Validate Intel diagnostic; do not merge stale tmate solely to keep a shell. |
| #636 | 2026-02-13 / 2026-08-16 | Yes; 12/2 | macOS 15 ARM; brew update + tmate v3 | Mergeable; debug cancelled; no inline reviews | Duplicates platform-shell pattern | **REPLACE WITH GENERALIZED TEST**. Validate #756 ARM15 and record observation. |
| #639 | 2026-02-15 / 2026-02-15 | No; 119/3 | Ubuntu 22.04 ARM; cache v4 + setup `04a6d8c` core=true; source hello/linkage/version | Conflicted; old success; 5 inline findings | Only cache reuse/source assertions; not on main | **UPDATE**. Move to separate cache experiment, refresh pins/checkout config, validate cold/warm behavior and cache refresh. Reject redundant-env suggestion. |
| #642 | 2026-02-19 / 2026-08-16 | No; 12/6 | Ubuntu 22.04 x64; old setup `bc738ca` + Upterm v1 | Mergeable; debug failure after about 2h48; log shows setup/core clone and established SSH session; exact terminal cause unclear | Byte-identical workflow/diff to #657 | **REPLACE WITH GENERALIZED TEST**. Use current pinned setup in #756; don't label the old result a bootstrap failure. |
| #644 | 2026-02-23 / 2026-07-23 | Yes; 18/4 | macOS 14 ARM; brew update + Upterm v1 | Mergeable; cancelled; no reviews | Soon-to-retire OS reproduction has time-limited value | **KEEP AS EXPERIMENT**. Capture needed Sonoma evidence before Nov 2; bound/pin before rerunning. |
| #657 | 2026-03-07 / 2026-08-15 | Yes; 12/4 | Same runner/setup/commands as #642 | Mergeable; cancelled; no reviews | No unique diff or description | **SUPERSEDED** by #642. Preserve any external session notes, then close if owner agrees. |

No PR is currently an unconditional merge candidate. Interactive jobs report
session lifetime, not a test assertion. For #642 the review's old tmate-specific
SHA is stale, but the requirement to pin the current Upterm action remains valid.
Its old setup pin concern also remains. For #639 pinning concerns remain; the
suggested historical SHAs should not be copied verbatim today.

### Proposed keeper metadata

Draft bodies are in [pr-metadata/](pr-metadata/). They explicitly distinguish
observed results from missing/expired evidence. Commands are proposals, not executed:

```bash
gh pr edit 449 --title 'brew-debug: inspect the raw Ubuntu 22.04 ARM runner' --body-file docs/pr-metadata/449.md
gh pr edit 558 --title 'brew-debug: inspect Homebrew on macOS 26 ARM' --body-file docs/pr-metadata/558.md
gh pr edit 622 --title 'brew-debug: inspect Homebrew on macOS 15 Intel' --body-file docs/pr-metadata/622.md
gh pr edit 636 --title 'brew-debug: inspect Homebrew on macOS 15 ARM' --body-file docs/pr-metadata/636.md
gh pr edit 639 --title 'ci(homebrew): measure Linux ARM core-tap cache reuse' --body-file docs/pr-metadata/639.md
gh pr edit 642 --title 'brew-debug: inspect Homebrew setup on Ubuntu 22.04 x64' --body-file docs/pr-metadata/642.md
gh pr edit 644 --title 'brew-debug: preserve macOS 14 ARM diagnostics before retirement' --body-file docs/pr-metadata/644.md
```

### Draft closure comments

For #657, once approved:

> Closing this duplicate runner experiment because its current brew-debug workflow
> and diff are identical to #642: Ubuntu 22.04 x64, the same Homebrew setup commit,
> and the same Upterm session. #642 preserves that test configuration. No unique
> commands or observations were found in this PR's description or reviews.

For #558/#622/#636/#642, **only after replacement is merged and the relevant hosted
run succeeds**, substitute the PR-specific runner and actual run URL:

> Closing this platform-shell experiment after Runner diagnostics was validated on
> RUNNER in RUN_URL. The replacement records image and Homebrew state and supports
> a bounded actor-restricted shell. The original branch configuration remains in
> this PR's history; any unique observations are recorded in the linked run notes.

Do not post the conditional comment before those conditions are true. Closing
same-repo PRs invokes branch cleanup; do not assume the branch will remain.

## Docker, Renovate, and repository hygiene

Docker baseline built successfully on local Linux ARM64. Debian trixie supplies
unzip 6.0-29; the base image is digest-pinned. Retain the build/toolbox image model
and root user; there is no service process or copied application needing a new
runtime-user design. The container patch keeps versions except pinning goimports
to the exact version resolved by the baseline (`golang.org/x/tools v0.49.0`). It
cleans apt lists and verifies exact checksum entries before extraction. HTTPS
checksum files provide integrity checking but do not replace independent signature
verification. SBOM/provenance expansion is optional; no new supply-chain framework
is warranted. Binfmt's mutable image remains a reproducibility limitation even
though its action is pinned. amd64 still needs a native or emulated build smoke.

Renovate's best-practices preset already pins action and Docker digests; the live
dashboard confirms all five mise tools are detected. Keep Renovate. The release
branch pattern, daily schedule, dashboard, two-day release delay with digest
exceptions, and vulnerability alerts are coherent. Global automerge includes major
updates; retain the owner's policy, but green checks only protect what runs (most
manual experiments do not run on dependency PRs). Fixing the unsupported rebase
strategy and ARG extraction addresses demonstrated gaps. No Dependabot is needed.

No new SECURITY/CONTRIBUTING/CODEOWNERS/templates are justified for this personal
sandbox. README and AGENTS are sufficient. `.editorconfig`, `.yamlfmt`, `.yamllint`
and cache gitignore are useful. `.licrc` has no active workflow consumer but remains
a historical Licensebat config; removal is optional, not evidence-backed necessity.
The Google/Twitter Hurl fixtures are historical references, not scheduled tests.
The five chenrui.dev fixtures deliberately assert exact headers/cookies; Sep 5
logs show assertion failures hidden by advisory workflow semantics. Do not rewrite
all fixtures into generic HTTP 200 checks to manufacture green results.

| Issue | Classification | Recommendation |
| --- | --- | --- |
| #35 Dependency Dashboard | Automation dashboard | Keep; use it to confirm new ARG dependencies appear after Renovate refresh. ShellCheck inactivity is not proof of abandonment. |
| #2 ZAP Scan Baseline Report | Historical external-site report | Archive/close candidate after owner review; concerns Meetup, not evidence of a vulnerability in this repository. No rescanning performed. |
| #560 Docker formatter committing to PRs | Feature idea | Defer automatic writes. If revived, start with a read-only formatting check and define intended image formatting policy first. |

## Validation and limits

| Check | Baseline | Result after scoped changes |
| --- | --- | --- |
| mise install/current | Installed requested versions | actionlint 1.7.12, lychee 0.24.2, ShellCheck 0.11.0, yamllint 1.38.0, zizmor 1.30.0 |
| git diff --check | Pass | Pass before every commit |
| actionlint all workflows | Two SC2129 findings in Helm | Pass; no exclusions |
| yamllint workflows/config | Pass | Pass |
| ShellCheck / bash -n | Two SC2086 installer findings; Bash syntax passes | Pass after quoting |
| regular zizmor | Green but 17 ignores | Green with one exact cleanup ignore |
| no-ignore auditor/online zizmor | Detailed review performed | Remaining categories discussed above, not silently ignored |
| lychee all original Markdown | 18 unique URLs pass | Pass: all 36 unique links in the audit documentation |
| dispatch helper | Inspected original curl flow | Mocked gh verifies JSON/stdin, HTTP exit propagation and invalid arguments; no event sent |
| credential workflow | Unsafe content print found | Fake file verifies mode 600, no content output, space-containing path and cleanup; no real secret used |
| Docker | ARM64 build passes | Patched ARM64 image build and Terraform/Conftest/goimports smoke pass before final retry/built-in-smoke edits; final rebuild blocked by repeated network timeouts. ARM32 rejection passes. |
| Renovate | Old local validator rejects pre-existing baseBranchPatterns | ARG extraction passes for Terraform, Conftest and pinned goimports; current official JSON schema passes. Full current-validator installation stalled and was stopped; no downgrade for stale tooling. |

The security merge is verified; hosted queues can outlive the local audit. Syntax
checks do not establish a new manual workflow's hosted execution, ARM/Intel parity,
cache effectiveness, registry publication, or secret rotation. No mutating manual
workflow was dispatched. PR metadata drafts and closure recommendations remain
unexecuted.

## Commits and review map

| PR | Scope | Commits |
| --- | --- | --- |
| #753 (merged by owner) | Credential/event security and Helm defects | `8814da5`; squash commit `454a161` |
| #754 | Reproducible checks, CI, human/agent documentation | `39d5fd7`, `a6268f1`, `583c2b3`, `74308bf`; `603a334` incorporates the security squash without force-pushing |
| #755 | Git-tap regression semantics | `44188cf` |
| #756 (based on #755) | Manual runner diagnostics and scratchpad templates | `d48617f` |
| #757 | Container integrity, supported architectures and PR build smoke | `c6de1ba` |
| #758 | Renovate merge policy and extraction | `966c2ac` |

All authored commits include DCO sign-off. Existing experiment PR metadata is
unchanged. #754 was retargeted after #753 merged, and main was incorporated so its
diff excludes merged security work. #756 should be refreshed onto main after #755
merges. GitHub checks were still queued during the final local validation; they
are not reported as passing. The combined patch set passes `mise run check` with
one exact zizmor ignore and 48 persona-suppressed findings.

## Worthwhile next work

Recommended: review scoped PRs; run #756 on the required platforms after landing;
refresh #639 with cold/warm cache evidence; close #657 only after approval; remove
macOS 14 from routine coverage before retirement while preserving its reproduction.
Fix the stale Homebrew label glob. Decide whether image compression should publish
changes or be an explicit compression-only diagnostic before granting write scope.

Optional: pin binfmt's image digest, migrate Docker GHCR auth after confirming
package permissions, separate advisory live-site monitoring from exact historical
HTTP fixtures, and remove unused Licensebat config only if its reference value is
no longer wanted. None requires another task runner or blanket modernization.
