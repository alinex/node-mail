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
    retry:
      title: "Retry"
      description: "the number of retries to take if sending failed"
      type: 'object'
      allowedKeys: true
      mandatoryKeys: true
      keys:
        times:
          title: "Number of Attempts"
          description: "the number of maximal attempts to run successfully"
          type: 'integer'
          min: 0
          default: 1
        interval:
          title: "Time to Wait"
          description: "the time to wait before retrying a failed attempt"
          type: 'interval'
          unit: 'ms'
          min: 0
          default: 5000
      default: {times: 1, interval: 5000}
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
    attachments:
      title: "Attachments"
      description: "the attachments to be included"
      type: 'array'
      allowedKeys: true
      entries:
        title: "Attachment"
        description: "the attachment to be included"
        type: 'object'
        allowedKeys: true
        keys:
          filename:
            title: "Reported Filename"
            description: "the filename to be reported as the name of the attached file
            (set this value as false to disable, default: created automatically)"
            type: 'string'
          content:
            title: "Content"
            description: "the content of the attached file"
            type: 'string'
          path:
            title: "Include File"
            description: "the path to a file or an URL if you want to stream the
            file instead of including it"
            type: 'string'
          contentType:
            title: "Content Type"
            description: "the optional content type for the attachment (autodetected)"
            type: 'string'
          contentDisposition:
            title: "Disposition"
            description: "the optional content disposition type for the attachment
            (default: attachment)"
            type: 'string'
          cid:
            title: "Content ID"
            description: "the optional content id for using inline images in HTML message source"
            type: 'string'
          encoding:
            title: "Encoding"
            description: "the content encoding like: base64, hex, binary etc."
            type: 'string'


# Complete Schema Definition
# -------------------------------------------------

exports.templates =
  title: "Email Templates"
  description: "the possible templates used for sending emails"
  type: 'object'
  entries: [email]
