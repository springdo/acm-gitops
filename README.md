## ACM / GitOps Demo

Order of play:
1. Provision ACM cluster (v2.8.x in my tests)
    * Create the `AWS Credential` in the UI on acm for now supplying all the things like keys etc 
2. Add Red Hat GitOps (ArgoCD) to the hub cluster with a global instance. Handy one liner below for getting the admin passwd for ArgoCD
```bash
oc extract secrets/openshift-gitops-cluster --keys=admin.password -n openshift-gitops --to=-
```

3. Spin up new instance using ACM (hive)
    * Set the workerpool nodes to 0 and the master replicas to 1 for Single Node OpenShift
    * Wait 45 mins 🥱

With these building blocks in place you can now try:
1. Creating cluster set and using GitOps to apply day 2 config or other custom objects to each cluster based on placements etc
2. Use GitOps to automatically provision clusters 

### 1. ACM to ArgoCD Intergration
See `argocd-acm-integration` folder for detailed README

### 2. GitOps give me a cluster please :)
See instructions in hte `sno` readme