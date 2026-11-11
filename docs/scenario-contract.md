# Scenario contract

Every scenario in this lab follows the same contract. It keeps the scenarios
predictable for the person solving them and lets CI verify each one the same way.

## Directory layout

Each scenario lives in its own directory under `scenarios/k8s/`:

```
scenarios/k8s/07-frontend-cannot-reach-backend/
├── README.md      # the symptom as a user sees it, no spoilers
├── break.sh       # breaks the working lab
├── check.sh       # exit code 0 = fixed
├── hint.md        # a nudge for when you are stuck
└── SOLUTION.md    # symptoms → diagnosis → root cause → fix → prevention
```

The directory name is a number plus a description of the **symptom**, not the
cause. `07-frontend-cannot-reach-backend` is fine; `07-service-selector` would
give the answer away before the scenario starts.

| File | Required | Purpose |
| --- | --- | --- |
| `README.md` | yes | What the user observes and what counts as solved |
| `break.sh` | yes | Turns the working lab into the broken one |
| `check.sh` | yes | Tells whether the lab works again |
| `hint.md` | yes | Points to where to look, without naming the fix |
| `SOLUTION.md` | yes | Full walkthrough with real command output |
| `setup.sh` | no | Extra preparation, only if the scenario needs more than the default lab |

## Lifecycle

```bash
make up                         # create the cluster and deploy the app
make list                       # show available scenarios
make break SCENARIO=<name>      # start a scenario
make check SCENARIO=<name>      # verify the fix
make reset                      # return to the working state
make down                       # delete the cluster
```

`make reset` deletes the `lab` namespace and deploys the app again from `app/`.
The manifests in `app/` are the single source of truth for the working state.

## Rules for `break.sh`

1. **Change the cluster, never the files in `app/`.**
   `make reset` restores the lab from those files. If a scenario edited them,
   there would be no working state left to return to.

2. **Print nothing that reveals the change.**
   `kubectl` reports what it did (`service/backend selector updated`), which is
   the answer to the scenario. Send standard output to `/dev/null` and print
   one neutral line at the end. Leave standard error alone, so a real failure
   of the script is still visible.

3. **Make the failure visible immediately.**
   A broken configuration does not always break traffic right away. In
   scenario 07 the frontend kept answering through an already open keep-alive
   connection after the Service lost its endpoints. The script restarts the
   frontend and waits for the rollout, so the symptom is there the moment
   `make break` returns.

4. **Finish only when the lab is in its final broken state.**
   Wait for any rollout the script triggers. Otherwise a `check` that runs
   right after `break` may still see the old, working pods.

5. **Start with `set -euo pipefail`.**
   A script that fails halfway must stop and return a non-zero exit code
   instead of reporting success.

## Rules for `check.sh`

1. **Check the outcome, not the fix.**
   Verify that the application works from the user's point of view, for
   example that a request through the frontend returns the expected response.
   Do not check that a particular field has a particular value. A scenario
   usually has several correct fixes (`kubectl edit`, `kubectl apply`,
   `kubectl rollout undo`), and all of them must pass.

2. **Exit code is the result.**
   `0` means fixed, anything else means still broken. CI relies on this.

3. **Look at the response body, not only the HTTP status.**
   The frontend answers `200 OK` even when the backend is unreachable and puts
   the error into the body. A status-only check would pass on a broken lab.

4. **Use a timeout.**
   Some failures make requests hang instead of failing. Every network call
   needs a limit (`curl -m 5`), so the check always finishes.

5. **Print one clear line.**
   Start it with `OK:` or `FAIL:` and describe what was verified, never the
   cause.

6. **Never modify anything.**
   `check.sh` only observes. Running it twice must give the same result.

## Rules for `README.md`

Describe only what a user or an on-call engineer would see: the failing
request, the error text, what still works. Do not name the broken Kubernetes
object or the kind of mistake. State the condition that counts as solved and
show the `make break` / `make check` commands.

## Rules for `hint.md` and `SOLUTION.md`

`hint.md` narrows the search without giving the answer: which command to run
or which part of the system to inspect.

`SOLUTION.md` follows a fixed structure:

1. **Symptoms** — what was observed.
2. **Diagnosis** — the commands that were run and their real output.
3. **Root cause** — what was actually wrong.
4. **Fix** — at least one way to repair it.
5. **Prevention** — what would have caught this before production.

## How CI uses the contract

For every scenario CI runs the same sequence on a fresh cluster:

```
make up → make check (must pass) → make break → make check (must fail)
```

This proves two things: the scenario starts from a working lab, and `break.sh`
really breaks what `check.sh` verifies.

## Adding a scenario

1. Create `scenarios/k8s/NN-symptom-description/`.
2. Write `break.sh` and `check.sh`, make both executable (`chmod +x`).
3. Run the cycle by hand: `check` passes, `break`, `check` fails, `reset`,
   `check` passes again.
4. Solve the scenario yourself and record the real output in `SOLUTION.md`.
5. Write `README.md` and `hint.md` last, when you know what the symptom looks
   like and where people are likely to get stuck.
