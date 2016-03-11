Package: alinex-mail
=================================================

[![Build Status](https://travis-ci.org/alinex/node-mail.svg?branch=master)](https://travis-ci.org/alinex/node-mail)
[![Coverage Status](https://coveralls.io/repos/alinex/node-mail/badge.png?branch=master)](https://coveralls.io/r/alinex/node-mail?branch=master)
[![Dependency Status](https://gemnasium.com/alinex/node-mail.png)](https://gemnasium.com/alinex/node-mail)

An easy to use module for sending mails.

- support for handlebars
- support for report
- support for templates
- fully configurable

While sending mails it will also transform inline images in html into cid images
attached to the mail to make it more standard conform.

> It is one of the modules of the [Alinex Universe](http://alinex.github.io/code.html)
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
```


Configuration
-------------------------------------------------



License
-------------------------------------------------

Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
