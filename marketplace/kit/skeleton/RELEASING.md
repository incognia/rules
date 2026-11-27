# Releasing a plugin

Checklist for every release of a plugin. Users receive an update only when the version changes.

- [ ] Bump `version` in `plugins/<plugin>/.claude-plugin/plugin.json` (MAJOR, MINOR or PATCH; see `CONTRIBUTING.md`)
- [ ] Update the skill and plugin descriptions in every description language if behaviour changed
- [ ] Update the plugin's row (version and skills) in `README.md` and in every translation, in the same commit
- [ ] Run `claude plugin validate .` and `claude plugin validate ./plugins/<plugin>`
- [ ] Compare the copies of `python_check.py`
- [ ] Record the release with the changelog skill and commit with scope `<plugin>`
- [ ] Open the merge or pull request and wait for the owning team's review

## What users do after the merge

```bash
claude plugin marketplace update <marketplace>
```

```bash
claude plugin update <plugin>@<marketplace>
```

- Open sessions keep the old version until `/reload-plugins` or a new session.
- `plugin update` fails with «is not installed» on a machine where the plugin was never installed: install it there first with `/plugin install <plugin>@<marketplace>`.
- Private marketplaces do not update automatically unless the user turns it on.
