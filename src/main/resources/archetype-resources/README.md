# EJB Application Migration Guide

## Copy Existing Source Code and Resources

From the existing code base, copy the source and resources from the existing application into the corresponding Maven modules (EJB/Web/EAR).

## Validate Successful Maven Build of Existing Codebase

Before continuing, we need to get a successful Maven build.

### Set up Java Version matching the Existing Codebase

If using the Maven command line, make sure `JAVA_HOME` is set to the version required to build the existing code.  For example, Java 1.8.

If using the IDE, make sure the build paths are set up correctly.

### Add Any Missing Dependencies to the Parent pom.xml

The majority of dependencies have been added to the parent pom.xml file, but depending on the application, there may be other dependecies required to build the application.

If the build fails due to missing classes/dependencies, look at the Ant build.xml file to determine the missing dependency and version.  These dependencies can be added to the Maven dependencies section of the parent pom.xml

### Build Existing Application Using Maven

Run the Maven build by executing the following command:

```
mvn clean install
```

*NOTE:* Do not proceed until all errors are fixed and the build is successful

## Run Migration Tooling

### Perform Dry Run

The project is setup to use the OpenRewrite plugin to perform migration tasks.  

#### Execute OpenRewrite DryRun

Before modifying the existing code and resources, you can run a dry run to view the changes that will be applied.

To run the dry run, use the following command:

```
mvn rewrite:dryRun
```

#### Validate rewrite.patch

The result of the dry run produces a file called `rewrite.patch` in the `target` directory of the parent project.

This is a Git diff file showing the changes to be made.  If the diff looks good, proceed to the next step.

#### Execute OpenRewrite Run

To apply the changes to the project, run the command:

```
mvn rewrite:run
```

### Perform pom.xml Updates

#### Uncomment All TODOs in pom.xml Files

The pom.xml required are indicated by `TODO` comments.

#### Parent

#### Remove Old Dependencies from Parent pom.xml

Remove the `<dependencies>` tag from the parent pom.xml.  These dependencies will be defined in the submodules.

#### Remove the OpenRewrite Plugin

Remove the `<build>` tag from the parent pom.xml.  The OpenRewrite plugin is no longer required after the initial migration.

#### Remove the Recipes Project

Delete the `recipes` from the modules list in the parent pom.xml.  The `recipes` directory can also be removed.

#### Add the Dependency Management Dependencies and Properties

In the `<properties>` tag, uncomment the versions for the bom, login util, primefaces, and oracle driver.

Uncomment the `<dependencyManagement>` tag.

#### EJB

Uncomment the `<dependencies>` tag from the ejb pom.xml.  These are the baseline dependencies.

Add any other required dependencies for the EJB module here.

#### Web

Uncomment the `<dependencies>` tag from the web pom.xml.  These are the baseline dependencies.

Add any other required dependencies for the Web module here.

#### EAR

Uncomment the login utility dependency in the dependency section.

Uncomment the login utility in the configuration.

### Perform Maven Build and Validate

Once the automation and pom.xml updates have been performed, try to build the application using the command:

```
mvn clean install
```

There will most likely be more manual changes, required but this should give an indication of any other compilation and packaging issues.

*NOTE:*  The command will try to undeploy/deploy the application on the local EAP 8 server so the server must be running.  Alternatively, comment out the wildfly maven plugin in the EAR pom.xml.

## Potential Manual Updates

The following are possible manual changes that may need to be completed:

### persistence.xml

Add any missing persistence units in the EAR project.  The path is in `src/main/application/META-INF`.

### Fix Public Properties

All beans need to have private properties with an associated getter and setter.  Deployment errors should indicate if these changes are required in the EJB or Web projects.

### Add implements Serializable to any classes with @Named Annotations:

The automation handles base cases for this, but if the class already implements another interface or if it extends another class, you will have to manually add the implements Serializable declaration.  The import `java.io.Serializable` will  need to be added as well as generating the serialiable UID.

Deployment errors indicating `passivation` messages will indicate which classes are required to be modified.

### Register Required Bundles:

In the web project, any required bundles listed in the faces-config.xml file will need to be moved to `src/main/resources/<qualified-path>/<bundle-name>`.

This must match the location specified in the faces-config.xml.

### Update Login Bean:

The automation provides a default LoginBean.java.new class that can be used to replace the existing LoginBean.java.  Just delete the original and remove the `.new` extension.

Key items to make sure are correct:
- Validate correct value for APP_KEY
- The redirect in the method localCacLogin points to the correct start page.  Most likely, start.xhtml.
- The automation should update the method name in welcome.xhtml, but verify that the correct LoginBean login method is being used.

### StartPageFilter.java Needs to Inject UserBean

In the Web project, StartPageFilter.java should be updated by the automation, but validate the following are correct:
- UserBean must be injected into the class instead of getting from the request.  
- Add @Inject UserBean userBean to the class
- import for jakarta.inject.Inject has been added
- userBean is using the injected UserBean instead of manual instantiation
- references to HttpSession have been removed

### ModuleUtility.java Updates

The automation should replace all `.faces` references with `.xhtml`.  Validate that thsi has been done for the ModuleUtility.java class in the Web project.

### Update Cookie Settings for Local Development

In the web.xml in the Web project, make sure `secure` and `http-only` are set to false in the `cookie-config` tag.  These values need to be true for non-dev environments.

### Use @PostConstruct to instantiate based on an Injected object

If a value is null during testing, verify that the value is not being set to a value of an injected object in the constructor of the class injecting the object.  The injected value may not be available when the contructor is executed.

Instead use and @PostContruct method to set the value to assure that the value will be available.

### CSS Updates

If the selected values are not visible in the dropdown menus, set the padding to 0em.

### Replace the javax.faces.render.Renderer

This implementation needs to be replaced with the CERS implementation.

### Replace com.sun.faces.util.MessageFactory

The MessageFactory imports should be changed to use the class provided from the Login Utility.   This will required an update to the first argument provided to any calls.  Make sure you are passing the correct object.

### Remove Duplicate Classes if Using Common Utility Library

Classes like `User.java` and `Person.java` can be in both the old code and the utility library which can cause duplicate named query or entity errors during deployment.  

Remove the existing classes and change imports to match the package from the common utility.

### Add PersistentUnit name to @PersistenceContext Annotations:

The automation will attempt to add (unitName="persistenceUnit") to all classes that find the @PersistenceContext annotation.

If the persistence unit name does not match the one created as part of the archetype generated code, it will need to be updated in the java classes as necessary.  Please note that the persistence name needs to match one defined in the persistence.xml file located in the EAR project.

### Long to Integer Conversion Error:

A parsing error can occur if there is a mismatch in type between the entity and the code that casts the string to and integer or long.

Make sure the entity property types match those being parsed.  If properties are Long, use Long.parseLong(string) or if they are Integer, use Integer.parseInt(string)

### Changine the Root Path Context:

The path used matches the base artifactId of the Web project.   In order to change the context root, update the artifact name in the web pom.xml.  Then, change the references to the web artifact in the EAR pom.xml.  This is in the dependencies and build tags.
