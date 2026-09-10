An enterprise-grade DevSecOps pipeline and infrastructure-as-code (IaC) deployment for a secure Python FastAPI microservice. The project provisions AWS infrastructure using Terraform and automates continuous integration (CI) with strict vulnerability scanning through GitHub Actions, Amazon ECR, and a lightweight K3s Kubernetes cluster managed securely via AWS Systems Manager (SSM).

---

## Architecture Overview

Traffic flows from the internet through a Traefik Ingress controller directly into a K3s Kubernetes cluster hosted on an Amazon EC2 instance. The pipeline enforces strict security gates, rejecting any container build that fails the automated vulnerability scan.

```text
[ Developer ] 
      │ (git push)
      ▼
[ GitHub Actions ] ──(Trivy Vulnerability Scan)──┐
      │                                          │
      ├──► [ Amazon ECR ] (Private Vault) ◄──────┤
      │                                          │
      └──► [ AWS Systems Manager (SSM) ]         │
                 │ (Secure Shell access)         │
                 ▼                               │
          [ Amazon EC2 ]                         │
                 │                               │
                 ▼                               │
          [ K3s Kubernetes Cluster ]             │
                 │                               │
                 ▼                               │
          [ Traefik Ingress (Port 80) ]          │
                 │ (Traffic Routing)             │
                 ▼                               │
          [ Pod: DevSecOps API ] ◄──(Image Pull)─┘
```

---

## Tech Stack

* **Application:** Python 3.12, FastAPI, Uvicorn
* **Containerization:** Docker (Hardened, Non-root `appuser`)
* **Infrastructure as Code (IaC):** Terraform
* **Cloud Platform (AWS):** EC2, ECR, IAM, Systems Manager (SSM)
* **Container Orchestration:** K3s (Lightweight Kubernetes), Traefik Ingress
* **CI/CD & Security:** GitHub Actions, Aqua Trivy

---

## Key Cloud Engineering Features

* **Shift-Left Security:** The CI pipeline automatically scans the Docker image using Trivy, intentionally failing the build and blocking the deployment if `HIGH` or `CRITICAL` OS or library vulnerabilities are detected.
* **Zero-SSH Inbound Security:** The EC2 host exposes zero inbound management ports (Port 22 is disabled). Server access and Kubernetes bootstrapping execute securely via AWS Systems Manager (SSM) agent and IAM instance profiles.
* **Hardened Container Runtime:** The Dockerfile is optimized for layer caching, utilizes `--no-cache-dir` to reduce attack surface, and drops root privileges to a dedicated, limited `appuser` before execution.
* **Infrastructure as Code:** The AWS compute footprint, security groups, and zero-trust IAM roles are declared and managed deterministically via Terraform.
* **Kubernetes Orchestration:** Container deployment, scaling, and self-healing are managed by a K3s cluster, with public traffic dynamically routed via a Traefik Ingress controller on standard port 80.

---

## Repository Structure

```text
.
├── .github/workflows/
│   └── ci.yml               # GitHub Actions pipeline (Build, Scan, Push)
├── terraform/               # Infrastructure as Code (Modular setup)
│   ├── provider.tf          # AWS provider configuration
│   ├── iam-role.tf          # AWS IAM roles and SSM instance profiles
│   ├── k3s-server-sg.tf     # Security Group definitions for cluster access
│   ├── k3s-server.tf        # Main EC2 instance provisioning
│   └── outputs.tf           # Exported infrastructure values (e.g., Public IP)
├── Dockerfile               # Hardened container specification
├── main.py                  # FastAPI application code
├── requirements.txt         # Python dependencies
├── k8s-deployment.yaml      # Kubernetes Deployment manifest
├── k8s-service.yaml         # Kubernetes Service manifest
└── ingress.yaml             # Traefik Ingress routing for port 80
```

---

## API Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/` | Root endpoint verifying active deployment |
| `GET` | `/docs` | Auto-generated interactive Swagger UI documentation |

#### Sample Root Response:
```json
{
  "status": "healthy",
  "message": "Automated DevSecOps Pipeline Active"
}
```

---

## Setup & Deployment Instructions

### 1. Provision Infrastructure via Terraform

```bash
cd terraform
terraform init
terraform apply -auto-approve
```
*Note the outputted `k3s_public_ip` for later configuration.*

### 2. Configure GitHub Secrets

Add the following repository secrets under **Settings > Secrets and variables > Actions**:
* `AWS_ACCESS_KEY_ID`: IAM user access key with ECR push permissions.
* `AWS_SECRET_ACCESS_KEY`: Corresponding IAM secret key.

### 3. CI Pipeline Execution

Push any changes to the `main` branch to trigger the automated CI build, Trivy vulnerability scan, and image push to AWS ECR.
```bash
git add .
git commit -m "feat: secure application and deployment setup"
git push origin main
```

### 4. Kubernetes Bootstrap & Deployment

Connect securely to the provisioned EC2 instance via AWS SSM:
```bash
aws ssm start-session --target <INSTANCE_ID>
```

Install K3s and extract the generated configuration:
```bash
sudo su - ubuntu
curl -sfL [https://get.k3s.io](https://get.k3s.io) | INSTALL_K3S_EXEC="--tls-san <PUBLIC_IP>" sh -
```

From your local machine, deploy the ECR registry credentials, application manifests, and ingress controller:
```bash
kubectl apply -f k8s-deployment.yaml
kubectl apply -f k8s-ingress.yaml
```

---

## Contact

**Sujal Surani** - [https://www.linkedin.com/in/sujal-surani/]

## Maintainer

Created and maintained by **Sujal Surani**.