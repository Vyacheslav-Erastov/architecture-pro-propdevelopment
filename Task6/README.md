# Задание 6. Аудит активности пользователей и обнаружение инцидентов

Для проверки задания необходимо выполнить следующую последовательность команд:

```
minikube stop
minikube delete

mkdir -p ~/.minikube/files/etc/ssl/certs
cp audit-policy.yaml ~/.minikube/files/etc/ssl/certs

minikube start \
  --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=-

bash simulate-incident.sh

kubectl logs kube-apiserver-minikube -n kube-system | grep audit.k8s.io/v1 > audit.log

bash audit-filter.sh audit.log
```

Результаты сбора и фильтрации логов можно посмотреть в файле `audit-extract.json`