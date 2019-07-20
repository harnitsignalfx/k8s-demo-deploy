#!/bin/bash

if [ ! -f ../current_namespace ]
then
  echo "expected ../current_namespace to exist, failed (need to run step0?)"
  exit 1
fi

namespace="$(cat ../current_namespace)"

#deploy some misconfigured pods

#ImagePull fail
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook-go/redis-slave-controller.json

#Crash (bad CMD)
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook-go/guestbook-controller.json

#service without provider
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/cassandra/cassandra-service.yaml
