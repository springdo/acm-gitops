if [[ $# -eq 0 ]] ; then
    echo 'Pass a CLUSTER_NAME 🙏'
    exit 0
fi

export CLUSTER_NAME=${1}

helm template -f secrets.yaml --set sealedSecrets=false --set cluster.name=$CLUSTER_NAME -s templates/secrets/all.yaml sno > /tmp/$CLUSTER_NAME-all.yaml

kubeseal < /tmp/$CLUSTER_NAME-all.yaml > sealedsecrets/$CLUSTER_NAME-sealed-secrets.yaml \
    -n $CLUSTER_NAME \
    --controller-namespace labs-ci-cd \
    --controller-name sealed-secrets \
    -o yaml

oc create namespace $CLUSTER_NAME --dry-run=client -o yaml > sealedsecrets/$CLUSTER_NAME-ns.yaml

echo "🦭 sealed $CLUSTER_NAME 🔐"
