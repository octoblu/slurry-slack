_ = require 'lodash'
PassportSlack = require 'passport-slack'

class SlackStrategy extends PassportSlack
  constructor: (env) ->
    throw new Error('Missing required environment variable: slurry_SLACK_SLACK_CLIENT_ID')     if _.isEmpty process.env.slurry_SLACK_SLACK_CLIENT_ID
    throw new Error('Missing required environment variable: slurry_SLACK_SLACK_CLIENT_SECRET') if _.isEmpty process.env.slurry_SLACK_SLACK_CLIENT_SECRET
    throw new Error('Missing required environment variable: slurry_SLACK_SLACK_CALLBACK_URL')  if _.isEmpty process.env.slurry_SLACK_SLACK_CALLBACK_URL

    options = {
      clientID:     process.env.slurry_SLACK_SLACK_CLIENT_ID
      clientSecret: process.env.slurry_SLACK_SLACK_CLIENT_SECRET
      callbackUrl:  process.env.slurry_SLACK_SLACK_CALLBACK_URL
    }

    super options, @onAuthorization

  onAuthorization: (accessToken, refreshToken, profile, callback) =>
    callback null, {
      id: profile.id
      username: profile.username
      secrets:
        credentials:
          secret: accessToken
          refreshToken: refreshToken
    }

module.exports = SlackStrategy
