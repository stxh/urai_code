# Changelog

## 2025-11-20

- Refactor `ccs.cmd` to delegate to PowerShell and fix argument forwarding
- Add `AICONF_DIR` override to both CMD and PowerShell implementations
- Enhance `ccs.ps1` with `--list` and `--config`, and set both `ANTHROPIC_API_KEY` and `ANTHROPIC_AUTH_TOKEN`
- Improve help messages and error outputs; mask API keys consistently
- Add optional PATH injection for Bun (`%USERPROFILE%\.bun\bin`)
- Add automated tests (`tests/ccs-tests.ps1`) covering config listing and command delegation
- Document Windows behavior and rollback via `CCS_USE_LEGACY=1`