# GitOps deployment of SNO clusters 
using sealed secrets to keep info safe and using a single namespace for all provisioned clusters as a workaround to having multiple copies of all the secrets. The instructions below 

## SETUP - USING SEALED SECRETS 
1. login to ocp (might need `--insecure-skip-tls-verify=true` if in demo dot redhat envs) ... 
```bash
oc login  ... 
```

2. Install SealedSecrets in a namespace eg `labs-ci-cd`.
```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install my sealed-secrets/sealed-secrets -f sealedsecrets/values.yaml -n labs-ci-cd --create-namespace
```

3. create a `secrets.yaml` file containing the values needed as per the example at the end of the `values.yaml`
```yaml
secrets:
  aws_access_key_id: 'changeme'
  aws_secret_access_key: 'changeme'
  pullSecret: 'changeme'
  sshPrivateKey: 'changeme'
```

4. Generate Secret files from these values and given `CLUSTER_NAME` and store in tmp for now:
```bash
export CLUSTER_NAME=blerg
helm template -f secrets.yaml --set sealedSecrets=false --set cluster.name=$CLUSTER_NAME -s templates/secrets/all.yaml sno > /tmp/$CLUSTER_NAME-all.yaml
```

5. Seal the secrets for your new CLUSTER_NAME and create an NS for them to live cluster side
```bash
kubeseal < /tmp/$CLUSTER_NAME-all.yaml > sealedsecrets/$CLUSTER_NAME-sealed-secrets.yaml \
    -n $CLUSTER_NAME \
    --controller-namespace labs-ci-cd \
    --controller-name sealed-secrets \
    -o yaml

oc create namespace $CLUSTER_NAME --dry-run=client -o yaml > sealedsecrets/$CLUSTER_NAME-ns.yaml
```

6. Commit the encrypted values and new ns to git. ENSURE you don not check in your AWS creds by accident (like i did first time)
`git add sealedsecrets` && `git commit ...`

7. Generate your Application resource in ArgoCD to sync the secrets to the cluster 
```bash
# dirty hack - should define proper roles / resps for the ArgoCD service account
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller

oc apply -f SealedSecretsApp.yaml
```
![Alt text](secrets-syncd.png)

8. Create the `ApplicationSet` to watch for new clusters arriving to the `clusters` folder and update the variables accordingly. In particular take note of the `baseDomain` and ensure it matches the ones created for the given AWS creds
`oc apply -f ClusterProvisionerAppSet.yaml`

9. In ArgoCD - hit sync to create the clusters. For full e2e automation , this could be set to auto sync but can have some mild issues when cleaning resources up from teh ACM side... you should see the clusters appear in the UI on ACM too.
