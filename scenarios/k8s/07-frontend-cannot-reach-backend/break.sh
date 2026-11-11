#!/usr/bin/env bash
set -euo pipefail

kubectl -n lab set selector service backend 'app=backend-v2' > /dev/null
kubectl -n lab rollout restart deployment/frontend > /dev/null
kubectl -n lab rollout status deployment/frontend --timeout=120s > /dev/null

echo 'Scenario is active. Read its README.md and start debugging.'
