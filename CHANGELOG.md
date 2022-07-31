## v0.3.1 (July 31, 2022)
### Release Notes
This patch contains a crucial bug fixe for the installer and helper error recognition improvements. 

### Changelog
**Bug Fixes**
- Fixed install script not actually adding `/usr/local/bin` to PATH when missing (which could prevent the user from using the tool)

**Improvements**
- Code density improvements
- Improved recognition of helper failure by adding a unresponsive helper timeout (modify with `-T`)

___

## v0.3.0 (July 17, 2022)
### Release Notes
This minor contains crucial fixes and cleanups from the last version, as well as a couple of new features.

### Changelog
**Features**
- Added client command line argument to use tty redirection over binary cloning (experimental)
- Added installer command line argument to reinstall  

**Bug Fixes**
- Fixed running command from helper not accepting full command string args
- Fixed client command line args breaking command string input when separated
- (macOS) Fixed `chown` possibly working incorrectly by making use  of options `-t` or `-b`

**Improvements**
- Hide ugly install script errors and replaced with meaningful ones

___

## v0.2.0 (July 15, 2022)
### Release Notes
This minor contains brand new command line arguments to the client, as well as general improvements and minor fixes. More fixes and improvements to come in a future patch.

### Changelog
**Features**
- Added command line argument to run command in the background via the helper
- Added command line argument to attempt to force a command to run, ignoring all error and safety checks
- Added command line argument to run command rootless on helper failure

**Bug Fixes**
- (MacOS) Hopeful fix for install script skipping `chmod` for daemon plist randomly

**Improvements**
- Made scripts universal for all OS' rather than divided
- Improved on installer and helper outputs
- Hiding unneeded error from `rm` after command failure on exit

___

## v0.1.3 (June 26, 2022)
### Release Notes
This patch contains a crucial bug fix for macOS and general improvements for the tool.
### Changelog
**Bug Fixes**
- (MacOS) Fix for client failing to detect helper errors after system restart due to stderr log files being stored in `/tmp`

**Improvements**
- Helper may now report it's version with opt `-v`
- Install Script and Helper stdout have been further improved
- Generic dead code cleaning

___

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

**Improvements**

- Helper tool sampling interval increased
- Helper tool diagnostic stdout simplified and stored in .log file rather than plain text

___

## v0.1.0 (June 5, 2022)
Initial release. Bug fixes and Linux support coming soon in upcoming releases.
