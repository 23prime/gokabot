variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "cost_tag" {
  type = string

  default = "gokabot"
}

variable "container_port" {
  type = number

  default = 8080
}

variable "domain" {
  type = string

  default = "dev.gokabot.com"
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

variable "docker_hub_id" {
  type = string
}

variable "docker_hub_pass" {
  type = string
}
