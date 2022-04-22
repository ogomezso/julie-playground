FROM confluentinc/cp-server-connect:7.0.1

ENV CONNECT_PLUGIN_PATH: "/usr/local/share/kafka/plugins,/usr/share/filestream-connectors"

# Install FileSource connector
# RUN confluent-hub install --no-prompt mmolimar/kafka-connect-fs:1.3.0
RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.4.1

USER appuser
