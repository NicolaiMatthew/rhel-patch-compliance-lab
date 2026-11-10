
# CIS Exceptions Register

Profile: CIS RHEL 9 Level 1 Server (SSG `cis_server_l1`). Scope: rhel-dev01, rhel-test01, rhel-prod01.
Controls below were evaluated and deliberately not applied. Review quarterly.

| Rule | Severity | Decision | Reason | Compensating control |
|---|---|---|---|---|
| Set boot loader password in GRUB2 | High | Accept risk | VMs have no physical console; GRUB is reachable only through the Proxmox console | Proxmox console restricted to the admin account |
| /tmp on a separate partition | Low | Accept risk | Single-disk cloud image; repartitioning requires a rebuild | /dev/shm hardened (nodev, nosuid, noexec); revisit in golden image (Packer) |
| Limit users' SSH access (AllowUsers/AllowGroups) | Unknown | Defer | Allow-list must be designed with the automation account to avoid lockout | Root login disabled; key-only access; MaxAuthTries 4 |
| Require sudo re-authentication | Medium | Accept risk | Automation account uses key-based SSH with NOPASSWD sudo | All sudo commands logged to /var/log/sudo.log; root SSH disabled |
| Custom CIS crypto policy module | Medium | Defer | System-wide crypto policy change needs compatibility testing with Katello/RHSM | RHEL DEFAULT crypto policy |
| Install systemd-journal-remote | Medium | Accept risk | No central log collector in this environment | Persistent, compressed local journald |
| journald and rsyslog not both active | Medium | Accept risk | rsyslog kept for compatibility | Both log locally with restricted permissions |
| firewalld loopback trust/restrict rules | Medium | Defer | Needs rule design and testing | firewalld enabled, default zone allows SSH only |
| AIDE verifies audit tools | Medium | Defer | Requires custom aide.conf rules | AIDE enabled with daily integrity check |
| Remaining partition mount options (/var, /var/log, /home) | Medium | N/A | Single root filesystem; rules report notapplicable | n/a |
| Active authselect profile includes PAM modules | Medium | Defer | Requires a custom authselect profile; vendor `sssd` profile kept for supportability | Lockout, password quality and history enforced via authselect features and config files |
| Authentication required for single-user mode | Medium | Accept risk | Rescue/emergency mode reachable only from the hypervisor console | Proxmox console restricted to the admin account |
| Default bash umask (/etc/bashrc) | Medium | Backlog | Vendor /etc/bashrc still sets 022 | umask 027 enforced via /etc/profile.d/cis.sh and login.defs |
| Interactive session timeout | Medium | Implemented differently | TMOUT=900 (readonly, exported) in /etc/profile.d/cis.sh; scanner expects a different declaration syntax | Idle shells exit after 15 minutes |
| User initialization files mode 0740 or less | Medium | Backlog | Cloud-init creates the automation user's dotfiles as 0644 | No interactive human accounts on these hosts |
| nftables service disabled | Medium | Backlog | firewalld uses nftables as its backend; standalone nftables.service must be explicitly masked | firewalld active and enforcing |
| SSH ClientAliveCountMax | Medium | Accept (tuned) | Set to 3 (45 s idle disconnect); stricter profile value drops automation sessions | ClientAliveInterval 15; MaxAuthTries 4 |

**Decision key:** Accept risk = deliberately not applied, with a reason. Defer = planned once a dependency is resolved. Backlog = known fix, not yet applied. Implemented differently = control is in place; scanner does not recognize the method. Accept (tuned) = applied with a less strict value, with a reason.
