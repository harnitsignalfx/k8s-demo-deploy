#!/bin/bash

namespace="$1"

if [ -f ../current_namespace ]
then
  namespace=`cat ../current_namespace`
  echo "Namespace $namespace already exists"
  exit 1
fi

exit 0
