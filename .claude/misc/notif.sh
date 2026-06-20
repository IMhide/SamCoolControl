#!/bin/bash

# Check if correct number of arguments provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <subtitle> <message>"
    echo "Example: $0 \"Build Complete\" \"All tests passed successfully\""
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Arguments
SUBTITLE="$1"
MESSAGE="$2"

# Send notification with local icon
terminal-notifier -title ProjectX -subtitle "$SUBTITLE" -message "$MESSAGE"

# Play sound
afplay "$SCRIPT_DIR/codec.aiff"
