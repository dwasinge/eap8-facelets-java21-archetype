# EJB Application Migration Guide

## Clone/Unzip This project

## Build and Install the Maven Archetype

From the root directory, install build and install the maven archetype into the local .m2 repository.

```
# From directory containing pom.xml
mvn clean install
```

## Create New Maven Project Structure for App to be Migrated

### Available Configuration

#### Maven Project Properties

- `groupId`: group ID to be used for generated maven artifacts
- `artifactId`: base name of the artifacts to be generated

#### EAR Project Properties

- `persistenceUnitName`: defines the name of the persistence unit in the persistence.xml
- `jtaDatasourceName`: name of the datasource used by the persistence unit in the persistence.xml
- `appKey`: application key value used in LoginBean.java

## Generate Maven Project Structure

Run the following command replacing the 4 placeholders with the desired values.

```
# bash
mvn archetype:generate \
    -DarchetypeGroupId=com.example \
    -DarchetypeArtifactId=eap8-facelets-java21-archetype \
    -DarchetypeVersion=1.0.0-SNAPSHOT \
    -DgroupId=<artifact-group-id> \
    -DartifactId=<base-artifact-id> \
    -Dversion=1.0.0-SNAPSHOT \
    -DpersistenceUnitName=<persistence-unit-name> \
    -DjtaDatasourceName=<eap-configured-datasource-name> \
    -DappKey=<applicaiton-key> \
    -DinteractiveMode=false

# or powershell
mvn archetype:generate `
    -DarchetypeGroupId=com.example `
    -DarchetypeArtifactId=eap8-facelets-java21-archetype `
    -DarchetypeVersion=1.0.0-SNAPSHOT `
    -DgroupId=<artifact-group-id> `
    -DartifactId=<base-artifact-id> `
    -Dversion=1.0.0-SNAPSHOT `
    -DpersistenceUnitName=<persistence-unit-name> `
    -DjtaDatasourceName=<eap-configured-datasource-name> `
    -DappKey=<applicaiton-key> `
    -DinteractiveMode=false
```
This command creates the new Maven project structure.   Continue following the instructions found in the README.md file in the root directory of the created project.
