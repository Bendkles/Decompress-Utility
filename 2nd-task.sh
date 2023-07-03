#!/bin/bash

# Set default values
count=-1
timeout=1
user=""

# Parse command-line arguments
while getopts "c:t:u:" opt; do
  case $opt in
    c)
      count=$OPTARG
      ;;
    t)
      timeout=$OPTARG
      ;;
    u)
      user=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Shift the command-line arguments to get the executable name
shift $((OPTIND-1))
exe_name=$1

# Check if the executable name is provided
if [ -z "$exe_name" ]; then
  echo "Usage: psping [-c ###] [-t ###] [-u user-name] exe-name"
  exit 1
fi

# Initialize the counter
ping_count=0

# Loop indefinitely or until the ping count is reached
while [ "$count" -lt 0 ] || [ $ping_count -lt "$count" ]; do
  # Count the number of live processes for the user and executable
  live_count=$(pgrep -u "$user" "$exe_name" | wc -l)

  # Echo the number of live processes
  echo "$live_count"

  # Increment the ping count
  ping_count=$((ping_count+1))

  # Sleep for the specified timeout
  sleep "$timeout"
done


# ./psping [-c ###] [-t ###] [-u user-name] exe-name
# To count the number of live processes for the user jack whose 
#executable file is /opt/google/chrome/chrome --type=-broker every 2 seconds 
# for a total of 5 pings, you can use the following command: bash
# ./psping -c 5 -t 2 -u jack "/opt/google/chrome/chrome --type=-broker"