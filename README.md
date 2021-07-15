# Standalone reproducer for ENTMQBR-5212

Create a standalone broker with `AMQ_SSL_PROVIDER=OPENSSL` specified.

`./create_broker.sh`

## Switching to the previous release, broker starts up successsfully

` oc set image statefulset mybroker-amq mybroker-amq=registry.redhat.io/amq7/amq-broker:7.8-16.1623245297`

`
2021-07-15 18:08:12,006 INFO  [org.apache.activemq.artemis.core.server] AMQ221001: Apache ActiveMQ Artemis Message Broker version 2.16.0.redhat-00012 [mybroker, nodeID=7ab22dea-e594-11eb-a8ec-0a580a800243]
2021-07-15 18:08:12,258 INFO  [org.apache.amq.hawtio.branding.PluginContextListener] Initialized amq-broker-redhat-branding plugin
2021-07-15 18:08:12,296 INFO  [org.apache.activemq.hawtio.plugin.PluginContextListener] Initialized artemis-plugin plugin
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/home/jboss/mybroker/tmp/webapps/jetty-mybroker-amq-0_mybroker-amq-headless_amq-demo_svc_cluster_local-8161-hawtio_war-_console-any-3976178847137835831/webapp/WEB-INF/lib/slf4j-log4j12-1.7.22.redhat-2.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/opt/amq/lib/slf4j-jboss-logmanager-1.0.4.GA-redhat-00001.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
INFO  | main | Initialising hawtio services
INFO  | main | Configuration will be discovered via system properties
INFO  | main | Welcome to hawtio 2.0.0.fuse-sb2-780022-redhat-00001
INFO  | main | Starting hawtio authentication filter, JAAS realm: "activemq" authorized role(s): "" role principal classes: "org.apache.activemq.artemis.spi.core.security.jaas.RolePrincipal"
INFO  | main | Proxy servlet is disabled
INFO  | main | Jolokia overridden property: [key=policyLocation, value=file:/home/jboss/mybroker/etc/jolokia-access.xml]
2021-07-15 18:08:12,979 INFO  [org.apache.activemq.artemis] AMQ241001: HTTP Server started at https://mybroker-amq-0.mybroker-amq-headless.amq-demo.svc.cluster.local:8161
`

## Switching to current release demonstrates the issue

`oc set image statefulset mybroker-amq mybroker-amq=registry.redhat.io/amq7/amq-broker:7.8`

`
2021-07-15 18:09:45,646 INFO  [org.apache.activemq.artemis.core.server] AMQ221080: Deploying address acme.egg.queue supporting [ANYCAST]
2021-07-15 18:09:45,647 INFO  [org.apache.activemq.artemis.core.server] AMQ221003: Deploying ANYCAST queue acme.egg.queue on address acme.egg.queue
2021-07-15 18:09:46,007 ERROR [org.apache.activemq.artemis.core.server] AMQ224097: Failed to start server: java.lang.NoClassDefFoundError: io/netty/internal/tcnative/SSLSessionCache
	at io.netty.handler.ssl.ReferenceCountedOpenSslServerContext.newSessionContext(ReferenceCountedOpenSslServerContext.java:186) [netty-all-4.1.63.Final-redhat-00001.jar:4.1.63.Final-redhat-00001]
	at io.netty.handler.ssl.OpenSslServerContext.<init>(OpenSslServerContext.java:356) [netty-all-4.1.63.Final-redhat-00001.jar:4.1.63.Final-redhat-00001]
	at io.netty.handler.ssl.OpenSslServerContext.<init>(OpenSslServerContext.java:336) [netty-all-4.1.63.Final-redhat-00001.jar:4.1.63.Final-redhat-00001]
	at io.netty.handler.ssl.SslContext.newServerContextInternal(SslContext.java:473) [netty-all-4.1.63.Final-redhat-00001.jar:4.1.63.Final-redhat-00001]
	at io.netty.handler.ssl.SslContextBuilder.build(SslContextBuilder.java:609) [netty-all-4.1.63.Final-redhat-00001.jar:4.1.63.Final-redhat-00001]
	at org.apache.activemq.artemis.core.remoting.impl.ssl.SSLSupport.createNettyContext(SSLSupport.java:213) [artemis-core-client-2.16.0.redhat-00022.jar:2.16.0.redhat-00022]
	at org.apache.activemq.artemis.core.remoting.impl.ssl.DefaultOpenSSLContextFactory.getServerSslContext(DefaultOpenSSLContextFactory.java:54) [artemis-core-client-2.16.0.redhat-00022.jar:2.16.0.redhat-00022]
	at org.apache.activemq.artemis.core.remoting.impl.netty.NettyAcceptor.loadSSLContext(NettyAcceptor.java:389) [artemis-server-2.16.0.redhat-00022.jar:2.16.0.redhat-00022]
	at org.apache.activemq.artemis.core.remoting.impl.netty.NettyAcceptor.<init>(NettyAcceptor.java:346) [artemis-server-2.16.0.redhat-00022.jar:2.16.0.redhat-00022]
	at org.apache.activemq.artemis.core.remoting.impl.netty.NettyAcceptorFactory.createAcceptor(NettyAcceptorFactory.java:43) [artemis-server-2.16.0.redhat-00022.jar:2.16.0.redhat-00022]
	at org.apache.activemq.artemis.core.remoting.server.impl.RemotingServiceImpl.createAcceptor(RemotingServiceImpl.java:275) [artemis-server-2.16.0.redhat-00022.jar:2.16.0.redhat-00022]
	at org.apache.activemq.artemis.core.remoting.server.impl.RemotingServiceImpl.start(RemotingServiceImpl.java:218) [artemis-server-2.16.0.redhat-00022.jar:2.16.0.redhat-00022]
`

