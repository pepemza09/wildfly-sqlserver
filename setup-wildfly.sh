#!/bin/bash

# Script para configurar WildFly con usuario administrador y datasource para SQL Server

echo "Configurando WildFly..."

# Crear usuario administrador
echo "Creando usuario administrador..."
/opt/jboss/wildfly/bin/add-user.sh -u ${WILDFLY_ADMIN_USER} -p ${WILDFLY_ADMIN_PASSWORD} --silent

# Crear directorio para módulos personalizados si no existe
mkdir -p /opt/jboss/wildfly/modules/system/layers/base/com/microsoft/sqlserver/main

# Nota: El driver JDBC de SQL Server debe ser descargado manualmente
# y copiado al contenedor. Ver instrucciones en README.

echo "Configuración de WildFly completada."
echo "Usuario administrador: ${WILDFLY_ADMIN_USER}"
echo "Consola de administración disponible en: http://localhost:9990"