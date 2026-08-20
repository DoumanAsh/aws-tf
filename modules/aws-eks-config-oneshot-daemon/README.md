# aws-eks-config-oneshot-daemon

Simple oneshot daemon job that runs once on every node to allow performing system actions with elevated privileges

## Why

EKS Auto mode comes with limited ability to customize nodes so as alternative we can use onetime `daemonset` to perform initialization using privileged pods

To facilitate one time execution it uses `affinity` to schedule pods only in one of the following cases:
- No label `${name}-version` is present on the node
- Label `${name}-version` is present but its value doesn't match expected md5 of `settings_script`

Once pod launches it runs two containers
- Init container that performs execution of `settings_script` command wrapped in `set -e` under standard shell
- Kubectl container to apply `${name}-version` label to mark node as configured, preventing future execution until `settings_script` changes

Possible use cases:
- Configure `vm.swappiness` in nodes that run AWS's `Bottlerocket` images to reduce it from 200 to 60 in order to reduce preference for swap memory
    - This is primary purpose of this module as high swap memory usage will lead to high CPU usage in small nodes
    - Setting 60 will reduce swap memory usage from 500mb to 100mb and CPU usage by 30% (under requests taking 90%+ of node's RAM)
    - This module was developed when EKS Auto used `Bottlerocket (EKS Auto, Standard) 2026.8.10 (aws-k8s-1.34-standard)`

## Optional parameters

| Parameter              | Description |
|------------------------|-------------|
| `name`                 | Name to be used to initialize kubernetes resources. Defaults to `eks-sys-config-oneshot` |
| `namespace`            | Namespace where to create resources. Defaults to `kube-system` |
| `k8s_version`          | Container `registry.k8s.io/kubectl` version to use to apply node label. Defaults to `v1.34.9` |
| `settings_script`      | Shell commands to run as part of node config init script. Defaults to `sysctl -w vm.swappiness=60` |
