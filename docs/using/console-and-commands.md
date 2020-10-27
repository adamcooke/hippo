# Console and commands

Interacting with a running application is usually essential.

Application manifests can define a series of command aliases which can be easily executed within your instance when needed. This is very useful for accessing application or database consoles and manifest authors are encouraged to make these available.

These aliases can be used to run commands within an EXISTING running pod in the application.

```bash
hippo staging exec console
# Downloading secret encryption key... done
# Defaulting container name to cuetip.
# Use 'kubectl describe pod/worker-557686bb6c-tzqqd -n postal' to see all of the containers in this pod.
# Loading production environment (Rails 6.0.1)
# irb(main):001:0>
```

As you can see above, running `exec console` has hooked into a `worker` pod and executed an application console which we can now use as normal.

Alternatively, the manifest author may provide commands to look at database consoles directly, for example:

```bash
hippo [stage-name] exec mysql
# Downloading secret encryption key... done
# Defaulting container name to mariadb.
# Use 'kubectl describe pod/mariadb-master-0 -n postal' to see all of the containers in this pod.
# Reading table information for completion of table and column names
# You can turn off this feature to get a quicker startup with -A
#
# Welcome to the MariaDB monitor.  Commands end with ; or \g.
# Your MariaDB connection id is 394533
# Server version: 10.3.21-MariaDB-log Source distribution
#
# Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
#
# Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
#
# MariaDB [postal]>
```

For a full list of the aliases that are provided for the application you can use the `--list` option.

```bash
hippo [stage-name] exec --list
# console      Opens a Rails console (on deployment/worker)
# mysql        Opens a MySQL console (on pod/mariadb-master-0)
```
