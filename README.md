# hugoblog chart

Helm chart for one or more static Hugo sites published as containers.

Each entry in `hugoblog/values.yaml` creates one Deployment, Service, and optional Ingress.

Example:

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
