#!/bin/bash

# Kill any existing ngrok sessions
killall ngrok
if [ -f /tmp/ngrok_addresses.json ]; then rm /tmp/ngrok_addresses.json; fi
if [ -f /tmp/ngrok.json ]; then rm /tmp/ngrok.json; fi
if [ -f /tmp/github-event-source.yaml ]; then rm /tmp/github-event-source.yaml; fi
if [ -f /tmp/ngrok.yml1 ]; then rm /tmp/ngrok.yml1; fi
if [ -f /tmp/ngrok.yml ]; then rm /tmp/ngrok.yml; fi

# Gerneate ngrok config from running services
argo_local=$(minikube service --url argo-server -n argo-events)
gateway_local=$(minikube service --url github-gateway-svc -n argo-events)

while [ -z $argo_local ]; do
  sleep 5
  argo_local=$(minikube service --url argo-server -n argo-events)
done

while [ -z $gateway_local ]; do
  sleep 5
  gateway_local=$(minikube service --url github-gateway-svc -n argo-events)
done

sed "s~SUB12000~$gateway_local~g" ngrok.yml > /tmp/ngrok.yml1
sed "s~SUB2746~$argo_local~g" /tmp/ngrok.yml1 > /tmp/ngrok.yml

# Start ngrok and log output to /tmp/ngrok.json
ngrok start -config /tmp/ngrok.yml --all --log-format json --log /tmp/ngrok.json > /dev/null 2>&1 &

# Wait until the tunnels have started
while [ ! -f /tmp/ngrok.json ]; do
  sleep 1
done

echo "Ngrok started"

until grep -q "workflows" /tmp/ngrok.json; do
  sleep 1
done

until grep -q "webhook" /tmp/ngrok.json; do
  sleep 1
  cat /tmp/ngrok.json
done

echo "Tunnels have been created"

# Dump the generated addresses
cat /tmp/ngrok.json | jq 'select(.url != null)' > /tmp/ngrok_addresses.json

# Set the URLs to environment variables
workflow=$(cat /tmp/ngrok_addresses.json | jq 'select(.name == "workflows")' | jq -r '.url')
webhook=$(cat /tmp/ngrok_addresses.json | jq 'select(.name == "webhook")' | jq -r '.url')

if [ -z "$workflow" ]; then
  echo "Workflow is undefined"
  exit
fi

if [ -z "$webhook" ]; then
  echo "Webhook is undefined"
  exit
fi

echo "NGROK_2746=$workflow" > .ngrok
echo "NGROK_12000=$webhook" >> .ngrok

# sed "s~SUBSTITUTE~$webhook~g" kubernetes/argo-events/github-event-source.yaml > /tmp/github-event-source.yaml
# kubectl replace -f /tmp/github-event-source.yaml
kubectl create secret generic ngrok \
  --namespace argo-events \
  --from-literal=ngrok_2746=$workflow \
  --from-literal=ngrok_12000=$webhook \
  --dry-run=client -o yaml | kubectl apply -f -
