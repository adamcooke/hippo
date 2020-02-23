# Deploying updates

If the application is updates and you wish to apply these updates, the process is almost identical to that of the installation.

```bash
hippo [stage-name] deploy
```

This will run all the same tasks as the `install` command but it will execute the `deploy` jobs (which are meant to upgrade schemas etc...) rather than the install ones.
