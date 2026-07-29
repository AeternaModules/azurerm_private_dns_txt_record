variable "private_dns_txt_records" {
  description = <<EOT
Map of private_dns_txt_records, attributes below
Required:
    - name
    - private_dns_zone_id
    - ttl
    - record (block):
        - value (required)
Optional:
    - tags
EOT

  type = map(object({
    name                = string
    private_dns_zone_id = string
    ttl                 = number
    tags                = optional(map(string))
    record = list(object({
      value = string
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.private_dns_txt_records : (
        length(v.record) >= 1
      )
    ])
    error_message = "Each record list must contain at least 1 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.private_dns_txt_records : (
        length(trimspace(v.name)) > 0
      )
    ])
    error_message = "must not be empty or only whitespace"
  }
  validation {
    condition = alltrue([
      for k, v in var.private_dns_txt_records : (
        alltrue([for item in v.record : (length(item.value) >= 1 && length(item.value) <= 1024)])
      )
    ])
    error_message = "must be between 1 and 1024 characters"
  }
  validation {
    condition = alltrue([
      for k, v in var.private_dns_txt_records : (
        v.tags == null || (length(v.tags) <= 50)
      )
    ])
    error_message = "[from tags.Validate: invalid when len(value) > 50]"
  }
  # Note: 6 additional provider-side validators are enforced at apply time but not mirrored as validation{} blocks here (bespoke or non-mechanically-translatable).
}

