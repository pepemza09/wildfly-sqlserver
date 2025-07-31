# WildFly + SQL Server con Docker Compose

Esta configuración te permite ejecutar WildFly y SQL Server Standard en contenedores Docker con acceso completo a la interfaz de administración.

## Estructura de archivos

```
proyecto/
├── docker-compose.yml
├── Dockerfile.wildfly
├── setup-wildfly.sh
├── configure-sqlserver-driver.cli
├── module.xml
└── README.md
```

## Configuración previa

### 1. Descargar el driver JDBC de SQL Server

Debes descargar manualmente el driver JDBC de Microsoft SQL Server:

1. Ve a [Microsoft JDBC Driver para SQL Server](https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server)
2. Descarga `mssql-jdbc-12.4.2.jre11.jar` (o la versión más reciente)
3. Coloca el archivo JAR en el mismo directorio que tus archivos Docker

### 2. Modificar el Dockerfile (opcional)

Si necesitas copiar el driver JDBC durante el build, agrega estas líneas al Dockerfile.wildfly:

```dockerfile
# Copiar driver JDBC
COPY mssql-jdbc-12.4.2.jre11.jar /opt/jboss/wildfly/modules/system/layers/base/com/microsoft/sqlserver/main/
COPY module.xml /opt/jboss/wildfly/modules/system/layers/base/com/microsoft/sqlserver/main/
```

## Uso

### 1. Construir y ejecutar los contenedores

```bash
docker-compose up --build -d
```

### 2. Verificar que los servicios estén ejecutándose

```bash
docker-compose ps
```

### 3. Acceder a las interfaces

- **WildFly Application**: http://localhost:8080
- **WildFly Admin Console**: http://localhost:9990
  - Usuario: `admin`
  - Contraseña: `Admin@123`
- **SQL Server**: `localhost:1433`
  - Usuario: `sa`
  - Contraseña: `YourStrong@Passw0rd`

### 4. Configurar el datasource (después del primer inicio)

Si necesitas configurar el datasource para SQL Server, puedes hacerlo de dos formas:

#### Opción A: Via CLI (recomendado)
```bash
# Copiar el archivo CLI al contenedor
docker cp configure-sqlserver-driver.cli wildfly:/opt/jboss/

# Ejecutar la configuración
docker exec -it wildfly /opt/jboss/wildfly/bin/jboss-cli.sh --connect --file=/opt/jboss/configure-sqlserver-driver.cli
```

#### Opción B: Via Admin Console
1. Accede a http://localhost:9990
2. Ve a Configuration → Subsystems → Datasources & Drivers
3. Añade el driver y configura el datasource manualmente

## Configuración de seguridad

### Cambiar contraseñas por defecto

**Importante**: En producción, cambia las contraseñas por defecto:

1. **SQL Server**: Modifica `SA_PASSWORD` en docker-compose.yml
2. **WildFly Admin**: Modifica `WILDFLY_ADMIN_PASSWORD` en docker-compose.yml y Dockerfile.wildfly

### Variables de entorno disponibles

```yaml
# SQL Server
- ACCEPT_EULA=Y
- SA_PASSWORD=YourStrong@Passw0rd
- MSSQL_PID=Standard

# WildFly
- WILDFLY_ADMIN_USER=admin
- WILDFLY_ADMIN_PASSWORD=Admin@123
```

## Persistencia de datos

Los volúmenes configurados aseguran que los datos persistan entre reinicios:

- `sqlserver_data`: Datos de SQL Server
- `wildfly_deployments`: Aplicaciones desplegadas en WildFly
- `wildfly_logs`: Logs de WildFly

## Comandos útiles

```bash
# Ver logs
docker-compose logs -f wildfly
docker-compose logs -f sqlserver

# Parar servicios
docker-compose down

# Parar y eliminar volúmenes
docker-compose down -v

# Reiniciar un servicio específico
docker-compose restart wildfly
```

## Troubleshooting

### WildFly no inicia
- Verifica que los puertos 8080 y 9990 no estén en uso
- Revisa los logs: `docker-compose logs wildfly`

### No puedo conectar a SQL Server
- Verifica que el puerto 1433 no esté en uso
- Asegúrate de que la contraseña cumple con los requisitos de complejidad de SQL Server

### Error con el datasource
- Asegúrate de que el driver JDBC esté correctamente copiado
- Verifica que el module.xml esté en la ubicación correcta
- Revisa que SQL Server esté completamente iniciado antes de configurar el datasource