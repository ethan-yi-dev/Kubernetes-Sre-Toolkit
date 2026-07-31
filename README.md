# Kubernetes SRE Toolkit

A lightweight collection of Bash utilities for validating Kubernetes networking, service connectivity, and common operational issues.

---

## Overview

This project provides small command-line tools for Kubernetes troubleshooting and SRE workflows.

Current components:

- ✅ **Health Check** – Validate Service health from both the Kubernetes control plane and the data plane.
- 🚧 **Connectivity Matrix** – Generate Pod-to-Pod and Service connectivity matrices.
- 🚧 **Incident Detector** – Detect common networking and configuration issues.

---

## Features

### Health Check

The health check validates every Service in a namespace by performing:

- Discover Services
- Find backing Pods using the Service selector
- Verify all Pods are Ready
- Verify the Service has Endpoints
- Test TCP connectivity from a test Pod (`netshoot`)
- Generate a JSON health report

```bash
./scripts/health_check.sh <namespace>
```

Example:

```bash
./scripts/health_check.sh sre-lab
```

---

### Connectivity Matrix *(Coming Soon)*

Generate a namespace-wide connectivity matrix between workloads.

Planned features:

- Pod-to-Pod connectivity
- Service reachability
- NetworkPolicy validation
- JSON and table output

---

### Incident Detector *(Coming Soon)*

Automatically detect common Kubernetes networking failures.

Planned checks:

- Missing Endpoints
- Pod Not Ready
- DNS failures
- Service port mismatch
- NetworkPolicy blocking
- ImagePullBackOff / CrashLoopBackOff

---

## Architecture

```
                 health_check.sh
                        |
              Discover Services
                        |
                For each Service
                        |
            +-----------+-----------+
            |                       |
      Find backing Pods       Check Endpoints
            |
      Check Pod Ready
            |
 kubectl exec netshoot -- nc
            |
        TCP Connectivity
            |
        JSON Health Report
```

---

## Prerequisites

- Kubernetes cluster
- `kubectl`
- Bash
- A test Pod with `nc` installed (default: `netshoot`)

---

## Setup

Clone the repository and make the scripts executable.

```bash
chmod +x scripts/*.sh
```

Verify cluster connectivity.

```bash
kubectl get nodes
```

---

## Usage

### Health Check

Run against a namespace:

```bash
./scripts/health_check.sh <namespace>
```

Example:

```bash
./scripts/health_check.sh sre-lab
```

---

### Connectivity Matrix *(Coming Soon)*

```bash
./scripts/connectivity_matrix.sh <namespace>
```

---

### Incident Detector *(Coming Soon)*

```bash
./scripts/incident_detector.sh <namespace>
```

---

## Example Output

```json
[
  {
    "service": "nginx",
    "namespace": "sre-lab",
    "healthy": true,
    "endpoints": 2,
    "reason": "ok"
  },
  {
    "service": "redis",
    "namespace": "sre-lab",
    "healthy": true,
    "endpoints": 1,
    "reason": "ok"
  }
]
```

Exit codes:

| Code | Meaning |
|------|---------|
| 0 | All Services are healthy |
| 1 | One or more health checks failed |
| 2 | Invalid arguments or environment |

---

## Troubleshooting

| Reason | Description |
|---------|-------------|
| `no backing pods` | The Service selector does not match any Pods. |
| `not ready` | One or more backend Pods are not Ready. |
| `no endpoints` | The Service has no Ready Endpoints. |
| `connection refused` | The Service is reachable but the application is not listening on the target port. |
| `timeout` | DNS, NetworkPolicy, or routing prevented the TCP connection. |

---

## Roadmap

- [x] Health Check
- [ ] Connectivity Matrix
- [ ] Incident Detector
- [ ] JSON Schema documentation
- [ ] GitHub Actions integration