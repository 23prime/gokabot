resource "aws_ssm_parameter" "gokabot-DATABASE_URL" {
  name = "gokabot.DATABASE_URL"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.database_url

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-LINE_CHANNEL_SECRET" {
  name = "gokabot.LINE_CHANNEL_SECRET"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.line_channel_secret

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-LINE_CHANNEL_TOKEN" {
  name = "gokabot.LINE_CHANNEL_TOKEN"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.line_channel_token

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-MY_USER_ID" {
  name = "gokabot.MY_USER_ID"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.my_user_id

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-GOKABOU_USER_ID" {
  name = "gokabot.GOKABOU_USER_ID"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.gokabou_user_id

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-NGA_GROUP_ID" {
  name = "gokabot.NGA_GROUP_ID"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.nga_group_id

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-KMT_GROUP_ID" {
  name = "gokabot.KMT_GROUP_ID"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.kmt_group_id

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-DISCORD_BOT_TOKEN" {
  name = "gokabot.DISCORD_BOT_TOKEN"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.discord_bot_token

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-DISCORD_TARGET_CHANNEL_ID" {
  name = "gokabot.DISCORD_TARGET_CHANNEL_ID"

  data_type = "text"
  type      = "String"
  tier      = "Standard"
  value     = var.discord_target_channel_id

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-DISCORD_TARGET_CHANNEL_ID_DEV" {
  name = "gokabot.DISCORD_TARGET_CHANNEL_ID_DEV"

  data_type = "text"
  type      = "String"
  tier      = "Standard"
  value     = var.discord_target_channel_id_dev

  tags = {
    cost = var.cost_tag
  }
}

resource "aws_ssm_parameter" "gokabot-OPEN_WEATHER_API_KEY" {
  name = "gokabot.OPEN_WEATHER_API_KEY"

  data_type = "text"
  type      = "SecureString"
  tier      = "Standard"
  key_id    = var.kms_key_alias
  value     = var.open_weather_api_key

  tags = {
    cost = var.cost_tag
  }
}
