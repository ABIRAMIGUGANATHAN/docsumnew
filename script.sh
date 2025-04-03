#!/bin/bash
echo "User question received: $1"

# Example: Save question to a log file
echo "$(date): $1" >> questions.log

# Example: Use the question in another command (like calling an API)
# curl -X POST "https://api.example.com/process" -d "question=$1"

exit 0
