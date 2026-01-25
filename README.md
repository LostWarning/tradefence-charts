# tradefence-charts

This repository holds the top-level Helm charts used to deploy the TradeFence platform. Each service is packaged as a separate Helm chart in a top-level directory.

Purpose
-------

Provide maintainable Helm charts for deploying TradeFence components. Charts include `Chart.yaml`, default values (`values.yaml`) and `templates/` for Kubernetes manifests.

Quick structure
---------------

- `api-gateway/` — API Gateway service for TradeFence platform
- `data-ingestion-service/` — Service to fetch realtime stock data and publish it to redis
- `data-repository/` — Data repository service for TradeFence platform
- `etcd/` — etcd distributed key-value store with StatefulSet deployment
- `loki/` — Custom Loki for application and infrastructure monitoring
- `nats/` — NATS messaging system for pub/sub with in-memory cluster support
- `notification-service/` — Notification service for TradeFence platform
- `prometheus/` — Custom Prometheus alert rules for application and infrastructure monitoring
- `redis/` — Redis deployment for database caching
- `tempo/` — Grafana Tempo distributed tracing backend
- `traefik/` — Custom Traefik for application and infrastructure monitoring
- `trigger-scheduler/` — Trigger scheduler for TradeFence platform
- `user-service/` — User service for TradeFence platform
- `ws-gateway/` — WebSocket Gateway for TradeFence

Quick commands
--------------

Lint a single chart:

```bash
helm lint ./api-gateway
```

Render manifests locally (use local/staging values):

```bash
helm template api-gateway ./api-gateway
helm template data-ingestion-service ./data-ingestion-service
```

Install/upgrade to a cluster (example):

```bash
helm upgrade --install api-gateway ./api-gateway -n tradefence --create-namespace
```
Versioning
----------

The source of truth for versioning is the **`VERSION` file** located in the root of the **Application Repository**.

The `builder.sh` script reads this file to generate the final Docker tag.

**VERSION File Format:**
The file can contain just the version string, or key-value configuration:
```bash
VERSION=1.0.1-rc.1
# Optional: Override target infra branch (default: main)
GITOPS_BRANCH=release-1.0
# Optional: Override source tag for auto-branch creation
GITOPS_TAG=v1.0.0
```

**Generated Tag Format:**
`{VERSION}-build.{YYYYMMDD-HHMM}.SHA`
Example: `1.0.1-rc.1-build.20231027-1200.a1b2c3d`

CI Builder & Branching
----------------------

The builder employs a **Convention-Over-Configuration** strategy to manage infrastructure branches.

### 1. Standard Development (No Tag Argument)
*   **Target**: Defaults to `main` (or `GITOPS_BRANCH` if set).
*   **Use Case**: Daily CI builds, dev environment updates.

### 2. Release & Hotfix (With Tag Argument)
When the builder is invoked with a specific release tag (e.g., `./builder.sh app v1.0.1`), it activates **Auto-Branching**:

1.  **Derives Branch Name**: `fix/{app-name}-v{base-version}`
    *   Example: `VERSION=1.0.1` -> `fix/api-gateway-v1.0`
2.  **Auto-Creation**:
    *   If the branch exists, it is used.
    *   If missing, it is automatically created from the source tag (`{app-name}-v{VERSION}` or `GITOPS_TAG`).

This ensures that hotfixes requiring infrastructure changes are isolated from `main`.

Promotion
---------

When a build is tested and confirmed ready for the next environment, follow this promotion process:

1.  **Finalize Version**: Update the `appVersion` in `Chart.yaml` by removing the `build.{YYYYMMDD-HHMM}.SHA` suffix.
2.  **Tag Release**: Commit the change and create a git tag with the format: `{appName}-v{appVersion}`.
3.  **Prepare Next Cycle**: Update the `appVersion` in `Chart.yaml` to the next development version (e.g., increment the stability version) to start the next work cycle.

### Semantic Versioning

This project uses **Semantic Versioning** (`MAJOR.MINOR.PATCH`) to denote stability and feature sets.

-   **Target Versioning**: We use the *target* release version (e.g., `1.0.0`) even during early development (e.g., `1.0.0.alpha.1`) rather than a lower version like `0.0.1`.
    -   *Why?* This ensures that every artifact is easily identifiable as belonging to a specific release cycle. You know immediately that `1.0.0.alpha.1` is an early build of the upcoming `1.0.0` release.

-   **Stability Tags & Environments**:
    -   **QA**: Uses `alpha` or `beta` tags (e.g., `1.0.0.alpha.1`, `1.0.0.beta.1`).
    -   **Staging**: Uses `rc` (Release Candidate) tags (e.g., `1.0.0.rc.1`).
    -   **Production**: Uses the clean version (e.g., `1.0.0`).

-   **Stability Version**: An incremental counter for that stability phase (e.g., `alpha.1` -> `alpha.2`).

Example flow:
-   Dev/QA version: `1.0.0.alpha.1-build.2023...`
-   Promoted Tag (QA): `api-gateway-v1.0.0.alpha.1`
-   Promoted Tag (Staging): `api-gateway-v1.0.0.rc.1`
-   Next Dev version: `1.0.0.rc.2`
