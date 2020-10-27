# Installing the application

Once prepared, the application can be installed to the cluster. If everything has gone smoothly and the application's manifest has been configured correctly, this should be a simple operation.

::: warning NOTE ABOUT INSTALL
You should only use the `install` command the first time you install the application. To update the application in the future you should switch to using `deploy`.
:::

## What happen's during an install?

- Any configuration files will be repushed to Kubernetes.

- Any `install` jobs will be executed. Hippo will wait for them to complete successfully before continuing with the installation. If they fail or time out, the installation will be stopped. These jobs usually install database schemas or generally prepare any storage requirements.

- The application deployments (or stateful/daemon sets) will be applied to Kubernetes which will then begin to automatically start pods as needed.

- Hippo will then wait for all deployments to be rolled out successfully.

- When successful, all services (and ingresses and network policies) will be applied.

## Running the installation

Just run the `hippo [stage-name] install` command:

```bash
hippo [stage-name] install
# Updating manifest from https://github.com/postalhq/k8s-hippo... done
# Image for main exists at adamcooke/postal:docker
# Applying 1 namespace object
# ====> namespace/postal-demo unchanged
# Downloading secret encryption key... done
# Applying 1 configuration object
# ====> secret/postal-config unchanged
# Running install jobs
# Applying 1 deploy job object
# ====> job.batch/initialize created
# All jobs completed successfully
# You can review the logs for these by running the commands below
#
#   ✅  hippo staging kubectl -- logs job/initialize
#
# Using deployment ID: 7af69667d5cd
# Applying 5 deployment objects
# ====> deployment.apps/cron created
# ====> deployment.apps/requeuer created
# ====> deployment.apps/worker created
# ====> deployment.apps/smtp created
# ====> deployment.apps/web created
# Waiting for all deployments to roll out...
# Waiting for 3 deployments (smtp, web, worker)
# Waiting for 2 deployments (smtp, web)
# Waiting for 1 deployment (web)
# All 5 deployments all rolled out successfully
# Applying 9 service objects
# ====> ingress.networking.k8s.io/postal-web created
# ====> service/web created
# ====> networkpolicy.networking.k8s.io/default-block-policy created
# ====> networkpolicy.networking.k8s.io/allow-namespace-traffic created
# ====> networkpolicy.networking.k8s.io/allow-ingress-to-web created
# ====> networkpolicy.networking.k8s.io/allow-ingress-to-smtp created
# ====> networkpolicy.networking.k8s.io/allow-prometheus-traffic created
# ====> networkpolicy.networking.k8s.io/allow-cert-manager-traffic created
# ====> service/smtp created
```

The output you receive should look similar to above however it may be different if the jobs fail or the deployments do not roll out successfully. The output in these cases will show you the commands you can run to investigate the cause for these issues further.
