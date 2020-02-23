# Creating a stage

Stages are the name for each instance of your application. You can have as many stages as you wish within your configuration directory. Each stage is represented by a directory.

::: warning NOTE
You must be "in" the root of your configuration directory to run any commands in this section. Use `cd` before running these commands.
:::

You can create a stage manually but it is far quicker to use the `create` command as shown below.

```bash
hippo [stage-name] create
```

- You'll be prompted to enter the name of a new Kubernetes namespace that you'd like to run your stage within.

- Then you'll be prompted to enter the name of the context (from your `.kube/config` file) that you want to run your commands against. We recommend sharing the names of your contexts with anyone else on your team.

Once you've provided this information, Hippo will do a few things:

- A new namespace will be created on the appropriate Kubernetes cluster.

- A directory will be created with the same name as your stage.

- A `config.yaml` will be added to this directory containing the details of the branch, context and other configuration. The manifest may define some default configuration too which will be added in here.

- An encrypted `secrets.yaml` file will be added if the manifest defines any default secrets for newly created stages. If this is the case, a new secret will also be added to the Kubernetes API named `hippo-secret-key` which contains the private key used to encrypt & decrypt this file.
