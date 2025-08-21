

## Copilot Instructions for this repository

**Purpose**
This file tells Copilot how to behave when contributing to the `sonarscanner-cli-action` repository. The action should make using the SonarScanner CLI faster and easier than running the scanner inside a container while allowing a rich set of configurable parameters.

**High-level goals**
- Provide a thin, reliable wrapper (scripts & YAML) that runs SonarScanner CLI locally.
- Expose a large but well-documented set of CLI parameters for advanced use.
- Keep documentation, examples, and tests in sync with code changes.

**Core rules (always follow)**
- Follow the idiomatic, language-specific best practices for the languages used in this repo (bash, PowerShell, YAML). Use shellcheck-style guidance for bash and PowerShell best practices for ps1 scripts.
- Preserve and respect the repository folder layout: `docs/`, `examples/`, `scripts/`, tests, root `README.md`, `CHANGELOG.md`, and `action.yml`.
- Update documentation (`README.md`, files under `docs/`, and examples) whenever behavior, parameters, or public outputs change.
- Add unit tests for every new feature or behavior change. Prefer small, deterministic tests that run quickly.
- Update `CHANGELOG.md` for each versioned change and include a concise rationale and migration notes when necessary.
- Before changing defaults or adding/removing parameters, consult the official SonarScanner CLI documentation and release notes (see References below) and ensure compatibility.

**Behavioral checklist for code changes**
- Keep changes minimal and focused. Small, atomic commits are preferred.
- When adding a new parameter or flag, add:
  - Implementation in the relevant script(s).
  - Example in `examples/sonar-project.properties` or a new example file.
  - Documentation in `docs/` and a short usage note in `README.md`.
  - Unit tests exercising parsing, validation, and the new behavior.
  - A `CHANGELOG.md` entry describing the change.

**Contract (what to deliver for each change)**
- Inputs: script arguments, environment variables, and `action.yml` inputs.
- Outputs: exit code, logs, and any generated Sonar analysis artifacts or metadata.
- Error modes: invalid args -> non-zero exit + helpful message and usage; missing required env -> fail fast with instructive error; Sonar CLI failures -> propagate code and surface logs.

**Edge cases to consider**
- Empty or missing parameters.
- Conflicting parameters or mutually exclusive flags.
- Large argument strings (shell quoting/escaping issues).
- Cross-shell differences (bash vs zsh vs PowerShell) and path handling on macOS/Linux/Windows.
- Network timeouts when downloading SonarScanner binaries or plugins.

**Testing guidance**
- Use fast, deterministic unit tests for scripts where possible. For bash, prefer shunit2 or bats-like frameworks if present; for PowerShell, use Pester.
- Write table-driven tests for parsing and validation functions.
- Mock network calls and filesystem interactions when testing download or install logic.
- Add at least one integration-style smoke test that verifies the wrapper invokes SonarScanner with expected arguments (mocking the binary is acceptable).

**Documentation rules**
- The `README.md` must include: purpose, quick start (minimal commands), and an examples section that highlights common flags.
- `docs/` should contain: advanced usage, troubleshooting, and a parameter reference linking to the corresponding SonarScanner CLI docs.
- Every new public input (in `action.yml` or scripts) must have a corresponding line in `README.md` and an example in `examples/`.

**Release and changelog**
- For each release, update `CHANGELOG.md` with a short entry: category (Added, Changed, Fixed), bullet summary, and link to relevant doc/example.
- When SonarScanner CLI upstream releases change or add parameters, propose any necessary updates to this action (flag changes, new examples, docs).

**References (must be checked for compatibility and new parameters)**
- https://github.com/SonarSource/sonar-scanner-cli
- https://github.com/SonarSource/sonar-scanner-cli/releases

**Commit and review guidance**
- Use clear commit messages: start with a short imperative summary, and include a sentence or two of explanation when the change is non-trivial.
- When modifying behavior, include automated tests and documentation updates in the same pull request.
- Keep PRs small. If a change touches multiple areas (scripts, docs, examples, tests), group them into a single coherent PR but avoid unrelated changes.

**When blocked or unsure**
- If a Sonar parameter behavior is unclear, link to the exact line in the SonarSource repo or a release note and propose a safe default.
- If adding a complex feature, propose the design (short bullet list) in the PR description and request a quick review.

**Minimal linting and CI expectations**
- Ensure shell scripts are lint-clean (shellcheck) and PowerShell passes PSScriptAnalyzer where applicable.
- Tests should run locally and in CI. Keep test runtime small for quick feedback loops.

**Maintenance note**
- Periodically (at least when preparing a release) scan SonarScanner CLI releases for breaking changes and update this project accordingly.

**Contact points**
- When in doubt, open a PR with a design note and link to the SonarScanner docs that justify the change.

**Quick checklist (for maintainers to tick when making changes)**
- [ ] Code follows language idioms (bash/PowerShell/YAML)
- [ ] Tests added/updated
- [ ] README.md updated
- [ ] docs/ updated
- [ ] examples/ updated
- [ ] CHANGELOG.md entry added
- [ ] References checked (SonarScanner CLI repo & releases)

End of instructions
