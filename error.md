0.
```yaml
Error: Unable to continue with update: ServiceAccount "external-dns" in namespace "kube-system" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "external-dns"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "kube-system"
```

1. irsa 에러
```yaml
│ Error: Unable to continue with install: ServiceAccount "aws-load-balancer-controller" in namespace "kube-system" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "aws-load-balancer-controller"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "kube-system"
```

2. irsa 에러
```yaml
Warning  FailedBuildModel  31s (x5 over 70s)  ingress  (combined from similar events): Failed build model due to WebIdentityErr: failed to retrieve credentials
caused by: AccessDenied: Not authorized to perform sts:AssumeRoleWithWebIdentity
  status code: 403, request id: 76e48997-77ec-4b9c-8f6f-18351489ae36
```
```yaml
irsa iam 역할에서 sts부분을 잘못입력
Condition": {
                "StringEquals": {
                    "oidc.eks.ap-northeast-2.amazonaws.com/id/0F:aud": "sts.amazonaws.com",
                    "oidc.eks.ap-northeast-2.amazonaws.com/id/0F:sub": "system:serviceaccount:kube-system:external-dns"
                }

와 같이 oidc.eks.xxx로 시작해야합니다. 기존에는 https://oidc.xx로 시작하여 에러뜸
이 경우 replice(${var.oidc_issuer},"https://","")과 같이 앞의 https를 치환하여 변수 선언함
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

5. storageclass 생성 시 발생하는 에러

```yaml
│ Error: Post "http://localhost/apis/storage.k8s.io/v1/storageclasses": dial tcp 127.0.0.1:80: connect: connection refused
│ 
│   with module.addon.kubernetes_storage_class.gp3,
│   on ../modules/addon/eks-addon.tf line 71, in resource "kubernetes_storage_class" "gp3":
│   71: resource "kubernetes_storage_class" "gp3" {
│ 

provider에서 kubectl에 대한 버전 명시를 해줌으로써 해결
terraform
  required_providers{
      kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
``` 

6. ingress 리소스가 삭제되지 않음
```yaml
kubectl get ingress -n monitoring kube-prometheus-ingress -o yaml
finalizers:
  - ingress.k8s.aws/resources

속성이 있는 경우 해당 라인을 지워줘야 정상적으로 ingress가 삭제됩니다.
```

7. 최초 배포시 발생하는 internal error 
```yaml
│ Error: 13 errors occurred:
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/validate-networking-v1-ingress?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/validate-networking-v1-ingress?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
```

8. ingress 구성 시 targetgroup에 pod가 register 되지 않는 현상
```yaml
{
  "level": "error",
  "ts": "2024-08-09T11:15:32Z",
  "msg": "Reconciler error",
  "controller": "targetGroupBinding",
  "controllerGroup": "elbv2.k8s.aws",
  "controllerKind": "TargetGroupBinding",
  "TargetGroupBinding": {
    "name": "k8s-monitori-promethe-2b97ff96e5",
    "namespace": "monitoring"
  },
  "namespace": "monitoring",
  "name": "k8s-monitori-promethe-2b97ff96e5",
  "reconcileID": "0b68d0e0-2af4-4fbf-a8dd-7854c21187ac",
  "error": "AccessDenied: User: arn:aws:sts::866477832211:assumed-role/myeks-cluster-kube-system-aws-alb-con2024080911083073380000000e/1723201945139252758 is not authorized to perform: elasticloadbalancing:RegisterTargets on resource: arn:aws:elasticloadbalancing:ap-northeast-2:866477832211:targetgroup/k8s-monitori-promethe-2b97ff96e5/a3abbd7aeeb911df because no identity-based policy allows the elasticloadbalancing:RegisterTargets action\n\tstatus code: 403, request id: 11473f8d-a29c-4aed-ae26-794da9b9014b"
}
{
  "level": "info",
  "ts": "2024-08-09T11:15:40Z",
  "msg": "registering targets",
  "arn": "arn:aws:elasticloadbalancing:ap-northeast-2:866477832211:targetgroup/k8s-monitori-promethe-d0443b47ee/c165e8bfd2e33acd",
  "targets": [
    {
      "AvailabilityZone": null,
      "Id": "10.100.20.41",
      "Port": 3000
    }
  ]
}

왜 인지 모르겠지만 registerTarget, DeregisterTarget에 대한 권한이 없었음, 추가
```

9. alb controller error
```yaml
╰─ kubectl logs -n kube-system aws-load-balancer-controller-5d9884fd45-ghvql
{"level":"info","ts":"2024-08-11T12:31:17Z","msg":"version","GitVersion":"v2.8.1","GitCommit":"e6ce604adc0746511d58c3c81ac7eae7cdaf7bbe","BuildDate":"2024-05-31T21:34:51+0000"}
{"level":"error","ts":"2024-08-11T12:31:17Z","logger":"setup","msg":"unable to create controller","controller":"TargetGroupBinding","error":"no matches for kind \"TargetGroupBinding\" in version \"elbv2.k8s.aws/v1beta1\""}

crd를 강제로 삭제해서 이도저도 못하는 상황

-->
https://itnext.io/modify-helm-3-release-manifest-c3870b90213?gi=9b37587653d5
helm manifest를 수정하거나, helm으로 대충 설치하고 삭제하니까 정상화됨??
```

10. 최초 실행시 발생하는 에러
```yaml
Warning: Helm release "external-dns" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
│ 
│   with module.common.helm_release.external-dns,
│   on ../modules/common/external-dns.tf line 58, in resource "helm_release" "external-dns":
│   58: resource "helm_release" "external-dns" {
│ 
╵
╷
│ Warning: Helm release "fluent-bit" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
│ 
│   with module.common.helm_release.fluent-bit,
│   on ../modules/common/fluent-bit.tf line 41, in resource "helm_release" "fluent-bit":
│   41: resource "helm_release" "fluent-bit" {
│ 
╵
╷
│ Warning: Helm release "prometheus-grafana" was created but has a failed status. Use the `helm` command to investigate the error, correct it, then run Terraform again.
│ 
│   with module.common.helm_release.prometheus_grafana,
│   on ../modules/common/prometheus.tf line 7, in resource "helm_release" "prometheus_grafana":
│    7: resource "helm_release" "prometheus_grafana" {
│ 
╵
╷
│ Error: 1 error occurred:
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│ 
│ 
│ 
│   with module.common.helm_release.external-dns,
│   on ../modules/common/external-dns.tf line 58, in resource "helm_release" "external-dns":
│   58: resource "helm_release" "external-dns" {
│ 
╵
╷
│ Error: 1 error occurred:
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│ 
│ 
│ 
│   with module.common.helm_release.fluent-bit,
│   on ../modules/common/fluent-bit.tf line 41, in resource "helm_release" "fluent-bit":
│   41: resource "helm_release" "fluent-bit" {
│ 
╵
╷
│ Error: 13 errors occurred:

│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "mservice.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/mutate-v1-service?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/validate-networking-v1-ingress?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│       * Internal error occurred: failed calling webhook "vingress.elbv2.k8s.aws": failed to call webhook: Post "https://aws-load-balancer-webhook-service.kube-system.svc:443/validate-networking-v1-ingress?timeout=10s": no endpoints available for service "aws-load-balancer-webhook-service"
│ 
│ 
│ 
│   with module.common.helm_release.prometheus_grafana,
│   on ../modules/common/prometheus.tf line 7, in resource "helm_release" "prometheus_grafana":
│    7: resource "helm_release" "prometheus_grafana" {
│ 
 dependson 잘 걸어주기
```

11.
```yaml
삭제 시 node가 먼저 삭제가되어 alb controller 파드가 비정상적으로 pending 이 되어 다른 리소스가 삭제가 되지 않음
```

12, jenkins plugin down load시 network is unreachable 문제
```yaml
Downloaded and validated plugin kubernetes-client-api
Checksum valid for: kubernetes-client-api
Nov 12, 2024 4:46:04 AM org.apache.http.impl.execchain.RetryExec execute
INFO: I/O exception (java.net.SocketException) caught when processing request to {s}->https://mirrors.tuna.tsinghua.edu.cn:443: Network is unreachable

Checksum valid for: git-client
Downloaded jackson2-api from https://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/plugins/jackson2-api/2.17.0-379.v02de8ec9f64c/jackson2-api.hpi (attempt 1 of 3)
Downloaded and validated plugin jackson2-api
Downloaded durable-task from https://repo.jing.rocks/jenkins/plugins/durable-task/577.v2a_8a_4b_7c0247/durable-task.hpi (attempt 1 of 3)
Downloaded and validated plugin durable-task
Checksum valid for: jackson2-api
Checksum valid for: durable-task
Downloaded kubernetes-client-api from https://ftp.yz.yamagata-u.ac.jp/pub/misc/jenkins/plugins/kubernetes-client-api/6.10.0-240.v57880ce8b_0b_2/kubernetes-client-api.hpi (attempt 1 of 3)
Downloaded and validated plugin kubernetes-client-api
Checksum valid for: kubernetes-client-api
```

13,
```yaml
terraform 에서 argocd applicaiton resource 사용하는 경우 권한문제
```

14,
```yaml
argocd에 helm 유형의 repo를 등록하는 경우, 
error testing repository connectivity: Get 12341.dkr.ecr.ap-northeast-2.amazonaws.com/helm-charts/cad/index.yaml": unsupported protocol scheme "" 
와 같은 에러가 출력됨, 이는 enableOCI 옵션을 true 설정하면 된다.
```