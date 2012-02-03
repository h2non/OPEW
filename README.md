## IMPORTANT!
**OPEW IS CURRENTLY UNDER CONTINUOUS DEVELOPMENT AND SOFTWARE ARCHITECTURE DESIGNING. 
THIS IS JUST A PUBLIC TESTING RELEASE CANDIDATE FOR EXPERIMENTAL PROTOSALS AND 
GIVEN SOME FEEDBACK FROM THE DEVELOPERS COMMUNITY. TEST IT AND MAIL ME ANY ISSUE, IDEAS, PROBLEMS YOU EXPERIMENT VIA <tomas@rijndael-project.com>**

# About

OPEW (Open Web Development Stack) is a complete, independent and extensible open distribution stack for GNU/Linux based OS. 
Its goal is to provides an powerful and portable ready-to-run development environment focused on modern and robust (web) programming languages. 

# Features

## Languages

* PHP 
* Perl
* Python `(experimental)`
* Node.js
* Ruby `(experimental)`
* Go `(experimental)`
* Lua `(experimental)`
* Tcl `(experimental)`

## Database management systems

* MySQL 
* PostgreSQL
* SQLite
* MongoDB
* Redis

## Features list

* Much more than a LAMPP stack
* Easy to install, extend, deploy and improve
* Full language support: PHP, Ruby, Python, Perl, Node.js, Go, Tcl and Lua
* Open source DBMS included: MySQL, PostgreSQL, MongoDB and SQLite
* Native support for each language package manager 
* Indepent and portable ready-to-run stack distribution
* Git SCM and web code revision tools included
* FastCGI support for Apache handling
* phpMyAdmin, phpPgAdmin, phpSQLiteAdmin and phpMoAdmin
* Addons extensible 
* 64 bits support
* Well documented and tutorials 
* Development tools for a fast setup project environment

# Requirements

* x64 based (64 bits) compatible processor
* At once a mininal GNU/Linux (64 bits) based OS
* Minimum of 256 MB of RAM
* Minimum of 512 MB of hard disk free space (so 1GB is recommended)
* TCP/IP protocol support
* Root access level

# Installation

Get the latest OPEW release from <http://sourceforge.net/projects/opew/files/latest/download>.

After it, simply do:

```
$ chmod +x opew-1.0.*.bin
# ./opew-1.0.*.bin
```

Later, just follow the installation steps.

# Usage

When OPEW was correctly installed you can start the services (HTTP Server, MySQL, PostgreSQL...) using the following script:

```
# /opt/opew/scripts/opew (start|stop|restart|status) <service> 
```

Get help about services availables

```
# /opt/opew/scripts/opew help
```

Start coding creating a new project (beta)

```
# /opt/opew/scripts/new_project
```

Use the OPEW enviroment to start development

```
$ /opt/opew/scripts/env_opew
```

Now, you can try to run directly, for example Ruby, Node.js or PHP binaries using the OPEW environment 

```bash
# PHP version example
bash-4.1# php -v
# Node.js version example
bash-4.1# node -v
# Ruby version example
bash-4.1# ruby -v 
# Python version example
bash-4.1# python -v
```

Also (but still experimental) you can use its respective language package manager. Here an example

```bash
# Node.js NPM installation example
bash-4.1# npm install socket.io
# PHP Pecl installation example
bash-4.1# pecl install radius
# Ruby gems installation example
bash-4.1# gem install rails
# Python easy_install installation example
bash-4.1# easy_install Django
```

# Users authentication

Default OPEW services authentication credentials:

* MySQL
  - User: `root`
  - Password: `opewopew`
* PosgreSQL 
  - User: `postgres`
  - Password: `opewopew`
* HTTP Auth
 - User: `opew`
 - Password: `opew`

# Author

OPEW was born in 2010 from an idea and personal project by Tomas Aparicio in order to supply some personal development needs.
OPEW become another research project under continuous development and improvent.

# License

OPEW native code is licensed under GNU GPL 3.0 
OPEW includes a lot of packages with its respectives licenses. See the licenses/ directory for details.

# Code

All the code developed for the OPEW project should stay at the Git public repository <https://github.com/h2non/OPEW>.
Take a look at the [project site](http://opew.sf.net) for more information and documentation.

# Download

You can download the last OPEW release (beta) from:
http://sourceforge.net/projects/opew/files/latest/download

Take into account OPEW is a beta experimental version.
An improved new release with all feature is coming soon... keep updated.
More info: <http://opew.sf.net>

