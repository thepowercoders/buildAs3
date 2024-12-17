> :memo: **Note:** This wiki was generated using [as3Markdown.ps1](https://github.com/thepowercoders/buildas3/blob/main/as3Markdown.ps1) based on the AS3 configuration files on Dec 17 17:01:00.

# Declarations
This LLD is aligned to the following declarations:
|device|declaration|ID|Branch|Partition|Date Created|
|---|---|---|---|---|---|
|vm-bigip-001|vm-bigip-001.as3.as3Tenant1.json|759654624|main|as3Tenant1|17-12-24_16:42|
|vm-bigip-001|vm-bigip-001.as3.Common.json|435439860|main|Common|17-12-24_16:41|
# Devices
The following devices are configured:
|device|device group|AS3 Classes configured|
|---|---|---|
|vm-bigip-001||GSLB-Data-Center, GSLB-Server, GSLB-Domain, GSLB-Pool, Certificate, Monitor, Pool, Service-HTTPS, TLS-Client, TLS-Server|
# AS3 Configuration for Partition: as3Tenant1


## Class: GSLB-Domain

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-domain

### GSLB-Domain Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/dns/as3-GSLB_Domain.json

```json
				"{{Class:GSLB_Domain}}": {
					"class": "GSLB_Domain",
					"domainName": "{{domainName}}",
					"resourceRecordType": "{{resourceRecordType}}",
					"pools": [
						{ "use": "{{multi:pools}}" }
					],
					"poolLbMode": "{{poolLbMode}}"
				},
```

### GSLB-Domain Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/dns/as3-GSLB_Domain.csv

|device|application|Class:GSLB_Domain|domainName|resourceRecordType|multi:pools|poolLbMode|
|---|---|---|---|---|---|---|
vm-bigip-001|app01|gslbWip-app01|app01.wip.test.com|A|gslbPool-app01|global-availability

## Class: GSLB-Pool

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-pool

### GSLB-Pool Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/dns/as3-GSLB_Pool.json

```json
				"{{Class:GSLB_Pool}}": {
					"class": "GSLB_Pool",
					"enabled": true,
					"lbModePreferred": "{{lbModePreferred}}",
					"lbModeAlternate": "{{lbModeAlternate}}",
					"lbModeFallback": "{{lbModeFallback}}",
					"manualResumeEnabled": false,
					"verifyMemberEnabled": true,
					"remark": "{{remark}}",
					"members": [
						{{subtable:GSLB_Pool_members}}
					],
					"bpsLimit": 0,
					"bpsLimitEnabled": false,
					"ppsLimit": 0,
					"ppsLimitEnabled": false,
					"connectionsLimit": 0,
					"connectionsLimitEnabled": false,
					"maxAnswersReturned": 1,
					"resourceRecordType": "{{resourceRecordType}}",
					"ttl": {{ttl}}
				},
```

### GSLB-Pool Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/dns/as3-GSLB_Pool.csv

|device|application|Class:GSLB_Pool|resourceRecordType|remark|subtable:GSLB_Pool_members|lbModePreferred|lbModeAlternate|lbModeFallback|ttl|
|---|---|---|---|---|---|---|---|---|---|
vm-bigip-001|app01|gslbPool-app01|A|Example WIP for app01|gslbPool-app01|ratio|global-availability|none|300

### GSLB_Pool_members Subtable Data

### GSLB-Pool Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/dns/sub-GSLB_Pool_members.json.json

```json
						{
							"ratio": {{ratio}},
							"server": {
								"{{use}}": "{{server}}"
							},
							"virtualServer": "{{virtualServer}}"
						},
```

### GSLB-Pool Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/dns/sub-GSLB_Pool_members.csv

|GSLB_Pool_members|ratio|use|server|virtualServer|
|---|---|---|---|---|
gslbPool-app01|50|bigip|/Common/gslbServer-vm001|/as3Tenant1/app01/vs-vm002App01Server1
gslbPool-app01|50|bigip|/Common/gslbServer-vm001|/as3Tenant1/app01/vs-vm002App01Server2

## Class: Certificate

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#certificate

### Certificate Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-certificate.json

```json
				"{{Class:Certificate}}": {
					"class": "Certificate",
					"certificate": { "bigip": "{{certificate}}" },
					"privateKey": { "bigip": "{{privateKey}}" },
					"chainCA": { "bigip": "{{chainCA}}" }
				}
```

### Certificate Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/ltm/as3-certificate.csv

|device|application|Class:Certificate|certificate|privateKey|chainCA|
|---|---|---|---|---|---|
vm-bigip-002|app01|cert-default|/Common/default.crt|/Common/default.key|*not used*

## Class: Monitor

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#monitor

### Monitor Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-monitor_https.json

```json
				"{{Class:Monitor}}": {
					"class": "Monitor",
					"monitorType": "https",
					"remark": "{{remark}}",
					"clientTLS": { "use": "{{clientTLS}}" },
					"send": "{{send}}",
					"receiveDown": "{{receiveDown}}",
					"receive": "{{receive}}",
					"interval": {{interval}},
					"timeUntilUp": 15,
					"timeout": {{timeout}},
					"targetPort": {{targetPort}}
				}
```

### Monitor Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/ltm/as3-monitor_https.csv

|device|application|Class:Monitor|remark|targetPort|receiveDown|receive|send|interval|timeout|clientTLS|
|---|---|---|---|---|---|---|---|---|---|---|
vm-bigip-001|app01|monitor-app01|app01 Health Monitor|443|*not used*|200|GET / HTTP/1.1\r\nHost: app01.azure-api.net|20|61|servertls-app01

## Class: Pool

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#pool

### Pool Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-pool_simple.json

```json
				"{{Class:Pool}}": {
					"class": "Pool",
					"remark": "{{remark}}",
					"monitors": [
						{ "use": "{{multi:monitor}}"}
					],
					"minimumMonitors": "{{minimumMonitors}}",
					"members": [
						{
							"serverAddresses": [
								"{{multi:serverAddresses}}"
							],
							"adminState": "enable",
							"shareNodes": {{shareNodes}},
							"servicePort": {{servicePort}}
						}
					]
				},
```

### Pool Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/ltm/as3-pool_simple.csv

|device|application|Class:Pool|remark|multi:serverAddresses|servicePort|multi:monitor|minimumMonitors|shareNodes|
|---|---|---|---|---|---|---|---|---|
vm-bigip-001|app01|pool-app01Server1|App01 Server 1 Pool|192.168.100.1<br>192.168.100.2|443|monitor-app01|*not used*|true
vm-bigip-001|app01|pool-app01Server2|App01 Server 2 Pool|192.168.200.1<br>192.168.200.2|443|monitor-app01|*not used*|true

## Class: Service-HTTPS

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-https

### Service-HTTPS Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-service_HTTPS.json

```json
				"{{Class:Service_HTTPS}}": {
					"class": "Service_HTTPS",
					"virtualAddresses": [
						"{{virtualAddresses}}"
						],
					"shareAddresses": {{shareAddresses}},
					"profileHTTP": {
						"{{profileHTTP_use}}": "{{profileHTTP}}"
					},
					"profileTrafficLog": { "bigip": "{{profileTrafficLog}}" },
					"pool": "{{pool}}",
					"persistenceMethods": [],
					"remark": "{{remark}}",
					"addressStatus": true,
					"allowVlans": [
						"{{allowVlans}}"
						],
					"iRules": [
						"{{multi:iRules}}"
					],
					"virtualPort": {{virtualPort}},
					"redirect80": false,
					"snat": "{{snat}}",
					"serverTLS": "{{serverTLS}}",
					"clientTLS": "{{clientTLS}}",
					"policyFirewallStaged": { "use": "{{policyFirewallStaged}}" },
					"policyFirewallEnforced": { "use": "{{policyFirewallEnforced}}" },
					"policyWAF": { "use": "{{policyWAF}}" },
					"profileDOS": { "use": "{{profileDOS}}" },
					"profileProtocolInspection": { "use": "{{profileProtocolInspection}}" },
					"securityLogProfiles":  [{ "bigip": "{{securityLogProfiles}}" }]
				},
```

### Service-HTTPS Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/ltm/as3-service_HTTPS.csv

|device|application|Class:Service_HTTPS|virtualAddresses|shareAddresses|profileHTTP_use|profileHTTP|profileTrafficLog|multi:iRules|pool|remark|allowVlans|virtualPort|snat|serverTLS|clientTLS|policyFirewallStaged|policyFirewallEnforced|policyWAF|profileDOS|profileProtocolInspection|securityLogProfiles|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
vm-bigip-001|app01|vs-vm001App01Server1|192.168.10.1|false|bigip|/Common/http|*not used*|*not used*|pool-app01Server1|Pool App01 Server 1|*not used*|443|auto|clienttls-app01|servertls-app01|*not used*|*not used*|*not used*|*not used*|*not used*|*not used*
vm-bigip-001|app01|vs-vm001App01Server2|192.168.20.1|false|bigip|/Common/http|*not used*|*not used*|pool-app01Server2|Pool App01 Server 2|*not used*|443|auto|clienttls-app01|servertls-app01|*not used*|*not used*|*not used*|*not used*|*not used*|*not used*

## Class: TLS-Client

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#tls-client

### TLS-Client Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-tls_client.json

```json
                "{{Class:TLS_Client}}": {
                    "class": "TLS_Client",
                    "remark": "{{Class:TLS_Client}}",
					"allowExpiredCRL": false,
					"cipherGroup": { "bigip": "{{cipherGroup}}" },
                    "authenticationFrequency": "every-time",
                    "dtlsEnabled": false,
                    "dtls1_2Enabled": false,
                    "clientCertificate": "{{clientCertificate}}",
					"validateCertificate": {{validateCertificate}},
					"sendSNI": "{{sendSNI}}",
                    "cacheTimeout": {{cacheTimeout}},
                    "trustCA": { "bigip": "{{trustCA}}" }
                },
```

### TLS-Client Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/ltm/as3-tls_client.csv

|device|application|Class:TLS_Client|clientCertificate|cipherGroup|trustCA|validateCertificate|sendSNI|cacheTimeout|
|---|---|---|---|---|---|---|---|---|
vm-bigip-001|app01|servertls-app01|cert-default|*not used*|/Common/default.crt|true|*not used*|*not used*

## Class: TLS-Server

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#tls-server

### TLS-Server Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-tls_server.json

```json
                "{{Class:TLS_Server}}": {
                    "class": "TLS_Server",
                    "authenticationMode": "{{authenticationMode}}",
                    "forwardProxyEnabled": false,
                    "authenticationFrequency": "every-time",
                    "remark": "{{Class:TLS_Server}}",
                    "certificates": [
                        {
                            "certificate": "{{certificate}}"
                        }
                    ],
                    "authenticationTrustCA": {
                        "bigip": "{{authenticationTrustCA}}.crt"
                    },
                    "cacheTimeout": {{cacheTimeout}}
                },
```

### TLS-Server Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/as3Tenant1/ltm/as3-tls_server.csv

|device|application|Class:TLS_Server|certificate|authenticationTrustCA|authenticationMode|cacheTimeout|
|---|---|---|---|---|---|---|
vm-bigip-001|app01|clienttls-app01|cert-default|/Common/ca-bundle|require|*not used*
# AS3 Configuration for Partition: Common


## Class: GSLB-Data-Center

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-data-center

### GSLB-Data-Center Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/dns/as3-GSLB_Data_Center.json

```json
                "{{Class:GSLB_Data_Center}}": {
                    "class": "GSLB_Data_Center",
                    "enabled": true,
                    "location": "{{location}}",
                    "remark": "{{remark}}",
                    "proberPreferred": "{{proberPreferred}}",
                    "proberFallback": "{{proberFallback}}"
                }
```

### GSLB-Data-Center Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/Common/dns/as3-GSLB_Data_Center.csv

|device|application|Class:GSLB_Data_Center|location|remark|proberPreferred|proberFallback|
|---|---|---|---|---|---|---|
vm-bigip-001|Shared|gslbDatacenter-azure|UK|Azure|inside-datacenter|any-available

## Class: GSLB-Server

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-server

### GSLB-Server Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/dns/as3-GSLB_Server.json

```json
                "{{Class:GSLB_Server}}": {
                    "class": "GSLB_Server",
                    "dataCenter": {
                        "use": "{{dataCenter}}"
                    },
                    "devices": [
                        {{subtable:GSLB_Server_Device}}
                    ],
                    "monitors": [
                        {
                            "bigip": "{{GSLB_Monitor}}"
                        }
                    ],
                    "serverType": "{{serverType}}",
                    "virtualServerDiscoveryMode": "{{virtualServerDiscoveryMode}}",
                    "virtualServers": [
                        {{subtable:GSLB_Server_vips}}
                    ]
                },
```

### GSLB-Server Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/Common/dns/as3-GSLB_Server.csv

|device|application|Class:GSLB_Server|dataCenter|subtable:GSLB_Server_Device|GSLB_Monitor|serverType|virtualServerDiscoveryMode|subtable:GSLB_Server_vips|
|---|---|---|---|---|---|---|---|---|
vm-bigip-001|Shared|gslbServer-vm001|gslbDatacenter-azure|dc1|/Common/bigip|bigip|disabled|bigip-001-vips

### GSLB_Server_Device Subtable Data

### GSLB-Server Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/dns/sub-GSLB_Server_Device.json.json

```json
						{
							"address": "{{address}}",
							"addressTranslation": "{{addressTranslation}}",
							"remark": "{{remark}}"
						}
```

### GSLB-Server Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/Common/dns/sub-GSLB_Server_Device.csv

|GSLB_Server_Device|address|addressTranslation|remark|
|---|---|---|---|
dc1|192.168.1.5|*not used*|vm-bigip-001

### GSLB_Server_vips Subtable Data

### GSLB-Server Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/dns/sub-GSLB_Server_vips.json.json

```json
						{
							"address": "{{address}}",
							"monitors": [
								{
									"{{monitors}}": "{{GSLB_Monitor}}"
								}
							],
							"name": "{{name}}",
							"port": {{port}}
						}
```

### GSLB-Server Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant1/Common/dns/sub-GSLB_Server_vips.csv

|GSLB_Server_vips|address|monitors|GSLB_Monitor|name|port|
|---|---|---|---|---|---|
bigip-001-vips|192.168.10.1|bigip|/Common/bigip|/as3Tenant1/app01/vs-vm001App01Server1|443
bigip-001-vips|192.168.20.1|bigip|/Common/bigip|/as3Tenant1/app01/vs-vm001App01Server2|443
