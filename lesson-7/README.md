# Lesson 7 — EKS + ECR + Helm

Розгортання Django-застосунку на Amazon EKS за допомогою Terraform і Helm.

## Структура проєкту

```
lesson-7/
├── backend.tf                    # S3 backend для Terraform state
├── main.tf                       # Головний файл Terraform
├── outputs.tf                    # Outputs (endpoint, ECR URL тощо)
├── modules/
│   ├── eks/                      # Модуль EKS-кластера та Node Group
│   ├── ecr/                      # Модуль ECR-репозиторію
│   ├── vpc/                      # Модуль VPC, підмереж, маршрутів
│   └── s3-backend/               # Модуль S3 + DynamoDB для state
└── charts/django-app/            # Helm-чарт застосунку
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
        ├── deployment.yaml       # Deployment з resources та HPA
        ├── service.yaml          # LoadBalancer Service
        ├── configmap.yaml        # Змінні середовища (без секретів)
        ├── secret.yaml           # Kubernetes Secret (пароль БД)
        └── hpa.yaml              # HorizontalPodAutoscaler (CPU)
```

## Інфраструктура

| Ресурс | Деталі |
|---|---|
| Кластер EKS | `eks-cluster-demo`, регіон `us-east-1` |
| Node Group | `t3.small`, 1–2 вузли (ON_DEMAND) |
| ECR | `l7-ecr` — зберігає Docker-образ Django |
| VPC | `10.0.0.0/16`, 3 публічних + 3 приватних підмережі |
| Terraform state | S3 bucket + DynamoDB lock table |

## Розгортання

### 1. Terraform — створення інфраструктури

```bash
cd lesson-7

# Ініціалізація з S3 backend
terraform init

# Перегляд плану
terraform plan

# Застосування
terraform apply
```

### 2. Підключення до кластера

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name eks-cluster-demo
```

### 3. Збірка та завантаження Docker-образу в ECR

```bash
# Отримати URL репозиторію
ECR_URL=$(terraform output -raw ecr_repository_url)

# Авторизація в ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin $ECR_URL

# Збірка та push образу
docker build -t django-app ../doker-django-app/django/
docker tag django-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### 4. Helm — розгортання застосунку

```bash
cd charts

# Встановлення
helm install django-app ./django-app

# Або оновлення існуючого релізу
helm upgrade django-app ./django-app

# Перегляд статусу
helm status django-app
```

### 5. Перевірка ресурсів у кластері

```bash
# Pods
kubectl get pods

# Service (зовнішній IP LoadBalancer)
kubectl get svc

# ConfigMap та Secret
kubectl get configmap
kubectl get secret

# HPA
kubectl get hpa
```

## Helm-чарт

### Основні компоненти

- **Deployment** — запускає Django-контейнер з `resources` (requests/limits) для коректної роботи HPA
- **Service** — тип `LoadBalancer`, порт 80 → 8000
- **ConfigMap** — змінні середовища (без чутливих даних)
- **Secret** — пароль до бази даних (`POSTGRES_PASSWORD`)
- **HPA** — автомасштабування від 2 до 6 реплік при CPU > 70%

### Налаштування (values.yaml)

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"

autoscaling:
  minReplicas: 2
  maxReplicas: 6
  targetCPUUtilizationPercentage: 70
```

## Знищення інфраструктури

```bash
# Видалити Helm-реліз
helm uninstall django-app

# Знищити інфраструктуру
cd lesson-7
terraform destroy
```
