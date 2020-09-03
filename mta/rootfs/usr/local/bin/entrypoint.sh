#!/bin/sh
set -e

postconf myhostname="${MAILNAME}"
postconf mynetworks="${MYNETWORKS}"

if [ "${FILTER_MIME}" == "true" ]
then
  postconf mime_header_checks=regexp:/etc/postfix/mime_header_checks
fi

if [ "${RELAYHOST}" != "false" ]
then
  postconf relayhost=${RELAYHOST}
fi

dockerize \
  -template /etc/postfix/ldap-domains.cf.templ:/etc/postfix/ldap-domains.cf \
  -template /etc/postfix/ldap-users.cf.templ:/etc/postfix/ldap-users.cf \
  -template /etc/postfix/ldap-groups.cf.templ:/etc/postfix/ldap-groups.cf \
  -template /etc/postfix/ldap-aliases.cf.templ:/etc/postfix/ldap-aliases.cf \
  -template /etc/postfix/ldap-recipient-access.cf.templ:/etc/postfix/ldap-recipient-access.cf \
  -wait tcp://${MDA_HOST}:2003 \
  -wait tcp://${RSPAMD_HOST}:11332 \
  -wait file://${SSL_CERT} \
  -wait file://${SSL_KEY} \
  -timeout ${WAITSTART_TIMEOUT} \
  /usr/bin/supervisord
