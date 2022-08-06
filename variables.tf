variable environment {
    type        = string
    default     = "Development"
}


variable local_private_key {
    type        = string
    description = "Private key used to deploy resources to local instance"
    sensitive   = true
}


variable postgres_password {
    type        = string
    description = "Postgres database password"
    sensitive   = true
}
