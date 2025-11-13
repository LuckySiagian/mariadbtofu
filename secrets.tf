resource "kubernetes_secret" "mariadb_secret" {
  metadata {
    name = "mariadb-secret"
  }

  data = {
    mariadb-password = base64encode("siskaweek12")
  }

  type = "Opaque"
}
