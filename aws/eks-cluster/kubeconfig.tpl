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
      server: ${cluster_endpoint}
      certificate-authority-data: ${cluster_certificate_authority}

users:
  - name: ${cluster_name}
    user:
      exec:
        apiVersion: client.authentication.k8s.io/v1alpha1
        command: aws
        args:
          - eks
          - get-token
          - --region
          - ${cluster_region}
          - --cluster-name
          - ${cluster_name}
