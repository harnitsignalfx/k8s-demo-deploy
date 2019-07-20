#!/bin/bash
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
