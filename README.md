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
  terraform workspace new rpi2
  terraform workspace select rpi2
  terraform init
  terraform plan -var-file="terraform.rpi2.tfvars"
  terraform apply -var-file="terraform.rpi2.tfvars"
```

### Workernode

```cmd
  terraform workspace new rpi3
  terraform workspace select rpi3
  terraform init
  terraform plan -var-file="terraform.rpi3.tfvars"
  terraform apply -var-file="terraform.rpi3.tfvars"
```

```cmd
  terraform workspace new rpi4
  terraform workspace select rpi4
  terraform init
  terraform plan -var-file="terraform.rpi4.tfvars"
  terraform apply -var-file="terraform.rpi4.tfvars"
```

## Kubernetes

### kubeconfig

1. Get kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>
2. Configuration of kubectl <https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/>
3. Test access
   - `--kubeconfig` flag

      ```cmd
      kubectl --kubeconfig kubeconfig get node
      ```

   - `KUBECONFIG` environment variable

      ```cmd
      set KUBECONFIG=kubeconfig
      kubectl get node
      ```

4. Create Kubernetes Dashboard

   ```cmd
   kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml
   kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
   kubectl -n kubernetes-dashboard describe secret admin-user-token
   kubectl proxy
   ```

5. Login Kubernetes Dashboard  
   <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>
