# Project Status: Alpha

## Overview

The purpose of this project is to provide an implementation of AWX on Minikube using Hyper-V or single node k3s on Centos8 using the AWX Operator. This contains the minimum configuration needed to build the instance while maintaining ownership of the data and passwords through the use of persistent volumes.

## References

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl guides](<https://kubectl.docs.kubernetes.io/guides/>)
- [kubectl Quick Reference](<https://kubernetes.io/docs/reference/kubectl/quick-reference/>)
- [K3s - Lightweight Kubernetes](https://docs.k3s.io/) @v1.29.0+k3s1
- [INSTALL.md on ansible/awx](https://github.com/ansible/awx/blob/23.5.1/INSTALL.md) @23.5.1
- [README.md on ansible/awx-operator](https://github.com/ansible/awx-operator/blob/2.9.0/README.md) @2.9.0

## Setup Minikube on Windows 11

### Environment

- Tested on:
  - Windows 11 Pro
  - Minikube v1.32.0
- Products that will be deployed:
  - AWX Operator 2.9.0
  - AWX - 23.5.1
  - PostgreSQL 13

### Setup Minikube

Elevated Powershell

```powershell

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

choco install kubernetes-cli -y

choco install minikube -y

minikube.exe config set driver hyperv

minikube.exe start

# Needed to enable the ingress controller to set the awx-operator resource ingress_type: ingress
# I noticed I need to start this service anytime the minikube vm is powered off or stopped. probably a way to make persist.
minikube.exe addons enable ingress

# Once you know the minikube ip, modify your local hosts file to point to the hostname specified in the awx-operator (default: meta.name.example.com)
# or specify a hostname: awx.willywonka.com in your awx-demo.yml file under ingress_type:.
Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n172.29.41.85`tawx-demo.example.com" -Force

# The IP Address might change for your minikube instance if you stop or rebuild it. Be sure to either add a dhcp reservation or update your hosts file to point to the right IP. For my purposes, I would just update my hostfile every time I start minikube to work on it. Long term this isn't ideal.

# Validate After

kubectl get po -A

minikube dashboard
```

You should now be able to access the minikube dashboard from your internet browser using the link provided in the output of the minikube dashboard command. Leave this terminal running to keep the dashboard up.

In a separate powershell terminal, you can start issuing commands like minikube, kubectl, or kustomize. These commands will directly interact with the minikube instance. You can run the rest of the AWX setup steps from here.

## Setup K3s on Centos 8

### Centos 8 Environment

- Tested on:
  - RHEL 8 (Minimal)
  - K3s - v1.29.0+k3s1
- Products that will be deployed:
  - AWX Operator 2.9.0
  - AWX - 23.5.1
  - PostgreSQL 13

### Install K3s

- Setup a Centos 8 VM

- Disable firewalld (Recommeneded but not required) [Installation](https://docs.k3s.io/installation/requirements#operating-systems)

```bash
sudo systemctl disable firewalld --now
```

- Install git and curl

```bash
sudo dnf install -y git curl
```

> Note: Git is required for kustomization manifest to pull awx operator images.

- Install a single-node server using the [install script](https://docs.k3s.io/installation/configuration#configuration-with-install-script)

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.29.0+k3s1 sh -s - --write-kubeconfig-mode 644
```

- Deploy Project to Linux Host

- You can either install git and clone the project or use something like WinSCP to copy the project. In this case, I used git to clone the repo to /opt/awx-on-k3s.

- Create requried directorys for the Persistent Volumes defined in base/pv.yml. Be sure to do this in the awx-on-k3s directory.

```bash
sudo mkdir -p /data/postgres-13
sudo mkdir -p /data/projects
sudo chmod 755 /data/postgres-13
sudo chown 1000:0 /data/projects
sudo mkdir -p /data/backup
```

## The following Steps can be completed on either minikube or centos at this point

## Install AWX Operator

Initial attempt at using the concept of Bases and Overlays. I created the operator/kustomization.yml separate from our base/ directory. Learn more about [Bases and Overlays](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#bases-and-overlays). I intent to circle back and implement some kind of dev/test/prod overlay strategy.

- Navigate to the project directory, in this project example, either V1, or V2 (I recommend v2 as its more complete)

> You can run kubectl apply on the folder that contains your kustomization.

```bash
kubectl apply -k operator
```

> Or you can run kubectl apply specifying the file directly.

```bash
kubectl apply -f v2/operator/kustomization.yml
```

- After the operator is running, you can verify the pods in the namespace are running:

```bash
kubectl get pods -n awx
```

- To verify the deployment ran and see all resources in the awx namespace and their status run:

```bash
 kubectl -n awx get all
```

- You should see an output similar to:

```bash
NAME                                                   READY   STATUS    RESTARTS   AGE
pod/awx-operator-controller-manager-68d787cfbd-kjfg7   2/2     Running   0          16s

NAME                                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/awx-operator-controller-manager-metrics-service   ClusterIP   10.43.150.245   <none>        8443/TCP   16s

NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/awx-operator-controller-manager   1/1     1            1           16s

NAME                                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/awx-operator-controller-manager-68d787cfbd   1         1         1       16s
```

## Prepare required files to deploy AWX

- All files required for AWX are located in the base/ directory. The configuration is set to utilize TLS certificates and to configure a custom CA-Bundle. The following documentation was used to do this.
  - [Network and TLS](https://ansible.readthedocs.io/projects/awx-operator/en/latest/user-guide/network-and-tls-configuration.html)
  - [Trusting a Custom Certificate](https://ansible.readthedocs.io/projects/awx-operator/en/latest/user-guide/advanced-configuration/trusting-a-custom-certificate-authority.html)
  - [Trust-Custom-CA-Tips](https://github.com/kurokobo/awx-on-k3s/blob/main/tips/trust-custom-ca.md) - public project by kurokobo, great example project.

> **What I did:** I used my labs internal CA to generate a cert issued to awx.jacobbweber.com, named tls.crt and tls.key.I took the root and intermediate certificate, combined them to a .pem format named cacert.pem. All of these files were copied directly to the base/ directory. The awx resources/secrets reference them in their relative path.

- For learning purposes, you can also just use a self signed Certificate. Required openssl.

> For Centos8

```bash
AWX_HOST="awx.example.com"
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out ./base/tls.crt -keyout ./base/tls.key -subj "/CN=${AWX_HOST}/O=${AWX_HOST}" -addext "subjectAltName = DNS:${AWX_HOST}"
```

> For minikube

```powershell
$DNSHost="awx.example.com"
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -out ./base/tls.crt -keyout ./base/tls.key -subj "/CN=$DNSHost/O=$DNSHost" -addext "subjectAltName = DNS:$DNSHost"
```

- Deploy AWX

```bash
kubectl apply -k base
```

- To monitor the progress you can view the log output

```bash
kubectl -n awx logs -f deployments/awx-operator-controller-manager
```

- When the deployment is complete, the log ends with:

```bash
$ kubectl -n awx logs -f deployments/awx-operator-controller-manager
...
----- Ansible Task Status Event StdOut (awx.ansible.com/v1beta1, Kind=AWX, awx/awx) -----
PLAY RECAP *********************************************************************
localhost                  : ok=84   changed=0    unreachable=0    failed=0    skipped=79   rescued=0    ignored=1
```

- Deploy Persistent Volume and Persistent Volume Claims for backups.

> This step is only if you intend on taking backups, I wanted to do backups in my lab for learning purposes but you can skip this step and still use awx.

```bash
kubectl apply -k backup
```

- You should now be able to go to <https://awx.fbinsmi.com> in your browser.

# Useful Commands and info

- List services running on minikube "I used this to see the IP and Port awx was running on after deployment"

```bash
minikube service list
```

- List Secrets

```bash
kubectl get secret -n awx
```

- Decode Secret in Powershell

```powershell
$secret = kubectl get secret -n awx awx-demo-admin-password -o jsonpath="{.data.password}"
$decodedSecret = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($secret))
Write-Output $decodedSecret
```

> Da heck is kustomization.yml
In Kubernetes, a kustomization.yaml file is part of Kustomize, a tool that enables customization of Kubernetes manifests. The kustomization.yaml file provides a configuration for Kustomize, allowing you to define various customization options and settings for managing and deploying Kubernetes resources.
