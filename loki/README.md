# Loki Helm Configuration

Grafana Loki log aggregation system configuration for TradeFence environments.

## Overview

This directory contains Helm values files for deploying Loki across different environments. The Loki Helm chart is fetched directly by ArgoCD from the [official Grafana Helm repository](https://grafana.github.io/helm-charts) - this directory only contains values files.

## Architecture

### Log Collection
All environments use **OpenTelemetry Collector** for log collection and forwarding to Loki. Promtail is disabled across all environments for consistency.

### Deployment Modes

#### Local (values-local.yaml)
- **Mode**: SimpleScalable (distributed)
- **Components**: write, read, backend (1 replica each)
- **Storage**: S3 (MinIO at host.k3d.internal:9000)
- **KVStore**: etcd (etcd.default.svc.cluster.local)
- **Use Case**: Local development with production-like architecture

#### Staging (values-staging.yaml)
- **Mode**: SimpleScalable (distributed)
- **Components**: write, read, backend (1 replica each)
- **Storage**: Filesystem (50Gi)
- **KVStore**: inmemory
- **Resources**: 250m CPU, 512Mi memory (requests)
- **Use Case**: Staging environment testing

#### Production (values-production.yaml)
- **Mode**: SimpleScalable (distributed)
- **Components**: write, read, backend (1 replica each)
- **Storage**: Filesystem (100Gi)
- **KVStore**: inmemory
- **Resources**: 500m CPU, 1Gi memory (requests)
- **Use Case**: Production workloads

## Files Structure

```
loki/
├── README.md                    # This file
├── values-local.yaml            # Local development configuration
├── values-staging.yaml          # Staging environment configuration
└── values-production.yaml       # Production environment configuration
```

## Configuration Details

### Local Environment Specifics
- Uses MinIO for S3-compatible object storage
- Requires etcd in the default namespace
- Hardcoded credentials (for local dev only - see warning in file)
- SimpleScalable mode provides production-like distributed architecture

### Staging/Production Specifics
- Filesystem storage with persistent volumes
- In-memory KV store (suitable for SimpleScalable mode)
- No external dependencies required (etcd not needed with inmemory kvstore)
- Different resource allocations based on environment needs
- Same SimpleScalable architecture as local for consistency

## Deployment

Loki is deployed via ArgoCD. The ArgoCD Application manifest:
- Fetches chart directly from Grafana Helm repository (version 6.46.0)
- Uses values files from this repository
- Located at: `tradefence-deploy/environments/{env}/loki.yaml`

## OpenTelemetry Integration

To send logs from OpenTelemetry Collector to Loki, use the following configuration:

```yaml
exporters:
  loki:
    endpoint: http://loki-write.monitoring.svc.cluster.local:3100/loki/api/v1/push
```

**Note**: All environments use the same `loki-write` service endpoint for log ingestion since all use SimpleScalable mode.

**For Grafana Datasource** (querying logs):
- Use: `http://loki-gateway` (port 80)
- The gateway routes read requests to the appropriate components

## Version Information

- **Chart Version**: 6.46.0 (Grafana Loki Helm Chart)
- **App Version**: 3.5.7 (Loki)
- **Deployment**: Managed by ArgoCD

## Notes

- No Chart.yaml in this directory - ArgoCD fetches the chart directly
- Promtail is disabled in all environments
- All environments use OpenTelemetry Collector for unified observability
- Local environment mirrors production architecture for better testing
