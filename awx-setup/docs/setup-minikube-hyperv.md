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
minikube.exe config set cpus 4

minikube.exe start
```

> Needed to enable the ingress controller to set the awx-operator resource ingress_type: ingress
> I noticed I need to start this service anytime the minikube vm is powered off or stopped. probably a way to make persist.

```powershell
minikube.exe addons enable ingress
```

> Once you know the minikube ip, modify your local hosts file to point to the hostname specified in the awx-operator (default: meta.name.example.com),or specify a hostname: awx.willywonka.com in your awx-demo.yml file under ingress_type:.
> **Warning** The IP Address might change for your minikube instance if you stop or rebuild it. Be sure to either add a dhcp reservation or update your hosts file to point to the right IP. For my purposes, I would just update my hostfile every time I start minikube to work on it. Long term this isn't ideal.

## Validate After

```powershell
kubectl get po -A

minikube dashboard
```

You should now be able to access the minikube dashboard from your internet browser using the link provided in the output of the minikube dashboard command. Leave this terminal running to keep the dashboard up.

In a separate powershell terminal, you can start issuing commands like minikube, kubectl, or kustomize. These commands will directly interact with the minikube instance. You can run the rest of the AWX setup steps from here.

> This is the powershell snippet I just copy and paste after I startup my minikube instance, im lazy.

```powershell
minikube.exe start

# Define the new IP address and domain
$domain = "awx-demo.example.com"

# Regular expression pattern to match any IP address
$ipPattern = "\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b"

# Define the file path
$filePath = "C:\Windows\System32\drivers\etc\hosts"

# Make a Backup
Copy-Item -Path $filePath -Destination ($filepath + '_backup')

# Read the content of the file
$content = Get-Content -Path $filePath

write-verbose "Content: $content" -verbose

$MinikubeIP = minikube.exe ip

# Check if the new entry already exists
$newEntry = "$MinikubeIP $domain"

if (!($content -like "*$domain*")) {
  write-verbose "No Entry exists so adding one" -verbose
  Add-Content -Path $FilePath -Value "`n$MinikubeIP` $Domain" -Force
} else {
    write-verbose "Entry exists so updating IP to current minikube value $MinikubeIP" -verbose

  # Replace any IP address followed by spaces and the specific domain with the new IP address
    $updatedContent = $content -replace "($ipPattern) +$domain", $newEntry

    # Write the updated content back to the file
    Set-Content -Path $filePath -Value $updatedContent
}

start-sleep 10
kubectl apply -k .\examples\v3\operator

start-sleep 10
kubectl apply -k .\examples\v3\base
```
