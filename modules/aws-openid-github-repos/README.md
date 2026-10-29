# aws-openid-github-repos

Connector between ECR and github repositories to enable you to push image into your ECR repositories declared by [aws-ecr-repos](../aws-ecr-repos) module

## Github OIDC

New repositories might use [immutable subject claims](https://github.blog/changelog/2026-04-23-immutable-subject-claims-for-github-actions-oidc-tokens/) by default.

To verify that you should always check your claim prefix in your repo via `Settings -> Actions -> OIDC`

## Required parameters

| Parameter              | Description |
|------------------------|-------------|
| `repositories`         | List of full repository name that will be allowed to auth. Requires full qualified name `<org|username>[@prefix]/<repo>` |
| `policy`               | IAM policy name to create for your `repositories` |

## Optional parameters

| Parameter              | Description |
|------------------------|-------------|
| `aws_iam_openid_connect_provider_arn`| ARN of existing `aws_iam_openid_connect_provider`. If not specified resource will be created by this module |
