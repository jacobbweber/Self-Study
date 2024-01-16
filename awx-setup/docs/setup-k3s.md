# Centos 8 Environment

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
