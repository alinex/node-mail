# Configuration Schema
# =================================================


# Email Action
# -------------------------------------------------
exports.email = email =
  title: "Email Action"
  description: "the setup for an individual email action"
  type: 'object'
  allowedKeys: true
  keys:
    base:
      title: "Base Template"
      type: 'string'
      description: "the template used as base for this"
      list: '<<<context:///email>>>'
    transport:
      title: "Service Connection"
      description: "the service connection to send mails through"
      type: 'or'
      or: [
        type: 'string'
      ,
        type: 'object'
      ]
    from:
      title: "From"
      description: "the address emails are send from"
      type: 'string'
    replyTo:
      title: "Reply To"
      description: "the address to send answers to"
      type: 'string'
      optional: true
    to:
      title: "To"
      description: "the address emails are send to"
      type: 'array'
      toArray: true
      entries:
        type: 'string'
    cc:
      title: "Cc"
      description: "the carbon copy addresses"
      type: 'array'
      toArray: true
      entries:
        type: 'string'
    bcc:
      title: "Bcc"
      description: "the blind carbon copy addresses"
      type: 'array'
      toArray: true
      entries:
        type: 'string'
    locale:
      title: "Locale Setting"
      description: "the locale setting for subject and body dates"
      type: 'string'
      minLength: 2
      maxLength: 5
      lowerCase: true
      match: /^[a-z]{2}(-[a-z]{2})?$/
    subject:
      title: "Subject"
      description: "the subject line of the generated email"
      type: 'handlebars'
    body:
      title: "Content"
      description: "the body content of the generated email"
      type: 'handlebars'
    attachements:
      title: "Attachements"
      description: "should attachements be included"
      type: 'boolean'
      optional: true


# Complete Schema Definition
# -------------------------------------------------

exports.templates =
  title: "Email Templates"
  description: "the possible templates used for sending emails"
  type: 'object'
  entries: [email]
