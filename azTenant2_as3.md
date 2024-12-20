> :memo: **Note:** This wiki was generated using [as3Markdown.ps1](https://github.com/thepowercoders/buildas3/blob/main/as3Markdown.ps1) based on the AS3 configuration files on Dec 17 17:01:04.

# Declarations
This LLD is aligned to the following declarations:
|device|declaration|ID|Branch|Partition|Date Created|
|---|---|---|---|---|---|
|vm-bigip-002|vm-bigip-002.as3.Common.json|1395517003|main|Common|17-12-24_16:42|
# Devices
The following devices are configured:
|device|device group|AS3 Classes configured|
|---|---|---|
|vm-bigip-002|mybigip-group|iRule, Pool, DNS-Profile, Service-TCP, Service-UDP, Log-Publisher, Security-Log-Profile, Traffic-Log-Profile|
# AS3 Configuration for Partition: Common


## Class: iRule

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#irule

### iRule Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-irule.json

```json
                "{{Class:iRule}}": {
                    "class": "iRule",
                    "remark": "{{remark}}",
                    "iRule": {
                        "base64": "{{irule:base64}}"
                    }
                },
```

### iRule Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/ltm/as3-irule.csv

|device|application|Class:iRule|remark|irule:base64|
|---|---|---|---|---|
vm-bigip-002|Shared|irule-telemetryLocalRule|Telemetry Streaming|[irule-telemetryLocalRule.tcl](https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/irules/irule-telemetryLocalRule.tcl)
vm-bigip-002|Shared|irule-telemetryDnsReqLog|LTM Request Logging|[irule-telemetryDnsReqLog.tcl](https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/irules/irule-telemetryDnsReqLog.tcl)

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

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/ltm/as3-pool_simple.csv

|device|application|Class:Pool|remark|multi:serverAddresses|servicePort|multi:monitor|minimumMonitors|shareNodes|
|---|---|---|---|---|---|---|---|---|
vm-bigip-002|Shared|pool-telemetry|Telemetry Streaming to Azure Sentinel|255.255.255.254|6514|*not used*|*not used*|*not used*

## Class: DNS-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#dns-profile

### DNS-Profile Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-profile_dns.json

```json
				"{{Class:DNS_Profile}}": {
					"class": "DNS_Profile",
					"remark": "{{remark}}",
					"parentProfile": {
						"bigip": "/Common/dns"
					},
					"cacheEnabled": {{cacheEnabled}},
					"cache": { "use" : "{{cache}}" },
					"localBindServerEnabled": false,
					"rapidResponseEnabled": false,
					"unhandledQueryAction": "{{unhandledQueryAction}}",
					"dnssecEnabled": false,
					"globalServerLoadBalancingEnabled": {{globalServerLoadBalancingEnabled}},
					"dnsExpressEnabled": false,
					"zoneTransferEnabled": false,
					"recursionDesiredEnabled": {{recursionDesiredEnabled}},
					"securityEnabled": false
				},
```

### DNS-Profile Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/ltm/as3-profile_dns.csv

|device|application|Class:DNS_Profile|cacheEnabled|remark|cache|unhandledQueryAction|globalServerLoadBalancingEnabled|recursionDesiredEnabled|
|---|---|---|---|---|---|---|---|---|
vm-bigip-002|Shared|profileDns-gslb|false|DM DNS Internal Profile|*not used*|reject|true|true

## Class: Service-TCP

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-tcp

### Service-TCP Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-service_TCP_simple.json

```json
				"{{Class:Service_TCP}}": {
					"class": "Service_TCP",
					"virtualAddresses": [
						"{{virtualAddresses}}"
						],
					"iRules": [
						"{{multi:iRules}}"
					],
					"pool": "{{pool}}",
					"remark": "{{remark}}",
					"addressStatus": true,
					"virtualPort": {{virtualPort}},
					"allowVlans": ["{{allowVlans}}"],
				},
```

### Service-TCP Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/ltm/as3-service_TCP_simple.csv

|device|application|Class:Service_TCP|virtualPort|pool|remark|virtualAddresses|multi:iRules|allowVlans|
|---|---|---|---|---|---|---|---|---|
vm-bigip-002|Shared|vip-telemetryLocal|6514|pool-telemetry|Telemetry Streaming|255.255.255.254|irule-telemetryLocalRule|*not used*

## Class: Service-UDP

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-udp

### Service-UDP Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/ltm/as3-service_UDP.json

```json
			"{{Class:Service_UDP}}": {
				"class": "Service_UDP",
				"virtualAddresses": [
					"{{virtualAddresses}}"
				],
				"shareAddresses": {{shareAddresses}},
				"iRules": [
					{"{{iRules_use}}": "{{multi:iRules}}"}
				],
				"virtualPort": {{virtualPort}},
				"profileUDP": {
					"bigip": "/Common/udp"
				},
				"{{profile_type}}": {
					"{{profile_use}}": "{{profile_name}}"
				},
				"remark": "{{remark}}",
				"allowVlans": [
					"{{multi:allowVlans}}"
				]
			},
```

### Service-UDP Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/ltm/as3-service_UDP.csv

|device|application|Class:Service_UDP|virtualPort|multi:allowVlans|remark|virtualAddresses|shareAddresses|profile_type|profile_use|profile_name|iRules_use|multi:iRules|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
vm-bigip-002|Shared|vip-gslbListener|53|external|GSLB DNS listener|192.168.1.4|false|profileDNS|use|profileDns-gslb|use|irule-telemetryDnsReqLog

## Class: Log-Publisher

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#log-publisher

### Log-Publisher Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/telemetry/as3-logging.json

```json
                "{{remote-high-speed-log}}": {
                    "class": "Log_Destination",
                    "type": "remote-high-speed-log",
                    "protocol": "tcp",
                    "pool": {
                        "use": "{{pool}}"
                    }
                },
                "{{Log_Destination}}": {
                    "class": "Log_Destination",
                    "type": "splunk",
                    "forwardTo": {
                        "use": "{{remote-high-speed-log}}"
                    }
                },
                "{{Class:Log_Publisher}}": {
                    "class": "Log_Publisher",
                    "destinations": [
                        {
                            "use": "{{Log_Destination}}"
                        }
                    ]
                },
```

### Log-Publisher Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/telemetry/as3-logging.csv

|device|application|Class:Log_Publisher|Log_Destination|remote-high-speed-log|pool|
|---|---|---|---|---|---|
vm-bigip-002|Shared|logPublisher-telemetry|logDestination-telemetry|logDestination-telemetryHsl|pool-telemetry

## Class: Security-Log-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#security-log-profile

### Security-Log-Profile Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/telemetry/as3-Security_Log_Profile.json

```json
                "{{Class:Security_Log_Profile}}": {
                    "class": "Security_Log_Profile",
                    "application": {
                        "localStorage": false,
                        "remoteStorage": "splunk",
                        "protocol": "tcp",
                        "servers": [
                            {
                                "address": "127.0.0.1",
                                "port": "6514"
                            }
                        ],
                        "storageFilter": {
                            "requestType": "all"
                        }
                    },
                    "network": {
                        "publisher": {
                            "use": "{{publisher}}"
                        },
                        "logRuleMatchAccepts": false,
                        "logRuleMatchRejects": true,
                        "logRuleMatchDrops": true,
                        "logIpErrors": true,
                        "logTcpErrors": true,
                        "logTcpEvents": true
                    },
                    "dosApplication": {
                        "remotePublisher": {
                            "use": "{{publisher}}"
                        }
                    },
                    "dosNetwork": {
                        "publisher": {
                            "use": "{{publisher}}"
                        }
                    },
                    "protocolDnsDos": {
                        "publisher": {
                            "use": "{{publisher}}"
                        }
                    },
                    "protocolInspection": {
                        "publisher": {
                            "use": "{{publisher}}"
                        },
                        "logPacketPayloadEnabled": true
                    }
                }
```

### Security-Log-Profile Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/telemetry/as3-Security_Log_Profile.csv

|device|application|Class:Security_Log_Profile|publisher|
|---|---|---|---|
vm-bigip-002|Shared|security-loggingProfile|logPublisher-telemetry

## Class: Traffic-Log-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#traffic-log-profile

### Traffic-Log-Profile Template

Template File Location: https://github.com/thepowercoders/buildas3/blob/main/templates/telemetry/as3-Traffic_Log_Profile.json

```json
                "{{Class:Traffic_Log_Profile}}": {
                    "class": "Traffic_Log_Profile",
                    "requestSettings": {
                        "requestEnabled": {{requestEnabled}},
                        "requestProtocol": "mds-tcp",
                        "requestPool": {
                            "use": "{{requestPool}}"
                        },
                        "requestTemplate": "event_source=\"request_logging\",hostname=\"$BIGIP_HOSTNAME\",client_ip=\"$CLIENT_IP\",server_ip=\"$SERVER_IP\",dest_ip=\"$VIRTUAL_IP\",dest_port=\"$VIRTUAL_PORT\",http_method=\"$HTTP_METHOD\",http_uri=\"$HTTP_URI\",virtual_name=\"$VIRTUAL_NAME\",event_timestamp=\"$DATE_HTTP\",Microtimestamp=\"$TIME_USECS\""
                    },
                    "responseSettings": {
                        "responseEnabled": {{responseEnabled}},
                        "responseProtocol": "mds-tcp",
                        "responsePool": {
                            "use": "{{responsePool}}"
                        },
                        "responseTemplate": "event_source=\"response_logging\",hostname=\"$BIGIP_HOSTNAME\",client_ip=\"$CLIENT_IP\",server_ip=\"$SERVER_IP\",http_method=\"$HTTP_METHOD\",http_uri=\"$HTTP_URI\",virtual_name=\"$VIRTUAL_NAME\",event_timestamp=\"$DATE_HTTP\",http_statcode=\"$HTTP_STATCODE\",http_status=\"$HTTP_STATUS\",Microtimestamp=\"$TIME_USECS\",response_ms=\"$RESPONSE_MSECS\""
                    }
                },            
```

### Traffic-Log-Profile Data

Data File Location: https://github.com/thepowercoders/buildas3/blob/main/data/azTenant2/Common/telemetry/as3-Traffic_Log_Profile.csv

|device|application|Class:Traffic_Log_Profile|requestEnabled|requestPool|responseEnabled|responsePool|
|---|---|---|---|---|---|---|
vm-bigip-002|Shared|profile-ltmRequestLog|true|pool-telemetry|true|pool-telemetry
