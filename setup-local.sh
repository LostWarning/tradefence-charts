#!/bin/bash
set -e

REGISTRY_NAME="tradefence-registry"
CLUSTER_NAME="tradefence-local"
REGISTRY_PORT="5000"

# 1. Create Registry if it doesn't exist
if ! k3d registry list | grep -q "$REGISTRY_NAME"; then
    echo "Creating registry '$REGISTRY_NAME'..."
    k3d registry create "$REGISTRY_NAME" --port "$REGISTRY_PORT"
else
    echo "Registry '$REGISTRY_NAME' already exists."
fi

# 2. Create Cluster if it doesn't exist
if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Creating cluster '$CLUSTER_NAME'..."
    k3d cluster create "$CLUSTER_NAME" \
        --registry-use "k3d-$REGISTRY_NAME:$REGISTRY_PORT" \
        -p "80:80@loadbalancer" \
        -p "443:443@loadbalancer" \
        --k3s-arg "--disable=traefik@server:0"
else
    echo "Cluster '$CLUSTER_NAME' already exists."
fi

# 3. Install/Upgrade Traefik
if [ -f "traefik/values-dev.yaml" ]; then
    echo "Installing/Upgrading Traefik..."
    helm repo add traefik https://traefik.github.io/charts
    helm repo update
    helm upgrade --install traefik traefik/traefik \
        -f traefik/values-dev.yaml \
        --namespace kube-system \
        --create-namespace
else
    echo "Warning: traefik/values-dev.yaml not found. Skipping Traefik installation."
fi
