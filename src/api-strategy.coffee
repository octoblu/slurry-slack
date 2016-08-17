_ = require 'lodash'
PassportSlack = require('passport-slack').Strategy

class SlackStrategy extends PassportSlack
  constructor: (env) ->
    throw new Error('Missing required environment variable: SLURRY_SLACK_SLACK_CLIENT_ID')     if _.isEmpty process.env.SLURRY_SLACK_SLACK_CLIENT_ID
    throw new Error('Missing required environment variable: SLURRY_SLACK_SLACK_CLIENT_SECRET') if _.isEmpty process.env.SLURRY_SLACK_SLACK_CLIENT_SECRET
    throw new Error('Missing required environment variable: SLURRY_SLACK_SLACK_CALLBACK_URL')  if _.isEmpty process.env.SLURRY_SLACK_SLACK_CALLBACK_URL

    options = {
      clientID:     process.env.SLURRY_SLACK_SLACK_CLIENT_ID
      clientSecret: process.env.SLURRY_SLACK_SLACK_CLIENT_SECRET
      callbackUrl:  process.env.SLURRY_SLACK_SLACK_CALLBACK_URL
      scope: "client"
    }

    super options, @onAuthorization

  onAuthorization: (accessToken, refreshToken, profile, callback) =>
    callback null, {
      id: profile.id
      username: profile.displayName
      secrets:
        credentials:
          secret: accessToken
          refreshToken: refreshToken
    }

module.exports = SlackStrategy
