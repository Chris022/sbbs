#!/bin/bash

readonly ConfigFile=~/.config/sbbs/config.sh
readonly Dependencies="tar awk"
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
    if [[ ${cnt_backups} -gt $3 ]]
    then
      rm "$1/${backup}"
      let "cnt_backups=cnt_backups-1"
    fi 
  done
}

# Check if config exists.
if [ ! -f "$ConfigFile" ]; then
  echo "Config File at '${ConfigFile}' does not exist!"
  exit 1
fi

# Load Config
source ${ConfigFile}


oldIFS=${IFS}
IFS=" "

# Use tr command to replace the delimiter character with a newline
read -ra backup_names <<< "$BackupNames"
read -ra backup_sources <<< "$BackupSources"

IFS=${oldIFS}

check_installed_progs ${Dependencies}

# For each Target start compressing and moving the new backup into the location
# and then deleting the old ones.

for ((i=0;i < ${#backup_names[@]}; i++))
do
  echo "Backup '${backup_names[$i]}' started."
  echo "Zipping '${backup_sources[$i]}'."
  
  # Create the new name of the tarball
  printf -v date '%(%Y-%m-%d_%H:%M:%S)T' -1 # Get the current date and time
  tarball_name="${backup_names[$i]}_at_${date}"
  
  # Compress the backup target 
  # Use the -C option to run the command from the root directory!
  tar -czf ${BackupTarget}/${tarball_name}.tar.gz -C / ${backup_sources[$i]} &> /dev/null
  
  echo "Cleaning old backups." 
  remove_old_backups ${BackupTarget} ${backup_names[$i]} ${BackupCount} 

  echo ""
done
