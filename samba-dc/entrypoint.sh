#!/bin/sh -e

if [ ${RUN_TYPE} == "samba-dc" ]; then
  if [ -z "${NETBIOS_NAME}" ]; then
    NETBIOS_NAME=$(hostname -s | tr [a-z] [A-Z])
  else
    NETBIOS_NAME=$(echo ${NETBIOS_NAME} | tr [a-z] [A-Z])
  fi
  REALM=$(echo "${REALM}" | tr [a-z] [A-Z])
  DNS_BACKEND=$(echo "${DNS_BACKEND}" | tr [a-z] [A-Z])
  
  if [ ! -f /etc/timezone ] && [ ! -z "${TZ}" ]; then
    echo 'Set timezone'
    cp /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} >/etc/timezone
  fi
  
  if [ ! -f /var/lib/samba/registry.tdb ]; then
    if [ ! -f /run/secrets/${ADMIN_PASSWORD_SECRET} ]; then
      echo 'Cannot read secret ${ADMIN_PASSWORD_SECRET} in /run/secrets'
      exit 1
    fi
    ADMIN_PASSWORD=$(cat /run/secrets/${ADMIN_PASSWORD_SECRET})
    if [ "${BIND_INTERFACES_ONLY}" == "yes" ]; then
      INTERFACE_OPTS="--option=\"bind interfaces only=yes\" \
        --option=\"interfaces=${INTERFACES}\" --host-ip=${HOSTIP} --host-ip6=${HOSTIP6}"
    fi
    if [ ${DOMAIN_ACTION} == "provision" ]; then
      PROVISION_OPTS="--server-role=dc --use-rfc2307 --domain=${WORKGROUP} \
      --realm=${REALM} --adminpass='${ADMIN_PASSWORD}'"
    elif [ ${DOMAIN_ACTION} == "join" ]; then
      PROVISION_OPTS="${REALM} DC -UAdministrator --password='${ADMIN_PASSWORD}'"
    else
      echo 'Only provision and join actions are supported.'
      exit 1
    fi
  
    rm -f /etc/samba/smb.conf /etc/krb5.conf
    echo "samba-tool domain ${DOMAIN_ACTION} ${INTERFACE_OPTS} ${PROVISION_OPTS} \
       --dns-backend=${DNS_BACKEND}" | sh
  fi
  
  ln -sf /var/lib/samba/private/krb5.conf /etc/
  
  exec samba --model=${MODEL} -i </dev/null
elif [ ${RUN_TYPE} == "bind-dc" ]; then
  exec named -c /etc/bind/named.conf -g
else
  echo 'Only samba-dc and bind-dc types are supported.'
  exit 1
fi