# Welcome to the AWS ECR Docker Lab

## What You'll Build

In this advanced hands-on lab you will master Docker image workflows using **Amazon Elastic Container Registry (ECR)** — the same workflow used in real-world CI/CD pipelines.

---

## Lab Architecture

```
┌─────────────────────────────────────────────────┐
│                  AWS Account                    │
│                                                 │
│         ┌────────────────────────┐              │
│         │   Amazon ECR           │              │
│         │   Repository:          │              │
│         │   my-lab-app           │              │
│         └──────────┬─────────────┘              │
└────────────────────│────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼       docker push       ▼
 ┌─────────────┐         ┌─────────────┐
 │   BUILDER   │ ──────► │  ECR Repo   │
 │  Container  │         │             │
 │             │ ◄────── │             │
 └─────────────┘  pull   └──────┬──────┘
                                │
                           docker pull
                                │
                                ▼
                        ┌─────────────┐
                        │  CONSUMER   │
                        │  Container  │
                        │  (runs img) │
                        └─────────────┘
```

---

## What You'll Do

| Chapter | Terminal Tab | Action |
|---------|-------------|--------|
| **1 — Build & Push** | Builder | Write Dockerfile → Build → Authenticate → Push to ECR |
| **2 — Pull & Run** | Consumer | Authenticate → Pull from ECR → Run container |

---

## Your Lab Environment

| Tab | Purpose |
|-----|---------|
| **Builder** | Chapter 1 workspace |
| **Consumer** | Chapter 2 workspace |
| **AWS Credentials** | View your AWS access keys and Account ID |

> **Tip:** Run `source /etc/profile` in any terminal after opening it to load all pre-configured environment variables (`ECR_REGISTRY`, `AWS_ACCOUNT_ID`, etc.).

---

## Key Concepts

**ECR (Elastic Container Registry)**
AWS's fully managed private Docker registry. Stores, versions, and secures your container images.

**Docker-in-Docker (DinD)**
Both containers run their own Docker daemons — completely isolated. The Consumer has no knowledge of what's in the Builder unless it pulls from ECR.

**Why This Matters**
This is the core pattern of every production CI/CD pipeline:
- **Builder** = CI runner (GitHub Actions, Jenkins, etc.)
- **ECR** = Centralised image registry
- **Consumer** = Production server / Kubernetes pod

---

Click **Next** to begin!
