# Raspberry Pi Initialization with Terraform

This is for Provisioning a Rpi2/3 with Raspian Lite.
I have implemented this for easily bootstrapping RPI Docker Hosts

## Manual Steps

### terraform.tfvars

Create a file "terraform.tfvars" for easy adding variable defaults.
Te only variable that must be set is "ip_adress" for initial connection to Raspberry Pi.
An Example File "terraform.tfvars.example" is included.

### initialize

Before first use terraform modules must be initialized

```sh
   terraform init
```

### Workspace

```sh
   terraform workspace
   terraform workspace new rpi2
   terraform workspace select rpi2
```

### plan

```sh
   terraform plan -var-file="terraform.rpi2.tfvars"
```

### apply

```sh
   terraform apply -var-file="terraform.rpi2.tfvars"
```

## Deployment

### Servernode

```cmd
   cd servernode
   ..\terraform workspace new rpi2
   ..\terraform workspace select rpi2
   ..\terraform init
   ..\terraform plan -var-file="terraform.rpi2.tfvars"
   ..\terraform apply -var-file="terraform.rpi2.tfvars"
```

### Workernode

```cmd
   cd workernode
   ..\terraform workspace new rpi3
   ..\terraform workspace select rpi3
   ..\terraform init
   ..\terraform plan -var-file="terraform.rpi3.tfvars"
   ..\terraform apply -var-file="terraform.rpi3.tfvars"
```

```cmd
   cd workernode
   ..\terraform workspace new rpi2
   ..\terraform workspace select rpi4
   ..\terraform init
   ..\terraform plan -var-file="terraform.rpi4.tfvars"
   ..\terraform apply -var-file="terraform.rpi4.tfvars"
```
