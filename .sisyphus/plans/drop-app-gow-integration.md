# Build Drop-App Custom GoW Image (Repo Scope Only)

## TL;DR

> **Primary plan**: Build a **custom Docker image** on top of `ghcr.io/games-on-whales/base-app:edge`, install `drop-app`, and publish it via CI/CD with automated rebuild triggers.
>
> **Important scope change** (from review): this repo delivers the **image only** (and build pipeline). End-user Wolf profile wiring is out of scope.

---

## Context

### Confirmed Decisions
- Drop server is already deployed and out of scope.
- We integrate Drop **client app** (`drop-app`) only.
- This repo should become a **custom image repository**.
- Base image tag must be `edge` (not `stable`).
- Add CI/CD for auto-build/update when dependencies change.
- User-side Wolf profile setup happens on end-user server (out of scope here).

### In Scope
- Custom image build files (Dockerfile + startup script + metadata docs).
- CI/CD workflow for build/test/publish and dependency-driven rebuilds.
- Verification scripts/checks for image integrity and runtime startup sanity.

### Out of Scope
- Editing user Wolf configs/profiles.
- Deploying/updating end-user compose stacks.
- Drop server changes.

---

## Work Objectives

### Core Objective
Produce a maintainable, reproducible, auto-built Drop-app image for GoW consumers.

### Concrete Deliverables
- `apps/drop-app/build/Dockerfile` using `ARG BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge`
- `apps/drop-app/build/scripts/startup.sh`
- Image README/runbook for consumer usage
- CI/CD workflows (build, validate, publish, scheduled rebuild)
- Evidence artifacts for build/runtime checks

### Must Have
- Base image pinned to GoW `base-app:edge`.
- Pinned Drop-app release with controlled upgrade path.
- CI publish pipeline + automated rebuild trigger strategy.
- Non-interactive verification commands for image validity.

### Must NOT Have
- No user-specific Wolf profile modifications in this repo.
- No assumptions about consumer host paths or server URLs hardcoded.
- No privileged mode defaults.

---

## Verification Strategy

- Test style: **tests-after implementation**.
- Every task includes command-executable acceptance checks and QA scenarios.
- Evidence location: `.sisyphus/evidence/task-{N}-{slug}.{ext}`.

---

## Execution Strategy

### Parallel Waves

**Wave 1 (Contracts + CI design)**
- T1: Image contract (base `edge`, pinning strategy, env contract)
- T2: CI/CD architecture (events, caching, publish, security)
- T3: Versioning/tagging policy (semver/date+sha, rollback)

**Wave 2 (Image implementation)**
- T4: Dockerfile implementation
- T5: Startup script implementation
- T6: Runtime dependency validation script/check target

**Wave 3 (Pipeline implementation)**
- T7: Build+test workflow
- T8: Publish workflow (registry push + tags)
- T9: Dependency-watch / scheduled auto-rebuild workflow

**Wave 4 (Hardening + docs)**
- T10: Supply-chain/security hardening (pinning/attest/sbom optional tier)
- T11: Consumer documentation and runbook

**Final Verification Wave (parallel)**
- F1 plan compliance, F2 quality audit, F3 QA replay, F4 scope fidelity

### Dependency Matrix
- T1 blocks T4,T5,T6
- T2 blocks T7,T8,T9
- T3 blocks T8,T11
- T4 blocks T6,T7
- T5 blocks T7
- T6 blocks T10
- T7 blocks T8,T10
- T8 blocks T11
- T9 blocks T11
- T10 blocks FINAL
- T11 blocks FINAL

---

## TODOs

- [ ] 1. Define image contract (`base-app:edge` + pinning + env)

  **What to do**:
  - Fix base contract to `ghcr.io/games-on-whales/base-app:edge`.
  - Define Drop-app version pin/fallback policy.
  - Define minimal runtime env contract (no user-host assumptions).

  **Acceptance Criteria**:
  - [ ] Contract doc explicitly states `edge` tag and no `stable` usage.

  **QA Scenarios**:
  ```
  Scenario: Base tag validation
    Tool: Bash
    Steps:
      1. Search repo for base image references.
      2. Assert only edge tag is used in source templates.
    Expected Result: No stable-tag references.
    Evidence: .sisyphus/evidence/task-1-base-tag-check.txt

  Scenario: Contract drift detection
    Tool: Bash
    Steps:
      1. Compare contract doc keys vs Dockerfile args/env keys.
    Expected Result: No missing/extra required keys.
    Evidence: .sisyphus/evidence/task-1-contract-drift-error.txt
  ```

- [ ] 2. Design CI/CD architecture for low-maintenance auto-updates

  **What to do**:
  - Define trigger matrix: push, PR, schedule, manual dispatch.
  - Define rebuild rules for dependency drift (base image/drop-app release).
  - Define caching and failure notification strategy.

  **Acceptance Criteria**:
  - [ ] CI/CD architecture doc includes trigger-to-action mapping.

  **QA Scenarios**:
  ```
  Scenario: Trigger matrix completeness
    Tool: Bash
    Steps:
      1. Validate doc has push/pr/schedule/manual triggers.
    Expected Result: All triggers documented.
    Evidence: .sisyphus/evidence/task-2-trigger-matrix.txt

  Scenario: Missing trigger guard
    Tool: Bash
    Steps:
      1. Verify dependency-change trigger exists (base/drop release signal).
    Expected Result: Dependency trigger explicitly covered.
    Evidence: .sisyphus/evidence/task-2-dep-trigger-error.txt
  ```

- [ ] 3. Define tagging/versioning and rollback policy

  **What to do**:
  - Specify immutable tag policy and latest alias rules.
  - Define rollback policy to last known-good image digest.

  **Acceptance Criteria**:
  - [ ] Policy includes immutable tags + documented rollback command path.

  **QA Scenarios**:
  ```
  Scenario: Tag policy validity
    Tool: Bash
    Steps:
      1. Validate policy includes immutable and floating tags with precedence.
    Expected Result: Tag policy unambiguous.
    Evidence: .sisyphus/evidence/task-3-tag-policy.txt

  Scenario: Rollback ambiguity check
    Tool: Bash
    Steps:
      1. Confirm rollback references digest, not mutable tag only.
    Expected Result: Digest-based rollback present.
    Evidence: .sisyphus/evidence/task-3-rollback-error.txt
  ```

- [ ] 4. Implement Drop-app Dockerfile on GoW edge base

  **What to do**:
  - Create Dockerfile from `BASE_APP_IMAGE=edge`.
  - Install pinned drop-app artifact + required runtime deps.

  **Acceptance Criteria**:
  - [ ] `docker build` succeeds from clean context.

  **QA Scenarios**:
  ```
  Scenario: Clean image build
    Tool: Bash
    Steps:
      1. Run docker build with explicit BASE_APP_IMAGE=edge.
      2. Assert exit code 0.
    Expected Result: Build success.
    Evidence: .sisyphus/evidence/task-4-build.log

  Scenario: Dependency failure visibility
    Tool: Bash
    Steps:
      1. Simulate unavailable pinned artifact.
      2. Confirm build fails with actionable message.
    Expected Result: Deterministic failure mode.
    Evidence: .sisyphus/evidence/task-4-artifact-error.log
  ```

- [ ] 5. Implement startup script for GoW launcher path

  **What to do**:
  - Use GoW launcher convention through `/opt/gow/launch-comp.sh`.
  - Ensure script is executable and robust to optional env absence.

  **Acceptance Criteria**:
  - [ ] Script passes shell syntax check and executable check in image.

  **QA Scenarios**:
  ```
  Scenario: Startup script validity
    Tool: Bash
    Steps:
      1. Run shell syntax check.
      2. Verify executable bit in built image.
    Expected Result: Valid and executable startup script.
    Evidence: .sisyphus/evidence/task-5-startup-valid.txt

  Scenario: Missing optional env
    Tool: Bash
    Steps:
      1. Launch without optional env variables.
      2. Assert no immediate crash loop.
    Expected Result: Graceful default behavior.
    Evidence: .sisyphus/evidence/task-5-env-error.log
  ```

- [ ] 6. Add runtime dependency verification target/script

  **What to do**:
  - Add command/script to validate required binaries/libs are present.
  - Expose as CI step and local smoke command.

  **Acceptance Criteria**:
  - [ ] Verification command returns pass on valid image.

  **QA Scenarios**:
  ```
  Scenario: Runtime dependency check pass
    Tool: Bash
    Steps:
      1. Execute dependency-check command against built image.
    Expected Result: Pass status.
    Evidence: .sisyphus/evidence/task-6-dep-pass.txt

  Scenario: Missing lib detection
    Tool: Bash
    Steps:
      1. Simulate/inspect missing runtime lib condition.
      2. Assert command exits non-zero with clear output.
    Expected Result: Missing dependency clearly reported.
    Evidence: .sisyphus/evidence/task-6-dep-error.txt
  ```

- [ ] 7. Implement CI workflow for build + smoke validation

  **What to do**:
  - Add workflow for PR/push image build and smoke checks.
  - Include cache strategy and artifact logs.

  **Acceptance Criteria**:
  - [ ] Workflow runs successfully on sample change.

  **QA Scenarios**:
  ```
  Scenario: PR pipeline happy path
    Tool: Bash
    Steps:
      1. Trigger workflow in CI context.
      2. Verify build and dependency checks pass.
    Expected Result: Green pipeline.
    Evidence: .sisyphus/evidence/task-7-ci-pass.txt

  Scenario: Failing build gate
    Tool: Bash
    Steps:
      1. Introduce controlled invalid build input.
      2. Confirm pipeline fails before publish stages.
    Expected Result: Proper fail-fast gating.
    Evidence: .sisyphus/evidence/task-7-ci-gate-error.txt
  ```

- [ ] 8. Implement publish workflow (registry push + tags)

  **What to do**:
  - Push validated images to registry with immutable and alias tags.
  - Emit digest outputs for consumers.

  **Acceptance Criteria**:
  - [ ] Publish step outputs digest and expected tags.

  **QA Scenarios**:
  ```
  Scenario: Publish happy path
    Tool: Bash
    Steps:
      1. Run publish workflow on approved branch/tag.
      2. Verify digest + tags exist in registry.
    Expected Result: Published image retrievable by digest.
    Evidence: .sisyphus/evidence/task-8-publish-pass.txt

  Scenario: Unauthorized publish prevention
    Tool: Bash
    Steps:
      1. Trigger publish from unauthorized context.
      2. Verify workflow blocks push.
    Expected Result: No unauthorized image push.
    Evidence: .sisyphus/evidence/task-8-publish-error.txt
  ```

- [ ] 9. Implement dependency-driven auto-rebuild workflow

  **What to do**:
  - Add scheduled workflow to detect upstream drift (GoW edge base / Drop release).
  - Rebuild + validate + optionally publish under controlled policy.

  **Acceptance Criteria**:
  - [ ] Drift detection path can trigger rebuild pipeline automatically.

  **QA Scenarios**:
  ```
  Scenario: Drift-triggered rebuild
    Tool: Bash
    Steps:
      1. Simulate upstream version drift input.
      2. Confirm rebuild workflow starts and runs checks.
    Expected Result: Automated rebuild path executes.
    Evidence: .sisyphus/evidence/task-9-drift-rebuild.txt

  Scenario: No-drift no-op
    Tool: Bash
    Steps:
      1. Run scheduler with unchanged upstream versions.
      2. Confirm no unnecessary publish occurs.
    Expected Result: Safe no-op behavior.
    Evidence: .sisyphus/evidence/task-9-noop-error.txt
  ```

- [ ] 10. Add supply-chain hardening gates

  **What to do**:
  - Add checks for pinned downloads/checksums.
  - Add optional SBOM/attestation stage if feasible in pipeline.

  **Acceptance Criteria**:
  - [ ] Artifact integrity verification present for Drop-app download path.

  **QA Scenarios**:
  ```
  Scenario: Checksum validation pass
    Tool: Bash
    Steps:
      1. Validate checksum/signature for fetched artifact.
    Expected Result: Integrity checks pass.
    Evidence: .sisyphus/evidence/task-10-integrity-pass.txt

  Scenario: Tampered artifact detection
    Tool: Bash
    Steps:
      1. Simulate checksum mismatch.
      2. Assert pipeline blocks build/publish.
    Expected Result: Tampered artifact rejected.
    Evidence: .sisyphus/evidence/task-10-integrity-error.txt
  ```

- [ ] 11. Write consumer runbook (image usage only)

  **What to do**:
  - Document image tags/digests, required env, and expected mounts as guidance.
  - Include explicit note: Wolf profile setup is performed by end user.

  **Acceptance Criteria**:
  - [ ] Runbook clearly separates repo responsibilities from end-user deployment responsibilities.

  **QA Scenarios**:
  ```
  Scenario: Scope boundary clarity
    Tool: Bash
    Steps:
      1. Review runbook sections for ownership boundaries.
    Expected Result: No instructions that mutate user-specific Wolf config in this repo workflow.
    Evidence: .sisyphus/evidence/task-11-scope-clarity.txt

  Scenario: Missing mandatory usage info
    Tool: Bash
    Steps:
      1. Verify runbook includes tag/digest/env/mount prerequisites.
    Expected Result: Mandatory consumer inputs documented.
    Evidence: .sisyphus/evidence/task-11-usage-error.txt
  ```

---

## Final Verification Wave

- [ ] F1 Plan Compliance Audit (`oracle`)
- [ ] F2 Build/Workflow Quality Review (`unspecified-high`)
- [ ] F3 QA Scenario Replay (`unspecified-high`)
- [ ] F4 Scope Fidelity Check (`deep`)

---

## Commit Strategy
- C1: `feat(image): add drop-app custom image on gow base-app edge`
- C2: `ci(build): add build+smoke validation workflow`
- C3: `ci(release): add publish + dependency auto-rebuild workflows`
- C4: `docs(runbook): add consumer image usage and scope boundaries`

## Success Criteria

### Verification Commands
```bash
docker build -t <registry>/drop-app-gow:dev --build-arg BASE_APP_IMAGE=ghcr.io/games-on-whales/base-app:edge apps/drop-app/build
# Expected: exit code 0

docker run --rm <registry>/drop-app-gow:dev sh -lc 'command -v drop-app && test -x /opt/gow/startup-app.sh'
# Expected: both checks succeed

# CI-level expected checks:
# - build workflow PASS
# - publish workflow emits digest
# - scheduled dependency check can trigger rebuild when upstream drift detected
```

### Final Checklist
- [ ] Custom image builds on `base-app:edge`.
- [ ] CI/CD auto-build and update path is implemented.
- [ ] Publish workflow provides immutable digest output.
- [ ] Repo scope stays image/pipeline only (no user Wolf profile mutation tasks).
