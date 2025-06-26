# ☁️ Kimai Cloud Migration Project – DevOps Internship

This project demonstrates the **end-to-end cloud migration** of the [Kimai](https://github.com/kevinpapst/kimai2) open-source time-tracking application to AWS Cloud using **DevOps principles** like Infrastructure as Code (Terraform), CI/CD (Jenkins), Security, Monitoring, and AWS best practices.

---

## 📌 Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Phase-wise Breakdown](#phase-wise-breakdown)
- [Monitoring & Alerting](#monitoring--alerting)
- [Security Measures](#security-measures)
- [Cost Optimization](#cost-optimization)

---

## 🚀 Project Overview

- **Objective**: Migrate Kimai from GitHub to a secure, scalable, monitored AWS infrastructure using DevOps tools.
- **Approach**: Build a modular and production-ready setup with automation, observability, and cost-efficiency.

---

## 🧰 Tech Stack

| Category              | Tools Used                              |
|-----------------------|------------------------------------------|
| Cloud Provider        | AWS EC2, S3, IAM, CloudWatch             |
| Infrastructure as Code| Terraform                                |
| Containerization      | Docker, Docker Compose                   |
| CI/CD                 | Jenkins                                  |
| Monitoring & Alerts   | Prometheus, Grafana, CloudWatch          |
| Logging               | CloudWatch Agent                         |
| Security              | Security Groups, IAM, Bastion Host       |
| OS                    | Amazon Linux 2023                        |

---

## 🏗️ Architecture

![Kimai Cloud Architecture](docs/kimai-architecture.png)

- **Bastion Host** in public subnet to securely SSH into private EC2
- **Kimai App** runs in a private EC2 using Docker
- **Monitoring tools** (Prometheus, Grafana) installed on the same EC2
- **Jenkins** is used for CI/CD (auto-pulls from GitHub and deploys)
- All logs sent to **CloudWatch Logs**
- Alerts and dashboards live in **Grafana**

---

## 📚 Phase-wise Breakdown

### Phase 1: Design
- High-Level and Low-Level Design
- MNC-style architecture aligned with AWS best practices

### Phase 2: Infrastructure as Code
- Used Terraform to provision:
  - VPC, Subnets, Route Tables
  - Security Groups
  - IAM Role & Instance Profile
  - EC2 instances (Bastion + Kimai Server)
  - Outputs (Public/Private IPs)

### Phase 3: CI/CD & Deployment
- Jenkins installed on Kimai server
- Pipeline to pull `kimai-app` from GitHub and deploy via `docker-compose`

### Phase 4: Security
- Bastion access only for SSH (Kimai EC2 has no open SSH)
- Security Groups restrict traffic by ports and IPs
- IAM Role allows CloudWatch agent access securely

### Phase 5: Monitoring & Logging
- **System metrics**: Prometheus + Node Exporter
- **App metrics**: Grafana Dashboard (CPU, RAM, Disk)
- **Logs**: CloudWatch agent sends `/var/log` to CloudWatch Logs
- **Alerts**: Grafana notifies high CPU, low disk, app down

### Phase 6: Documentation & Assessment
- HLD and LLD created
- AWS Well-Architected reviewed
- README and Final Report included

---

## 📊 Monitoring & Alerting

- **Grafana Dashboard** includes:
  - CPU usage
  - Memory usage
  - Disk availability
- **Prometheus Rules**:
  - High CPU (>70% for 1 min)
  - Low Disk (<20%)
  - App health checks (optional with Blackbox)

---

## 🔐 Security Measures

- IAM Role scoped to CloudWatch only
- Kimai server only accessible through Bastion
- Dockerized app for safe and isolated deployment
- Port access restricted by Security Groups (Free Tier-optimized)

---

## 💸 Cost Optimization

- **Free Tier** services only:
  - 1 EC2 (t2.micro) for Kimai, Jenkins, Monitoring
  - 1 Bastion EC2 (t2.micro)
- EC2 stopped when not in use to stay within 750 hours/month
- No paid services (ELB, RDS, etc.) used

---
