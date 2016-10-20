Alinex Mail: Readme
=================================================

[![GitHub watchers](
  https://img.shields.io/github/watchers/alinex/node-mail.svg?style=social&label=Watch&maxAge=2592000)](
  https://github.com/alinex/node-mail/subscription)
<!-- {.hidden-small} -->
[![GitHub stars](
  https://img.shields.io/github/stars/alinex/node-mail.svg?style=social&label=Star&maxAge=2592000)](
  https://github.com/alinex/node-mail)
[![GitHub forks](
  https://img.shields.io/github/forks/alinex/node-mail.svg?style=social&label=Fork&maxAge=2592000)](
  https://github.com/alinex/node-mail)
<!-- {.hidden-small} -->
<!-- {p:.right} -->

[![npm package](
  https://img.shields.io/npm/v/alinex-mail.svg?maxAge=2592000&label=latest%20version)](
  https://www.npmjs.com/package/alinex-mail)
[![latest version](
  https://img.shields.io/npm/l/alinex-mail.svg?maxAge=2592000)](
  #license)
<!-- {.hidden-small} -->
[![Travis status](
  https://img.shields.io/travis/alinex/node-mail.svg?maxAge=2592000&label=develop)](
  https://travis-ci.org/alinex/node-mail)
[![Coveralls status](
  https://img.shields.io/coveralls/alinex/node-mail.svg?maxAge=2592000)](
  https://coveralls.io/r/alinex/node-mail?branch=master)
[![Gemnasium status](
  https://img.shields.io/gemnasium/alinex/node-mail.svg?maxAge=2592000)](
  https://gemnasium.com/alinex/node-mail)
[![GitHub issues](
  https://img.shields.io/github/issues/alinex/node-mail.svg?maxAge=2592000)](
  https://github.com/alinex/node-mail/issues)
<!-- {.hidden-small} -->


An easy to use module for sending mails.

- fully configurable
- configuration templates
- using markdown with auto text/html creation
- support for handlebars templates

While sending mails it will also transform inline images in html into cid images
attached to the mail to make it more standard conform.

> It is one of the modules of the [Alinex Namespace](https://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](https://alinex.github.io/develop).

__Read the complete documentation under
[https://alinex.github.io/node-mail](https://alinex.github.io/node-mail).__
<!-- {p: .hidden} -->


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
The configuration is based on multiple email templates. They can be made on top of
each other.

They will be defined under `/email` and  an example may look like:

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

Read more at the {@link configSchema.coffee} page.


Debugging
----------------------------------------------
If you have any problems you may always run it with debugging by setting the `DEBUG`
environment variable like:

``` coffee
DEBUG=mail* myprog-usingsshtunnel
```

The following targets are possible:
- `mail` general logging
- `mail:data` output all mail elements instead of only the envelope

If you enable debugging of `mail` the given configuration will also be validated.


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
