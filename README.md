# sbbs
A Simple Bash Backup Script

## Encryption
This script also automatically encrypts the backups it creates. To do this it
uses openssl. This was chosen instead of gpg since gpg does store state which
makes it harder to decrypt a backup on a new machine. One problem you have to
deal with is, that openssl does not allow big files to be encrypted using
public private key encryption. Because of this the bash script starts by
generating a symmetric key each time it encrypts a backup. This symmetric key
is then encrypted using a public key and stored for each backup. The backedup
Data itself is then encrypted using the symmetric key!


