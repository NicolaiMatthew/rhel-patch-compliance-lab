# CIS RHEL 9 Level 1 Server - Results

| Host | Baseline | Remediated | Failed rules |
|---|---|---|---|
| rhel-dev01  | 69.82% | 92.27% | 110 -> 17 |
| rhel-test01 | 69.82% | 92.27% | 110 -> 17 |
| rhel-prod01 | 69.82% | 92.27% | 110 -> 17 |

Remaining failures are documented in [docs/exceptions.md](../docs/exceptions.md).

**Rebuild test (2026-11-10):** clients destroyed and rebuilt from Git (Terraform + Ansible) in 23 minutes; re-scanned at 92.27%, identical to the original remediation.
