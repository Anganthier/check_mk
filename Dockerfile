FROM centos:7.4.1708

# ARG can be overwritten on build time using "docker build --build-arg name=value"
ARG CMK_VERSION="1.4.0p31"
ARG CMK_DOWNLOADNR="78"
ARG CMK_SITE="mva"
ARG MAILHUB="undefined"
ARG TIMEZONE="UTC"

RUN yum install epel-release -y ; \
    yum -y install --nogpgcheck https://mathias-kettner.de/support/${CMK_VERSION}/check-mk-raw-${CMK_VERSION}-el7-${CMK_DOWNLOADNR}.x86_64.rpm ssmtp which; \ 
    yum clean all

COPY    bootstrap.sh /opt/
COPY    redirector.sh /opt/

# http Port
EXPOSE 5000/tcp
# livestatus api port, not enabled by default
EXPOSE 5667/tcp

# set timezone
RUN rm -f /etc/localtime; ln -s "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime

ENV CMK_SITE=${CMK_SITE}
ENV PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

# Leave Directory empty, but create site
RUN omd create --no-init ${CMK_SITE} 

ENV MAILHUB=${MAILHUB}

WORKDIR /omd
ENTRYPOINT ["/opt/bootstrap.sh"]

