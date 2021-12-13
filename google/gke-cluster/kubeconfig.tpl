apiVersion: v1
kind: Config
preferences: {}

current-context: ${cluster_name}

contexts:
  - name: ${cluster_name}
    context:
      cluster: ${cluster_name}
      user: ${cluster_name}

clusters:
  - name: ${cluster_name}
    cluster:
      server: https://${cluster_endpoint}
      certificate-authority-data: ${cluster_certificate_authority}

users:
  - name: ${cluster_name}
    user:
      token: ${access_token}
