FROM docker.io/s390x/ibmjava:8-sdk

USER root
WORKDIR /app
COPY tools.jar /opt/ibm/java/jre/../lib/tools.jar
RUN apt-get update
RUN apt-get dist-upgrade
RUN apt-get install ninja-build cmake perl golang libssl-dev libapr1-dev autoconf automake libtool make tar git wget maven apache2-dev libnetty* sudo
RUN wget http://mirror.navercorp.com/apache/apr/apr-1.7.0.tar.gz
RUN wget http://mirror.navercorp.com/apache/apr/apr-util-1.6.1.tar.gz

### Automatic Build ##
RUN wget -q https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/netty-tcnative/2.0.36/build_netty.sh

RUN chmod 777 build_netty.sh
RUN ./build_netty.sh

## Manual Build ##
#RUN tar xvfz apr-1.7.0.tar.gz
#RUN tar xvfz apr-util-1.6.1.tar.gz
#WORKDIR /app/apr-1.7.0
#RUN ./configure -prefix=/usr/local/apr
#RUN make
#RUN make install

#WORKDIR /app/apr-util-1.6.1
#RUN ./configure --with-apr=/usr/local/apr --prefix=/usr/local/apr-util
#RUN make
#RUN make install

#WORKDIR /app

#ENV SOURCE_ROOT /app
#RUN git init
#RUN git clone -b netty-tcnative-parent-2.0.38.Final https://github.com/netty/netty-tcnative.git
#WORKDIR /app/netty-tcnative

#RUN sed -i '62,62 s/chromium-stable/patch-s390x-Jan2021/g' pom.xml
#RUN sed -i '66,66 s/1607f54fed72c6589d560254626909a64124f091/d83fd4af80af244ac623b99d8152c2e53287b9ad/g' pom.xml
#RUN sed -i '85,85 s/boringssl.googlesource.com/github.com\/linux-on-ibm-z/g'  boringssl-static/pom.xml

#RUN ./mvnw clean install -DskipTests
#RUN cp /usr/local/apr/lib/*.so /opt/ibm/java/lib/s390x/
#RUN cp /usr/local/apr-util/lib/*.so /opt/ibm/java/lib/s390x/
#RUN cp /app/netty-tcnative/openssl-dynamic/target/native-build/.libs/*.so /opt/ibm/java/lib/s390x/
#RUN cp /app/netty-tcnative/openssl-dynamic/target/native-build/.libs/libnetty_tcnative.so /usr/lib/s390x-linux-gnu/
#RUN cp -f /usr/local/apr/lib/libapr-1.a /usr/lib/s390x-linux-gnu/
#RUN cp -f /usr/local/apr/lib/libapr-1.la /usr/lib/s390x-linux-gnu/
#RUN cp -f /usr/local/apr/lib/libapr-1.so /usr/lib/s390x-linux-gnu/
#RUN cp -f /usr/local/apr/lib/libapr-1.so.0 /usr/lib/s390x-linux-gnu/
#RUN cp -f /usr/local/apr/lib/libapr-1.so.0.7.0 /usr/lib/s390x-linux-gnu/
#RUN rm -f /usr/lib/s390x-linux-gnu/libapr-1.so.0.6.3
### Manual Build End ###

ENV LD_LIBRARY_PATH $SOURCE_ROOT/netty-tcnative/openssl-dynamic/target/native-build/.libs/

WORKDIR /app
COPY IBM-Fabric-sdk-v2-0.0.1-SNAPSHOT.jar IBM-Fabric-sdk-v2-0.0.1-SNAPSHOT.jar
COPY WEB-INF WEB-INF
COPY lib lib
COPY netty_library netty_library

ENTRYPOINT ["java","-classpath","/app/lib/javax.json-1.1.4.jar:/app/lib/json-20080701.jar:/app/lib/json-simple-1.1.1.jar:/app/lib/javax.json-api-1.1.2.jar:/app/lib/json-sanitizer-1.1.jar:/app/lib/guava-30.0-android.jar:/app/lib/opencensus-api-0.12.3.jar:/app/lib/protobuf-java-3.10.0.jar:/app/lib/grpc-context-1.23.0.jar:/app/lib/failureaccess-1.0.1.jar:/app/lib/grpc-stub-1.31.0.jar:/app/lib/grpc-core-1.35.2.jar:/app/lib/grpc-api-1.35.0.jar:/app/lib/grpc-context-1.13.2.jar:/app/lib/opencensus-contrib-grpc-metrics-0.12.3.jar:/app/lib/futures-extra-4.2.0.jar","-Djava.library.path=/app/netty-tcnative/openssl-dynamic/target/native-build/.libs/:/usr/local/apr/lib/:/usr/local/apr-util/lib/","-Dcom.ibm.jsse2.overrideDefaultTLS=true","-Dhttps.protocols=TLSv1.2","-Dcom.lgcns.blockchain.framework.configuration=WEB-INF/config/telaio/komsco/prod/framework-config.properties","-jar","IBM-Fabric-sdk-v2-0.0.1-SNAPSHOT.jar"]
