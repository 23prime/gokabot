variable "cost_tag" {
  type = string
}

variable "database_url" {
  type = string
}

variable "line_channel_secret" {
  type = string
}

variable "line_channel_token" {
  type = string
}

variable "my_user_id" {
  type = string
}

variable "gokabou_user_id" {
  type = string
}

variable "nga_group_id" {
  type = string
}

variable "kmt_group_id" {
  type = string
}

variable "discord_bot_token" {
  type = string
}

variable "discord_target_channel_id" {
  type = string
}

variable "discord_target_channel_id_dev" {
  type = string
}

variable "open_weather_api_key" {
  type = string
}

variable "kms_key_alias" {
  type = string

  default = "alias/aws/ssm"
}
