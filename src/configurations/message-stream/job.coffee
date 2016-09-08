_       = require 'lodash'
slack = require 'slack'
MeshbluHttp = require 'meshblu-http'
MeshbluConfig = require 'meshblu-config'
SlurryStream = require 'slurry-core/slurry-stream'

class MessageStream
  constructor: ({@encrypted, @auth, @userDeviceUuid}) ->
    meshbluConfig = new MeshbluConfig({@auth}).toJSON()
    meshbluHttp = new MeshbluHttp meshbluConfig
    @_throttledMessage = _.throttle meshbluHttp.message, 500, leading: true, trailing: false

  do: ({slurry}, callback) =>
    bot = slack.rtm.client()
    slurryStream = new SlurryStream

    slurryStream.destroy = =>
      bot.close()

    bot.started (payload) =>
      bot.ws.on 'close', =>
        slurryStream.emit 'close'

      return callback null, slurryStream

    bot.message (data) =>
      message =
        devices: ["*"]
        data: data

      @_throttledMessage message, as: @userDeviceUuid, (error) =>
        slurryStream.emit 'error', error if error?

    bot.listen token: @encrypted.secrets.credentials.secret, (error) =>
      slurryStream.emit 'error', error if error?

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = MessageStream
