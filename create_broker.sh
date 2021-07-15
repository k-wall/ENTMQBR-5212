# Adapted from https://kb.tomd.xyz/amq-broker.html#deploying-amq-broker-76-persistent-non-clustered-ssl-on-openshift


MYPROJECT=amq-demo
BROKER_NAME=mybroker
oc new-project ${MYPROJECT}

# set up the keystore and truststore
keytool -genkey -alias broker -keypass password -keyalg RSA -keystore broker.ks -dname "CN=broker,L=Gimmerton" -storepass password -deststoretype pkcs12
keytool -genkey -alias client -keypass password -keyalg RSA -keystore client.ks -dname "CN=client,L=Gimmerton" -storepass password -deststoretype pkcs12

keytool -export -alias broker -keystore broker.ks -file broker_cert -storepass password
keytool -import -alias broker -keystore client.ts -file broker_cert -storepass password -noprompt

keytool -export -alias client -keystore client.ks -file client_cert -storepass password
keytool -import -alias client -keystore broker.ts -file client_cert -storepass password -noprompt

oc create secret generic ${BROKER_NAME}-app-secret --from-file=broker.ks --from-file=broker.ts -n ${MYPROJECT}

oc process -f https://raw.githubusercontent.com/jboss-container-images/jboss-amq-7-broker-openshift-image/78-7.8.2.GA/templates/amq-broker-78-persistence-ssl.yaml \
  -p AMQ_NAME=${BROKER_NAME} -p APPLICATION_NAME=${BROKER_NAME} \
  -p AMQ_PROTOCOL=openwire,amqp,stomp,mqtt,hornetq \
  -p AMQ_SSL_PROVIDER=OPENSSL \
  -p AMQ_QUEUES=acme.egg.queue \
  -p AMQ_USER=admin -p AMQ_PASSWORD=redstarcoffee \
  -p AMQ_SECRET=${BROKER_NAME}-app-secret \
  -p AMQ_TRUSTSTORE=broker.ts -p AMQ_KEYSTORE=broker.ks \
  -p AMQ_REQUIRE_LOGIN=true \
  -p AMQ_TRUSTSTORE_PASSWORD=password -p AMQ_KEYSTORE_PASSWORD=password \
  | jq '(.items[] | select(.kind == "StatefulSet") | .apiVersion) |= "apps/v1"' \
  | oc apply -f -

oc scale sts/${BROKER_NAME}-amq --replicas=1
