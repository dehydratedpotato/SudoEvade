<h1 align="center" style="">SudoEvade</h1>

<p align="center">
   Execute Bash commands with root privileges, without entering a password or editing your Sudoers file.

</p>

<p align="center">
    <a href="">
       <img alt="MacOS" src="https://img.shields.io/badge/MacOS-x86/arm64-red.svg"/>
    </a>
    <a href="">
       <img alt="Linux" src="https://img.shields.io/badge/Linux-Ubuntu/Debian+-violet.svg"/>
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

## How The Command Works

In order to run commands as root without the usuaul requirements of `bash`, SudoEvade leverages the power of a launch Daemon.

1. The client binary captures your inputted command string and saves it to a file.
2. When that file changes, the Daemon Helper may read it and find the location of the command's binary.
3. Once found, the Daemon Helper clones the binary to a hidden directory and modifies the clone to elevate it's privileges.
4. Once the cloned binary is finished, the client can then execute your inputted command using the cloned and modified binary.

There are easier ways SudoEvade could be implemented, but I specifically went this route because I thought it would be more interesting to deal with :wink:

## Installation and Usage
1. Download the .zip file from the [latest release](https://github.com/BitesPotatoBacks/SudoEvade/releases).
2. Unzip the .zip file and run the `install.sh` script in your terminal, like so: `sudo bash PATH/TO/SCRIPT/install.sh -i`. To see all installer options, use arg `-h`.
3. Once the installation is complete, you may execute a command with root priveleges using `sudoev YOUR_CMD_HERE`. To see all runtime options, use arg `-h`.

To check that SudoEvade is working properly, run `sudoev id -u`. If all is well, it should return a value of `0`.
___

If the install script fails and reports `Daemon did not start`, run `sudo bash PATH/TO/SCRIPT/install.sh -u` and then reinstall. If this fails, you may need to start the Daemon manually using one of the following command sets.
<details>
   
<summary>MacOS Manual Daemon Starting</summary>
   
```
sudo chmod 600 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
sudo launchctl load -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
sudo launchctl start -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
```
   
   Make sure the Daemon is running by checking `sudo launchctl list | grep "com.bitespotatobacks.SudoEvade"`.. 

</details>

<details>

<summary>Linux Manual Daemon Starting</summary>
   
```
sudo chmod 664 /etc/systemd/system/com.bitespotatobacks.SudoEvade.service
sudo systemctl daemon-reload
sudo systemctl start com.bitespotatobacks.SudoEvade
sudo systemctl enable com.bitespotatobacks.SudoEvade
 ```
   
   Make sure the Daemon is running by checking `systemctl | grep "com.bitespotatobacks.SudoEvade"`. 
   
</details>
  
## Known Issues
**The following issues have been identified:**
- (macOS) `chown root:wheel` may return `illegal group name` via SudoEvade
- (macOS) `kill` may return `illegal process id` via SudoEavde 

If any bugs or issues are identified or you want your system supported, please let me know in the [issues](https://github.com/BitesPotatoBacks/SudoEvade/issues) section.

## Support
If you would like to support this project, a small donation to my [Cash App](https://cash.app/$bitespotatobacks) would be much appreciated!

