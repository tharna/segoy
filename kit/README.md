# kit

Files that `scripts/segoy` vendors into other repos. Never edited in place in a target repo; change them here and run `scripts/segoy sync`.

- `common/` — vendored into every repo (leak guard). Milestone M2.
- `project/` — vendored into project repos (implement, review, retro). Milestone M3.
- `brain/` — template for a brain repo (capture, triage, spec, plan, promote, knowledge, review). Milestone M1.

Every skill follows the format in the root `CLAUDE.md` and must pass `scripts/segoy doctor --skills`. Kit skills are named `segoy-<name>` (architecture §2.2), so a repo's own skills cannot collide with them: the design docs' `triage` is `segoy-triage`, `brain-respond`'s skill is `segoy-respond`, and so on.

`scripts/segoy sync` keeps the kit-managed files up to date in each repo (architecture §2.2); everything else is the repo's after `init`.

`KIT.md` files describe a kit folder for Segoy developers and are not copied. Everything else under a kit folder is copied into target repos as-is, except `.segoy/config.yml.tmpl`, which becomes `.segoy/config.yml`, and `{{date}}`, which is replaced with the date of `segoy init`.
