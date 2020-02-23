# Viewing application status

tus` command is very useful for determing the current state of the running application at any time. This will list all key objects from the Kubernetes API.

```bash
hippo [stage-name] status
# NAME                            READY   STATUS    RESTARTS   AGE
# pod/cron-8469bc5554-c8lfn       1/1     Running   0          7m9s
# pod/mariadb-0                   2/2     Running   0          11m
# pod/rabbitmq-0                  2/2     Running   0          11m
# pod/requeuer-685bd5fcc6-p999d   1/1     Running   0          7m9s
# pod/smtp-6b5c46fcdf-tbfjx       1/1     Running   0          7m9s
# pod/web-67c8796c56-s5bfv        1/1     Running   0          7m9s
# pod/worker-6b45b9c7cb-8659w     1/1     Running   0          7m9s
# pod/worker-6b45b9c7cb-hv7bl     1/1     Running   0          7m9s
#
# NAME                                TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                                          AGE
# service/cm-acme-http-solver-s2h58   NodePort       10.99.15.72      <none>         8089:30459/TCP                                   6m50s
# service/mariadb                     ClusterIP      10.96.244.101    <none>         3306/TCP,9104/TCP                                11m
# service/rabbitmq                    ClusterIP      10.111.144.180   <none>         4369/TCP,5672/TCP,25672/TCP,15672/TCP,9419/TCP   11m
# service/rabbitmq-headless           ClusterIP      None             <none>         4369/TCP,5672/TCP,25672/TCP,15672/TCP            11m
# service/smtp                        LoadBalancer   10.110.193.247   185.53.57.49   25:31482/TCP                                     6m51s
# service/web                         ClusterIP      10.99.93.232     <none>         80/TCP                                           6m52s
#
# NAME                                           HOSTS                 ADDRESS         PORTS     AGE
# ingress.extensions/cm-acme-http-solver-fzzk9   postal.mydomain.com   185.53.57.153   80        6m50s
# ingress.extensions/postal-web                  postal.mydomain.com   185.53.57.153   80, 443   6m52s
#
# NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
# deployment.apps/cron       1/1     1            1           7m10s
# deployment.apps/requeuer   1/1     1            1           7m10s
# deployment.apps/smtp       1/1     1            1           7m10s
# deployment.apps/web        1/1     1            1           7m10s
# deployment.apps/worker     2/2     2            2           7m10s
#
# NAME                        READY   AGE
# statefulset.apps/mariadb    1/1     11m
# statefulset.apps/rabbitmq   1/1     11m
```

You can optionally pass `--full` to this output to display additional objects which are needed less often.
