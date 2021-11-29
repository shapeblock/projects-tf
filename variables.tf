variable "cluster_name" {
  description = "Name of the k8s cluster."
}

variable "host" {
  description = "The cluster hostname"
}

variable "token" {
  description = "Service account token"
}

variable "ca_certificate" {
  description = "Cluster CA certificate"
}

variable "namespace" {
  description = "Namespace name."
}
