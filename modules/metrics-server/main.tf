# Metrics Server for Kubernetes HPA
# This module installs the Metrics Server which is required for HPA to work with resource-based metrics

resource "kubernetes_namespace" "metrics_server" {
  count = var.create_namespace ? 1 : 0
  
  metadata {
    name = var.namespace
    labels = var.tags
  }
}

# Install Metrics Server using kubectl provider
resource "kubernetes_manifest" "metrics_server" {
  manifest = {
    apiVersion = "v1"
    kind       = "Namespace"
    metadata = {
      name = var.namespace
      labels = var.tags
    }
  }
}

# ServiceAccount for Metrics Server
resource "kubernetes_manifest" "metrics_server_service_account" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "metrics-server"
      namespace = var.namespace
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
  }
}

# ClusterRole for Metrics Server
resource "kubernetes_manifest" "metrics_server_cluster_role" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRole"
    metadata = {
      name = "system:aggregated-metrics-reader"
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
        "rbac.authorization.k8s.io/aggregate-to-view" = "true"
        "rbac.authorization.k8s.io/aggregate-to-edit" = "true"
        "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
      })
    }
    rules = [
      {
        apiGroups = ["metrics.k8s.io"]
        resources = ["pods", "nodes"]
        verbs     = ["get", "list"]
      }
    ]
  }
}

# ClusterRoleBinding for Metrics Server
resource "kubernetes_manifest" "metrics_server_cluster_role_binding" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "metrics-server:system:auth-delegator"
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "ClusterRole"
      name     = "system:auth-delegator"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "metrics-server"
        namespace = var.namespace
      }
    ]
  }
}

# RoleBinding for Metrics Server
resource "kubernetes_manifest" "metrics_server_role_binding" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "RoleBinding"
    metadata = {
      name      = "metrics-server-auth-reader"
      namespace = "kube-system"
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "Role"
      name     = "extension-apiserver-authentication-reader"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "metrics-server"
        namespace = var.namespace
      }
    ]
  }
}

# ClusterRole for Metrics Server
resource "kubernetes_manifest" "metrics_server_cluster_role_main" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRole"
    metadata = {
      name = "system:metrics-server"
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    rules = [
      {
        apiGroups = [""]
        resources = ["pods", "nodes", "nodes/stats", "namespaces", "configmaps"]
        verbs     = ["get", "list"]
      }
    ]
  }
}

# ClusterRoleBinding for Metrics Server
resource "kubernetes_manifest" "metrics_server_cluster_role_binding_main" {
  manifest = {
    apiVersion = "rbac.authorization.k8s.io/v1"
    kind       = "ClusterRoleBinding"
    metadata = {
      name = "system:metrics-server"
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io"
      kind     = "ClusterRole"
      name     = "system:metrics-server"
    }
    subjects = [
      {
        kind      = "ServiceAccount"
        name      = "metrics-server"
        namespace = var.namespace
      }
    ]
  }
}

# Service for Metrics Server
resource "kubernetes_manifest" "metrics_server_service" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "metrics-server"
      namespace = var.namespace
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    spec = {
      ports = [
        {
          name       = "https"
          port       = 443
          protocol   = "TCP"
          targetPort = "https"
        }
      ]
      selector = {
        "k8s-app" = "metrics-server"
      }
    }
  }
}

# APIService for Metrics Server
resource "kubernetes_manifest" "metrics_server_api_service" {
  manifest = {
    apiVersion = "apiregistration.k8s.io/v1"
    kind       = "APIService"
    metadata = {
      name = "v1beta1.metrics.k8s.io"
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    spec = {
      service = {
        name      = "metrics-server"
        namespace = var.namespace
      }
      group                    = "metrics.k8s.io"
      version                  = "v1beta1"
      insecureSkipTLSVerify    = true
      groupPriorityMinimum     = 100
      versionPriority          = 100
    }
  }
}

# Deployment for Metrics Server
resource "kubernetes_manifest" "metrics_server_deployment" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "metrics-server"
      namespace = var.namespace
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          "k8s-app" = "metrics-server"
        }
      }
      strategy = {
        rollingUpdate = {
          maxUnavailable = 0
        }
      }
      template = {
        metadata = {
          labels = merge(var.tags, {
            "k8s-app" = "metrics-server"
          })
        }
        spec = {
          serviceAccountName = "metrics-server"
          containers = [
            {
              name  = "metrics-server"
              image = "registry.k8s.io/metrics-server/metrics-server:v0.6.4"
              args = [
                "--cert-dir=/tmp",
                "--secure-port=10250",
                "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
                "--kubelet-use-node-status-port",
                "--metric-resolution=15s",
                "--kubelet-insecure-tls"
              ]
              securityContext = {
                allowPrivilegeEscalation = false
                readOnlyRootFilesystem   = true
                runAsNonRoot             = true
                runAsUser                = 1000
                runAsGroup               = 1000
                capabilities = {
                  drop = ["ALL"]
                }
                seccompProfile = {
                  type = "RuntimeDefault"
                }
              }
              ports = [
                {
                  name          = "https"
                  containerPort = 10250
                  protocol      = "TCP"
                }
              ]
              readinessProbe = {
                httpGet = {
                  path   = "/readyz"
                  port   = "https"
                  scheme = "HTTPS"
                }
                initialDelaySeconds = 20
                periodSeconds       = 10
              }
              livenessProbe = {
                httpGet = {
                  path   = "/livez"
                  port   = "https"
                  scheme = "HTTPS"
                }
                initialDelaySeconds = 20
                periodSeconds       = 10
              }
              resources = {
                requests = {
                  cpu    = "100m"
                  memory = "200Mi"
                }
                limits = {
                  cpu    = "100m"
                  memory = "200Mi"
                }
              }
              volumeMounts = [
                {
                  name      = "tmp-dir"
                  mountPath = "/tmp"
                }
              ]
            }
          ]
          volumes = [
            {
              name = "tmp-dir"
              emptyDir = {}
            }
          ]
          nodeSelector = {
            "kubernetes.io/os" = "linux"
          }
        }
      }
    }
  }
}

# Pod Disruption Budget for high availability
resource "kubernetes_manifest" "metrics_server_pdb" {
  manifest = {
    apiVersion = "policy/v1"
    kind       = "PodDisruptionBudget"
    metadata = {
      name      = "metrics-server"
      namespace = var.namespace
      labels = merge(var.tags, {
        "k8s-app" = "metrics-server"
      })
    }
    spec = {
      minAvailable = 1
      selector = {
        matchLabels = {
          "k8s-app" = "metrics-server"
        }
      }
    }
  }
}
