# Setup AWX

Change your working directory to match the learning environment you setup.

```powershell
cd .\awx-on-minikube
```

> You can run kubectl apply on the folder that contains your kustomization.

```bash
kubectl apply -k operator
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

- You should now be able to go to <https://awx.example.com> in your browser.

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

## Updating Secrets after deployment

After the deployment, I wanted to update the passwords to something different than what I set them to during the first build.

I logged into the AWX instance and validated the username and passwords are what i set them to be.

Without knowing much about this at all, as a starting point, I wanted to just list what secrets were available in the namepspace.

```powershell
kubectl get secrets -n awx-demo
```

```powershell
NAME                              TYPE                DATA   AGE
awx-admin-password                Opaque              1      7m36s
awx-custom-secret-key             Opaque              1      7m36s
awx-demo-app-credentials          Opaque              3      7m16s
awx-demo-broadcast-websocket      Opaque              1      7m31s
awx-demo-postgres-configuration   Opaque              6      7m29s
awx-demo-receptor-ca              kubernetes.io/tls   2      7m19s
awx-demo-receptor-work-signing    Opaque              2      7m18s
redhat-operators-pull-secret      Opaque              1      7m34s
```

> Note: Pretty straight forward, they are what I created them to be, but felt nice seeing them.

I wanted to see more about the awx-admin-password, and after some research, I ran:

```powershell
kubectl get secret -n awx-demo awx-admin-password -o yaml
```

Which returned:

```powershell
apiVersion: v1
data:
  password: QW5zaWJsZTEyMyE=
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"password":"QW5zaWJsZTEyMyE="},"kind":"Secret","metadata":{"annotations":{},"name":"awx-admin-password","namespace":"awx-demo"},"type":"Opaque"}
  creationTimestamp: "2024-01-10T17:00:25Z"
  name: awx-admin-password
  namespace: awx-demo
  resourceVersion: "8077"
  uid: 39d55f0f-648c-49c6-ac6a-20da14a695ab
type: Opaque
```

In the output the password is base64 encoded, you can see its not the same as what I used in the deployment manifest.

After some research I found this method for updating the secret.

1. Encode the New Password: First, you'll need to encode your new password into base64 format. Suppose your new password is NewPassword123. You can use the following PowerShell command to encode it:

```powershell
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("NewPassword123"))
```

This will output the base64-encoded string of your new password.

2. Patch the Secret: Next, use the kubectl patch command to update the secret in your Kubernetes cluster. Replace <base64-encoded-password> with the output from the previous step. Here's an example PowerShell command:

```powershell
kubectl patch secret awx-admin-password -n awx-demo --type='json' -p="[{'op': 'replace', 'path': '/data/password', 'value':'<base64-encoded-password>'}]"
```

Ensure that you replace <base64-encoded-password> with the actual base64-encoded new password.

3. Verify the Update: After executing the patch command, you can confirm that the secret has been updated by retrieving it (or log into the site?):

```powershell
kubectl get secret -n awx-demo awx-admin-password -o yaml
```

This approach allows you to update the Kubernetes secret from a PowerShell environment. Make sure to encode the new password in base64 format before using it in the kubectl patch command, as Kubernetes secrets require base64-encoded data.


> Da heck is kustomization.yml
In Kubernetes, a kustomization.yaml file is part of Kustomize, a tool that enables customization of Kubernetes manifests. The kustomization.yaml file provides a configuration for Kustomize, allowing you to define various customization options and settings for managing and deploying Kubernetes resources.
