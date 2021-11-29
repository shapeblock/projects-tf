terraform {
  backend "pg" {}
}

provider "kubernetes" {
  host  = var.host
  token = var.token
  cluster_ca_certificate = base64decode(
    var.ca_certificate
  )
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
    labels = {
      from = "shapeblock"
    }
  }
}


data "kubernetes_secret" "registry_creds" {
  metadata {
    name      = "registry-creds"
    namespace = "default"
  }
}

resource "kubernetes_secret" "registry_creds" {
  metadata {
    name      = "registry-creds"
    namespace = var.namespace
    labels = {
      from = "shapeblock"
    }
  }

  data = data.kubernetes_secret.registry_creds.data

  type = "kubernetes.io/dockerconfigjson"
}

// service account
resource "kubernetes_service_account" "sa" {
  metadata {
    name      = var.namespace
    namespace = var.namespace
    labels = {
      from = "shapeblock"
    }
  }
  secret {
    name = "registry-creds"
  }
  // TODO: add another secret
  image_pull_secret {
    name = "registry-creds"
  }
}

// role binding
resource "kubernetes_role_binding" "rb" {
  metadata {
    name      = var.namespace
    namespace = var.namespace
    labels = {
      from = "shapeblock"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.namespace
    namespace = var.namespace
  }
}

resource "kubernetes_role_binding" "rb_kpack" {
  metadata {
    name      = "${var.namespace}-kpack"
    namespace = var.namespace
    labels = {
      from = "shapeblock"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "kpack-controller-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.namespace
    namespace = var.namespace
  }
}

resource "kubernetes_role_binding" "rb_helm" {
  metadata {
    name      = "${var.namespace}-helm"
    namespace = var.namespace
    labels = {
      from = "shapeblock"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "helm-operator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.namespace
    namespace = var.namespace
  }
}

data "kubernetes_secret" "token" {
  metadata {
    name      = kubernetes_service_account.sa.default_secret_name
    namespace = var.namespace
  }
}
