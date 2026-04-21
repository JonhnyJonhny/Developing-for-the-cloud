Video Link: https://buveduvn0-my.sharepoint.com/personal/phong_nk_st_buv_edu_vn/_layouts/15/guestaccess.aspx?share=IQBeXCyi0Nd-TamePV8s86iuARL77DMKtDyRGsX5VtRYK2k&nav=eyJyZWZlcnJhbEluZm8iOnsicmVmZXJyYWxBcHAiOiJPbmVEcml2ZUZvckJ1c2luZXNzIiwicmVmZXJyYWxBcHBQbGF0Zm9ybSI6IldlYiIsInJlZmVycmFsTW9kZSI6InZpZXciLCJyZWZlcnJhbFZpZXciOiJNeUZpbGVzTGlua0NvcHkifX0&e=nAYZ4N
---
## Technology Stack
- **Frontend** HTML/CSS/JavaScript, Nginx 1.25 (Alpine)
- **Backend** Node.js 18, Express.js
- **Database** AWS RDS MySQL 8.0
- **Containerization** Docker
- **Orchestration** Kubernetes (AWS EKS 1.31)
- **Service Mesh** Istio (Base, Istiod, ingress gateway)
- **Infrastructure as Code** Terraform
- **CI/CD** Github Action
- **Monitoring** Prometheus, Grafana, Splunk
- **Metrics** Prom-client (node.js), Kubernetes Metric Server
- **Auto-scaling** Horizontal Pod Autoscaler, Cluster autoscaler
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
1. **clone repo**
2. **install backend dependencies**
3. **configure environment variables**
 ```env
   PORT=3000
   DB_HOST=<your-mysql-host>
   DB_USER=admin
   DB_PASSWORD=<your-password>
   DB_NAME=appdb
   ```
4. **start the backend**
5. **serve frontend**
##build docker image locally##
1. docker build -f Dockerfile.backend -t budget-backend:local .
2. docker build -f Dockerfile.frontend -t budget-frontend:local .
---
## Cloud Deployment
1. **Provision the infrastructure using terraform**
- terraform init
- terraform plan (check first before deploying)
- terraform apply - type YES
2. **change DBpassword withint the variables.tf file**
3. **Update kubeconfig**
- aws eks update-kubeconfig --name budget-app-cluster --region us-east-1
4. **deploy kubernetes manifest**
- apply all manifest files within k8s manually
5. **verify deployment**
```env
kubectl get pods -n budget-tracker
kubectl get svc -n budget-tracker
kubectl get svc -n istio-system istio-ingress
```
6. **check monitoring services by adding repspective subdomain before the IP or DNS ex grafana. premetheus. splunk.**
