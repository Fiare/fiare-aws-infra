resource "kubernetes_deployment" "app" {
  metadata {
    name      = "deployment"
    namespace = "test-nginx"
    labels    = {
      app = "test-nginx"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "test-nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "test-nginx"
        }
      }

      spec {
        container {
          image = "729854234451.dkr.ecr.eu-west-1.amazonaws.com/fads6-test-nginx:latest"
          name  = "test-nginx"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [aws_eks_fargate_profile.main]
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "service-nginx-test"
    namespace = "ngoinx-test"
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.app]
}
