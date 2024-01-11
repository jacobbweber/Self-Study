# Setup Minikube

## Environment

- Tested on:
  - Windows 11 Pro
  - Minikube v1.32.0
- Products that will be deployed:
  - AWX Operator 2.9.0
  - AWX - 23.5.1
  - PostgreSQL 13

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
