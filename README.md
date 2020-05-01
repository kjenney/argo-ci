# argo-ci

Demo of using [Argo Workflows](https://argoproj.github.io/projects/argo) with [Argo Events](https://argoproj.github.io/projects/argo-events) to build a CI tool for Github.

```bash
make init

# expose github gateway
ngrok http 12000

# update the github event source with the publicly-exposed url via ngrok
kubectl edit eventsource -n argo-events github-event-source
# edit spec.github.example.webhook.url to match the https endpoint provided by ngrok
# also update to whatever repo you want it to control the webhooks for
```

## Troubleshooting

```bash
# tail gateway logs
kubectl logs -f -n argo-events -l gateway-name=github-gateway --all-containers

# tail sensor logs
kubectl logs -f -l owner-name=github-sensor -n argo-events
```
