#!/bin/bash

# Initialize variables
verbose=false
recursive=false
decompressed=0
not_decompressed=0

# Function to display help information
function display_help() {
  echo "Usage: $0 [FLAG] [FILE]"
  echo "Unpack compressed files."
  echo
  echo "Options:"
  echo "  -r, recurse into directories"
  echo "  -v, explain what is being done"
  echo "  --help, display this help and exit"
  echo
  echo "Examples:"
  echo "  $0 file.gz"
  echo "  $0 -r directory"
  exit 0
}

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
    if $command -f "$file"; then
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

# Check if any arguments were provided
if [ $# -eq 0 ]; then
  echo "Missing argument. Please provide a file or directory. For help use --help flag."
  exit 1
fi

# Parse command line arguments
while (( "$#" )); do
  case "$1" in
    -r)
      recursive=true
      shift
      ;;
    -v)
      verbose=true
      shift
      ;;
    --help)
      display_help
      ;;
    *)
      # Decompress each file in the input list
      if [[ -d "$1" ]]; then
        if $recursive; then
          traverse_directory "$1"
        fi
      elif [[ -f "$1" ]]; then
        decompress_file "$1"
      fi
      shift
      ;;
  esac
done

# Print the number of archives decompressed and the number of files not decompressed
echo "Decompressed $decompressed archive(s)"
echo "$not_decompressed file(s) were not decompressed"
