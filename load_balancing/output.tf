output "lb_url" {
  value = "http://${module.lb-http.external_ip}"
}
