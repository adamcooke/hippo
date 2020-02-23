# Welcome to Hippo 🦛

Hippo provides a utility framework allowing you to easily deploy applications & serivces onto any Kubernetes cluster. There are a number of key features:

- Manage multiple instances of the same application across multiple namespaces and/or clusters.
- Centralised configuration for application stored in a repository.
- Secret information is encrypted with a key kept on the Kubernetes API. This allows you to commit secrets to your repository which can only be used by those who also have access to the Kubernetes API.
- Ability to deploy new versions of an application and ensure all pods are reloaded and the deployment is monitored throughout.
- Run pre-deployment jobs (for example database migrations) using new image versions before pushing the images to existing deployments (i.e. the running application).
- Quick access commands for accessing application utilities such as consoles.
- Integrates with Helm allowing you to deploy and manage additional dependencies (such as databases).
