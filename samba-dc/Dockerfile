FROM alpine:latest
ARG BUILD_DATE
ARG VCS_REF
ARG HTTP_PROXY
ARG HTTPS_PROXY
LABEL org.opencontainers.image.authors="Rich Braun docker@instantlinux.net, Proteus Ndoskrnl lollipop.studio.cn@gmail.com" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.license=GPL-3.0 \
    org.label-schema.name=samba-dc \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url=https://github.com/magic0whi/ActiveDomain-Docker

ENV RUN_TYPE=samba-dc \
    ADMIN_PASSWORD_SECRET=samba-admin-password \
    BIND_INTERFACES_ONLY=yes \
    HOSTIP= \
    HOSTIP6= \
    DOMAIN_ACTION=provision \
    DOMAIN_MASTER=no \
    INTERFACES="lo eth0" \
    MODEL=standard \
    NETBIOS_NAME= \
    REALM=ad.example.com \
    TZ=UTC \
    WORKGROUP=AD \
    DNS_BACKEND=SAMBA_INTERNAL

COPY entrypoint.sh /usr/local/bin/
RUN export http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY} && \
    apk add --update --no-cache krb5 samba-dc tzdata bind bind-libs bind-tools chrony && \
    chmod 0755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]