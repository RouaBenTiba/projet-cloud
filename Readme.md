# ☁️ Déploiement d'une application Web sur AWS avec Terraform

## 📌 Présentation

Ce projet consiste à **déployer une application Web complète dans le Cloud AWS** en utilisant **Terraform** comme outil d'Infrastructure as Code (IaC).

L'objectif est de transformer une application développée localement en une application accessible depuis une infrastructure AWS composée de plusieurs services :

* 🌐 **VPC** pour le réseau
* 🔐 **Security Groups** pour la sécurité réseau
* 🖥️ **EC2** pour héberger le frontend
* ⚙️ **EC2** pour héberger le backend
* 🗄️ **Amazon RDS** pour la base de données
* 🏗️ **Terraform** pour automatiser la création et la configuration de l'infrastructure

L'ensemble de l'infrastructure est définie sous forme de code afin de pouvoir être créée, modifiée et supprimée de manière reproductible.

---

# 🎯 Objectifs du projet

Les principaux objectifs sont :

* comprendre les principes du Cloud Computing ;
* découvrir l'architecture AWS ;
* créer une infrastructure réseau avec une VPC ;
* déployer une application frontend et backend sur AWS ;
* utiliser Amazon RDS pour la base de données ;
* sécuriser les communications avec des Security Groups ;
* automatiser le déploiement avec Terraform ;
* comprendre le fonctionnement de l'Infrastructure as Code ;
* apprendre à gérer une infrastructure Cloud reproductible.

---

# 🏗️ Architecture Cloud

L'architecture mise en place peut être représentée ainsi :

```text
                         INTERNET
                             │
                             ▼
                    ┌─────────────────┐
                    │       AWS       │
                    │      VPC        │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
      ┌────────────────┐           ┌────────────────┐
      │ EC2 Frontend   │           │ EC2 Backend    │
      │                │           │                │
      │ Web Application│ ────────► │ REST API       │
      └────────────────┘           └───────┬────────┘
                                           │
                                           │
                                           ▼
                                  ┌─────────────────┐
                                  │   Amazon RDS    │
                                  │   Database      │
                                  └─────────────────┘
```

### Flux de communication

```text
Utilisateur
     │
     ▼
Frontend EC2
     │
     │ HTTP / API
     ▼
Backend EC2
     │
     │ Database connection
     ▼
Amazon RDS
```

Le frontend ne communique donc pas directement avec la base de données.

Le backend joue le rôle d'intermédiaire entre l'application frontend et la base de données.

---

# ☁️ Services AWS utilisés

| Service             | Utilisation                           |
| ------------------- | ------------------------------------- |
| **Amazon VPC**      | Création du réseau virtuel            |
| **Amazon EC2**      | Hébergement du frontend et du backend |
| **Amazon RDS**      | Hébergement de la base de données     |
| **Security Groups** | Contrôle du trafic réseau             |
| **AWS IAM**         | Gestion des permissions AWS           |
| **Terraform**       | Provisionnement de l'infrastructure   |

---

# 🏗️ Pourquoi Terraform ?

Terraform permet de décrire l'infrastructure Cloud sous forme de code.

Au lieu de créer manuellement :

* la VPC ;
* les instances EC2 ;
* les règles réseau ;
* la base RDS ;
* les différentes configurations ;

tout est défini dans des fichiers `.tf`.

Le déploiement peut ensuite être effectué avec :

```bash
terraform init
terraform plan
terraform apply
```

Cela permet d'avoir une infrastructure :

* reproductible ;
* versionnée avec Git ;
* automatisable ;
* plus facile à maintenir.

---

# 📂 Structure du projet

```text
projet-cloud/
│
├── terraform/
│   │
│   ├── backend.tf
│   ├── frontend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── rds.tf
│   ├── security_groups.tf
│   ├── user_data_backend.sh
│   ├── user_data_frontend.sh
│   ├── variables.tf
│   ├── vpc.tf
│   └── .gitignore
│
└── README.md
```

---

# 📄 Rôle des fichiers Terraform

## `main.tf`

Fichier principal de configuration Terraform.

Il permet d'organiser les différents composants de l'infrastructure AWS.

---

## `vpc.tf`

Ce fichier définit l'infrastructure réseau AWS.

Il contient notamment les ressources nécessaires à la création de la :

* VPC ;
* subnets ;
* Internet Gateway ;
* route tables ;
* routes.

La VPC permet d'isoler l'infrastructure du projet dans un réseau virtuel AWS.

---

## `security_groups.tf`

Les Security Groups permettent de contrôler les communications entre les différentes ressources.

Le principe est de n'autoriser que les ports nécessaires.

Par exemple :

```text
Internet
   │
   │ HTTP / HTTPS
   ▼
Frontend
   │
   │ API
   ▼
Backend
   │
   │ PostgreSQL / MySQL
   ▼
RDS
```

Cette séparation permet de limiter les accès directs aux ressources internes.

---

## `frontend.tf`

Ce fichier définit les ressources nécessaires à l'hébergement du frontend sur AWS.

L'instance EC2 est configurée pour pouvoir exécuter et servir l'application frontend.

---

## `backend.tf`

Ce fichier définit les ressources nécessaires à l'hébergement du backend.

Le backend expose l'API utilisée par le frontend.

---

## `rds.tf`

Ce fichier définit la base de données Amazon RDS.

RDS permet de disposer d'une base de données managée par AWS plutôt que d'installer et administrer manuellement un serveur de base de données sur EC2.

---

## `variables.tf`

Ce fichier contient les variables utilisées par Terraform.

Cela permet d'éviter de placer directement toutes les valeurs dans les fichiers de ressources.

Exemples de paramètres pouvant être configurés :

```text
AWS Region
VPC CIDR
Subnet CIDR
Instance type
Database name
Database username
Database password
```

---

## `outputs.tf`

Ce fichier définit les informations importantes affichées après le déploiement.

Par exemple :

```text
Frontend public IP
Backend public IP
RDS endpoint
```

Ces informations permettent ensuite de récupérer facilement les endpoints nécessaires pour accéder à l'application.

---

# 🚀 Déploiement étape par étape

## 1. Prérequis

Avant de commencer, installer :

* AWS CLI
* Terraform
* Git

Et disposer d'un compte AWS avec les permissions nécessaires pour créer les ressources utilisées.

---

# 2. Configurer AWS CLI

Après installation de l'AWS CLI :

```bash
aws configure
```

AWS demande alors :

```text
AWS Access Key ID
AWS Secret Access Key
Default region
Output format
```

Il est ensuite possible de vérifier l'identité AWS utilisée :

```bash
aws sts get-caller-identity
```

Cette commande permet de vérifier que les credentials configurés correspondent bien au compte et à l'identité AWS attendus.

---

# 3. Récupérer le projet

Cloner le repository :

```bash
git clone <repository-url>
```

Puis entrer dans le dossier Terraform :

```bash
cd projet-cloud/terraform
```

---

# 4. Initialiser Terraform

La première commande à exécuter est :

```bash
terraform init
```

Cette commande permet notamment de :

* télécharger le provider AWS ;
* initialiser le répertoire Terraform ;
* préparer le projet pour le déploiement.

---

# 5. Vérifier la configuration

Avant de créer l'infrastructure :

```bash
terraform validate
```

Cette commande vérifie que la configuration Terraform est syntaxiquement correcte.

Puis :

```bash
terraform fmt
```

permet de formater les fichiers Terraform.

---

# 6. Visualiser le plan

Avant de créer les ressources AWS :

```bash
terraform plan
```

Terraform affiche les ressources qui seront créées, modifiées ou supprimées.

Exemple :

```text
Plan: X to add, 0 to change, 0 to destroy.
```

Cette étape permet de vérifier l'infrastructure avant son déploiement.

---

# 7. Déployer l'infrastructure

Une fois le plan vérifié :

```bash
terraform apply
```

Terraform demande une confirmation :

```text
Do you want to perform these actions?
```

Entrer :

```text
yes
```

Terraform crée alors automatiquement les ressources AWS définies dans les fichiers `.tf`.

---

# 🔄 Ordre logique du déploiement

Le déploiement peut être compris de cette manière :

```text
1. VPC
   ↓
2. Subnets / Routing
   ↓
3. Security Groups
   ↓
4. EC2 Frontend
   ↓
5. EC2 Backend
   ↓
6. RDS Database
   ↓
7. Configuration des applications
   ↓
8. Application accessible depuis Internet
```

Terraform détermine automatiquement les dépendances entre les ressources.

---

# ⚙️ Configuration automatique avec User Data

Le projet utilise également des scripts :

```text
user_data_frontend.sh
user_data_backend.sh
```

Ces scripts permettent d'automatiser la configuration des instances EC2 lors de leur création.

L'objectif est d'éviter de devoir se connecter manuellement à chaque instance pour effectuer toutes les étapes d'installation.

Le principe est :

```text
Terraform
    │
    ▼
Création EC2
    │
    ▼
User Data
    │
    ├── Installation des dépendances
    ├── Configuration de l'application
    └── Démarrage du service
```

---

# 🖥️ Déploiement du Frontend

Le frontend est installé sur une instance EC2.

Le script :

```text
user_data_frontend.sh
```

permet d'automatiser sa configuration.

Après le déploiement, l'adresse IP publique ou l'endpoint fourni par Terraform permet d'accéder à l'application.

---

# ⚙️ Déploiement du Backend

Le backend est également hébergé sur EC2.

Le script :

```text
user_data_backend.sh
```

permet de configurer automatiquement l'environnement nécessaire au backend.

Le backend expose ensuite les API utilisées par le frontend.

---

# 🗄️ Déploiement de la base de données

La base de données est déployée avec Amazon RDS.

```text
Backend EC2
     │
     │ Database connection
     ▼
Amazon RDS
```

L'avantage de RDS est qu'AWS prend en charge une partie de l'administration de l'infrastructure de base de données.

---

# 🔐 Sécurité réseau

Les Security Groups sont utilisés pour contrôler les communications.

Le principe appliqué est :

```text
                INTERNET
                    │
             HTTP / HTTPS
                    │
                    ▼
              ┌──────────┐
              │ FRONTEND │
              └────┬─────┘
                   │
                API
                   │
                   ▼
              ┌──────────┐
              │ BACKEND  │
              └────┬─────┘
                   │
              DB PORT
                   │
                   ▼
                ┌─────┐
                │ RDS │
                └─────┘
```

L'objectif est de ne pas exposer inutilement la base de données à Internet.

---

# 📤 Récupérer les informations du déploiement

Après :

```bash
terraform apply
```

les outputs peuvent être affichés avec :

```bash
terraform output
```

Pour obtenir une valeur spécifique :

```bash
terraform output <output_name>
```

Ces informations peuvent notamment permettre de récupérer :

* l'adresse du frontend ;
* l'adresse du backend ;
* l'endpoint de la base de données.

---

# 🧪 Vérification du déploiement

Après le déploiement, plusieurs vérifications sont effectuées.

### Frontend

Vérifier que l'application frontend est accessible depuis un navigateur.

### Backend

Tester les endpoints de l'API.

### Database

Vérifier que le backend peut communiquer avec RDS.

### Architecture complète

```text
Browser
   │
   ▼
Frontend
   │
   ▼
Backend API
   │
   ▼
RDS
```

---

# 🧹 Suppression de l'infrastructure

Terraform permet également de supprimer les ressources créées :

```bash
terraform destroy
```

Terraform affiche les ressources qui seront supprimées et demande une confirmation.

```text
yes
```

Cette fonctionnalité est particulièrement utile pour un projet Cloud d'apprentissage afin d'éviter de laisser des ressources AWS actives inutilement.

---

# 🔒 Bonnes pratiques de sécurité

Les informations sensibles ne doivent jamais être publiées dans GitHub.

Ne jamais versionner :

```text
AWS Access Key
AWS Secret Key
Database Password
Private Keys
.pem files
.env files
Terraform state containing secrets
```

Le `.gitignore` doit notamment protéger les fichiers sensibles.

Exemple :

```gitignore
.terraform/
*.tfstate
*.tfstate.*
.env
*.pem
```

Les credentials AWS doivent être configurés localement ou via un mécanisme sécurisé adapté à l'environnement de déploiement.

---

# 🧠 Concepts Cloud et DevOps mis en pratique

Ce projet permet de mettre en pratique :

### ☁️ Cloud Computing

* AWS
* EC2
* RDS
* VPC
* Security Groups

### 🏗️ Infrastructure as Code

* Terraform
* Variables
* Outputs
* Dependencies
* `terraform plan`
* `terraform apply`
* `terraform destroy`

### 🌐 Networking

* VPC
* Subnets
* Routing
* Internet Gateway
* Security Groups
* Communication frontend/backend/database

### 🖥️ Administration système

* EC2
* Linux
* User Data
* Installation automatique des dépendances
* Configuration des services

### 🔐 Sécurité

* Security Groups
* IAM
* Gestion des credentials
* Protection des secrets

---

# 📚 Commandes Terraform utilisées

```bash
# Initialiser Terraform
terraform init

# Formater le code
terraform fmt

# Vérifier la configuration
terraform validate

# Voir les changements
terraform plan

# Déployer
terraform apply

# Voir les outputs
terraform output

# Détruire l'infrastructure
terraform destroy
```

---

# 📊 Résultat final

À la fin du projet, l'application locale est transformée en une application déployée dans le Cloud :

```text
                    AWS CLOUD
┌───────────────────────────────────────────────┐
│                                               │
│                    VPC                        │
│                                               │
│     ┌──────────────┐     ┌──────────────┐    │
│     │ EC2          │     │ EC2          │    │
│     │ Frontend     │────►│ Backend      │    │
│     └──────────────┘     └──────┬───────┘    │
│                                  │            │
│                                  ▼            │
│                           ┌──────────────┐    │
│                           │     RDS      │    │
│                           │  Database    │    │
│                           └──────────────┘    │
│                                               │
└───────────────────────────────────────────────┘
```

L'infrastructure peut être recréée à partir du code Terraform, ce qui illustre le principe d'**Infrastructure as Code**.

---

# 🚀 Améliorations possibles

Pour faire évoluer le projet vers une architecture plus proche d'un environnement professionnel, plusieurs améliorations sont possibles :

* utiliser un **Application Load Balancer** ;
* mettre le frontend et le backend dans des subnets adaptés ;
* placer RDS dans des subnets privés ;
* utiliser **IAM Roles** plutôt que des credentials statiques ;
* utiliser **AWS Secrets Manager** pour les secrets ;
* ajouter **CloudWatch** pour le monitoring ;
* utiliser **Auto Scaling** ;
* ajouter HTTPS avec **AWS Certificate Manager** ;
* mettre en place un pipeline **CI/CD avec GitHub Actions** ;
* containeriser les applications avec **Docker** ;
* utiliser **Amazon ECR** et **ECS** pour le déploiement des conteneurs.

---

# 🎓 Conclusion

Ce projet m'a permis de mettre en pratique le déploiement d'une application complète dans le Cloud AWS et de comprendre comment automatiser une infrastructure avec Terraform.

Les principaux concepts abordés sont :

**AWS + Terraform + VPC + EC2 + RDS + Security Groups + Infrastructure as Code + User Data**

Le projet constitue une première mise en pratique des principes **Cloud et DevOps**, avec une infrastructure entièrement définie sous forme de code.
