#!/bin/bash

# Function to check the OS version and release number
check_os_version() {
  if [[ -e /etc/os-release ]]; then
    source /etc/os-release
    echo "Operating System: $NAME"
    echo "Version: $VERSION_ID"
  else
    echo "Error: /etc/os-release file not found. Cannot determine the OS version."
  fi
}

# Call the function
check_os_version