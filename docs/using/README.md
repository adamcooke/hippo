# Setting up

Each application that can use Hippo must provide a **Hippo Manifest** which is a series of files which define exactly how that application should be deployed. You can make your own manifests or you can just pull from a public manifest hosted in a Git repository.

In this section, we're going to look at the options available to you as if your manifest has already been created. We'll look at making your own manifests shortly.

::: warning A NOTE ABOUT NAMING
For this guide, we will be installing an application named **postal** but this can be replaced with your own application name.
:::

## Files & directories

Each application that you wish to deploy should have a directory on your computer (also checked into version control) which will contain the configuration for each instance of that application that you wish to deploy. This is an example directory structure for that file.

```bash
postal/                 # Name of the application
  .git/                 # Your git repository
  manifest.yaml         # Details of the application manifest

  production/           # Configuration for your production instance
    config.yaml
    secrets.yaml

  staging/              # Configuration for your staging instance
    config.yaml
    secrets.yaml
```

## Initalizing this directory

The `hippo setup` command provides functionality to create your initial configuration directory.

```bash
mkdir -p ~/hippo-configs
cd ~/hippo-configs
hippo setup postal --remote https://github.com/postalhq/k8s-hippo
# Created configuration directory at /home/adam/hippo-configs/postal
# Updating local copy of remote repository...
# Updating manifest from https://github.com/postalhq/k8s-hippo... done
# Update completed successfully.
#
#   Repository....: https://github.com/postalhq/k8s-hippo
#   Branch........: master
#   Path..........: /
#
```

This will create a directory named `postal` which will contain a file named `manifest.yaml` which defines where your manifest is located.

## The `manifest.yaml` file

This file exists in the root of your application configuration directory and defines where the manifest actually exists. Manifests can either be located in a Git repository (i.e. remote) or on your own machine (i.e. local).

### Remote manifests

If you wish to use a remote manifest, you should use the type as `remote` and provide the `remoteOptions` as shown below. By default the `branch` will be `master` and the `path` will be the root of the repository.

```yaml
source:
  type: remote
  remoteOptions:
    repository: https://github.com/postalhq/k8s-hippo
    branch: master
    path: /
```

### Local manifests

If your manifest is local, you can just provide the path to the root of the manifest.

```yaml
source:
  type: local
  localOptions:
    path: /home/adam/manifests/postal
```

### Overriding manifest configuration

You can, if you wish, override the manifest configuration by adding a `manifest.local.yaml` file which will be merged when reading the main manifest file. You should exclude this `.local.yaml` file from being committed to your repository.
