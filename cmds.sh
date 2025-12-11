# ============================================================
# Последовательность команд для инициализации и запуска кластера
# Дипломное задание "Nightmare" - Kubernetes
# ============================================================
#
# Описание проекта: README.MD
# Пошаговая инструкция: DEPLOY.MD
# Манифесты: deploy/
#
# Этот файл содержит все команды для быстрого копирования и выполнения
# ============================================================

# ============================================================
# ПРЕДВАРИТЕЛЬНАЯ ПРОВЕРКА КЛАСТЕРА
# ============================================================

# Проверяем доступность кластера
kubectl cluster-info

# Проверяем ноды кластера (все должны быть Ready)
kubectl get nodes

# Проверяем версию Kubernetes
kubectl version --short


# ============================================================
# РАЗВЕРТЫВАНИЕ ПРИЛОЖЕНИЯ
# ============================================================

# Вариант 1: Одной командой (РЕКОМЕНДУЕТСЯ)
kubectl apply -f deploy/

# Вариант 2: Пошаговое развертывание
kubectl apply -f deploy/01-namespace.yaml
kubectl apply -f deploy/02-mongodb-deployment.yaml
kubectl apply -f deploy/03-mongodb-service.yaml
kubectl apply -f deploy/04-webapp-deployment.yaml
kubectl apply -f deploy/05-webapp-service.yaml
kubectl apply -f deploy/06-traefik-rbac.yaml
kubectl apply -f deploy/07-traefik-deployment.yaml
kubectl apply -f deploy/08-traefik-service.yaml
kubectl apply -f deploy/09-ingressclass.yaml
kubectl apply -f deploy/10-webapp-ingress.yaml


# ============================================================
# ПРОВЕРКА РАЗВЕРТЫВАНИЯ
# ============================================================

# Проверяем namespace
kubectl get namespaces

# Проверяем все ресурсы в namespace webapp
kubectl get all -n webapp

# Проверяем MongoDB
kubectl get deployment -n webapp mongodb
kubectl get pods -n webapp -l app=mongodb
kubectl get service -n webapp mongodb

# Проверяем веб-приложение
kubectl get deployment -n webapp webapp
kubectl get pods -n webapp -l app=webapp
kubectl get service -n webapp webapp

# Проверяем Traefik Ingress Controller
kubectl get deployment -n kube-system traefik
kubectl get pods -n kube-system -l app=traefik
kubectl get service -n kube-system traefik

# Проверяем Ingress
kubectl get ingress -n webapp
kubectl describe ingress -n webapp webapp-ingress

# Проверяем IngressClass
kubectl get ingressclass


# ============================================================
# ПОЛУЧЕНИЕ IP АДРЕСА НОДЫ ДЛЯ ДОСТУПА
# ============================================================

# Получаем IP адреса всех нод
kubectl get nodes -o wide

# Получаем IP конкретной ноды (например, node01)
kubectl get node node01 -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}'


# ============================================================
# ТЕСТИРОВАНИЕ ПРИЛОЖЕНИЯ
# ============================================================

# Заменяем <NODE_IP> на реальный IP ноды из предыдущей команды

# Тест через curl
curl -H "Host: webapp.local" http://<NODE_IP>:30080

# Пример:
# curl -H "Host: webapp.local" http://10.0.2.21:30080

# Доступ к Traefik Dashboard
# Открываем в браузере: http://<NODE_IP>:30081


# ============================================================
# НАСТРОЙКА HOSTS ДЛЯ ДОСТУПА ЧЕРЕЗ БРАУЗЕР
# ============================================================

# Linux/Mac: добавляем в /etc/hosts
# Windows: добавляем в C:\Windows\System32\drivers\etc\hosts
# Строка (заменяем <NODE_IP> на реальный):
# <NODE_IP> webapp.local

# Пример:
# 10.0.2.21 webapp.local

# После этого открываем в браузере:
# http://webapp.local:30080


# ============================================================
# МОНИТОРИНГ И ЛОГИ
# ============================================================

# Просмотр логов веб-приложения
kubectl logs -n webapp -l app=webapp --tail=100 -f

# Просмотр логов MongoDB
kubectl logs -n webapp -l app=mongodb --tail=100 -f

# Просмотр логов Traefik
kubectl logs -n kube-system -l app=traefik --tail=100 -f

# Просмотр событий в namespace
kubectl get events -n webapp --sort-by='.lastTimestamp'

# Детальная информация о поде
kubectl describe pod -n webapp <POD_NAME>


# ============================================================
# ДИАГНОСТИКА ПРОБЛЕМ
# ============================================================

# Проверяем статус всех подов
kubectl get pods -n webapp
kubectl get pods -n kube-system -l app=traefik

# Проверяем подключение к MongoDB из пода веб-приложения
kubectl exec -n webapp -it <WEBAPP_POD_NAME> -- sh
# Внутри пода:
# nc -zv mongodb 27017
# exit

# Проверяем Service endpoints
kubectl get endpoints -n webapp
kubectl get endpoints -n kube-system traefik


# ============================================================
# ПЕРЕЗАПУСК КОМПОНЕНТОВ (при необходимости)
# ============================================================

# Перезапуск веб-приложения
kubectl rollout restart deployment -n webapp webapp

# Перезапуск MongoDB
kubectl rollout restart deployment -n webapp mongodb

# Перезапуск Traefik
kubectl rollout restart deployment -n kube-system traefik

# Проверяем статус rollout
kubectl rollout status deployment -n webapp webapp


# ============================================================
# МАСШТАБИРОВАНИЕ (опционально)
# ============================================================

# Увеличить количество реплик веб-приложения
kubectl scale deployment -n webapp webapp --replicas=3

# Увеличить количество реплик Traefik
kubectl scale deployment -n kube-system traefik --replicas=3

# Проверяем автомасштабирование
kubectl get hpa -n webapp


# ============================================================
# УДАЛЕНИЕ РАЗВЕРТЫВАНИЯ
# ============================================================

# Удалить все ресурсы
kubectl delete -f deploy/

# Или удалить namespace (удалит все ресурсы внутри)
kubectl delete namespace webapp

# Удалить Traefik компоненты
kubectl delete deployment -n kube-system traefik
kubectl delete service -n kube-system traefik
kubectl delete clusterrolebinding traefik
kubectl delete clusterrole traefik
kubectl delete serviceaccount -n kube-system traefik
kubectl delete ingressclass traefik


# ============================================================
# ПОЛЕЗНЫЕ КОМАНДЫ
# ============================================================

# Получаем все ресурсы во всех namespace
kubectl get all --all-namespaces

# Получаем информацию о кластере
kubectl cluster-info dump

# Проверяем использование ресурсов
kubectl top nodes
kubectl top pods -n webapp

# Экспорт манифестов (для бэкапа)
kubectl get all -n webapp -o yaml > backup-webapp.yaml

# Применение с dry-run (проверка без применения)
kubectl apply -f deploy/ --dry-run=client

# Валидация манифестов
kubectl apply -f deploy/ --validate=true --dry-run=server


# ============================================================
# ИТОГОВАЯ ПРОВЕРКА
# ============================================================

# После успешного развертывания выполняем:
kubectl get all -n webapp
kubectl get all -n kube-system -l app=traefik
kubectl get ingress -n webapp
kubectl get ingressclass

# Проверяем доступность:
# curl -H "Host: webapp.local" http://<NODE_IP>:30080

