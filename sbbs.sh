#!/bin/bash

# Check if required programms are installed.
required_progs="tar"
for required_prog in ${required_progs}
do
  # Use the command command to check if the required program is missing.
  if ! command -v ${required_prog} &> /dev/null
  then
    echo "The command $required_prog could not be found. Please make sure it is installed!"
    exit 1
  fi
done

# Define some constants.
# These should enventually be moved to a config file.
# For now only define all these things as a variable. Later these need to
# become arrays to support multiple targets.
readonly TargetName="Documents" # Destination name should be a camel case string without any numbers.
readonly BackupDestination="/home/christoph/Backups"
readonly BackupTarget="/home/christoph/Documents"
readonly BackupCount=5


# TODO Check the existance of all the given locations

# Check if all files in the backup target have names according to the
# convention. Delete files that don't since these might cause problems later
# on.
readarray -d "\n" -t files <<< $(ls ${BackupDestination})
for file in ${files}
do
  if [[ ! ${file} =~ [A-Z][a-z]+"_at_"[0-9]{4}"-"[0-9]{2}"-"[0-9]{2}"_"[0-9]{2}":"[0-9]{2}":"[0-9]{2}".tar.gz" ]]
  then
    rm -rf ${BackupDestination}/${file} 
  fi
done


# Check amount of exising backups of target
# Use the find command to find all tarballs staring with given target name
# Then use the wc(word count) command to count the lines the find command
# returns
existing_backups=$(find ${BackupDestination} -name "${TargetName}_at_*.tar.gz" -type f | wc -l)

echo "There already are ${existing_backups} backups of this target"

if [[ ${existing_backups} -ge ${BackupCount} ]]
then
  echo "Too many backups exist... deleting oldest one."
  # Find oldest backup
  # To do this use awk to split the name of all files and reshape them to
  # start with the name in the beginning of the file. Then use sort to sort the
  # files and then use awk again to bring the filenames back into original
  # order
  readarray -t files <<< $(ls ${BackupDestination} | awk -F'[_\\-:.]' '{print $3 $4 $5 $6 $7 $8, $0}' | sort -n | awk -F' ' '{print $2}')
  n=0 
  while [[ ${existing_backups} -ge ${BackupCount} ]] 
  do
    rm "${BackupDestination}/${files[$n]}"
    let "existing_backups=existing_backups-1" 
    let "n=n+1"
  done
fi


# Create the new name of the tarball
printf -v date '%(%Y-%m-%d_%H:%M:%S)T' -1 # Get the current date and time
tarball_name="${TargetName}_at_${date}"


# Compress the backup target 
# Use the -C option to run the command from the rood directory!
tar -czf ${BackupDestination}/${tarball_name}.tar.gz -C / ${BackupTarget} &> /dev/null

