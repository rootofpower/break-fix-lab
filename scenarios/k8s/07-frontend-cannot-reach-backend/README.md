# 07 — Frontend cannot reach the backend

**Difficulty:** easy

## Symptom

Users report that the application stopped working. The frontend still opens at
`http://localhost:8080`, but every request that needs the backend fails:

```console
$ curl -X POST -d 'hello' localhost:8080/echo
[
  "backend http://backend:9898/echo call failed ..."
]
```

Nobody deployed a new version of the application, and `kubectl -n lab get pods`
shows every pod as `Running`.

## Your task

Find out why the frontend cannot reach the backend and fix it.
The scenario is solved when the request above returns `["hello"]` again.

## How to run

```bash
make break SCENARIO=07-frontend-cannot-reach-backend   # break the working lab
make check SCENARIO=07-frontend-cannot-reach-backend   # exit code 0 = fixed
```

Stuck? Open [hint.md](hint.md). The full walkthrough is in
[SOLUTION.md](SOLUTION.md) — try on your own first.
