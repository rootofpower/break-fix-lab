#!/usr/bin/env bash
set -euo pipefail

curl -s -m 5 -X POST -d 'hello' localhost:8080/echo | grep -q 'hello' || {
    echo "FAIL: request through the frontend did not return the expected response."
    exit 1
  }

echo "OK: frontend reached the backend and got the expected response."
