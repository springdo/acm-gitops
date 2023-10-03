# when deploying process sealed secrets to exist in the repo on cluster creation 

* install SealedSecrets in a namespace eg `labs-ci-cd`
* create a `secrets.yaml` file containing the values needed as per the example at hte end of the `values.yaml`
* `helm template -f secrets.yaml --set sealedSecrets=false -s templates/secrets/all.yaml . > /tmp/all.yaml`
* login to ocp
* seal the secrets for your new CLUSTER_NAME
```bash
export NAMESPACE=all-clusters; kubeseal < /tmp/all.yaml > templates/$NAMESPACE-sealed-secrets.yaml \
    -n $CLUSTER_NAME \
    --controller-namespace labs-ci-cd \
    --controller-name my-sealed-secrets \
    -o yaml
```