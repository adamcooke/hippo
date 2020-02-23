# Preparing the cluster

Once you have created your stage and added your initial configuration, you can go ahead and prepare to deploy your application.

## What does prepration do?

To prepare for the arrival of your new stage, there may be things that need to be performed on the Kubernetes cluster.

- It will push any configuration objects that have been defined in the application's manifest (including your own configuration variables as needed).

- Install any dependencies from Helm that are needed (also including your own confiuration). For example, if your application needs a MySQL database server, this will be installed and configured ready for use.

## Preparing

To prepare, you just need to run the command as shown below:

```bash
hippo [stage-name] prepare
# Applying 1 namespace object
# Updating manifest from https://github.com/postalhq/k8s-hippo... done
# ====> namespace/postal-demo unchanged
# Downloading secret encryiption key... done
# Applying 1 configuration object
# ====> secret/postal-config created
# Installing rabbitmq using Helm...
# Installing mariadb using Helm...
# Finished with 2 packages
```

If the application has dependencies, you'll now need to wait for them to be fully installed and then be ready for use. **Do not continue with application deployment until all dependencies are ready.**

## Checking dependency status

The status command will output the state of your namespace. This is what you should use to determine when your dependencies are ready.

```bash
hippo [stage-name] status
```

In this, you're looking for any `pods`, `statefulsets` and `deployments` to all be showing `Running` and 100% readiness (i.e. 1/1 or 2/2 etc...). This is an example of what you're looking for:

```text
NAME             READY   STATUS    RESTARTS   AGE
pod/mariadb-0    2/2     Running   0          50s
pod/rabbitmq-0   2/2     Running   0          53s

NAME                        READY   AGE
statefulset.apps/mariadb    1/1     98s
statefulset.apps/rabbitmq   1/1     101s
```
