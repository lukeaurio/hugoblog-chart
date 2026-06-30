# hugoblog chart

Helm chart for one or more static Hugo sites published as containers.

Each entry in `values.yaml` renders its own Kubernetes objects:

- 1 `Deployment`
- 1 `Service`
- 1 optional `Ingress`

The chart keeps the container model intentionally boring:

- one site per `Deployment`
- one `Service` per site
- one optional `Ingress` per site
- one HTTP container serving built Hugo output

Each site entry in `values.yaml` is isolated from the others. That makes it easy
to run a single blog today and add more sites later without changing the basic
deployment pattern.

The chart is built from the files in `hugoblog-chart/charts/hugoblog`.

## Install

This chart is published through chart-releaser as a Helm repository. Install it
with Helm after adding the chart repository URL that points to the published
`index.yaml`:

```bash
helm repo add hugoblog lukeaurio.github.io/hugoblog-chart
helm repo update
helm upgrade --install my-blog hugoblog/hugoblog -f values.yaml
```

To render manifests without applying them:

```bash
helm template my-blog hugoblog/hugoblog -f values.yaml
```

## Container Shape

Each pod is expected to:

- listen on port `80`
- serve `/`
- respond to HTTP readiness and liveness probes

The chart wires that up directly in the deployment template, so the container
image only needs to behave like a normal static web server.

## How naming works

Resource names are derived from:

- the Helm release name
- the site name in `sites[].name`

By default, a site named `blog` installed with release `my-blog` creates
resources such as:

- `my-blog-blog` for the Deployment, Service, and Ingress

If `fullnameOverride` is set, the resource name prefix changes to that value:

- `fullnameOverride: hugoblog`
- site `blog`
- resource name becomes `hugoblog-blog`

## Quick start

The minimum useful configuration is a site with an image repository:

```yaml
sites:
  - name: blog
    image:
      repository: ghcr.io/example/my-blog
```

This uses:

- `defaults.replicaCount` for replicas
- `defaults.imagePullPolicy` for the image pull policy
- `Chart.AppVersion` for the image tag
- `defaults.serviceType` and `defaults.servicePort` for the Service

## Values

### Top-level values

| Value | Type | Default | Description |
| --- | --- | --- | --- |
| `imagePullSecrets` | list | `[]` | Pod `imagePullSecrets` passed directly to the Pod spec. Use Kubernetes `LocalObjectReference` entries such as `- name: my-secret`. |
| `nameOverride` | string | `""` | Replaces the chart name in common helper names. |
| `fullnameOverride` | string | `""` | Replaces the generated release name prefix for rendered resources. |
| `defaults.replicaCount` | int | `1` | Default replica count for each site unless overridden per site. |
| `defaults.imagePullPolicy` | string | `IfNotPresent` | Default image pull policy for each site unless overridden per site. |
| `defaults.serviceType` | string | `ClusterIP` | Default Service type for each site unless overridden per site. |
| `defaults.servicePort` | int | `80` | Default Service port for each site unless overridden per site. |
| `podSecurityContext` | map | `{}` | Pod-level security context passed directly to the Pod spec. |
| `securityContext` | map | `{}` | Container-level security context passed directly to the container spec. |
| `sites` | list | required | List of site definitions. Each entry produces a separate set of Kubernetes resources. |
| `nodeSelector` | map | `{}` | Applied to every site Pod. |
| `tolerations` | list | `[]` | Applied to every site Pod. |
| `affinity` | map | `{}` | Applied to every site Pod. |

### Site values

Each entry in `sites` supports the following fields:

| Value | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | string | chart name | Site identifier used in resource names and labels. Keep it unique within the release. |
| `replicaCount` | int | `defaults.replicaCount` | Replica count for this site. |
| `image.repository` | string | required | Container image repository. This is required. |
| `image.tag` | string | `Chart.AppVersion` | Container image tag. |
| `image.pullPolicy` | string | `defaults.imagePullPolicy` | Pull policy for this site. |
| `service.type` | string | `defaults.serviceType` | Service type for this site. |
| `service.port` | int | `defaults.servicePort` | Service port for this site. |
| `ingress.enabled` | bool | `false` | When `true`, renders an Ingress for the site. |
| `ingress.className` | string | `""` | Optional `ingressClassName` for the Ingress. |
| `ingress.annotations` | map | `{}` | Extra annotations added to the Ingress metadata. |
| `ingress.hosts` | list | example host | Ingress rules. Each host entry contains `host` and `paths`. |
| `ingress.tls` | list | `[]` | TLS configuration passed directly to the Ingress spec. |
| `podAnnotations` | map | `{}` | Extra annotations added to the Pod template. |
| `podLabels` | map | `{}` | Extra labels added to the Pod template. |
| `resources` | map | `{}` | Container resource requests and limits. |

### Ingress host format

When `ingress.enabled` is `true`, define hosts like this:

```yaml
ingress:
  enabled: true
  hosts:
    - host: blog.example.com
      paths:
        - path: /
          pathType: Prefix
```

Each path is passed directly into the Ingress backend and should include:

- `path`
- `pathType`

## Examples

### Single site

```yaml
defaults:
  replicaCount: 2

sites:
  - name: blog
    image:
      repository: ghcr.io/example/blog
      tag: "1.2.3"
    service:
      port: 8080
    ingress:
      enabled: true
      className: nginx
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
      hosts:
        - host: blog.example.com
          paths:
            - path: /
              pathType: Prefix
      tls:
        - secretName: blog-example-com-tls
          hosts:
            - blog.example.com
```

### Multiple sites

```yaml
sites:
  - name: personal-blog
    image:
      repository: ghcr.io/example/personal-blog
      tag: "latest"
    ingress:
      enabled: true
      hosts:
        - host: blog.example.com
          paths:
            - path: /
              pathType: Prefix

  - name: docs
    replicaCount: 3
    image:
      repository: ghcr.io/example/docs
      tag: "2026.06.30"
    service:
      type: ClusterIP
      port: 80
    podLabels:
      app.kubernetes.io/tier: content
```

## Notes

- The container port is fixed at `80`.
- Readiness and liveness probes both check `GET /` on port `http`.
- If `sites` is empty, the chart renders no workload resources.
- Site names should be unique because they become part of resource names and selectors.