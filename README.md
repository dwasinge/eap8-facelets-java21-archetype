# eap8-facelets-java21-archetype

## What is Required?

### EAR Project Properties

- persistenceUnitName
- jtaDatasourceName

## WAR Project Properties

- appDisplayName

## How do I use it?

```
mvn archetype:generate \
    -DarchetypeGroupId=com.example \
    -DarchetypeArtifactId=eap8-facelets-java21-archetype \
    -DarchetypeVersion=1.0.0-SNAPSHOT \
    -DgroupId=com.example \
    -DartifactId=my-app \
    -Dversion=1.0.0-SNAPSHOT \
    -DpersistenceUnitName=<persistence-unit-name> \
    -DapplicationDisplayName=<application-display-name> \
    -DjtaDatasourceName=<eap-configured-datasource-name> \
    -DinteractiveMode=false
```
