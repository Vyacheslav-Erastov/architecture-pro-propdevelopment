# Задание 7. Аудит и обеспечение соответствия политике безопасности контейнеров (PSP / PodSecurity / OPA Gatekeeper)


Для проверки задания необходимо выполнить следующую последовательность команд:

1. Остановить, удалить и запустить `minikube`:

```
minikube stop
minikube delete

mkdir -p ~/.minikube/files/etc/ssl/certs
cp audit-policy.yaml ~/.minikube/files/etc/ssl/certs

minikube start \
  --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=-
```

2. Запустить скрипт проверки `PodSecurity Admission`:

Запуск
```
bash ./verify/verify-admission.sh
```

Результат:
```
=== Проверка PodSecurity Admission в namespace audit-zone ===
1. Создаем namespace с политикой restricted
namespace/audit-zone created
1. Пытаемся создать под с privileged: true
Ожидаем: ошибка от PodSecurity
Error from server (Forbidden): error when creating "insecure-manifests/01-privileged-pod.yaml": pods "privileged-pod" is forbidden: violates PodSecurity "restricted:latest": privileged (container "nginx" must not set securityContext.privileged=true), allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
1. Пытаемся создать под с hostPath
Ожидаем: ошибка от PodSecurity
Error from server (Forbidden): error when creating "insecure-manifests/02-hostpath-pod.yaml": pods "hostpath-pod" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), restricted volume types (volume "host-root" uses restricted volume type "hostPath"), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
1. Пытаемся создать под с root user
Ожидаем: ошибка от PodSecurity
Error from server (Forbidden): error when creating "insecure-manifests/03-root-user-pod.yaml": pods "root-pod" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (container "nginx" must not set securityContext.runAsNonRoot=false), runAsUser=0 (container "nginx" must not set runAsUser=0), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
1. Создаем безопасные поды (должны пройти)
pod/secure-pod created
pod/secure-volume-pod created
pod/nonroot-pod created
1. Проверяем состояние подов
NAME                READY   STATUS              RESTARTS   AGE
nonroot-pod         0/1     ContainerCreating   0          0s
secure-pod          0/1     ContainerCreating   0          0s
secure-volume-pod   0/1     ContainerCreating   0          0s
=== Проверка завершена ===
```

3. Запустить скрипт проверки `Gatekeeper`:

Запуск
```
bash ./verify/validate-security.sh
```

Результат:
```
=== ЗАПУСК GATEKEEPER ТЕСТА ===
1. Создаем audit-zone
namespace/audit-zone unchanged

1. Устанавливаем Gatekeeper
namespace/gatekeeper-system created
resourcequota/gatekeeper-critical-pods created
Warning: unrecognized format "int64"
customresourcedefinition.apiextensions.k8s.io/assign.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/assignimage.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/assignmetadata.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/configpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/configs.config.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/connectionpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/connections.connection.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/constraintpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/constrainttemplatepodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/constrainttemplates.templates.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/expansiontemplate.expansion.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/expansiontemplatepodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/modifyset.mutations.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/mutatorpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/providerpodstatuses.status.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/providers.externaldata.gatekeeper.sh created
customresourcedefinition.apiextensions.k8s.io/syncsets.syncset.gatekeeper.sh created
serviceaccount/gatekeeper-admin created
role.rbac.authorization.k8s.io/gatekeeper-manager-role created
clusterrole.rbac.authorization.k8s.io/gatekeeper-manager-role created
rolebinding.rbac.authorization.k8s.io/gatekeeper-manager-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/gatekeeper-manager-rolebinding created
secret/gatekeeper-webhook-server-cert created
service/gatekeeper-webhook-service created
deployment.apps/gatekeeper-audit created
deployment.apps/gatekeeper-controller-manager created
poddisruptionbudget.policy/gatekeeper-controller-manager created
mutatingwebhookconfiguration.admissionregistration.k8s.io/gatekeeper-mutating-webhook-configuration created
validatingwebhookconfiguration.admissionregistration.k8s.io/gatekeeper-validating-webhook-configuration created

1. Ждем запуска Gatekeeper...
pod/gatekeeper-controller-manager-8589dd6558-4qmdz condition met
pod/gatekeeper-controller-manager-8589dd6558-jvhlw condition met
pod/gatekeeper-controller-manager-8589dd6558-pkrpl condition met

1. Применяем ConstraintTemplates...
constrainttemplate.templates.gatekeeper.sh/k8sproppreventhostpath created
constrainttemplate.templates.gatekeeper.sh/k8sproppreventprivileged created
constrainttemplate.templates.gatekeeper.sh/k8sproprequirenonroot created

1. Применяем Constraints...
k8sproppreventhostpath.constraints.gatekeeper.sh/prevent-hostpath created
k8sproppreventprivileged.constraints.gatekeeper.sh/prevent-privileged created
k8sproprequirenonroot.constraints.gatekeeper.sh/require-nonroot created

1. ТЕСТ: Создаем под без readOnlyRootFilesystem: true
Error from server (Forbidden): error when creating "STDIN": admission webhook "validation.gatekeeper.sh" denied the request: [require-nonroot] Container must have readOnlyRootFilesystem: true: nginx

1. ТЕСТ: Создаем безопасный под
pod/read-only-pod created

=== ТЕСТ ЗАВЕРШЕН ===
```