.PHONY: up down

down:
		kind delete cluster --name break-fix

up:
		kind create cluster --config kind-config.yaml
		kubectl apply -k app/
		kubectl -n lab rollout status deployment/backend --timeout=120s
		kubectl -n lab rollout status deployment/redis --timeout=120s
		kubectl -n lab rollout status deployment/frontend --timeout=120s
