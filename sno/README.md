# GitOps deployment of SNO clusters 
using sealed secrets to keep info safe and using a single namespace for all provisioned clusters as a workaround to having multiple copies of all the secrets. The instructions below 

## SETUP - USING SEALED SECRETS 
1. Install SealedSecrets in a namespace eg `labs-ci-cd`.
```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install my sealed-secrets/sealed-secrets -f values.yaml -n labs-ci-cd --create-namespace 
```

2. create a `secrets.yaml` file containing the values needed as per the example at the end of the `values.yaml`
```yaml
secrets:
  aws_access_key_id: 'changeme'
  aws_secret_access_key: 'changeme'
  pullSecret: 'changeme'
  sshPrivateKey: 'changeme'
```

3. Generate Secret files from these values and store in tmp for now:
```bash
helm template -f secrets.yaml --set sealedSecrets=false -s sno/templates/secrets/all.yaml sno > /tmp/all.yaml
```

4. login to ocp ( might need `--insecure-skip-tls-verify=true` if in demo dot redhat envs) ... 
```bash
oc login  ... 
```

5. Seal the secrets for your new clusters NAMESPACE. In my workflow im using one ns for the secrets which are shared across all hive cluster deployments. Hive is designed to be multi tenant so this is just a simple work around to only have to do secrets once for N clusters. `NAMESPACE` here should match the one in your `clusters.namespace` property in `sno/values.yaml`
```bash
export NAMESPACE=all-clusters; kubeseal < /tmp/all.yaml > sealedsecrets/$NAMESPACE-sealed-secrets.yaml \
    -n $NAMESPACE \
    --controller-namespace labs-ci-cd \
    --controller-name my-sealed-secrets \
    -o yaml
```

6. Commit the encrypted values to git. ENSURE you don not check in your AWS creds by accident (like i did first time)
`git add sealedsecrets` && `git commit ...`

7. Generate your Application resource in ArgoCD to sync the secrets to teh cluster 
```bash
oc apply -f sealedsecrets/Application.yaml
```
