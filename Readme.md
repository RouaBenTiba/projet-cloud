# ☁️ Projet Cloud AWS — Déploiement avec Terraform

## 📌 Présentation

Ce projet consiste à **déployer une application Web complète sur Amazon Web Services (AWS)** en utilisant **Terraform** comme outil d'**Infrastructure as Code (IaC)**.

L'infrastructure a été conçue pour séparer les ressources publiques et privées, sécuriser les communications entre les différentes couches de l'application et assurer la **scalabilité automatique du backend**.

### Architecture mise en place

* 🌐 **AWS VPC**
* 🔀 **Sous-réseaux publics et privés**
* ⚖️ **Application Load Balancer (ALB)**
* 🖥️ **EC2 pour le frontend**
* ⚙️ **Auto Scaling Group pour le backend**
* 🗄️ **Amazon RDS MySQL**
* 🌍 **NAT Gateway**
* 🔐 **Security Groups**
* 🏗️ **Terraform**
* 🚀 **User Data** pour automatiser la configuration des instances

---

# 🎯 Objectifs

Les objectifs de ce projet sont de :

* déployer une application Web dans le Cloud AWS ;
* mettre en pratique l'**Infrastructure as Code** avec Terraform ;
* créer une architecture réseau avec une VPC ;
* séparer les ressources publiques et privées ;
* déployer un frontend sur EC2 ;
* déployer le backend avec un **Auto Scaling Group** ;
* utiliser un **Application Load Balancer** pour distribuer le trafic ;
* héberger la base de données avec Amazon RDS ;
* sécuriser les communications grâce aux Security Groups ;
* permettre aux ressources privées d'accéder à Internet via un NAT Gateway ;
* automatiser l'installation et la configuration avec User Data.

---

# 🏗️ Architecture AWS

L'architecture globale du projet est la suivante :

```text
                                INTERNET
                                    │
                                    ▼
                         ┌────────────────────┐
                         │   Frontend EC2     │
                         │   Public Subnet A  │
                         └─────────┬──────────┘
                                   │
                                   │ API
                                   ▼
                         ┌────────────────────┐
                         │ Application Load   │
                         │ Balancer (ALB)     │
                         │ Port 80            │
                         └─────────┬──────────┘
                                   │
                             Target Group
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
                    ▼                             ▼
          ┌──────────────────┐           ┌──────────────────┐
          │ Backend EC2 #1   │           │ Backend EC2 #2   │
          │ Private Subnet A │           │ Private Subnet B │
          └────────┬─────────┘           └────────┬─────────┘
                   │                              │
                   └──────────────┬───────────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │    Amazon RDS    │
                         │      MySQL       │
                         │   Private Subnet │
                         └──────────────────┘


                 ┌─────────────────────────────────────┐
                 │              AWS VPC                 │
                 │                                     │
                 │  Public Subnet A   Public Subnet B  │
                 │                                     │
                 │  Private Subnet A  Private Subnet B│
                 │                                     │
                 │          NAT Gateway                │
                 └─────────────────────────────────────┘
```

---

# 🔄 Flux de communication

Le fonctionnement principal est :

```text
Utilisateur
     │
     ▼
Frontend EC2
     │
     │ Requête API
     ▼
Application Load Balancer
     │
     ▼
Auto Scaling Group
     │
     ├── Backend EC2
     │
     └── Backend EC2
             │
             ▼
        Amazon RDS
```

Le frontend est hébergé sur une instance EC2 située dans un **subnet public**.

Le backend est déployé dans des **subnets privés** et n'est pas directement accessible depuis Internet.

L'ALB reçoit les requêtes et les transmet aux instances backend du Target Group.

---

# ☁️ Services AWS utilisés

| Service                       | Rôle                                                   |
| ----------------------------- | ------------------------------------------------------ |
| **Amazon VPC**                | Création du réseau virtuel                             |
| **Public Subnets**            | Hébergement des ressources accessibles depuis Internet |
| **Private Subnets**           | Hébergement du backend et de RDS                       |
| **Internet Gateway**          | Accès Internet des ressources publiques                |
| **NAT Gateway**               | Accès Internet sortant des ressources privées          |
| **Application Load Balancer** | Distribution du trafic vers le backend                 |
| **EC2**                       | Hébergement du frontend et du backend                  |
| **Auto Scaling Group**        | Gestion automatique du nombre d'instances backend      |
| **Amazon RDS**                | Base de données MySQL managée                          |
| **Security Groups**           | Contrôle du trafic réseau                              |
| **Terraform**                 | Provisionnement de l'infrastructure                    |

---

# 🌐 Architecture réseau

La VPC utilise le bloc CIDR :

```text
10.0.0.0/16
```

Elle est divisée en quatre sous-réseaux.

### Subnets publics

```text
Public A → 10.0.1.0/24
Public B → 10.0.2.0/24
```

Ils sont associés à la route Internet via l'**Internet Gateway**.

Le frontend est déployé dans le subnet public A.

L'ALB est réparti sur les deux subnets publics afin de fonctionner dans deux Availability Zones.

### Subnets privés

```text
Private A → 10.0.3.0/24
Private B → 10.0.4.0/24
```

Ils sont utilisés pour :

* les instances backend ;
* la base de données RDS.

Ces ressources ne possèdent pas d'adresse IP publique.

---

# 🌍 Internet Gateway

L'Internet Gateway permet aux ressources situées dans les subnets publics de communiquer avec Internet.

Le routage public est configuré avec :

```text
0.0.0.0/0 → Internet Gateway
```

---

# 🔀 NAT Gateway

Les ressources situées dans les subnets privés doivent parfois accéder à Internet pour effectuer des opérations sortantes.

Par exemple :

```text
apt update
git clone
installation de packages
```

Le **NAT Gateway** permet ces connexions sortantes sans donner d'adresse IP publique aux instances privées.

Architecture :

```text
Backend privé
     │
     ▼
Route Table privée
     │
     ▼
NAT Gateway
     │
     ▼
Internet Gateway
     │
     ▼
Internet
```

Le NAT Gateway est placé dans le subnet public A.

Une Elastic IP lui est associée.

---

# ⚖️ Application Load Balancer

Le projet utilise un **Application Load Balancer (ALB)**.

L'ALB :

* est accessible depuis Internet ;
* écoute sur le port `80` ;
* distribue les requêtes vers le backend ;
* utilise un Target Group ;
* effectue des health checks.

Configuration principale :

```text
Protocol : HTTP
Port     : 80
```

Le Target Group utilise le port de l'application backend :

```text
Port : 3000
```

---

# ❤️ Health Check

L'ALB vérifie automatiquement l'état des instances backend grâce à l'endpoint :

```text
/health
```

Configuration :

```text
Interval : 30 secondes
Timeout  : 5 secondes
Healthy threshold   : 2
Unhealthy threshold : 2
```

Une instance backend considérée comme indisponible peut ainsi être retirée du trafic.

---

# 📈 Auto Scaling

Le backend est déployé avec un **Auto Scaling Group**.

Configuration :

```text
Minimum instances : 1
Desired instances : 2
Maximum instances : 4
```

Cela signifie que l'infrastructure démarre normalement avec **2 instances backend**, mais peut adapter automatiquement le nombre d'instances entre **1 et 4**.

---

## 🎯 Scaling basé sur le CPU

Une politique de **Target Tracking Scaling** est configurée.

La cible est :

```text
CPU moyen : 70 %
```

Lorsque la charge augmente, AWS peut lancer de nouvelles instances backend.

Lorsque la charge diminue, le nombre d'instances peut être réduit.

```text
             Charge faible
                  │
                  ▼
              1 instance
                  │
                  │ CPU ↑
                  ▼
              2 instances
                  │
                  │ CPU ↑
                  ▼
              3 instances
                  │
                  │ CPU ↑
                  ▼
              4 instances
                  │
             Maximum atteint
```

---

# 🚀 Launch Template

Le backend utilise un **Launch Template** pour définir le modèle des instances créées par l'Auto Scaling Group.

Il définit notamment :

* l'AMI Ubuntu ;
* le type d'instance ;
* la clé SSH ;
* le Security Group ;
* le User Data ;
* la configuration réseau.

L'Auto Scaling Group utilise ensuite ce modèle pour créer les instances backend.

---

# 🖥️ Frontend

Le frontend est déployé sur une instance :

```text
EC2
```

située dans :

```text
Public Subnet A
```

L'instance reçoit une adresse IP publique.

Le script `user_data_frontend.sh` automatise :

1. la mise à jour du système ;
2. l'installation de Node.js ;
3. l'installation d'Angular CLI ;
4. le clonage du repository ;
5. l'installation des dépendances ;
6. le build de l'application ;
7. l'installation et la configuration de Nginx ;
8. le démarrage du serveur Web.

Le frontend est ensuite servi par **Nginx**.

---

# ⚙️ Backend

Le backend est déployé automatiquement sur les instances EC2 créées par l'Auto Scaling Group.

Le script :

```text
user_data_backend.sh
```

effectue notamment :

1. la mise à jour du système ;
2. l'installation de Node.js ;
3. l'installation de Git ;
4. le clonage du repository ;
5. la création du fichier `.env` ;
6. l'installation des dépendances ;
7. l'installation de PM2 ;
8. le démarrage du backend.

Le backend écoute sur :

```text
Port 3000
```

---

# 🗄️ Amazon RDS

La base de données utilise :

```text
Amazon RDS
MySQL 8.0
```

Configuration :

```text
Database : appdb
Instance : db.t3.micro
Storage  : 20 GB
```

RDS est placé dans les subnets privés :

```text
Private A
Private B
```

et possède :

```text
publicly_accessible = false
```

La base de données n'est donc pas directement accessible depuis Internet.

---

# 🔐 Security Groups

Plusieurs Security Groups permettent de contrôler les communications.

## ALB

Le Security Group de l'ALB autorise :

```text
Internet → ALB
Port 80
```

---

## Backend

Le Security Group du backend autorise uniquement le trafic provenant du Security Group de l'ALB sur :

```text
Port 3000
```

Ainsi, le backend n'est pas directement exposé à Internet.

```text
Internet
    │
    X
    │
    ▼
Backend

ALB
 │
 │ Port 3000
 ▼
Backend
```

---

## RDS

Le Security Group RDS autorise uniquement les connexions provenant du Security Group backend sur :

```text
Port 3306
```

Architecture de sécurité :

```text
Internet
   │
   ▼
 ALB : 80
   │
   ▼
Backend : 3000
   │
   ▼
RDS : 3306
```

---

# 🏗️ Infrastructure as Code avec Terraform

L'ensemble de l'infrastructure est définie avec Terraform.

Cela permet de créer l'infrastructure AWS à partir du code plutôt que de créer manuellement chaque ressource depuis la console AWS.

Les principaux avantages sont :

* reproductibilité ;
* automatisation ;
* versionnement avec Git ;
* maintenance simplifiée ;
* traçabilité des changements.

---

# 📂 Structure du projet

```text
projet-cloud/
│
├── terraform/
│   │
│   ├── .gitignore
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
│   └── terraform.tfvars
│
└── README.md
```

---

# 📄 Description des fichiers

| Fichier                 | Rôle                                                                     |
| ----------------------- | ------------------------------------------------------------------------ |
| `main.tf`               | Provider AWS, AMI Ubuntu et clé SSH                                      |
| `vpc.tf`                | VPC, subnets, Internet Gateway, NAT Gateway et routing                   |
| `frontend.tf`           | Instance EC2 frontend                                                    |
| `backend.tf`            | ALB, Target Group, Launch Template, Auto Scaling Group et scaling policy |
| `rds.tf`                | Amazon RDS MySQL et DB Subnet Group                                      |
| `security_groups.tf`    | Security Groups ALB, frontend, backend et RDS                            |
| `variables.tf`          | Variables Terraform                                                      |
| `outputs.tf`            | Outputs du déploiement                                                   |
| `user_data_frontend.sh` | Installation et configuration automatique du frontend                    |
| `user_data_backend.sh`  | Installation et configuration automatique du backend                     |
| `.gitignore`            | Protection des fichiers qui ne doivent pas être versionnés               |

---

# ⚙️ Prérequis

Avant de commencer, installer :

* **AWS CLI**
* **Terraform**
* **Git**
* **Node.js** si nécessaire pour le développement local

Il faut également disposer d'un compte AWS avec les permissions nécessaires pour créer les ressources utilisées.

---

# 🔑 Configuration AWS

Configurer les credentials AWS :

```bash
aws configure
```

Puis vérifier l'identité AWS :

```bash
aws sts get-caller-identity
```

---

# 🚀 Déploiement avec Terraform

Entrer dans le dossier Terraform :

```bash
cd terraform
```

## 1. Initialiser Terraform

```bash
terraform init
```

---

## 2. Formater le code

```bash
terraform fmt
```

---

## 3. Vérifier la configuration

```bash
terraform validate
```

---

## 4. Prévisualiser les ressources

```bash
terraform plan
```

Cette commande permet de vérifier les ressources qui seront créées avant de lancer le déploiement.

---

## 5. Déployer l'infrastructure

```bash
terraform apply
```

Confirmer avec :

```text
yes
```

Terraform va alors créer automatiquement l'infrastructure AWS.

---

# 📤 Récupérer les informations du déploiement

Après le déploiement :

```bash
terraform output
```

Les outputs permettent notamment de récupérer :

* DNS de l'ALB ;
* IP publique du frontend ;
* URL du frontend ;
* endpoint RDS ;
* commande SSH.

---

# 🔍 Vérification du déploiement

Après le déploiement, vérifier :

### Frontend

Accéder à l'adresse IP publique du frontend.

### ALB

Accéder au DNS de l'Application Load Balancer.

### Backend

Vérifier que le Target Group indique les instances comme :

```text
Healthy
```

### Auto Scaling

Vérifier dans AWS que l'Auto Scaling Group contient le nombre attendu d'instances.

### RDS

Vérifier que la base de données est disponible et accessible uniquement depuis le backend.

---

# 🧹 Suppression de l'infrastructure

Pour supprimer les ressources AWS créées par Terraform :

```bash
terraform destroy
```

Puis confirmer :

```text
yes
```

Cette commande permet de supprimer l'infrastructure afin d'éviter de conserver des ressources AWS inutilisées.

---

# 🔐 Sécurité

Les informations sensibles ne doivent jamais être publiées sur GitHub.

Ne jamais versionner :

```text
terraform.tfvars
*.tfstate
*.tfstate.*
.env
*.pem
AWS credentials
Database passwords
Private keys
```

Le mot de passe RDS doit être fourni de manière sécurisée.

Le projet utilise également des Security Groups afin de limiter les communications :

```text
Internet → ALB : 80
ALB → Backend : 3000
Backend → RDS : 3306
```

---

# ⚠️ Amélioration de sécurité importante

Pour un environnement de production, plusieurs améliorations seraient recommandées :

* utiliser **AWS Secrets Manager** pour les credentials RDS ;
* utiliser des **IAM Roles** plutôt que des credentials statiques ;
* limiter SSH à une IP spécifique ;
* utiliser HTTPS avec **AWS Certificate Manager** ;
* mettre en place un NAT Gateway par Availability Zone pour une meilleure résilience ;
* ajouter **CloudWatch** pour le monitoring ;
* utiliser un Load Balancer avec HTTPS ;
* automatiser le déploiement avec un pipeline CI/CD.

---

# 📊 Architecture finale

```text
                         ┌───────────────┐
                         │   INTERNET    │
                         └───────┬───────┘
                                 │
                     ┌───────────┴───────────┐
                     │                       │
                     ▼                       ▼
             ┌──────────────┐        ┌──────────────┐
             │ Frontend EC2 │        │     ALB      │
             │ Public A     │        │ Public A/B   │
             └──────────────┘        └──────┬───────┘
                                            │
                                     Target Group
                                            │
                              ┌─────────────┴─────────────┐
                              │                           │
                              ▼                           ▼
                     ┌────────────────┐         ┌────────────────┐
                     │ Backend EC2    │         │ Backend EC2    │
                     │ Private A      │         │ Private B      │
                     └───────┬────────┘         └───────┬────────┘
                             │                           │
                             └─────────────┬─────────────┘
                                           │
                                           ▼
                                  ┌─────────────────┐
                                  │   Amazon RDS    │
                                  │    MySQL 8.0    │
                                  │   Private A/B   │
                                  └─────────────────┘

                         PRIVATE SUBNETS
                                │
                                ▼
                         NAT Gateway
                                │
                                ▼
                            INTERNET
```

---

# 🧠 Compétences développées

Ce projet m'a permis de mettre en pratique :

### ☁️ Cloud

* AWS
* EC2
* RDS
* VPC
* ALB
* Auto Scaling
* NAT Gateway

### 🏗️ DevOps

* Terraform
* Infrastructure as Code
* User Data
* automatisation du déploiement
* gestion des environnements

### 🌐 Networking

* VPC
* Public Subnets
* Private Subnets
* Route Tables
* Internet Gateway
* NAT Gateway
* Security Groups
* Load Balancing

### 🔐 Sécurité

* isolation des ressources privées ;
* contrôle des ports ;
* Security Groups ;
* protection de RDS ;
* gestion des credentials.

---

# 🚀 Améliorations futures

Les prochaines évolutions possibles du projet sont :

* 🔐 HTTPS avec AWS Certificate Manager ;
* 📊 monitoring avec CloudWatch ;
* 🔄 CI/CD avec GitHub Actions ;
* 🐳 containerisation avec Docker ;
* 📦 Amazon ECR ;
* 🚢 migration vers ECS ou EKS ;
* 🔑 AWS Secrets Manager ;
* 🛡️ amélioration de la stratégie IAM ;
* 🌍 haute disponibilité du NAT Gateway ;
* 📈 amélioration des politiques Auto Scaling.

---

# 🎓 Conclusion

Ce projet constitue une mise en pratique complète du **Cloud Computing et de l'Infrastructure as Code**.

L'application est déployée sur une architecture AWS comprenant :

**VPC + Public/Private Subnets + Internet Gateway + NAT Gateway + ALB + EC2 + Auto Scaling + RDS + Security Groups + Terraform**

L'utilisation de Terraform permet de définir l'ensemble de l'infrastructure sous forme de code et de la déployer de manière reproductible.

Ce projet m'a permis de renforcer mes compétences en **AWS, Terraform, Cloud, Networking, Infrastructure as Code et DevOps**.
