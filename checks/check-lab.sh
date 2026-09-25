#!/bin/bash
set -uo pipefail

# Quick health check for the SRE lab environment.
# Run this before starting exercises or after resetting to baseline.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass=0
fail=0

check() {
    local desc="$1"
    shift
    if "$@" &>/dev/null; then
        echo -e "  ${GREEN}✅ PASS${NC}  $desc"
        pass=$((pass + 1))
    else
        echo -e "  ${RED}❌ FAIL${NC}  $desc"
        fail=$((fail + 1))
    fi
}

echo "=========================================="
echo "  SRE Lab Health Check"
echo "=========================================="
echo ""

echo "Cluster:"
check "kind cluster 'sre-lab' exists" bash -c 'kind get clusters 2>/dev/null | grep -qx sre-lab'
check "kubectl can reach the API server" kubectl cluster-info

echo ""
echo "Nodes:"
check "All nodes are Ready" bash -c '
  out=$(kubectl get nodes --no-headers 2>/dev/null) || exit 1
  [ -n "$out" ] || exit 1
  ! echo "$out" | grep -q NotReady
'

echo ""
echo "Cilium:"
check "Cilium is running" bash -c 'kubectl get ds -n kube-system cilium -o jsonpath="{.status.numberReady}" | grep -qE "^[1-9]"'

echo ""
echo "Namespace sre-lab:"
check "Namespace exists" kubectl get namespace sre-lab
check "nginx pods Running" bash -c 'kubectl get pods -n sre-lab -l app=nginx --no-headers | grep -q Running'
check "redis pod Running" bash -c 'kubectl get pods -n sre-lab -l app=redis --no-headers | grep -q Running'
check "redis-client pod Running" bash -c 'kubectl get pods -n sre-lab -l app=redis-client --no-headers | grep -q Running'
check "netshoot pod Running" bash -c 'kubectl get pods -n sre-lab -l app=netshoot --no-headers | grep -q Running'

echo ""
echo "Services:"
check "nginx Service has endpoints" bash -c 'kubectl get endpoints nginx -n sre-lab -o jsonpath="{.subsets}" | grep -q addresses'
check "redis Service has endpoints" bash -c 'kubectl get endpoints redis -n sre-lab -o jsonpath="{.subsets}" | grep -q addresses'

echo ""
echo "Connectivity:"
check "netshoot can curl nginx" kubectl exec -n sre-lab netshoot -- curl -sS --max-time 5 nginx
check "netshoot can reach redis" kubectl exec -n sre-lab netshoot -- nc -zv -w 3 redis 6379
check "DNS resolves nginx" kubectl exec -n sre-lab netshoot -- nslookup nginx

echo ""
echo "Network Policies:"
np_count=$(kubectl get networkpolicy -n sre-lab --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [ "$np_count" -eq 0 ]; then
    echo -e "  ${GREEN}✅ PASS${NC}  No NetworkPolicies active (clean baseline)"
else
    echo -e "  ${YELLOW}⚠  WARN${NC}  $np_count NetworkPolicy(ies) found — may affect exercises"
fi

echo ""
echo "=========================================="
echo -e "  Results: ${GREEN}$pass passed${NC}, ${RED}$fail failed${NC}"
echo "=========================================="

exit $fail
