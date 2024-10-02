# sbbs
A Simple Bash Backup Script

## Installation
To install this program simply run the install.sh as root.

Next you need to create a encryption key pair for encrypting the backups. This
is done by using the following commands. I'd suggest you placing your public
key into /usr/share/sbbs.
```bash
openssl genrsa -out private.key 4096 && openssl rsa -in private.key -pubout -out /usr/share/sbbs/public.pub
```
INFO: Make shure youre private key is stored somewhere secure! For example
inside your password-save!

Don't forget to edit the config file `etc/sbbs`.

Then enable the timer that runs the programm once every day using
```bash
sudo systemctl start sbbs.timer && sudo systemctl enable sbbs.timer
```


## Encryption
This script also automatically encrypts the backups it creates. To do this it
uses openssl. This was chosen instead of gpg since gpg does store state which
makes it harder to decrypt a backup on a new machine. One problem you have to
deal with is, that openssl does not allow big files to be encrypted using
public private key encryption. Because of this the bash script starts by
generating a symmetric key each time it encrypts a backup. This symmetric key
is then encrypted using a public key and stored for each backup. The backedup
Data itself is then encrypted using the symmetric key!

## Cloud storrage
If you want to store your backups into the cloud, I'd suggest using rclone. I'd
suggest first copying your backups to a local location (e.g. a sd card) and
then using the DeCommand option in the config file, to execute a command
after the programm executed successfully.

### Google Drive
Lets say you want to backup your data to google drive. In that case you can use
the following list of commands:

1) Install rclone `sudo pacman -S rclone`
2) Configure rclone `sudo rclone config` and create a new remote by pressing "n".
3) You can call your remote whatever you want. I'll call it "backups".
4) Select "Google Drive" and leave clinet\_id client\_secret blank! And choose
1 as a permission.
5) Don't edit the advanced config and then use Y to authenticate rclone!
6) Last, don't configure it as a shared drive and finish the config. 
7) Now one can simply use the command `rclone sync -P --transfers=10
--checkers=10 --drive-chunk-size=16384 FOLDERPATH REMOTENAME:/` to sync between
the local folder and Google Drive.





