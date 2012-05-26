#!/bin/sh
#
# OPEW - Open Web Development Stack
# This script is a part of the OPEW project 
# @package	stack/scripts/setenv.sh
# @description	Set OPEW enviroment variables
#

echo $LD_LIBRARY_PATH | egrep "/opt/opew/stack/common" > /dev/null
if [ $? -ne 0 ] ; then
PATH="/opt/opew/stack/python/bin:/opt/opew/stack/mysql/bin:/opt/opew/stack/apache2/bin:/opt/opew/stack/common/bin:$PATH"
export PATH
LD_LIBRARY_PATH="/opt/opew/stack/mysql/lib:/opt/opew/stack/python/lib:/opt/opew/stack/apache2/lib:/opt/opew/stack/common/lib::/opt/opew/stack/common/include:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
fi
 
##### IMAGEMAGICK ENV #####
MAGICK_HOME="/opt/opew/stack/common"
export MAGICK_HOME
MAGICK_CONFIGURE_PATH="/opt/opew/stack/common/lib/ImageMagick-6.5.8/config:/opt/opew/stack/common/share/ImageMagick-6.5.8/config"
export MAGICK_CONFIGURE_PATH
MAGICK_CODER_MODULE_PATH="/opt/opew/stack/common/lib/ImageMagick-6.5.8/modules-Q16/coders"
export MAGICK_CODER_MODULE_PATH

#### NGINX ENV ####
PATH="/opt/opew/stack/nginx/sbin:$PATH"
export PATH

#### LDAP ENV ####
LDAPCONF="/opt/opew/stack/common/etc/openldap/ldap.conf"
export LDAPCONF

##### PHP ENV #####
PATH="/opt/opew/stack/php/bin:$PATH"
export PATH
PHP_PEAR_SYSCONF_DIR="/opt/opew/stack/php/etc"
export PHP_PEAR_SYSCONF_DIR
#PHPRC=/opt/opew/stack/php/etc
#export PHPRC

##### MYSQL ENV #####

##### APACHE ENV #####

##### CURL ENV #####
CURL_CA_BUNDLE="/opt/opew/stack/common/openssl/certs/curl-ca-bundle.crt"
export CURL_CA_BUNDLE

#### MEMCACHED ENV ####
PATH="/opt/opew/stack/memcached/bin:$PATH"
export PATH

#### PERL ####
PATH="/opt/opew/stack/perl/bin:$PATH"
export PATH
LD_LIBRARY_PATH="/opt/opew/stack/perl/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
PERL5LIB="/opt/opew/stack/perl/lib"
export PERL5LIB

##### PERL ENV #####
PERL5LIB="/opt/opew/stack/perl/lib/5.14.2:/opt/opew/stack/perl/lib/site_perl/5.14.2"
#"/opt/opew/stack/perl/lib/site_perl/5.14.2/x86_64-linux"
export PERL5LIB

##### GIT ENV #####
GITPERLLIB="/opt/opew/stack/git/lib/site_perl/5.8.8"
export GITPERLLIB
GIT_EXEC_PATH="/opt/opew/stack/git/libexec/git-core/"
export GIT_EXEC_PATH
GIT_TEMPLATE_DIR="/opt/opew/stack/git/share/git-core/templates"
export GIT_TEMPLATE_DIR
PATH="/opt/opew/stack/git/bin:$PATH"
export PATH
LD_LIBRARY_PATH="/opt/opew/stack/git/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH

#### NODE.JS ####
PATH="/opt/opew/stack/node/bin:$PATH"
export PATH
LD_LIBRARY_PATH="/opt/opew/stack/node/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
NODE_PATH="/opt/opew/stack/node:/opt/opew/stack/node/lib/node_modules"
export NODE_PATH

#### RUBY ENV ####
PATH="/opt/opew/stack/ruby/bin:$PATH"
export PATH
LD_LIBRARY_PATH="/opt/opew/stack/ruby/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
DYLD_LIBRARY_PATH="/opt/opew/stack/ruby/lib:$DYLD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH
GEM_HOME="/opt/opew/stack/ruby/lib/ruby/gems/1.9.1"
RUBY_HOME="/opt/opew/stack/ruby"
RUBYLIB="/opt/opew/stack/ruby/lib/ruby/site_ruby/1.9.1:/opt/opew/stack/ruby/lib/ruby/site_ruby/1.9.1/x86_64-linux:/opt/opew/stack/ruby/lib/ruby/site_ruby/:/opt/opew/stack/ruby/lib/ruby/vendor_ruby/1.9.1:/opt/opew/stack/ruby/lib/ruby/vendor_ruby/1.9.1/x86_64-linux:/opt/opew/stack/ruby/lib/ruby/vendor_ruby/:/opt/opew/stack/ruby/lib/ruby/1.9.1:/opt/opew/stack/ruby/lib/ruby/1.9.1/x86_64-linux:/opt/opew/stack/ruby/lib/ruby/:/opt/opew/stack/ruby/lib"
RUBYOPT=rubygems
export GEM_HOME
export RUBY_HOME
export RUBYLIB
export RUBYOPT

#### LUA ENV ####
PATH="/opt/opew/stack/lua/bin:$PATH"

#### SQLITE3 ENV ####
PATH="/opt/opew/stack/sqlite3/bin:$PATH"
export PATH
LD_LIBRARY_PATH="/opt/opew/stack/sqlite3/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
DYLD_LIBRARY_PATH="/opt/opew/stack/sqlite3/lib:$DYLD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH

#### MONGODB ENV ####
PATH="/opt/opew/stack/mongodb/bin:$PATH"
export PATH

#### REDIS ENV ####
PATH="/opt/opew/stack/redis/bin:$PATH"
export PATH

#### PYTHON ####
PYTHONHOME="/opt/opew/stack/python"
export PYTHONHOME
export PYTHON_EGG_CACHE="/opt/opew/stack/python/tmp"

#### GOLANG ####
GOROOT=/opt/opew/stack/go
export GOROOT
GOPATH=/opt/opew/stack/go
export GOPATH
GOARCH=amd64
export GOARCH
GOOS=linux
export GOOS
PATH="/opt/opew/stack/go/bin:$PATH"
export PATH
GOBIN="/opt/opew/stack/go/bin:$PATH"
export GOBIN
LD_LIBRARY_PATH="/opt/opew/stack/go/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH

##### POSTGRES ENV #####
PATH="/opt/opew/stack/postgresql/bin:$PATH"
export PATH
LD_LIBRARY_PATH="/opt/opew/stack/postgresql/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH
DYLD_LIBRARY_PATH="/opt/opew/stack/postgresql/lib:$DYLD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH

