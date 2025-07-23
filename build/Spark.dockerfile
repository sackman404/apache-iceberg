FROM openjdk:17-slim-bullseye

USER root

RUN addgroup --gid 1000 spark && adduser --uid 1000 --gid 1000 spark
RUN mkdir -p /home/spark/spark-events
RUN chown -R spark:spark /home/spark

RUN apt-get update && apt-get -y upgrade && apt-get -y install vim less wget procps iputils-ping curl python3 python3-pip tini

USER spark
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc  --create-dirs -o /home/spark/minio-binaries/mc && chmod +x /home/spark/minio-binaries/mc
ENV PATH=$PATH:/home/spark/minio-binaries/
USER root

RUN mkdir -p /opt/ && \
    cd /opt/ && \
    wget https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz && \
    tar xzvf spark-3.5.1-bin-hadoop3.tgz && \
    rm spark-3.5.1-bin-hadoop3.tgz && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz && \
    tar xzvf apache-maven-3.9.6-bin.tar.gz && \
    rm apache-maven-3.9.6-bin.tar.gz

ENV PATH=$PATH:/opt/apache-maven-3.9.6/bin:/opt/spark-3.5.1-bin-hadoop3/bin

RUN mvn dependency:get -Dartifact=org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.5.2 && \
    mvn dependency:get -Dartifact=org.apache.iceberg:iceberg-core:1.5.2 && \
    mvn dependency:get -Dartifact=org.apache.iceberg:iceberg-aws:1.5.2 && \
    mvn dependency:get -Dartifact=org.apache.iceberg:iceberg-aws-bundle:1.5.2 && \
    mvn dependency:get -Dartifact=org.postgresql:postgresql:42.7.3

RUN find /root/.m2/ -name \*.jar -exec mv {} /opt/spark-3.5.1-bin-hadoop3/jars/ \; && rm -rf /root/.m2/

ENV SPARK_HOME=/opt/spark-3.5.1-bin-hadoop3/
USER spark
WORKDIR /home/spark/

CMD ["bash"]