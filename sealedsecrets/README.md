```bash
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm install my sealed-secrets/sealed-secrets -f values.yaml -n labs-ci-cd --create-namespace 
```
