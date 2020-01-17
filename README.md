# Hippo 🦛

Hippo is a tool to manage the orchestration of a deployment of an application from a Git repository to a Kubernetes cluster via Docker images. It handles the building of docker images, publishing those images and then orchestrating the k8s cluster to bring those images to life.

It provides a similar syncronous flow to other deployment solutions like Capistrano. You run `deploy` and it takes care of getting that repository's code live.

- Handles building templates on demand based on the current HEAD commit of a branch in a Git repository.
- Handles pushing built templates to a Docker registry.
- Handles configuring Kubernetes to use these new imags through standard Kubernetes Object Definition files.
- Handles running upgrade/migration scripts during the application process.
- Provides some useful tools and shortcuts for interacting with your application once it has been deployed to your cluster (for example accessing consoles, logs and status information quickly and easily).

## Using Hippo

First things first, you need a `Hippofile`. This is the file that describe how your application will be built, published and deployed.

### Creating a Hippofile

A Hippofile is actually a few files contained within a directory. At the root of the directory you have a `Hippofile` and then a directory named `kubernetes` that contains all the Kubernetes objects that your application needs.

To get started, just run `hippo init` and we'll make a directory called `hippo` and copy in some example configuration.

Open up `hippo/Hippofile` and make the appropriate changes needed for your application.

- Set the repository URL
- Add any stages that you need to deploy to
- Add the details about the builds that you need to create from Docker

### Getting your Dockerfile in order

Before you can do much, you'll need to make sure your application runs happily and can be built using a Dockerfile. Make sure you can build and publish your images in your repository and ensure that you commit and push any updates you make. Hippo works with a clean copy of your repository from the URL provided in your Hippofile.

### Bootstrap your Kubernetes cluster

**Note:** Hippo uses `kubectl` to access your cluster. You need to configure this and be sure you are in the correct context before using any Hippo commands or you may experience errors or accidentally deploy to the wrong cluster.

Next, you need to get your cluster into a state ready to receive your application. We do not wish to store too much environment specific configuration in your repository (although you can store `vars` in the stages configuration if you need to).

The idea of this step is to create a new of initial configuration ConfigMaps and Secrets that you can then edit in place on the cluster. You should define the example config files in `hippo/kubernetes/setup.yml`.

```
$ cd path/to/myapp
$ hippo setup staging
```

At this point, you'll want to go ahead and edit any configuration that you've added to make sure it is suitable. Your application is not yet on the cluster. Something like below might be useful:

```
$ kubectl -n myapp-staging edit cm env-vars
$ kubectl -n myapp-staging edit secret tls-certs
```

### Installing the application

It's very likely that you'll want to run some additional bootstrapping tasks once you have set up the cluster. This is the job of the `install` task. This task will run any jobs that you define in `hippo/kubernetes/install_jobs.yml`.

For exampe, you might use this to populate a database that you have no configured.

This is the first time that Hippo will actually try and build an image for your application too. These steps are run in whatever the HEAD commit of the stage branch is set to.

```
$ cd path/to/app
$ hippo install staging
```

### Deploying the application

Finally, you can go ahead and deploy the application. This is the task that you'll run most often when you make changes to your application. It encapsulates the process of building your image, publishing it to a registry, running any pre-deployment tasks (like database migrations) and then making your new image live.

```
$ cd path/to/app
$ hippo deploy staging
```
