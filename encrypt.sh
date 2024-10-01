# Generate public-private key pair:
#openssl genrsa -out keyfile.key 4096
# Extract public key:
#openssl rsa -in keyfile.key -pubout -out keyfile.pub


# Generate a random symmetric key
openssl rand 256 > symmetric_key

# Use symmetric key to encrypt backup
openssl enc -aes-256-cbc -pbkdf2 -salt -out "test.enc" -pass file:./symmetric_key -in test.tar.gz

# Use public key to encrypt symmetric key
openssl pkeyutl -encrypt -pubin -inkey keyfile.pub -in symmetric_key -out symmetric_key.enc

# Remove unencryped symmetric key
rm symmetric_key
