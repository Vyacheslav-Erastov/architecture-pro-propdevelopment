#!/bin/bash

echo "=== Проверка PodSecurity Admission в namespace audit-zone ==="

echo "1. Создаем namespace с политикой restricted"
kubectl apply -f 01-create-namespace.yaml

echo "2. Пытаемся создать под с privileged: true"
echo "Ожидаем: ошибка от PodSecurity"
kubectl apply -f insecure-manifests/01-privileged-pod.yaml 2>&1 | grep -A5 -B5 "Error"

echo "3. Пытаемся создать под с hostPath"
echo "Ожидаем: ошибка от PodSecurity"
kubectl apply -f insecure-manifests/02-hostpath-pod.yaml 2>&1 | grep -A5 -B5 "Error"

echo "4. Пытаемся создать под с root user"
echo "Ожидаем: ошибка от PodSecurity"
kubectl apply -f insecure-manifests/03-root-user-pod.yaml 2>&1 | grep -A5 -B5 "Error"

echo "5. Создаем безопасные поды (должны пройти)"
kubectl apply -f secure-manifests/01-secure.yaml
kubectl apply -f secure-manifests/02-secure.yaml
kubectl apply -f secure-manifests/03-secure.yaml

echo "6. Проверяем состояние подов"
kubectl get pods -n audit-zone

echo "=== Проверка завершена ==="