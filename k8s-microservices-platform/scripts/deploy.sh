#!/bin/bash

kubectl create namespace microservices

helm install postgres ./helm/postgres -n microservices
helm install order ./helm/order-service -n microservices
helm install api ./helm/api-gateway -n microservices
helm install frontend ./helm/frontend -n microservices

kubectl apply -f k8s/ingress.yaml
