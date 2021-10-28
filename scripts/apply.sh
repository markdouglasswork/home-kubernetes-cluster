#!/usr/bin/env bash

kubectl create configmap prometheus-cm --dry-run=client --from-file=prometheus/config/prometheus.yml --output=yaml | kubectl replace --filename -

kubectl apply --filename=prometheus/kubernetes_objects/

kubectl create configmap grafana-dashboards-cm --dry-run=client --from-file grafana/config/dashboards --output=yaml | kubectl replace --filename -
kubectl create configmap grafana-datasource-cm --dry-run=client --from-file grafana/config/datasources.yml --output=yaml | kubectl replace --filename -
kubectl create configmap grafana-dashboard-providers-cm --dry-run=client --from-file=grafana/config/dashboard-providers.yml --output=yaml | kubectl replace --filename -

kubectl apply --filename=grafana/kubernetes_objects/

