#!/bin/bash

LOG_FILE="${1:-audit.log}"

echo "Подозрительные события из $LOG_FILE"

echo "=== Доступ к secrets ==="
jq 'select(.objectRef.resource=="secrets" and .verb=="get")' "$LOG_FILE" > secrets.tmp.json

echo "=== kubectl exec ==="
jq 'select(.verb=="get" and .objectRef.subresource=="exec")' "$LOG_FILE" > execs.tmp.json

echo "=== Привилегированные поды ==="
jq 'select(.objectRef.resource=="pods" and (.requestObject.spec.containers[]?.securityContext.privileged? == true // empty))' "$LOG_FILE" > privileged.tmp.json

echo "=== RoleBindings ==="
jq 'select(.objectRef.resource=="rolebindings" and .verb=="create") | select(.requestObject.roleRef.name == "cluster-admin")' "$LOG_FILE" > bindings.tmp.json

echo "=== Audit policy ==="
grep -i 'audit-policy' "$LOG_FILE" | jq . > audit-policy.tmp.json

cat *.tmp.json > audit-extract.json

echo "Извлечено в audit-extract.json"