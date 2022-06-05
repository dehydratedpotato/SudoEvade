<h1 align="center" style="">SudoEvade</h1>

<p align="center">
   Execute Bash commands with root privileges, without entering a password or editing your Sudoers file.
</p>
<p align="center">
    <a href="">
       <img alt="MacOS" src="https://img.shields.io/badge/MacOS_Support-x86,_arm64-red.svg"/>
    </a>
    <a href="">
       <img alt="Linux" src="https://img.shields.io/badge/Linux_Support-Coming_Soon-violet.svg"/>
    </a>
    <a href="https://github.com/BitesPotatoBacks/SudoEvade/releases">
        <img alt="Releases" src="https://img.shields.io/github/release/BitesPotatoBacks/SudoEvade.svg"/>
    </a>
    <a href="https://github.com/BitesPotatoBacks/SudoEvade/blob/main/LICENSE">
        <img alt="License" src="https://img.shields.io/github/license/BitesPotatoBacks/SudoEvade.svg"/>
    </a>
<!--     <a href="https://cash.app/$bitespotatobacks">
        <img alt="License" src="https://img.shields.io/badge/donate-Cash_App-default.svg"/>
    </a> -->
    <br>
</p>

## Installation and Usage
1. Download the proper .zip for your operating system from the [latest release](https://github.com/BitesPotatoBacks/SudoEvade/releases)
2. Unzip the .zip and run the `install.sh` script in your terminal, like so: `sudo sh PATH/TO/SCRIPT/install.sh -i`
3. Once the installation is complete, you may execute a command with root priveleges using `sudoev YOUR_CMD_HERE`

If the install script fails and reports `Daemon did not start`, run `sudo sh PATH/TO/SCRIPT/install.sh -u` and then reinstall. If this fails, you may attempt to start the Daemon manually by performing the following:
```
sudo chmod 600 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
sudo launchctl load -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
sudo launchctl start -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
```
Check the Daemon status with `sudo launchctl list | grep "com.bitespotatobacks.SudoEvade"`
  
## Known Issues
The following issues are currently under investigation and will be fixed in an upcoming patch:
- Scripts run with `sh` do not behave correctly
- Certain shell builtin commands (such as `read`) complain and prevent themselves from being run

If any other bugs or issues are identified or you want your system supported, please let me know in the [issues](https://github.com/BitesPotatoBacks/SudoEvade/issues) section.

## Support
If you would like to support this project, a small donation to my [Cash App](https://cash.app/$bitespotatobacks) would be much appreciated!

