# Configuring a stage

Your stage configuration defines everything that's needed to run your application. This may include database connection details, API keys, hostnames and more.

There are two types of configuration:

- **Configuration** - this is plain text configuration variables which are defined in `config.yaml`

- **Secrets** - these are encrypted values that are not stored in plain text in your configuration directory. They are encrypted using a private key that is available in the Kubernetes API.

## Configuration

In addition to application specific configuration, there are also other values that you may wish to specify in here. This is an example `config.yaml`.

```yaml
name: staging
namespace: postal-staging
context: staging-cluster
config:
  hostname: postal.mydomain.com
  storageClass: nfs
  workers:
    replicas: 4
```

- **Line 1** defines the name of the stage.
- **Line 2** specifies the namespace that your application will be deployed into (each stage always should have its own unique namespace).
- **Line 3** specifies the name of the kubectl context of the cluster you wish to connect to.
- **Lines 4 to 8** contain application specific configuration.

::: tip
Manifest authors can provide default values for the `config` section of this file so if you create your stage with `hippo [stage-name] create` this section may already contain some placeholder values for you to update.
:::

## Secrets

Secrets exist to allow you to store private information as part of your stage. You do not want to be uploading API keys or passwords into repositories in plain text as this will pose a security risk.

Hippo provides a utility that allows you to encrypt secrets into a file which can be committed. This is stored in the `secrets.yaml` file in your stage configuration directory.

::: danger A NOTE ABOUT THE PRIVATE KEY
The private key that encrypts your secrets is stored on the Kubernetes API within a `Secret` named `hippo-secret-key` in the stage's namespace. Remember, secrets on Kubernetes are not that secret - they're just base64 encoded and available to anyone with API access to those resources in your namespace. This is usually fine because those with access to your API should also be permitted to read the secrets in this repository (and they likely can anyway through the Kubernetes API).
:::

### Editting secrets

The `hippo [stage-name] secrets` utility command will decrypt the secrets, open the decrypted file in an editor and then encrypt it again when it closes.

The secrets file itself is just YAML.

As with configuration, the manifest author may have provided some default secrets which you may wish to change or review. In some cases, manifests may request that random values are provided automatically (for example it may generate a random database password which you don't need to change).

::: tip CHOOSING AN EDITOR
Hippo will open the editor defined in the `EDITOR` environment variable so be sure to set this. I usually recommend `nano` for edits like this.
:::

```bash
hippo [stage-name] secrets
```

## Reviewing configuration

All configuration that is entered is exposed to your manifest through the Hippo templating system. For a full list of all variables which have been set, you can run the command below:

```bash
hippo [stage-name] vars
```
