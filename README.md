# Simple Backup Bash Script (sbbs)
Sbbs is a super simple way of creating backups of specific folders. It simply allows selecting folders and then encrypts and copies these folders to a specified location. It also keeps track how many backups of a specific folder there are and deletes the oldest one if there are more than a specified number.

## Installation

Clone this repo and run the `install.sh` file as root.

```bash
git clone https://github.com/Chris022/sbbs
cd sbbs
sudo bash install.sh
```

This moves all required files into place.

Next, you need to create a public/private key pair for encrypting the backups. This is done by using the following commands. 
```bash
openssl genrsa -out private.key 4096 && openssl rsa -in private.key -pubout -out /usr/share/sbbs/public.pub
```
I'd suggest you placing your public key into /usr/share/sbbs. **Important: Make sure you store the content of `private.key` somewhere save - you will need it if you want to restore a backup-, AND THEN DELETE THE FILE.**

Now is a good time to edit the config file `/etc/sbbs`. For more information, see (Config)[Config].

The only thing that's left then is to activate the service that calls the script daily. This is done using
```bash
sudo systemctl start sbbs.timer && sudo systemctl enable sbbs.timer
```

## Config

The config file itself is simply a bash script. There are the following variables that can be edited:

*BackupNames* - A space separated list of the names of your backups - e.g. "Documents Downloads"

*BackupSources* - A space separated list of the paths to folders that should be backuped - e.g. "/home/chris/Documents /home/chris/Downloads"

*BackupCount* - How many copies of each backup should be kept - e.g. 4

*BackupTarget* - The path of the location where the backups should be kept - e.g. "/media/backups"

*PublicKey* - The path to the public key - e.g. "/usr/share/sbbs/public.pub"

*StartCommand* - A command that is run before the backing up starts

*DoneCommand* - A command that is run after the backing up - e.g. "rclone sync ${BackupTarget} backups:/"

## Recovering a backup

In order to recover a backup, start by creating a new file `private.key`.
Edit this file and paste your private Key inside. Make sure the "---....---"
at the end and the beginning of the key are on a new line each. (Your file
should consist out of 3 lines)
Next you simply download the backup and unpack it with
```bash
tar -xf FILENAME.tar.gz
```
Next, you need to decrypt the symmetric key used to encrypt the data itself.
This can be done using the following command.
```bash
openssl pkeyutl -decrypt -inkey ./private.key -in key.enc -out key
```
Now the symmetric key can be used to decrypt the real data.
```bash
openssl enc -d -aes-256-cbc -pbkdf2 -salt -out data.tar.gz -pass file:key -in file.enc
```

Then unpack the final tar using
```bash
tar -xf data.tar.gz
```

## Using Cloud storage
If you want to store your backups into the cloud, I'd suggest using rclone. I'd
suggest first copying your backups to a local location (e.g. a sd card) and
then using the DoneCommand option in the config file, to execute a command
after the program executed successfully.

### Google Drive
Let's say you want to back up your data to google drive. In that case, you can use
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
