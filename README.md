# aws terraform modules

[![Tofu](https://github.com/DoumanAsh/aws-tf/actions/workflows/tofu.yaml/badge.svg)](https://github.com/DoumanAsh/aws-tf/actions/workflows/tofu.yaml)

My personal modules for use with AWS

## Modules

- [alb-ingressclass/](modules/alb-ingressclass) - Defines ingress class to be used by [alb](modules/alb)
- [alb](modules/alb) - ALB setup module
- [aws-eks-config-oneshot-daemon](modules/aws-eks-config-oneshot-daemon) - Module to create oneshot daemon for purpose of performing one time node initialization
- [aws-ecr-repos](modules/aws-ecr-repos) - Module to setup ECR repositories. WIP
- [aws-openid-github-repos](modules/aws-openid-github-repos) - OpenID federation setup between github and your ECR repos. WIP
