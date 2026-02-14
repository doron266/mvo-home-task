# moveo home task

This project is my moveo home task. I was asked to deploy a containerized website using nginx,

over aws infrastructure using any preferred IAC.

Definition of done: searching for the instance in the browser will get us the web content,

"yo this is nginx" for example

---

## 📌 Overview

the project involved 4 main concepts which i needed to take care for:

- The full infrastructure and the website should be accessible and deployed by executing 'terraform apply'
- The instance should be placed in a private subnet, which means services outside the VPC cant reach it due to luck of public IP
- Security concepts that i will touch later
- Basic infrastructure standards for high availability

---

## 🛠️ Tech Stack

- Terraform
- AWS
- Docker
- Nginx

---

## Documentation

### Prerequisites


- Terraform >= 1.x
- Docker, any version from the past 2 years should be fine
- AWS CLI ready and configured!!!
- An AWS account
- git
---

### Installation

```bash
git clone https://github.com/your-org/your-repo.git
cd your-repo
terraform apply
```
---
### Security concepts

- usage of security groups: well configured security groups only for the ports needed for the project 80 and 22 for advanced tasks in the future
- deployment ec2's sits in private subnet(no public IP): isolation from the world wide web adds a liar of security to our sensitive components
- no need for bastion host as it old method, but can easily added with a new resource to terraform file
---
### High availability concepts

- Standard of network infrastructure: inside our VPC 2 public subnets and 2 private subnets one from each sits in a different availability zone
- Routing: private subnet traffic routed to NAT getaways and public subnets traffic straight to internet getaways
- Usage of ALB(application load balancer): using ALB we are increasing our h-a and securely granting access to our private ec2 in the private subnets