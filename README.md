Video Link: https://buveduvn0-my.sharepoint.com/personal/phong_nk_st_buv_edu_vn/_layouts/15/guestaccess.aspx?share=IQBeXCyi0Nd-TamePV8s86iuARL77DMKtDyRGsX5VtRYK2k&nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=nAYZ4N
---
## Technology Stack
**Frontend** HTML/CSS/JavaScript, Nginx 1.25 (Alpine)
**Backend** Node.js 18, Express.js
**Database** AWS RDS MySQL 8.0
**Containerization** Docker
**Orchestration** Kubernetes (AWS EKS 1.31)
**Service Mesh** Istio (Base, Istiod, ingress gateway)
**Infrastructure as Code** Terraform
**CI/CD** Github Action
**Monitoring** Prometheus, Grafana, Splunk
**Metrics** Prom-client (node.js), Kubernetes Metric Server
**Auto-scaling** Horizontal Pod Autoscaler, Cluster autoscaler
---
## Setup instruction 
### Prerequisite
- [Node.js 18+]
- [Docker]
- [Terraform 1.5+]
- [AWS CLI v2]
- [kubectl]
- [Helm 3+]
---
### local deploymeny
**clone repo**
**install backend dependencies**
**configure environment variables**
 ```env
   PORT=3000
   DB_HOST=<your-mysql-host>
   DB_USER=admin
   DB_PASSWORD=<your-password>
   DB_NAME=appdb
   ```
**start the backend**
**serve frontend**
##build docker image locally##
docker build -f Dockerfile.backend -t budget-backend:local .
docker build -f Dockerfile.frontend -t budget-frontend:local .
---
## Cloud Deployment
**Provision the infrastructure using terraform**
terraform init
terraform plan (check first before deploying)
terraform apply - type YES
**change DBpassword withint the variables.tf file**
**Update kubeconfig**
aws eks update-kubeconfig --name budget-app-cluster --region us-east-1
**deploy kubernetes manifest**
apply all manifest files within k8s manually
**verify deployment**
kubectl get pods -n budget-tracker
kubectl get svc -n budget-tracker
kubectl get svc -n istio-system istio-ingress
**check monitoring services by adding repspective subdomain before the IP or DNS ex grafana. premetheus. splunk.**
