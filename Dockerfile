FROM alpine
MAINTAINER Nacho Cañón <icanon@paradigmatecnologico.com>

# Install cURL, tar, etc
RUN apk --update add bash ca-certificates tar wget openssl unzip  alpine-sdk  openssl-dev \
    && cd /tmp \
    && wget -q --no-check-certificate "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk"  \
    && wget -q --no-check-certificate "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk"  \
    && apk add --allow-untrusted glibc-bin-2.21-r2.apk \
    && ldconfig /lib /usr/glibc/usr/lib \
    && apk add --allow-untrusted /tmp/glibc-2.21-r2.apk

# fix known bug about jndi lookup and alpine image.
RUN echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

# Java Version
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 45
ENV JAVA_VERSION_BUILD 14
ENV JAVA_PACKAGE       jdk

# Download and unarchive Java
RUN mkdir /opt && curl --progress-bar -jkLH "Cookie: oraclelicense=accept-securebackup-cookie"\
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
    | tar -xzf - -C /opt &&\
    ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk &&\
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so


# Set JAVA and maven environment
ENV M2_HOME /opt/apache-maven-3.3.9
ENV MAVEN_OPTS="-Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true"
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin:${M2_HOME}/bin

# install maven
RUN cd /tmp; \
    curl --progress-bar -jkL http://ftp.cixug.es/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.zip -o mvn.zip \
    && unzip mvn.zip \
    && mv apache-maven-3.3.9 /opt

# some cleanup
RUN apk del alpine-sdk  openssl-dev \
    && rm -fR /tmp/* 2> /dev/null


