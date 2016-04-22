# Api to real function
# =================================================

# Node Modules
# -------------------------------------------------

# include base modules
debug = require('debug')('mail')
chalk = require 'chalk'
nodemailer = require 'nodemailer'
moment = require 'moment'
fspath = require 'path'
# include alinex modules
config = require 'alinex-config'
async = require 'alinex-async'
util = require 'alinex-util'
Report = null # load on demand
# internal helpers
schema = require './configSchema'


# Setup
# -------------------------------------------------
# set the modules config paths and validation schema
exports.setup = async.once this, (cb) ->
  # set module search path
  config.register false, fspath.dirname __dirname
  # add schema for module's configuration
  config.setSchema '/email', schema.templates, cb


# Resolve Email Template
# -------------------------------------------------
exports.resolve = (setup) ->
  # use base settings
  while setup.base
    debug chalk.grey "loading base template #{setup.base}"
    base = config.get "/email/#{setup.base}"
    delete setup.base
    setup = util.extend 'MODE CLONE', base, setup
  setup


# Send Email
# -------------------------------------------------
exports.send = (setup, context, cb) ->
  # use base settings
  setup = exports.resolve setup
  # support handlebars
  if setup.locale # change locale
    oldLocale = moment.locale()
    moment.locale setup.locale
  setup.subject = setup.subject context if typeof setup.subject is 'function'
  addBody setup, context, ->
    if setup.locale # change locale back
      moment.locale oldLocale
    # cleanup
    delete setup.attachements if setup.attachements? is false
    # send email
    mails = setup.to?.map (e) -> e.replace /".*?" <(.*?)>/g, '$1'
    debug chalk.grey "sending email to #{mails?.join ', '}..."
    # setup transporter
    transporter = nodemailer.createTransport setup.transport ? 'direct:?name=hostname'
    if ~setup.html.indexOf "src=\"data:"
      transporter.use 'compile', require 'nodemailer-plugin-inline-base64'
    debug chalk.grey "using #{transporter.transporter.name}"
    # try to send email
    transporter.sendMail setup, (err, info) ->
      if err
        if err.errors
          debug chalk.red e.message for e in err.errors
        else
          debug chalk.red err.message
        debug chalk.grey "send through " + util.inspect setup.transport
      if info
        debug "message send: " + chalk.grey util.inspect(info).replace /\s+/, ''
        return cb new Error "Some messages were rejected: #{info.response}" if info.rejected?.length
      cb err?.errors?[0] ? err ? null


# Helper
# -------------------------------------------------

# ### Add body to mail setup from report
addBody= (setup, context, cb) ->
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
