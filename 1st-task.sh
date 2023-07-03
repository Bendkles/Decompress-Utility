#!/bin/bash

# Initialize variables
verbose=false
recursive=false
decompressed=0
not_decompressed=0

# Function to decompress a file
function decompress_file() {
  local file="$1"
  local compression

  # Get the compression type of the file
  compression=$(file -b "$file" | awk '{print $1}')

  # Define an associative array mapping compression types to decompression commands
  declare -A decompress_commands=(
    ["gzip"]="gunzip"
    ["bzip2"]="bunzip2"
    ["Zip"]="unzip"
    ["compress'd"]="tar -xf"
    ["POSIX"]="tar -xf"  # my additional compression type
    
  )

  # Get the decompression command for the compression type
  local command=${decompress_commands[$compression]}

  # If the compression type is recognized, decompress the file
  if [[ -n $command ]]; then
    if $command "$file"; then
      ((decompressed++))
      if $verbose; then
        echo "Unpacked $file"
      fi
    else
      ((not_decompressed++))
      echo "Error: Failed to decompress $file, please install the compression library $command first" 
    fi
  else
    ((not_decompressed++))
    if $verbose; then
      echo "Ignoring $file because it is not a recognized compressed file or it cannot be decompressed"
    fi
  fi
}

# Function to traverse a directory recursively and decompress all archives in it
function traverse_directory() {
  local dir="$1"

  while IFS= read -r -d '' file; do
    decompress_file "$file"
  done < <(find "$dir" -type f -print0)
}

# Parse command line arguments
while getopts "rv" opt; do
  case $opt in
    r)
      recursive=true
      ;;
    v)
      verbose=true
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Decompress each file in the input list
for file in "$@"; do
  if [[ -d "$file" ]]; then
    if $recursive; then
      traverse_directory "$file"
    fi
  elif [[ -f "$file" ]]; then
    decompress_file "$file"
  fi
done

# Print the number of archives decompressed and the number of files not decompressed
echo "Decompressed $decompressed archive(s)"
echo "$not_decompressed file(s) were not decompressed"


