## v0.1.2 (June 15, 2022)
### Release Notes
This patch contains crucial bug fixes and improvements as well as **Linux support** (official support for Ubuntu and Debian based distros).
### Changelog
**Bug Fixes**
- Fix for shell builtin commands failing to execute
- Fix for shell scripts not working properly when using shell builtin commands
- Fix for issue cause by previous patch that prevented root privileges on certain commands

**Improvements**
- Added version reporting to installer
- Improvements to error catching in stdout for helper diagnostic logs
- Generic efficiency and speed improvements

___

## v0.1.1 (June 12, 2022)
### Release Notes

This patch contains crucial bug fixes and improvements. More bug fixes and Linux support coming soon in upcoming releases. Make sure to uninstall your previous release before installing this patch.

### Changelog

**Bug Fixes**

- Fixed binaries located at paths containing spaces unable to execute
- Fixed binaries located at paths using trailing characters (./) unable to execute
- Fixed binaries reporting their names to contain a sudoev_ prefix
- 
**Improvements**

- Helper tool sampling interval increased
- Helper tool diagnostic stdout simplified and stored in .log file rather than plain text

___

## v0.1.0 (June 5, 2022)
Initial release. Bug fixes and Linux support coming soon in upcoming releases.
