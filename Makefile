.PHONY: up down list break require-scenario check

SCENARIO_DIR = scenarios/k8s/$(SCENARIO)

require-scenario:
		@test -n "$(SCENARIO)" || { \
          			echo "Error: SCENARIO is not set."; \
          			echo "Usage: make $(MAKECMDGOALS) SCENARIO=<name>"; \
          			echo "Run 'make list' to see available scenarios."; \
          			exit 1; }
		@test -d "$(SCENARIO_DIR)" || { \
  					echo "Error: SCENARIO '$(SCENARIO)' not found"; \
  					echo "Run 'make list' to see available scenarios.";\
  					exit 1; }


down:
		kind delete cluster --name break-fix

up:
		kind create cluster --config kind-config.yaml
		kubectl apply -k app/
		kubectl -n lab rollout status deployment/backend --timeout=120s
		kubectl -n lab rollout status deployment/redis --timeout=120s
		kubectl -n lab rollout status deployment/frontend --timeout=120s

list:
		@ls scenarios/k8s

break: require-scenario
		@bash $(SCENARIO_DIR)/break.sh

check: require-scenario
		@bash $(SCENARIO_DIR)/check.sh
