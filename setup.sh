#!/usr/bin/env bash

# cleanup
# helm delete nginx-ingress --purge
# helm delete prometheus --purge
# helm delete cert-manager --purge
#
# kubectl delete ns cert-manager
# kubectl delete ns monitoring
# kubectl delete ns nginx-ingress
#
# kubectl delete crd prometheusrules.monitoring.coreos.com
# kubectl delete crd servicemonitors.monitoring.coreos.com
# kubectl delete crd alertmanagers.monitoring.coreos.com
# kubectl delete crd prometheuses.monitoring.coreos.com
# kubectl delete crd podmonitors.monitoring.coreos.com
# kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml

# -----------------

kubectl create namespace cert-manager
kubectl create namespace nginx-ingress
kubectl create namespace monitoring

kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml
# helm repo add jetstack https://charts.jetstack.io
# helm repo update
helm install \
  --name cert-manager \
  --namespace cert-manager \
  jetstack/cert-manager

kubectl apply -f ./issuer.yaml

kubectl create cm grafana-nginx-ingress -n monitoring --from-file=dashboards/nginx-ingress.json
kubectl label cm grafana-nginx-ingress grafana_dashboard=nginx-ingress -n monitoring

# prometheus operator with alertmanager and grafana

helm install stable/prometheus-operator -f values/prometheus.yaml \
  --name prometheus \
  --namespace monitoring

# nginx ingress

helm install stable/nginx-ingress -f values/nginx-ingress.yaml \
  --name nginx-ingress \
  --namespace nginx-ingress
