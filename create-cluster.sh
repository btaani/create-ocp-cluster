#!/bin/bash

# 1. Cleanup old cluster data if any
openshift-install destroy cluster --dir ./cluster

# 2. Generate a cluster name in the format <username>-<random number>
export NAME=`whoami`-$RANDOM

# 3. Add the cluster name to install-config.yaml
# (install-config.yaml should reside in the same directory as this script)
yq -i '.metadata.name = strenv(NAME)' install-config.yaml

# 4. Create the cluster
mkdir cluster 2&>/dev/null
cp install-config.yaml ./cluster/install-config.yaml
openshift-install create cluster --dir ./cluster

# 5. Login to the cluster
export KUBECONFIG=~/ocp/cluster/auth/kubeconfig
oc login -u kubeadmin -p $(cat ./cluster/auth/kubeadmin-password)

echo "----------------------------------------------------------------"
echo "Cluster API : https://api.$NAME.devcluster.openshift.com:6443"
echo "Web console : https://console-openshift-console.apps.$NAME.devcluster.openshift.com/"
echo "Username    : kubeadmin"
echo "Password    : `cat ./cluster/auth/kubeadmin-password`"
echo "Created at  : `date  '+%T'`"
echo "Expires at  : `date -d '+10 hour' '+%T'`"
echo "----------------------------------------------------------------"