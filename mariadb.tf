############################################
# mariadb.tf
# Deployment, PVC, dan Service untuk MariaDB
############################################

# PersistentVolumeClaim untuk data MariaDB
resource "kubernetes_persistent_volume_claim" "mariadb_pvc" {
  metadata {
    name = "mariadb-pvc"
    labels = {
      app = "mariadb"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
    # storage_class_name optional: hapus/comment jika tidak dipakai di Minikube
    # storage_class_name = "standard"
  }
}

# Deployment MariaDB
resource "kubernetes_deployment" "mariadb" {
  metadata {
    name = "mariadb"
    labels = {
      app = "mariadb"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mariadb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mariadb"
        }
      }

      spec {
        container {
          name  = "mariadb"
          image = "mariadb:10.6"   # gunakan tag yang spesifik, jangan "mariadb: latest"
          
          port {
            container_port = 3306
          }

          env {
            name = "MARIADB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mariadb-secret"
                key  = "mariadb-password"
              }
            }
          }

          env {
            name  = "MARIADB_DATABASE"
            value = "lukas"          # ubah jika mau nama DB berbeda (mis. "ariel")
          }

          volume_mount {
            name       = "mariadb-storage"
            mount_path = "/var/lib/mysql"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        } # container

        volume {
          name = "mariadb-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mariadb_pvc.metadata[0].name
          }
        } # volume
      } # spec
    } # template
  } # spec
}

# Service (NodePort) untuk MariaDB
resource "kubernetes_service" "mariadb" {
  metadata {
    name = "mariadb"
    labels = {
      app = "mariadb"
    }
  }

  spec {
    selector = {
      app = "mariadb"
    }

    port {
      port        = 3306
      target_port = 3306
      node_port   = 30306
    }

    type = "NodePort"
  }
}
