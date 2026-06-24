# hugoblog chart

Helm chart for one or more static Hugo sites published as containers.

The chart keeps the container model intentionally boring:

- one site per `Deployment`
- one `Service` per site
- one optional `Ingress` per site
- one HTTP container serving the built Hugo output

Each site entry in `values.yaml` is isolated from the others. That makes it easy to run a single blog today and add more sites later without changing the basic deployment pattern.

## Container Shape

Each pod is expected to:

- listen on port `80`
- serve `/`
- respond to HTTP readiness and liveness probes

The chart wires that up directly in the deployment template, so the container image only needs to behave like a normal static web server.

## Site Configuration

The main site settings live under `sites`:

- `name` becomes part of the Kubernetes resource names
- `image.repository` is required
- `image.tag` defaults to the chart app version when omitted
- `image.pullPolicy` defaults to `IfNotPresent`
- `replicaCount` defaults to `1`
- `service.type` defaults to `ClusterIP`
- `service.port` defaults to `80`
- `ingress.enabled` controls whether an Ingress is rendered

Per-site pod settings are also available:

- `podAnnotations`
- `podLabels`
- `resources`

Cluster-wide settings are available too:

- `imagePullSecrets`
- `nodeSelector`
- `tolerations`
- `affinity`

## Example

```yaml
sites:
  - name: blog-willberto-biz
    image:
      repository: ghcr.io/willberto/blog-willberto-biz
      tag: latest
    ingress:
      enabled: true
      className: nginx
      hosts:
        - host: blog.willberto.biz
          paths:
            - path: /
              pathType: Prefix
```

## Mental Model

If you only remember one thing, make it this: the chart is not trying to orchestrate a complex app. It is just packaging static Hugo sites into small, predictable containers and exposing them through normal Kubernetes primitives.
