#!/bin/bash

set -eu -x
set -o pipefail
set -o xtrace

/etc/eks/bootstrap.sh \
  --apiserver-endpoint '${cluster_endpoint}' \
  --b64-cluster-ca '${certificate_authority}' \
  '${cluster_name}'
