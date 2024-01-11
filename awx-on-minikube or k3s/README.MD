# Project Status: Alpha

## Overview

The purpose of this project is to provide an basic implementation of AWX on Minikube using Hyper-V or single node k3s on Centos8 using the AWX Operator. I started this project knowing nothing about kubernetes or containers, but I needed AWX because...ansible GUI...This contains the minimum configuration needed to build the instance while maintaining ownership of the data and passwords through the use of persistent volumes. There are multiple versions (examples) of this project that may continue to grow as I learn new techniques.

## References

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl guides](<https://kubectl.docs.kubernetes.io/guides/>)
- [kubectl Quick Reference](<https://kubernetes.io/docs/reference/kubectl/quick-reference/>)
- [K3s - Lightweight Kubernetes](https://docs.k3s.io/) @v1.29.0+k3s1
- [INSTALL.md on ansible/awx](https://github.com/ansible/awx/blob/23.5.1/INSTALL.md) @23.5.1
- [README.md on ansible/awx-operator](https://github.com/ansible/awx-operator/blob/2.9.0/README.md) @2.9.0


## Setup Minikube on Windows 11

[Minikube Setup](./docs/setup-minikube.md)

## Setup K3s on Centos 8

[K3s Setup](./docs/setup-k3s.md)

## Install AWX Operator

[Deploy AWX](./docs/awx-setup.md)


## V1

Folllowing the offical AWX-Operator documentation examples

## V2

Learning to utilize secrets generator and adopting what I learned from the AWX-Operator official documentation. 
