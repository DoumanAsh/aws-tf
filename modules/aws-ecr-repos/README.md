# aws-ecr-repos

Simple module to declare and configure ECR repos

You can use [aws-openid-github-repos](../aws-openid-github-repos) to configure OIDC connector with your github repos

## Required parameters

| Parameter              | Description |
|------------------------|-------------|
| `repositories`         | List of repositories to create|
| `policy`               | IAM policy name to create for your `repositories` |

## Optional parameters

| Parameter              | Description |
|------------------------|-------------|
| `image_tag_mutability` | Specifies tag mutability. Allowed values are `MUTABLE` or `IMMUTABLE`. Defaults to `MUTABLE`. |
| `scan_on_push`         | Specifies to enable scan of the image on the push. Defaults to `false`. |
| `encryption_type`      | Specifies encryption used by the created repositories. Allowed valuesa are `AES256` or `KMS`. Defaults to `AES256`
| `tags`                 | List of tags to attach to created AWS resources. Defaults to `null`. |
| `continious_scan_type` | Specifies type of contitionous scan. Allowed values are `ENHANCED` or `BASIC`. Defaults to `null`. |
