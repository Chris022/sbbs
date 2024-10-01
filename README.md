# sbbs
A Simple Bash Backup Script

## Installation
To install this program simply run the install.sh as root.
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


