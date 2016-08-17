http    = require 'http'
_       = require 'lodash'
Slack = require 'slack'
MeshbluHttp = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'

class PublicFilteredStream
  constructor: ({@encrypted, @auth, @userDeviceUuid}) ->
    meshbluConfig = new MeshbluConfig({@auth}).toJSON()
    meshbluHttp = new MeshbluHttp meshbluConfig
    @slack = new Slack({
      consumer_key:        process.env.SLURRY_SLACK_SLACK_CLIENT_ID
      consumer_secret:     process.env.SLURRY_SLACK_SLACK_CLIENT_SECRET
      access_token_key:    @encrypted.secrets.credentials.token
      access_token_secret: @encrypted.secrets.credentials.secret
    })
    @_throttledMessage = _.throttle meshbluHttp.message, 500, leading: true, trailing: false

  do: ({slurry}, callback) =>
    metadata =
      track: _.join(slurry.track, ',')
      follow: _.join(slurry.follow, ',')

    @slack.stream 'statuses/filter', metadata, (stream) =>
      stream.on 'data', (event) =>
        message =
          devices: ['*']
          metadata: metadata
          data: event

        @_throttledMessage message, as: @userDeviceUuid, (error) =>
          console.error error if error?

      stream.on 'error', (error) =>
        console.error error.stack

      return callback null, stream

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = PublicFilteredStream
