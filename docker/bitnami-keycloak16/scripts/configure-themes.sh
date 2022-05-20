keycloak_configure_themes() {
    jboss-cli.sh <<EOF
embed-server --server-config=${KEYCLOAK_CONF_FILE} --std-out=discard
batch
/subsystem=keycloak-server/theme=defaults/ :write-attribute(name=default, value=\${env.KEYCLOAK_DEFAULT_THEME})
/subsystem=keycloak-server/theme=defaults/ :write-attribute(name=welcomeTheme, value=\${env.KEYCLOAK_WELCOME_THEME})
run-batch
stop-embedded-server
EOF
}

keycloak_configure_themes