chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

config = require 'alinex-config'
stubTransport = require 'nodemailer-stub-transport'

describe "Base", ->

  mail = require '../../src/index'

  it "should run the selfcheck on the schema", (cb) ->
    validator = require 'alinex-validator'
    schema = require '../../src/configSchema'
    validator.selfcheck schema.email, ->
      validator.selfcheck schema.templates, cb

  it "should run setup", (cb) ->
    mail.setup cb

  it "should resolve email objects", ->
    config.value =
      email:
        default:
          to: ['info@alinex.de']
    result = mail.resolve
      base: 'default'
    expect(result).to.deep.equal config.value.email.default

  it "should send mail", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
    , (err, info) ->
      console.log err, info
      cb()
