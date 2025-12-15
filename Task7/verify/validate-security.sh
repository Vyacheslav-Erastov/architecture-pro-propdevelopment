#!/bin/bash
echo "=== ЗАПУСК GATEKEEPER ТЕСТА ==="

echo "1. Создаем audit-zone"
kubectl apply -f 01-create-namespace.yaml
echo ""

echo "2. Устанавливаем Gatekeeper"
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.21.0/deploy/gatekeeper.yaml
echo ""

echo "3. Ждем запуска Gatekeeper..."
kubectl wait --for=condition=ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=120s
echo ""

echo "4. Применяем ConstraintTemplates..."
kubectl apply -f gatekeeper/constraint-templates/
sleep 40
echo ""

echo "5. Применяем Constraints..."
kubectl apply -f gatekeeper/constraints/
sleep 10
echo ""

echo "6. ТЕСТ: Создаем под без readOnlyRootFilesystem: true"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: non-read-only-pod
  namespace: audit-zone
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx:latest
    command: ["sleep", "3600"]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
EOF

echo ""
echo "7. ТЕСТ: Создаем безопасный под"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: read-only-pod
  namespace: audit-zone
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx:latest
    command: ["sleep", "3600"]
    securityContext:
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
    volumeMounts:
    - name: config
      mountPath: /config
  volumes:
  - name: config
    emptyDir: {}
EOF

echo ""
echo "=== ТЕСТ ЗАВЕРШЕН ==="