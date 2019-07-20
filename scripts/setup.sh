#!/bin/bash

if [ $# -eq 0 ]
then
  echo "No arguments supplied!"
  echo "Usage: ./setup.sh <namespace> to create a demo namespace and populate"
  exit 1
fi

namespace="$1"

if [ -f ../current_namespace ]
then
  namespace=`cat ../current_namespace`
  echo "Namespace already exists. Did you clean up?"
  exit 1
fi

kubectl get namespace $namespace 2>/dev/null 1>/dev/null
rc=$?
if [ $rc == 0 ]
then
  echo "Namespace already exists, aborting"
  exit $rc
fi

echo "Creating Namespace $namespace"
kubectl create namespace $namespace

echo $namespace > ../current_namespace

echo "Attempting to fetch examples from https://github.com/kubernetes/examples.git"
(cd ..; git clone https://github.com/kubernetes/examples.git 2>/dev/null)
rc=$?
if [ $rc == 0 ]
then
  echo "Applying dockerfile patch"
  cat guestbook-go-dockerfile.patch | (cd /k8s-demo-deploy/examples/guestbook-go/ ; patch Dockerfile)
  cat guestbook-go-makefile.patch | (cd /k8s-demo-deploy/examples/guestbook-go/ ; patch Makefile)
  cat guestbook-controller-json.patch | (cd /k8s-demo-deploy/examples/guestbook-go/ ; patch guestbook-controller.json)
  cat frontend-service-yaml.patch | (cd /k8s-demo-deploy/examples/guestbook/ ; patch frontend-service.yaml)
  echo "Building docker image"
  (cd /k8s-demo-deploy/examples/guestbook-go; make build)
  rc=$?
  if [ $rc != 0 ]
  then
    echo "Build failed, aborting"
    exit $rc
  fi
else
  echo "Examples directory already exists, assuming patched"
fi

#deploy a well behaved workload

kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook/redis-master-deployment.yaml
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook/redis-master-service.yaml
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook/redis-slave-deployment.yaml
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook/redis-slave-service.yaml
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook/frontend-deployment.yaml
kubectl --namespace $namespace apply -f /k8s-demo-deploy/examples/guestbook/frontend-service.yaml

a=1
while [ $a -lt 500 ]
do
  let b=500-$a
  let c=$a%10
  if [ $c -eq 0 ]
  then 
    echo "Sleeping for $b more seconds"
  fi
  let a++
  sleep 1
done

if [ -f ../current_namespace ]
then
  namespace=`cat ../current_namespace`
  echo "about to delete everything in namespace $namespace"
  echo "Hit ^C now if that's not what you wanted"
  echo "5"
  sleep 1
  echo "4"
  sleep 1
  echo "3"
  sleep 1
  echo "2"
  sleep 1
  echo "1"
  sleep 1
  kubectl delete namespace $namespace
  rm ../current_namespace
  echo "the deed is done."
else
  echo "../current_namespace doesn't exist, nothing to cleanup"
  exit 1
fi
