NS=argo-events
# This is using an older version of Argo-Events before Gateway's were merged with EventSources
AE_HASH=336cb65a412db9b5b1362f04534e28ac74e829d9

watch:
	@watch "kubectl get pods -A --sort-by=status.startTime | awk 'NR<2{print \$$0;next}{print \$$0| \"tail -r\"}'"

init:
	kubectl create namespace $(NS) --dry-run=client -o yaml | kubectl apply -f -
	kubectl create secret generic github-access-token \
		--namespace $(NS) \
		--from-literal=username=$$(source .env && echo $$GITHUB_USERNAME) \
		--from-literal=password=$$(source .env && echo $$GITHUB_ACCESS_TOKEN) \
		--dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n $(NS) -f https://raw.githubusercontent.com/argoproj/argo-events/$(AE_HASH)/manifests/namespace-install.yaml
	kubectl apply -n $(NS) -f kubernetes/argo-events
	helm upgrade argo-artifacts stable/minio \
		--install --namespace $(NS) \
		--set service.type=LoadBalancer --set fullnameOverride=argo-artifacts
	kubectl apply -n $(NS) -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/quick-start-postgres.yaml
	kubectl apply -n $(NS) -f kubernetes/argo-workflow
	kubectl patch svc -n $(NS) argo-server -p '{"spec": {"type": "LoadBalancer"}}'

dockerhub:
	@kubectl create secret generic dockerhub --namespace $(NS) \
			--from-literal=username=$$(source .env && echo $$DOCKERHUB_USERNAME) \
			--from-literal=password=$$(source .env && echo $$DOCKERHUB_PASSWORD) \
			--dry-run=client -o yaml | kubectl apply -f -

deinit:
	kubectl delete -n $(NS) -f kubernetes/argo-events
	kubectl delete -n $(NS) -f https://raw.githubusercontent.com/argoproj/$(NS)/$(AE_HASH)/manifests/namespace-install.yaml
	kubectl delete -n $(NS) -f https://raw.githubusercontent.com/argoproj/argo/stable/manifests/install.yaml
	helm delete --namespace $(NS) argo-artifacts

.PHONY: \
	init deinit \
	dockerhub \
	watch
