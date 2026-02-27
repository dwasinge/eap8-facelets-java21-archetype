# PowerShell Scripts
Suggested order:
1. Import swap
2. Schema/Table JAP annotation
3. Managed Bean to Named Annotation
4. Managed Property to Inject and Serializable

Before running each script, please make sure you have set the variables for each script correctly and are in the right directory. on powershell run "dir" to check your directory, and "cd" to navigate to the desired directory where the scripts can be executed. To run each script ".\script-file.ps1"
## Import Swap
This Powershell script finds and replaces java import statements based on a hashtable of "replacable" key/value pairs. 
TODO:This script will also remove all import statements based on a values in the "removed" list.
### Variables
|Name|Type|Default|Description|
|---|---|---|---|
|TargetDirectory|String|D:\User\Project|Directory where script will start and recursively make changes|
|Replacable|HashTable|<>|Key/value pairs of all search/replace import statements
TODO:
|Removed|List|<>|list of all deprecated  import statements

## Schema and Table JAP Annotation
This powershell script will update the @Named(schema.table) annotation to @Named(name = "table", schema = "schema").
### Variables
|Name|Type|Default|Description|
|---|---|---|---|
|TargetDirectory|String|D:\User\Project|Directory where script will start and recursively make changes|
## Managed Bean to Named Annotation
This powershell script will search and replace all @managedBean(name = bean) annotations with @Named(bean).
### Variables
|Name|Type|Default|Description|
|---|---|---|---|
|TargetDirectory|String|D:\User\Project|Directory where script will start and recursively make changes|
## Managed Property to Inject and Serializable
This powershell script will search and replace the @managedProperty(${bean}) annotation with @inject. The script will then find all beans that are injected and ensure they implement Serializable interface. This requires an additional effort to manually generate the uniqueID for the list of all beans that were modified to implement serializable. 
### Variables
|Name|Type|Default|Description|
|---|---|---|---|
|TargetDirectory|String|D:\User\Project|Directory where script will start and recursively make changes|