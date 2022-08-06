terraform {
  cloud {
    organization = "yeebs"

    workspaces {
      name = "home-monitoring"
    }
  }
}
