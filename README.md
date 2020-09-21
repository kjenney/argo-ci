# argo-ci

Demo of using [Argo Workflows](https://argoproj.github.io/projects/argo) with [Argo Events](https://argoproj.github.io/projects/argo-events) to build a CI tool for Github.

## Prerequisites

* [Helm3](https://helm.sh/docs/intro/install/) Installed
* Helm repo: `helm repo add stable https://kubernetes-charts.storage.googleapis.com/`

## Secrets

Secrets are stored in .env. See `sample.env`.

## Getting Started

```
# get everything up and running
make init

# set DockerHub secrets for pushing images
make dockerhub

# expose github gateway and argo workflows with minikube
./ngrok-generate.sh

# update the github event source with the publicly-exposed url via ngrok
kubectl edit eventsource -n argo-events github-event-source
# edit spec.github.example.webhook.url to match the https endpoint provided by ngrok
# (use the url that's forwarding to 12000)
```

## Create bucket on Minio

Login to the Minio UI using a web browser (port 9000) after obtaining the external IP using kubectl.

```
kubectl get service argo-artifacts -n argo-events
```

On Minikube:

```
minikube service --url argo-artifacts -n argo-events
```

NOTE: When minio is installed via Helm, it uses the following hard-wired default credentials, which you will use to login to the UI:

```
AccessKey: AKIAIOSFODNN7EXAMPLE
SecretKey: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

Add a new bucket named `artifacts` (default creds)

## Troubleshooting

```bash
# tail gateway logs
kubectl logs -f -n argo-events -l gateway-name=github-gateway --all-containers

# tail sensor logs
kubectl logs -f -l owner-name=github-sensor -n argo-events

# delete all workflows
kubectl delete workflow -n argo-events --all
```
