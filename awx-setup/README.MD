# Project Status: Alpha

## Overview

The purpose of this project is to to deliver a fundamental setup of AWX on Minikube using Hyper-V, or on a single-node k3s server on Centos8, utilizing the AWX Operator.

This is primarily for educational purposes so it's important to note that this documentation may become obsolete over time. Always consult the official documentation for the most current information.

## References

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl guides](<https://kubectl.docs.kubernetes.io/guides/>)
- [kubectl Quick Reference](<https://kubernetes.io/docs/reference/kubectl/quick-reference/>)
- [K3s - Lightweight Kubernetes](https://docs.k3s.io/) @v1.29.0+k3s1
- [INSTALL.md on ansible/awx](https://github.com/ansible/awx/blob/23.5.1/INSTALL.md) @23.5.1
- [README.md on ansible/awx-operator](https://github.com/ansible/awx-operator/blob/2.9.0/README.md) @2.9.0

## Pick your learning environment

Before you can deploy AWX you need an instance of kubernetes. I primarily use minikube on hyper-v to quickly test kubernetes manifests as I learn new techniques. For my segmented private lab environment I run a single-node k3s server on centos8.


| Minikube on Hyper-V    |  Minikube on Docker  | K3s on Centos8 |
|:-----------------------------|:-----------------|:-----------------|
| [Minikube Setup](./docs/setup-minikube-hyperv.md)    |   TBD   | [K3s Setup](./docs/setup-k3s.md) |


## Install AWX Operator

[Deploy AWX](./docs/setup-awx.md)

## Examples

The examples folder includes various versions meant to demonstrate my learning process as I discovered new things. The initial version included only the basic examples taken from the AWX-Operator documentation using all defaults.

- [V1](./docs/v1.md)
- [V2](./docs/v2.md)
- [V3](./docs/v3.md)
- [V4](./docs/v4.md)
- [V5](./docs/v5.md)
- [V6](./docs/v6.md)