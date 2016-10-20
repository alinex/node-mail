# Mail Module
# =================================================


# Node Modules
# -------------------------------------------------
debug = require('debug') 'mail'
debugData = require('debug') 'mail:data'
chalk = require 'chalk'
nodemailer = require 'nodemailer'
moment = require 'moment'
fspath = require 'path'
# include alinex modules
config = require 'alinex-config'
util = require 'alinex-util'
Report = null # load on demand
validator = null # loaded on demand
# internal helpers
schema = require './configSchema'


# Setup
# -------------------------------------------------

# Set the modules config paths and validation schema
#
# @param {Function(<Error>)} cb callback with error if something went wrong
exports.setup = util.function.once this, (cb) ->
  # set module search path
  config.register false, fspath.dirname __dirname
  # add schema for module's configuration
  config.setSchema '/email', schema.templates, cb


# Resolve Email Template
# -------------------------------------------------
# This step is not neccessary in general but if you want to change something
# between this step and the real sending you have to call this step on your own.

# Resolve template inheritance.
#
# @param {Object} setup settings for email with possible `base` entry
# @return {Object} with `base` entry resolved
exports.resolve = (setup) ->
  if debug.enabled
    validator ?= require 'alinex-validator'
    validator.checkSync
      name: 'mailSetup'
      title: "Mail Sending Setup"
      value: setup
      schema: schema.email
  # use base settings
  while setup.base
    debug chalk.grey "loading base template #{setup.base}" if debug.enabled
    base = config.get "/email/#{setup.base}"
    delete setup.base
    setup = util.extend 'MODE CLONE', base, setup
  setup


# Send Email
# -------------------------------------------------

# @param {Object} setup settings for email with possible `base` entry
# @param {Object} context data for handlebars replacement in the template
# @param {Function(<Error>, Object)} cb callback with error if something went wrong
# or the object with additional information if the mail was send
exports.send = (setup, context, cb) ->
  if typeof context is 'function'
    cb = context
    context = null
  if debug.enabled
    validator ?= require 'alinex-validator'
    validator.checkSync
      name: 'mailSetup'
      title: "Mail Sending Setup"
      value: setup
      schema: schema.email
  # use base settings
  setup = exports.resolve setup
  # support handlebars
  if setup.locale # change locale
    oldLocale = moment.locale()
    moment.locale setup.locale
  setup.subject = setup.subject context if typeof setup.subject is 'function'
  setup.text = setup.text context if typeof setup.text is 'function'
  setup.html = setup.html context if typeof setup.html is 'function'
  addBody setup, context, ->
    if setup.locale # change locale back
      moment.locale oldLocale
    # send email
    mails = setup.to?.map (e) -> e.replace /".*?" <(.*?)>/g, '$1'
    debug chalk.grey "sending email to #{mails?.join ', '}..." if debug.enabled
    # setup transporter
    transporter = nodemailer.createTransport setup.transport ? 'direct:?name=hostname'
    if setup.html and ~setup.html.indexOf "src=\"data:"
      transporter.use 'compile', require 'nodemailer-plugin-inline-base64'
    debug chalk.grey "using #{transporter.transporter.name}" if debug.enabled
    # try to send email
    send transporter, setup, cb


# Helper
# -------------------------------------------------

# Add body to mail setup from report and transform it into text and html.
#
# @param {Object} setup settings for email with possible `base` entry
# @param {Object} context data for handlebars replacement in the template
# @param {Function(<Error>, Object)} cb callback with error if something went wrong
addBody = (setup, context, cb) ->
  return cb() unless setup.body
  source = if typeof setup.body is 'function' then setup.body(context) else setup.body
  Report ?= require 'alinex-report'
  report = new Report
    source: source
  report.toHtml
    inlineCss: true
    locale: setup.locale
  , (err, html) ->
    setup.text = report.toText()
    setup.html = html
    delete setup.body
    cb err

# Sending mail with retry.
#
# @param {Object} setup settings for email with possible `base` entry
# @param {Object} context data for handlebars replacement in the template
# @param {Function(<Error>, Object)} cb callback with error if something went wrong
# or the object with additional information if the mail was send
send = (transporter, setup, cb, count = 0) ->
  debug chalk.grey "try #{count + 1}" if debug.enabled
  transporter.sendMail setup, (err, info) ->
    if err and debug.enabled
      if err.errors
        debug chalk.red e.message for e in err.errors
      else
        debug chalk.red err.message
      debug chalk.grey "send through " + util.inspect setup.transport
    if info
      if debug.enabled
        debug "message send: #{util.inspect(info.envelope).replace /\s+/, ''}" +
          chalk.grey " messageId: #{info.messageId}"
        if debugData.enabled
          for key, value of setup
            continue if key in ['retry']
            debugData chalk.grey "#{key}: #{util.inspect value}"
        debug "server response\n" + chalk.grey info.response
      if info.rejected?.length
        return cb new Error "Some messages were rejected: #{info.response}"
    # return if success
    return cb null, info unless err
    # retry on error
    if count < setup.retry?.times ? 0
      return send transporter, setup, cb, count + 1
    # failed completely
    cb err?.errors?[0] ? err ? null, info
