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

## Installation and Usage
1. Download the proper .zip file for your operating system from the [latest release](https://github.com/BitesPotatoBacks/SudoEvade/releases).
2. Unzip the .zip file and run the `install.sh` script in your terminal, like so: `sudo bash PATH/TO/SCRIPT/install.sh -i`.
3. Once the installation is complete, you may execute a command with root priveleges using `sudoev YOUR_CMD_HERE`.

If you would like to check that SudoEvade is working properly, you may execute `sudoev id -u`. It should return an id of `0` if all is well.
___

If the install script fails and reports `Daemon did not start`, run `sudo bash PATH/TO/SCRIPT/install.sh -u` and then reinstall. If this fails, you may attempt to start the Daemon manually by performing the following commands (depending on your OS):
<details>
   
<summary>Commands for MacOS</summary>
   
```
sudo chmod 600 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
sudo launchctl load -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
sudo launchctl start -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
```
   
   Make sure the Daemon is running by checking `sudo launchctl list | grep "com.bitespotatobacks.SudoEvade"`.. 

</details>

<details>

<summary>Commands for Linux</summary>
   
```
sudo chmod 664 /etc/systemd/system/com.bitespotatobacks.SudoEvade.service
sudo systemctl daemon-reload
sudo systemctl start com.bitespotatobacks.SudoEvade
sudo systemctl enable com.bitespotatobacks.SudoEvade
 ```
   
   Make sure the Daemon is running by checking `systemctl | grep "com.bitespotatobacks.SudoEvade"`. 
   
</details>

  
## Known Issues
**The follwing have been identified:**
- SudoEvade fails to check for helper errors after system restart due to diagnostic logs being stored in `/tmp` (will be fixed next release)

If any bugs or issues are identified or you want your system supported, please let me know in the [issues](https://github.com/BitesPotatoBacks/SudoEvade/issues) section.

## Support
If you would like to support this project, a small donation to my [Cash App](https://cash.app/$bitespotatobacks) would be much appreciated!

