Package: alinex-mail
=================================================

[![Build Status](https://travis-ci.org/alinex/node-mail.svg?branch=master)](https://travis-ci.org/alinex/node-mail)
[![Coverage Status](https://coveralls.io/repos/alinex/node-mail/badge.png?branch=master)](https://coveralls.io/r/alinex/node-mail?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-mail.png)](https://gemnasium.com/alinex/node-mail)

An easy to use module for sending mails.

- fully configurable
- configuration templates
- using markdown with auto text/html creation
- support for handlebars templates

While sending mails it will also transform inline images in html into cid images
attached to the mail to make it more standard conform.

> It is one of the modules of the [Alinex Namespace](http://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](http://alinex.github.io/develop).


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/alinex-mail.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/alinex-mail.png?months=9&height=3)
](https://www.npmjs.com/package/alinex-mail)

The easiest way is to let npm add the module directly to your modules
(from within you node modules directory):

``` sh
npm install alinex-mail --save
```

And update it to the latest version later:

``` sh
npm update alinex-mail --save
```

This package will install a lot of subpackages to ensure the full functionality
but only the ones really needed are loaded on demand.

Always have a look at the latest [changes](Changelog.md).


Usage
-------------------------------------------------

The first step is to load the module:

``` coffee
mail = require 'alinex-mail'
```

And now you simply send your mails:

``` coffee
mail.send
  base: 'default'
  subject: 'Test'
, context, (err) ->
  # handling of errors or success
```

The above setup is all you may need to send an email. All the missing information
is taken from it's base. Which is like always defined as a configuration setting.

The context is optional and only used if the mail's body contains handlebars
templates.

If you want to validate email settings within you applications configuration, you
may use the schema from this package:

``` coffee
emailSchema = require('alinex-mail/lib/configSchema').email
```

You may also resolve the email templates before sending it:

``` coffee
setup = mail.resolve setup
```


Configuration
-------------------------------------------------

The configuration is based on multiple email templates.

### Email Templates

They will be defined under `/email`:

``` yaml
# Email Templates
# =================================================


# Default Email Templates
# -------------------------------------------------
# This will extend/overwrite the already existing setup within the code.
default:
  # specify how to connect to the server
  transport: smtp://alexander.schilling%40mycompany.de:<PASSWORD>@mail.mycompany.de
  # specify retries
  retry:
    times: 1 # makes 2 tries at max
    interval: 5s
  # sender address
  from: alexander.schilling@mycompany.de
  replyTo: somebody@mycompany.de

  # content
  locale: en
  subject: >
    Database Report: {{name}}
  body: |+
    {{conf.title}}
    ==========================================================================

    {{conf.description}}

    Started at {{dateFormat date "LLL"}}:

    | Zeilen | Datei    | Beschreibung |
    | ------:| -------- | ------------ |
    {{#each result}}
    | {{rows}} | {{file}} | {{description}} |
    {{/each}}

    Find the files attached to your mail if data available!
```

To make it more modular you may also add a `base` setting to use the setting defined
there as a base and the options here may overwrite or enhance the base setup.

#### Transport

The transport setting defines how to send the email. This should specify the
connection for the mailserver to use for sending. It is possible to do this using
a connection url like above with the syntax:

    <protocol>://<user>:<password>@<server>:<port>

Or you may specify it as object like:

``` yaml
transport:
  pool: <boolean> # use pooled connections defaults to false
  direct: <boolean> # set to true to try to connect directly to recipients MX
  service: <string> # name of well-known service (will set host, port and secure options)
  # services: 1und1, AOL, DebugMail.io, DynectEmail, FastMail, GandiMail, Gmail,
  # Godaddy, GodaddyAsia, GodaddyEurope, hot.ee, Hotmail, iCloud, mail.ee, Mail.ru,
  # Mailgun, Mailjet, Mandrill, Naver, Postmark, QQ, QQex, SendCloud, SendGrid,
  # SES, Sparkpost, Yahoo, Yandex, Zoho
  host: <string> # the hostname or IP address to connect to
  port: <integer> # the port to connect to (defaults to 25 or 465)
  secure: <boolean> # if true the connection will only use TLS else (the default)
  # TLS may still be upgraded to if available via the STARTTLS command
  ignoreTLS: <boolean> # if this is true and secure is false, TLS will not be used
  requireTLS: <boolean> # if this is true and secure is false, it uses STARTTLS
  # even if the server does not advertise support for it
  tls: <object> # additional socket options like `{rejectUnauthorized: true}`
  auth: # authentication objects
    user: <string> # the username
    pass: <string> # the password for the user
  authMethod: <string> # preferred authentication method, eg. ‘PLAIN’
  name: <string> # hostname of the client, used for identifying to the server
  localAddress: <string> # the local interface to bind to for network connections
  connectionTimeout: <integer> # milliseconds to wait for the connection to establish
  greetingTimeout: <integer> # milliseconds to wait for the greeting after connection is established
  socketTimeout: <integer> # milliseconds of inactivity to allow
  debug: <boolean> # set to true to log the complete SMTP traffic
  # if pool is set to true:
  maxConnections: <integer> # the count of maximum simultaneous connections (defaults to 5)
  maxMessages: <integer> # limits the message count to be sent using a single connection (defaults to 100)
  rateLimit: <integer> # limits the message count to be sent in a second (defaults to false)    
```

#### Addressing

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

#### Content

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

#### Attachments

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



License
-------------------------------------------------

(C) Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
