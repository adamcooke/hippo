# Hippo 🦛

This README needs re-writing for the new 1.1 way of doing things. I'll get around to it shortly! Sorry if you stumble across this in the mean time.

## Deploying for the first time

* 1. Create your stages using `hippo [name] create`
* 2. Update any configuration you wish to apply in `stages/[name].yaml` and using `hippo [name] secrets` to set any encrypted values.
* 3. Use `hippo [name] prepare` to apply configuration and install any packages.
* 4. Use `hippo [name] install` to run the first deployment of the application.
* 5. Use `hippo [name] deploy` to run any additional deployments in the future.

