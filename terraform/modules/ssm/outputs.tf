output "gokabot-ssm-params" {
  value = {
    DATABASE_URL                  = aws_ssm_parameter.gokabot-DATABASE_URL
    LINE_CHANNEL_SECRET           = aws_ssm_parameter.gokabot-LINE_CHANNEL_SECRET
    LINE_CHANNEL_TOKEN            = aws_ssm_parameter.gokabot-LINE_CHANNEL_TOKEN
    MY_USER_ID                    = aws_ssm_parameter.gokabot-MY_USER_ID
    GOKABOU_USER_ID               = aws_ssm_parameter.gokabot-GOKABOU_USER_ID
    NGA_GROUP_ID                  = aws_ssm_parameter.gokabot-NGA_GROUP_ID
    KMT_GROUP_ID                  = aws_ssm_parameter.gokabot-KMT_GROUP_ID
    DISCORD_BOT_TOKEN             = aws_ssm_parameter.gokabot-DISCORD_BOT_TOKEN
    DISCORD_TARGET_CHANNEL_ID     = aws_ssm_parameter.gokabot-DISCORD_TARGET_CHANNEL_ID
    DISCORD_TARGET_CHANNEL_ID_DEV = aws_ssm_parameter.gokabot-DISCORD_TARGET_CHANNEL_ID_DEV
    OPEN_WEATHER_API_KEY          = aws_ssm_parameter.gokabot-OPEN_WEATHER_API_KEY
  }
}

