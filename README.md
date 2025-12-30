# tradefence-charts

This repository holds the top-level Helm charts used to deploy the TradeFence platform. Each service is packaged as a separate Helm chart in a top-level directory (for example, `api-gateway/`, `data-ingestion-service/`, `ws-gateway/`, `redis/`, `prometheus/`, `stock-tick-controller/`).

Purpose
-------

Provide maintainable, environment-aware Helm charts for deploying TradeFence components. Charts include `Chart.yaml`, environment overlays (`values-local.yaml`, `values-staging.yaml`, `values-production.yaml`) and `templates/` for Kubernetes manifests.

Quick structure
---------------

- `api-gateway/` — API ingress/service
- `ws-gateway/` — websocket gateway
- `data-ingestion-service/` — fetches realtime stock data and publishes to Redis
- `user-service/` — user-related service
- `stock-tick-controller/` — CRDs and controller (see `crds/`)
- `redis/` — StatefulSet + headless service
- `prometheus/` — Prometheus alert rules

Quick commands
--------------

Lint a single chart:

```bash
helm lint ./api-gateway
```

Render manifests locally (use local/staging values):

```bash
helm template tradefence-api ./api-gateway -f api-gateway/values-local.yaml
helm template tradefence-data ./data-ingestion-service -f data-ingestion-service/values-staging.yaml
```

Install/upgrade to a cluster (example):

```bash
helm upgrade --install tradefence-api ./api-gateway -f api-gateway/values-staging.yaml -n tradefence --create-namespace
```

Notes & gotchas
--------------

- There is a known Chart name inconsistency: `ws-gateway/Chart.yaml` currently lists `name: tradefence-api-gateway`. Ensure chart `name` and `appVersion` are correct before packaging to avoid collisions.
- CRD and StatefulSet changes require coordinated rollouts and special care in PR descriptions — see `stock-tick-controller/crds/` and `application-template/statefulset.yaml`.

Developer guidance for AI/automation
----------------------------------

See `.github/copilot-instructions.md` for repo-specific guidance intended for automated agents and maintainers (helm patterns, typical workflows, and recommended checks).

Contributing
------------

Open a PR against `main`. For chart/template changes include:

- The rendered manifest snippet (`helm template ...`) for reviewers.
- Which `values-*.yaml` was used to test.
- Any rollout/rollback notes for infra changes (CRDs, stateful sets, RBAC).

If you'd like a GitHub Actions workflow that lints all charts or runs `helm template` checks, ask and I can add a minimal CI job.

Test