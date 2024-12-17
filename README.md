# F5 Build - buildAs3.ps1
---
## Introduction
The script buildAs3.ps1 is used to create an F5 Application Services (AS3) declarative statement. This is a json formatted statement which can be used to configure an F5 as part of the Automation Toolchain.

It is sent using the Terraform [F5Networks/bigip provider](https://registry.terraform.io/providers/F5Networks/bigip/latest/docs) - using the [bigip_as3](https://registry.terraform.io/providers/F5Networks/bigip/latest/docs/resources/bigip_as3) resource.

## SYNTAX

### Path (Default)

``` powershell
# buildAs3.ps1
    {-Device <device-hostname> ;or
	 -DeviceGroup <device-group-name>}
     -Partition <partition-name>
    [-Detail]
    [-NoGSLBPool]
	[-IncludeSchema]
```

## EXAMPLES

### Example 1

This example creates a declaration for the device `vm-bigip-001` and partition `appgw`.

```powershell
buildAs3.ps1 -Device vm-bigip-001 -Partition appgw
```

### Example 2

This example creates a declaration for all devices in the group `bigip-group1` and partition `appgw`.

```powershell
buildAs3.ps1 -DeviceGroup bigip-group1 -Partition appgw
```

### Output

The script outputs it's progress and any errors to standard output (screen). 

```
+ Creating AS3 Config Snippits for Device: vm-bigip-001

Loading Data from: F5-AS3-Config\build\data\ltm\as3-service_HTTPS.csv against template: F5-AS3-Config\build\templates\ltm\as3-service_HTTPS.json
Creating snippets for Partition:appgw  Class:service_HTTPS
Done.

Loading Data from: F5-AS3-Config\build\data\as3-service_TCP.csv against template: F5-AS3-Config\build\templates\as3-service_TCP.json
Creating snippets for Partition:appgw  Class:service_TCP
Done.

<output continues for all classes...>

 ++ Creating AS3 Declaration for Partition: appgw
   Collating config snippets for Application: app01
      adding : vm-bigip-001.as3.appgw.app01.pool_complex.json
      adding : vm-bigip-001.as3.appgw.app01.service_HTTPS.json
   Collating config snippets for Application: Shared
      adding : vm-bigip-001.as3.appgw.Shared.addressdiscovery_azure.json
      adding : vm-bigip-001.as3.appgw.Shared.addressdiscovery_static.json
      adding : vm-bigip-001.as3.appgw.Shared.profile_http.json
Done.
AS3 Declaration is in: F5-AS3-Config\build\declarations\vm-bigip-001.as3.appgw.json

```

## PARAMETERS

### <tt>-Device</tt>
The name of the device as given in the file `devicelist.csv`. This can be any name as long as it will uniquely identify the device in the data files used by the script. It is recommended to use the device hostname as the device name.

### <tt>-DeviceGroup</tt>
A group name allocated to a set of devices in `devicelist.csv` using the json property `"groupname"`. This can be any name which logically groups devices and the script will produce declarations for every device in the given group. If you use the `-DeviceGroup` parameter, you should not use the `-Device` parameter.

### <tt>-Partition</tt>
The partition (tenant) which you want to create the declaration for. The script creates a declaration per tenant based on the data in the `/data/<partition>` folder.

> **Note:** All applications within a partition are included.
> **Note:** The script does NOT currently support per-application declarations.

### <tt>-Detail</tt>
This switch is used to show more detailed output when the script is run. Normally, when running, the script writes output to show each API Class being generated. With 'Detail', also the name of each class object will be shown.

### <tt>-NoGSLBPool</tt>
This switch is used to ignore any data for the device from AS3 Class:GSLB_Pool. This is useful when building `/Common` declarations containing GSLB Pools where the members are in other partitions 
as if you are building for the first time, these partitions may not be built. Also, you may be building a DNS before the LTMs (which the GSLB Pools reference) are built. Therefore, this switch just ignores
this data class. You can then re-run build without this switch to update the declaration afterwards.

### <tt>-IncludeSchema</tt>
This switch is used to add the schema reference (the '$schema' property) which is set to the latest AS3 schema. Only include this when you want to validate the declaration in the Visual Studio Code editor. 

**Important:** When deploying, this property is not stored in the running declaration so does not appear on a subsequent GET. The Terraform `bigip_bigiq_as3` resource checks the running declaration and, seeing this not present, causes Terraform to believe a change is needed to 're-add' it. Therefore, do not use this switch for declarations which are added via Terraform.


## File Requirements
The script requires the following files:

### <tt>devicelist.csv</tt>
This is a json file which declares as objects, the device names used in data files to represent the device which needs to be configured. It is suggested to use the device hostname for easy identification.

Example: `vm-bigip-001`

Each device object needs the following properties :

|name (Type)|Mandatory|Description|
|---|---|---|
|`deviceGroup` *(string or [Array])*|no|Optional group ID(s) which can be used to group devices so when the script runs it produces declarations for all the devices in the group. Also, used in the data file to allow a single data config line to match multiple devices.
|`AS3ClassList` *(string)*|yes|An array of all the AS3 classes* which need to be included in the AS3 declaration for the device.|


\* The class names are in the format of the corresponding data and template filenames - see data and template files below.

*Example devicelist.csv file:*
```
{
	"vm-bigip-001" : {
		"deviceGroup": "bigip-group1",
		"AS3ClassList": [
			"GSLB_Data_Center",
			"GSLB_Server"
		]
	}
}
```

### <tt>\templates directory files</tt>
In this folder are all the API json "snippets" which are parameterized blocks of code (using '{{' and '}}' to parameterize properties) for each class which needs to be added into the declaration. Which classes are parsed in this folder depends on the list given in the devicelist.csv file above for the device you are configuring. This allows you to create a declaration which only includes classes you need for each specific device.

The template files are divided into sub-folders representing the big-ip provisioned application which is associated with the config (DNS,LTM,AFM,ASM ...etc). There is no strict rule where these files need to be - it is just to split the files up to aid navigation. The script recurses into the `\templates` directory subfolders to find the template it needs.

The syntax for the template file needs to be:

`as3-<as3-class>.json`

* The prefix of the filename needs to be 'as3'.
* The as3-class should reflect the API Class as shown in the [F5 API Schema reference](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html) and also be the same name as the data file.
   * This is again not a strict rule, but helps identify what is being built.
* You may need to create different versions of template for the same class - in this case just suffix it with something relevant to the template.
   * Example - you may have a simple pool which defines a single static node, and a more complex pool which has multiple nodes with monitors.<br>In this case you could create 2 template (and data) files called:
   `as3-pool-simple.json` and `as3-pool-complex.json`
* New templates can be added for any desired class - see 'Adding New Classes' below.

### <tt>\data directory files</tt>
In this folder are all the API class data files which are used to create the code snippet for that class. There is a subfolder in this folder for each tenant/partition which holds data. This is because the script creates a declaration for a single partition only. Multiple partitions require the script to be run multiple times. In each `\data` directory there **has** to be at least a `\Common` directory.

The syntax for the data file needs to be:

`as3-<as3-class>.csv`

* The prefix of the filename needs to be AS3.
* The as3-class should reflect the API Class as shown in the [F5 API Schema reference](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html) and also be the same name as the template file.
* The table is a comma delimited CSV file which is composed of the following standard columns:

|Column|Column Name|Row Contents|Description|
|---|---|---|---|
|1|Device/Group ID|`<device>` or `group:<deviceGroup>`|Either the name given to the device in *devicelist.csv* or a group name relating to a group of devices in *devicelist.csv* *|
|2|Application|`<application_name>`|This is the application folder within the partition where your config will be placed. Try to group configuration associated with the applications your big-ip is supporting.<br>**Important**: If the partition is `Common`, the application must be called: `Shared`.
|3|AS3 Object Class|`Class:<class-name>`|The column heading name needs to have the prefix `Class` followed by a colon and then the AS3 class name. This column holds the name given to each class element.

Following this, ALL parameterized values in the template need to be added as additional columns, with their row data being the value which needs to be replaced for the specified device given in column 1.

> You can use '`group:<deviceGroup>`' in the device/group ID column when you want the same configuration to be added to all devices in the group. When the script sees this option, it will add the config line only if the current device which the declaration is being built for matches the group ID given here.

## Adding New Classes
To add a new API class - you need to firstly create a template snippet of the class code, then add the data file, and finally add it to the `AS3ClassList` property array in *devicelist.csv* for the device(s) you want 

### Example: Adding the LTM pool class.

### *Create Template*
Firstly we get the example of the JSON used to create the Pool. There are many examples of code on the F5 clouddocs website:

**Examples:** https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/

**Schema Reference:** https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html

Here is our example code. In an AS3 declaration the classes are tabulated 4 indents out so try and replicate this in the template file - it creates a neater looking declaration:
```json
				"my-app01-pool-001": {
					"class": "Pool",
					"remark": "Pool 001 for App01",
					"members": [
						{
							"serverAddresses": [
								"192.168.1.10"
							],
							"servicePort": 443
						}
					]
				},
````
Now we go through the snippet and parameterize all the values which may change depending on the specific device, partition, or app:
```json
				"{{Class:Pool}}": {
					"class": "Pool",
					"remark": "{{remark}}",
					"members": [
						{
							"serverAddresses": [
								"{{serverAddresses}}"
							],
							"servicePort": {{servicePort}}
						}
					]
				},
````
* The last line is usually added with a close brace and comma. The comma is not essential - the script will remove this last line and add a '},' or '}' accordingly depending on whether there are additional classes below this one when it generates the declaration.

> **Important:** Make sure the template starts with the class name (parameterized as `Class:<class-name>`) and ends with the closing brace for the class json snippet.

* We now save this snippet to the `/templates` folder in a suitable subfolder - in this case we'll use `/ltm` as pools are used in LTM applications.

### *Create Data File*

We now create a data file which contains all the devices which need configuring with the pool. For this simple example, we'll build in the `\Common` partition, so the
file will go into the `\data\Common\pool` folder.

As all AS3 config also needs to be assigned to an application, we add this to the data file, then add the `Class:Pool` field which holds our class object name, and finally the replaceable parameters are provided as per the original example code:

```
device,application,Class:Pool,remark,serverAddresses,servicePort
my-bigip-001,Shared,my-app01-pool-001,Pool 001 for App01,192.168.1.10,443

```

> Remember: If you are using the `\Common` partition, you can only have a single application, named: `Shared`.

### *Add to devicelist.csv*

We now add our device and specify the AS3 classes we want to build for the device:

```
{
	"my-bigip-001" : {
		"deviceGroup": "1",
		"AS3ClassList": [
			"pool"
		]
	}
}
```

Once added, we can test using the buildAs3 command:

` ./buildAs3.ps1 -Device my-bigip-001 -Partition Common`


**Example Output:**
```bash
+ Creating AS3 Config Snippits for LTM Device: my-bigip-001
Loading Data from: \F5-AS3-Config\build\data\Common\ltm\as3-pool.csv against template: \F5-AS3-Config\build\templates\ltm\as3-pool.json
Creating snippets for Partition:mypartition  Class:pool
Done.

 ++ Creating AS3 Declaration for Partition: Common
   Collating config snippets for Application: Shared
      adding : my-bigip-001.as3.Common.Shared.pool.json
Done.
AS3 Declaration is in: \F5-AS3-Config\build\declarations\my-bigip-001.as3.Common.json

```

We now have a fully formatted declaration which will be able to be run into the big-ip:
```json
{
    "$schema": "https://raw.githubusercontent.com/F5Networks/f5-appsvcs-extension/master/schema/latest/as3-schema.json",
    "class": "AS3",
    "action": "deploy",
    "persist": true,
    "declaration": {
        "class": "ADC",
        "schemaVersion": "3.34.0",
        "remark": "ID: 645322443 BR: main PAR:Common",
        "label": "ltm AS3 my-ltm1/Common RunID:2110407845",
        "Common": {
            "class": "Tenant",
            "remark": "ID: 645322443 BR: main DATE: 04-12-23_12:00",
			"Shared": {
                "class": "Application",
				"my-app01-pool-001": {
					"class": "Pool",
					"remark": "Pool 001 for App01",
					"members": [
						{
							"serverAddresses": [
								"192.168.1.10"
							],
							"servicePort": 443
						}
					]
				}
            }
        }
    }
}
```
* The RunID (a randomly generated number) is in the `declaration.remark` and tenant class remark fields. This helps identify the configuration which is active on the F5.


## Special Values for Columns and Row Data

The script supports some special values for row data and column naming - to support the ability to easily add more complex data, or remove properties from a template so it can be used for multiple services.

### Adding Certificates
Traffic Certificates can be added to AS3 traffic certificates/keys declarations.

To add them, the column name/header in the appropriate Class data file needs to be of format: `cert:<parmname>`
* Where 'parmname' is the replaceable parameter name in the template where the certificate data needs to be inserted. The script automatically converts the data into the required format (PEM format with CR linefeeds for AS3).

When the column header is of this format, the row value given is treated as a reference to a filename in the `\data\certificates` subdirectory. 

> **Note:** You cannot change the device certificate in AS3. You also cannot add traffic certificates where the private key is held in an external HSM.

### Adding WAF Declarations
The ASM module in big-ip creates a WAF profile which is downloadable as a JSON file which can then be added to the AS3 declarations in Class `WAF_Policy`. 

To add them, the column name in the appropriate Class data file needs to be of format: `waf:<parmname>`
* Where 'parmname' is the replaceable parameter name in the template where the WAF profile data needs to be inserted. The script automatically converts the data into a Base64 string.

When the column header is of this format, the row value given is treated as a reference to a filename in the `\data\asm` subdirectory.

### Adding iRules
iRules are TCL scripts which can be loaded into the as3 declaration directly from .tcl files. 

To add them, the column name in the appropriate Class data file needs to be of format: `irule:<parmname>`
* Where 'parmname' is the replaceable parameter name in the template where the iRule data needs to be inserted. The script automatically converts the data into a Base64 string.

When the column header is of this format, the row value given is treated as a reference to a filename in the `\data\irules` subdirectory.

### Deleting Properties
If a property which is parameterized in a template is not required for the particular device, AS3 and DO do not like empty strings in the declaration and error. Rather than having to create a new version of the template, you can remove properties (key:value objects) from a class by adding the value `!DELETE!` to the row data in the column which has the property you want to remove.

> **Note:** This only works when the property is on a single line. For arrays or properties which are defined on multiple lines this option will not work.

### Adding Multiple Properties
If a property/object has multiple values which are listed as an array, the script allows for a simple multi-value option. The array is created as a pipe ('|') delimited set of values for the given parameter name.

To add them, the column name in the appropriate Class data file needs to be of format: `multi:<parmname>`
* Where 'parmname' is the replaceable parameter name in the template where the multi-line data needs to be inserted.

When the column header is of this format, the row value given is treated as a pipe delimited set of values which are added to the declaration.

### Adding a subtable of data
If a Class object contains a property which has an array of more complex sets of values; then a subtable can be referenced. Effectively, this is a code snippet within a code snippet - it allows a block of code in a template to be inserted for as many subtable items are needed in an array. 

To add subtable data, the column name in the appropriate Class data file needs to be of format: `subtable:<parmname>`
* Where 'parmname' is the replaceable parameter name in the template where the subtable data needs to be inserted.

When the column header is of this format, the row value given is the name of a template and associated data file for the sub-elements of the array. 

Unlike Class data files, these subtable data files do not have the device, partition and application as the first 3 columns. Instead, the first column has the referenced parmname. Every row which has the matching parmname will be added as an element to the array, using the template file for the subtable.


### Subtable special values
When a subtable is defined, the json snippet can contain any of the following special values:

* !DELETE! option - for removing unwanted properties (works same as described above)
* multi:<parmname> option - for adding multiple values in a simple array (works same as described above)
* dns:zonefile option - this is a special option for subtables which are for DNS cache data - see below

#### DNS Cache data
To make it easier to manage the zone information for a DNS Cache, local and forward zone data can be held in simple text files which
are placed in the `\data\dns-zone` directory - where each line is a DNS entry in format:

`myf5.mydomain.com. 3600 A 192.168.100.1`

To add DNS data, the column name in the appropriate Class data file needs to be of format: `dns:zonefile`
* Where 'dns:zonefile' is also the replaceable parameter name in the template where the subtable data needs to have DNS entries added.

When the column header is of this format, the row value given is the name of the DNS zone file which needs to be loaded and inserted into the template.

Example:
The following \data\dns template is used to create the cache using AS3 class 'DNS_Cache':
```
				"{{Class:DNS_Cache}}": {
					"class": "DNS_Cache",
					"type": "{{type}}",
					"localZones": {
						{{subtable:DNS_Cache_localZones}}
					}
				},
```
This takes data from the corresponding data file which has the 'subtable' option and will load another template called 'DNS_Cache_localZones':
```
device,partition,application,Class:DNS_Cache,type,subtable:DNS_Cache_localZones
myf5-vm001,Common,Shared,f5-internal-dnscache,transparent,mylocaldns
```

```
						"{{localZone}}": {
							"type": "{{type}}",
							"records": [
								"{{dns:zonefile}}"
							]
						},
```

This also has a data file in \data\dns which has the 'dns:zonefile' option - pointing to a file in .\data\dns-zone\internaldns
```
DNS_Cache_localZones,localZone,type,dns:zonefile
mylocaldns,mydomain.com,deny,internaldns
```

This data file will then load the file internaldns and add the entries..

```
myf5-vm001.mydomain.com. 3600 A 192.168.100.1
myf5-vm002.mydomain.com. 3600 A 192.168.200.2
```

The resulting JSON AS3 will look like this:

				"f5-internal-dnscache": {
					"class": "DNS_Cache",
					"type": "transparent",
					"localZones": {
						"mydomain.com": {
							"type": "deny",
							"records": [
								"myf5-vm001.mydomain.com. 3600 A 192.168.100.1"
								"myf5-vm002.mydomain.com. 3600 A 192.168.200.2"
							]
						},
					}
				},
