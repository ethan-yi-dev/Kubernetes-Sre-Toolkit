#!/usr/bin/env bash

if [[ -n "${MSYSTEM:-}" ]]; then
  export MSYS_NO_PATHCONV=1
fi

NAMESPACE="${1:-}"

if [[ -z "$NAMESPACE" ]]; then
  echo "Usage: $0 <namespace>" >&2
  exit 2
fi

SERVICES=$(kubectl get svc -n "$NAMESPACE" \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

FIRST=true
UNHEALTHY=false

echo "["

for SERVICE in $SERVICES; do
  ENDPOINTS=$(kubectl get endpoints "$SERVICE" -n "$NAMESPACE" \
    -o jsonpath='{range .subsets[*].addresses[*]}{.ip}{"\n"}{end}' \
    2>/dev/null | grep -c .)

  if [[ "$ENDPOINTS" -eq 0 ]]; then
    HEALTHY=false
    REASON="no endpoints"
    UNHEALTHY=true
  else
    HEALTHY=true
    REASON="ok"
  fi

  if [[ "$FIRST" == "false" ]]; then
    echo ","
  fi

  printf '  {"service":"%s","namespace":"%s","healthy":%s,"endpoints":%s,"reason":"%s"}' \
    "$SERVICE" "$NAMESPACE" "$HEALTHY" "$ENDPOINTS" "$REASON"

  FIRST=false
done

echo
echo "]"

if [[ "$UNHEALTHY" == "true" ]]; then
  exit 1
fi

exit 0