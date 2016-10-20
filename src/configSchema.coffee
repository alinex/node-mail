###
Configuration
===================================================
The configuration consists of two parts:
- Email Template
- Collection of Templates
###


###
Email Template
------------------------------------------------------
{@schema #email}
###

exports.email = email =
  title: "Email Action"
  description: "the setup for an individual email action"
  type: 'object'
  allowedKeys: true
  keys:
    base:
      title: "Base Template"
      description: "the template used as basis for this one"
      type: 'string'
      list: '<<<context:///email>>>'
    transport:
      title: "Service Connection"
      description: "the service connection to send mails through"
      type: 'or'
      or: [
        title: "Transport URI"
        description: "the transport method as URI string through which the mail
        will be send like `<protocol>://<user>:<password>@<server>:<port>`"
        type: 'string'
      ,
        title: "Transport Object"
        description: "the mail transport settings through which the mail will be send"
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


###
Collection of Templates
------------------------------------------------------
{@schema #templates}
###

exports.templates =
  title: "Email Templates"
  description: "the possible templates used for sending emails"
  type: 'object'
  entries: [email]


###
Addressing
--------------------------------------------------------
First you can define the sender address using:

``` yaml
from: <string> # the address used as sender(often the same as used in transport)
replyTo: <string> # address which should be used for replys
```

And you give the addresses to send the mail to. In the following fields: `to`, `cc`
and `bcc` you may give a single address or a list of addresses to use.
All e-mail addresses can be plain e-mail addresses

    name@mymailserver.com

or with formatted name (includes unicode support)

    "My Name" <name@mymailserver.com>


Content
--------------------------------------------------------
The content of the mail consists of an subject line which should be not to long
and the body. The body is given as [Markdown](http://alinex.github.io/develop/lang/markdown.html)
syntax and supports all possibilities from
[report](http://alinex.github.io/node-report/README.md.html#markup%20syntax).
This will be converted to a plain text and html version for sending so that the
mail client can choose the format to display.

You may also give the 'text' and 'html' content as property itself. But keep in
mind that within the base properties no markdown conversions are done. In the
'body' it will.

Like you see above, you can use handlebar syntax to use some variables from the
code. This is possible in subject and body. And you may specify a
locale to use for date formatting.

You can also define different templates which can be referenced from within the
job.

Find more examples at [validator](http://alinex.github.io/node-validator/README.md.html#handlebars).


Attachments
--------------------------------------------------
The key `attachments` is used to add a list of files attached to the email and
consists of the following properties:

- `path` path to a file or an URL to include
- `filename` filename to be reported as the name of the attached file
- `content` String, Buffer or a Stream contents for the attachment
- `contentType` optional content type for the attachment, if not set will be
  derived from the filename property
- `contentDisposition` optional content disposition type for the attachment,
  defaults to ‘attachment’
- `cid` optional content id for using inline images in HTML message source
- `encoding` If set and content is string, then encodes the content to a Buffer
  using the specified encoding. Example values: base64, hex, binary etc.
- `headers` custom headers for the attachment node
###
