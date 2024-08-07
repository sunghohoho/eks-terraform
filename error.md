0.
```yaml
Error: Unable to continue with update: ServiceAccount "external-dns" in namespace "kube-system" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "external-dns"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "kube-system"
```

1.
```yaml
│ Error: Unable to continue with install: ServiceAccount "aws-load-balancer-controller" in namespace "kube-system" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "aws-load-balancer-controller"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "kube-system"
```

2.
```yaml
Warning  FailedBuildModel  31s (x5 over 70s)  ingress  (combined from similar events): Failed build model due to WebIdentityErr: failed to retrieve credentials
caused by: AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity
  status code: 403, request id: 76e48997-77ec-4b9c-8f6f-18351489ae36
```

 3. kubernetes_annotations 에러

```yaml
│ Another client is managing a field Terraform tried to update. Set "force" to true to
│ override: Apply failed with 1 conflict: conflict with "kubectl-client-side-apply" using
│ storage.k8s.io/v1: .metadata.annotations.storageclass.kubernetes.io/is-default-class
```


4. storageclass 생성 시 발생하는 에러

```yaml
│ Error: Post "http://localhost/apis/storage.k8s.io/v1/storageclasses": dial tcp 127.0.0.1:80: connect: connection refused
│ 
│   with module.addon.kubernetes_storage_class.gp3,
│   on ../modules/addon/eks-addon.tf line 71, in resource "kubernetes_storage_class" "gp3":
│   71: resource "kubernetes_storage_class" "gp3" {
│ 
```1. kubernetes_annotations 에러

```yaml
│ Another client is managing a field Terraform tried to update. Set "force" to true to
│ override: Apply failed with 1 conflict: conflict with "kubectl-client-side-apply" using
│ storage.k8s.io/v1: .metadata.annotations.storageclass.kubernetes.io/is-default-class
```

1. storageclass 생성 시 발생하는 에러

```yaml
│ Error: Post "http://localhost/apis/storage.k8s.io/v1/storageclasses": dial tcp 127.0.0.1:80: connect: connection refused
│ 
│   with module.addon.kubernetes_storage_class.gp3,
│   on ../modules/addon/eks-addon.tf line 71, in resource "kubernetes_storage_class" "gp3":
│   71: resource "kubernetes_storage_class" "gp3" {
│ 
``` 