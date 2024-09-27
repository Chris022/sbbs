#!/bin/bash

readonly TargetPattern="[A-Z]([a-z][A-Z])*"
readonly DateInfoPattern="[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}:[0-9]{2}:[0-9]{2}"
readonly FileExtensionPattern="\.tar\.gz"
readonly BackupFilePattern="${TargetPattern}_at_${DateInfoPattern}${FileExtensionPattern}"



# Checks if every program in a given list is installed and crashes the script
# if one isn't.
# Args:
#   $1 - String - Space seperated list of program names
check_installed_progs(){
  # Check if required programms are installed.
  required_progs=$1
  for required_prog in ${required_progs}
  do
    # Use the command command to check if the required program is missing.
    if ! command -v ${required_prog} &> /dev/null
    then
      echo "The command $required_prog could not be found. Please make sure it is installed!"
      exit 1
    fi
  done
}


# Check if all files in a given folder have a valid name. If they don't delete
# the file. A valid name starts with a CamelCase String followed by "_at_" and
# then a date in YYYY-MM-DD_HH:MM:SS. The files has to have the filetype
# ".tar.gz".
# Args:
#   $1 - String - Path to the location where the files are located.
check_valid_file_names(){
  dest=$1
  readarray -d "\n" -t files <<< $(ls ${dest})
  for file in ${files}
  do
    if [[ ! ${file} =~ [A-Z][a-z]+"_at_"[-1-9]{4}"-"[0-9]{2}"-"[0-9]{2}"_"[0-9]{2}":"[0-9]{2}":"[0-9]{2}".tar.gz" ]]
    then
      rm -rf ${dest}/${file} 
    fi
  done
}


# Get all backup files of a given target in a given backup destination
# Args:
#   $1 - String - The backup dest path.
#   $2 - String - Name of the target.
get_backups(){
  echo "$(ls $1 | grep  -E "$2_at_${DateInfoPattern}${FileExtensionPattern}")"
}

# Sort backup file names by the date part.
# Args:
#   $1 - String - A newline seperated list of filenames
sort_backups(){
  echo "$(echo "$1"  | awk -F'[_\\-:.]' '{print $3 $4 $5 $6 $7 $8, $0}' | sort -n | awk -F' ' '{print $2}')"
}


# Count how many backup files of a given target exist in a given location and
# then remove all except for the newest x ones.
# Args:
#   $1 - String - The backup dest path.
#   $2 - String - Target Name.
#   $3 - Int - Count of backups to keep.
remove_old_backups(){
  backups=$(sort_backups "$(get_backups $1 $2)")
  cnt_backups=$(echo "$backups" | wc -l)
  readarray -d "\n" backups <<< $(echo "$backups")

  for backup in $backups
  do
    if [[ ${cnt_backups} -ge $3 ]]
    then
      rm "$1/${backup}"
      let "cnt_backups=cnt_backups-1"
    fi 
  done
}


# Main

check_installed_progs "tar"

# Define some constants.
# These should enventually be moved to a config file.
# For now only define all these things as a variable. Later these need to
# become arrays to support multiple targets.
readonly TargetName="Documents" # Destination name should be a camel case string without any numbers.
readonly BackupDestination="/home/christoph/Backups"
readonly BackupTarget="/home/christoph/Documents"
readonly BackupCount=5


# TODO Check the existance of all the given locations



#check_valid_file_names ${BackupDestination}
remove_old_backups ${BackupDestination} ${TargetName} ${BackupCount}

# Create the new name of the tarball
printf -v date '%(%Y-%m-%d_%H:%M:%S)T' -1 # Get the current date and time
tarball_name="${TargetName}_at_${date}"


# Compress the backup target 
# Use the -C option to run the command from the root directory!
tar -czf ${BackupDestination}/${tarball_name}.tar.gz -C / ${BackupTarget} &> /dev/null

