chai = require 'chai'
expect = chai.expect
### eslint-env node, mocha ###

config = require 'alinex-config'
stubTransport = require 'nodemailer-stub-transport'
handlebars = require 'handlebars'

mail = require '../../src/index'

describe "Setup", ->

  it "should run the selfcheck on the schema", (cb) ->
    validator = require 'alinex-validator'
    schema = require '../../src/configSchema'
    validator.selfcheck schema.email, ->
      validator.selfcheck schema.templates, cb

  it "should run setup", (cb) ->
    mail.setup cb

describe "Mailing", ->

  # pre setup config
  beforeEach ->
    config.value =
      email:
        default:
          to: ['info@alinex.de']
          retry:
            times: 1
            interval: 1000

  it "should resolve email objects", ->
    result = mail.resolve
      base: 'default'
    expect(result).to.deep.equal config.value.email.default

  it "should send mail", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
    , (err, info) ->
      expect(err).to.not.exist
      expect(info.envelope.to).to.deep.equal config.value.email.default.to
      cb()

  it "should get send error", (cb) ->
    mail.send
      base: 'default'
    , (err) ->
      expect(err).to.exist
      cb()

  it "should support all options", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
      locale: 'de'
      subject: "Hello {{name}}!"
      text: "Hello {{name}}!"
      html: "Hello {{name}}!"
      attachements: false
    , (err, info) ->
      expect(err).to.not.exist
      expect(info.envelope.to).to.deep.equal config.value.email.default.to
      body = info.response?.toString()
      expect(body).to.contain 'Subject: Hello {{name}}!'
      cb()

  it "should support handlebars in subject", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
      subject: handlebars.compile "Hello {{name}}!"
    , {name: 'Alex'}, (err, info) ->
      expect(err).to.not.exist
      expect(info.envelope.to).to.deep.equal config.value.email.default.to
      body = info.response?.toString()
      expect(body).to.contain 'Subject: Hello Alex!'
      cb()

  it "should support handlebars in text and html", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
      text: handlebars.compile "Hello {{name}}!"
      html: handlebars.compile "Hello <b>{{name}}</b>!"
    , {name: 'Alex'}, (err, info) ->
      expect(err).to.not.exist
      expect(info.envelope.to).to.deep.equal config.value.email.default.to
      body = info.response?.toString()
      expect(body).to.contain 'Hello Alex!'
      expect(body).to.contain 'Hello <b>Alex</b>!'
      cb()

  it "should support body (with markdown)", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
      body: "Hello **Alex**!"
    , {name: 'Alex'}, (err, info) ->
      expect(err).to.not.exist
      expect(info.envelope.to).to.deep.equal config.value.email.default.to
      body = info.response?.toString()
      expect(body).to.contain 'Hello **Alex**!'
      expect(body).to.contain '<strong>Alex</strong>!'
      cb()

  it "should support handlebars in body", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
      body: handlebars.compile "Hello **{{name}}**!"
    , {name: 'Alex'}, (err, info) ->
      expect(err).to.not.exist
      expect(info.envelope.to).to.deep.equal config.value.email.default.to
      body = info.response?.toString()
      expect(body).to.contain 'Hello **Alex**!'
      expect(body).to.contain '<strong>Alex</strong>!'
      cb()

  it "should transform inline images to cid", (cb) ->
    mail.send
      transport: stubTransport()
      to: ['info@alinex.de']
      html: 'Image is <img src="data:image/gif;base64,R0lGODdhEAAQAMwAAPj7+FmhUYjNfGuxYYDJdYTIeanOpT+DOTuANXi/bGOrWj6CONzv2sPjv2CmV1unU4zPgISg6DJnJ3ImTh8Mtbs00aNP1CZSGy0YqLEn47RgXW8amasW7XWsmmvX2iuXiwAAAAAEAAQAAAFVyAgjmRpnihqGCkpDQPbGkNUOFk6DZqgHCNGg2T4QAQBoIiRSAwBE4VA4FACKgkB5NGReASFZEmxsQ0whPDi9BiACYQAInXhwOUtgCUQoORFCGt/g4QAIQA7">'
    , (err, info) ->
      expect(err).to.not.exist
      expect(info.envelope.to).to.deep.equal config.value.email.default.to
      body = info.response?.toString()
      expect(body).to.contain '<img src="cid:'
      cb()
