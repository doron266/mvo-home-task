# moveo home task

This project is my moveo home task. I was asked to deploy a containerized website using nginx,

over aws infrastructure using any preferred IaC.

Definition of done: searching for the instance in the browser will get us the web content,

"yo this is nginx" for example

---

## 📌 Overview

the project involved 4 main concepts which I needed to take care for:

- The full infrastructure and the website should be accessible and deployed by executing 'terraform apply'
- The instance should be placed in a private subnet, which means services outside the VPC cant reach it due to luck of public IP
- Security concepts that I will touch later
- Basic infrastructure standards for high availability

---

## 🛠️ Tech Stack

- Terraform
- AWS
- Docker
- Nginx
- git

---

## Documentation

### Prerequisites


- Terraform >= 1.x
- Docker, not really because its auto installed on the deployment instances
- AWS CLI ready and configured!!!
- An AWS account
- git
---

### Installation

```bash
git clone https://github.com/doron266/mvo-home-task.git
cd mvo-home-task
terraform init
terraform apply
```
- After executing terraform apply you will be requested for approval, after initialization completes the ALB's DNS will be output
---
### Security concepts

- Usage of security groups: well configured security groups only for the ports needed for the project 80 and 22 for advanced tasks in the future
- Deployment ec2's sits in private subnet(no public IP): isolation from the world wide web adds a liar of security to our sensitive components
- No need for bastion host as its old method, but can easily add with a new resource to terraform file
---
### High availability concepts

- Standard of network infrastructure: inside our VPC 2 public subnets and 2 private subnets one from each sits in a different availability zone
- Routing: private subnet traffic routed to NAT getaways and public subnets traffic straight to internet getaways
- Usage of ALB(application load balancer): using ALB we are increasing our h-a and securely granting access to our private ec2 in the private subnets

### Important notes

- The variables.tf contains usefully variables with potential to be moduler and different; hardly recommended to replace the 'key_pair' variable and 'region' variable
- I have noticed that some ec2 models aren't available in different regions, so pay attention to that thing also
- The project was tested and built on eu-north-1 and t3.micro

---

## Module-based deployment

A module-based version of the same infrastructure was added under `modules/` and wired from `main-modules.tf`.

- `modules/network`: VPC, subnets, IGW, NAT gateways, routing
- `modules/compute`: EC2 instances, AMI lookup, security group and rules
- `modules/alb`: ALB, listener, target group, and attachments

By default, the original root resources are still used.
To also deploy the module-based stack, set:

```hcl
use_modules = true
```

inside `terraform.tfvars` (or pass `-var='use_modules=true'`).

When enabled, the module ALB output is available as:

- `module_alb_dns_name`
