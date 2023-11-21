locals {
  variant           = var.driver_version == "" ? "cpu" : "gpu"
  instance_type     = var.arch == "amd64" ? "m7i.large" : "m7g.large"
  helpers_directory = "/home/runner/helpers"
  image_id = join(
    "-",
    [
      for v in
      [
        var.image_name,
        var.timestamp
      ]
      : v if v != ""
    ]
  )
}
