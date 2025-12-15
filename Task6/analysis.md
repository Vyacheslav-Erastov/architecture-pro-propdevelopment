# Отчёт по результатам анализа Kubernetes Audit Log

## Подозрительные события

1. Доступ к секретам:
   - Кто: system:serviceaccount:secure-ops:monitoring
   - Где: kube-system namespace, default-token secret
   - Почему подозрительно: ServiceAccount monitoring запрашивает secrets в системном namespace без явных прав, что указывает на попытку эскалации привилегий

2. Привилегированные поды:
   - Кто: admin или текущий пользователь kubectl
   - Комментарий: Создан pod privileged-pod с securityContext.privileged: true, что предоставляет полный доступ к хосту и нарушает принцип наименьших привилегий

3. Использование kubectl exec в чужом поде:
   - Кто: admin или текущий пользователь
   - Что делал: Выполнен exec в coredns pod (kube-system) для чтения /etc/resolv.conf (но так как в coredns нет утилиты cat и sh, то ничего не происходит)

4. Создание RoleBinding с правами cluster-admin:
   - Кто: admin или текущий пользователь
   - К чему привело: ServiceAccount monitoring:secure-ops получил cluster-admin права, что дает полный контроль над кластером и потенциальную компрометацию

5. Удаление audit-policy.yaml:
   - Кто: admin с флагом --as=admin (Но данное действие не отображается в логах, так как это конфигурационный файл на хосте minikube и он не является ресурсом Kubernetes)
   - Возможные последствия: Отключение аудита делает кластер слепым к дальнейшим атакам, маскируя инциденты

## Вывод

Скрипт `simulate-incident.sh` моделирует типичную цепочку атаки: разведка secrets, эскалация через привилегированный pod, привилегированная эскалация RBAC и отключение мониторинга. Компрометация кластера подтверждается cluster-admin binding для monitoring SA. RBAC политика допускает ошибки: отсутствие deny на privileged containers, слабые bindings для SA и разрешение delete ConfigMaps (audit-policy как CM). Для исправления необходимо добавить admission controllers (PodSecurity, RBAC validation) и NetworkPolicies