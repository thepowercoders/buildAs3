> :memo: **Note:** This wiki was generated using [as3LLDWikiGenerator.ps1](https://dev.azure.com/test/test/_git/test?path=/buildAs3/as3LLDWikiGenerator.ps1) based on the AS3 configuration files on Sep 10 17:50:07.
[[_TOC_]]


# Declarations
This LLD is aligned to the following declarations:
|device|declaration|ID|Branch|Partition|Date Created|
|---|---|---|---|---|---|
|vm-test-dev-uks-bigip-001|vm-test-dev-uks-bigip-001.as3.Common.json|558982376|main|Common|10-09-24_17:49|
# Devices
The following devices are configured:
|device|device group|AS3 Classes configured|
|---|---|---|
|vm-test-dev-uks-bigip-001|test-bigip|DOS-Profile, Pool, iRule, Certificate, Certificate, Monitor, Monitor, TLS-Client, TLS-Server, Service-HTTPS, Service-HTTP, Log-Publisher, Security-Log-Profile, Traffic-Log-Profile|
# AS3 Configuration for Partition: azure_tenant_1


## Class: Certificate

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#certificate

### Certificate Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-certificate_file.json

```json
```

### Certificate Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/ltm/as3-certificate_file.csv

|device|application|Class:Certificate|cert:certificate|cert:privateKey|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|cert-trustchain-dccki|[default.cer](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/certificates/default.cer)|*not used*

## Class: iRule

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#irule

### iRule Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-irule.json

```json
```

### iRule Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/ltm/as3-irule.csv

|device|application|Class:iRule|remark|irule:base64|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|irule-telemetry-local-rule|Telemetry Streaming|[irule-ts.tcl](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/irules/irule-ts.tcl)

## Class: Pool

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#pool

### Pool Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-pool_simple.json

```json
```

### Pool Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/ltm/as3-pool_simple.csv

|device|application|Class:Pool|remark|multi:serverAddresses|servicePort|multi:monitor|minimumMonitors|shareNodes|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|pool-uks-telemetry-tcp6514|Telemetry Streaming to Azure Sentinel|255.255.255.254|6514|*not used*|*not used*|*not used*

## Class: Service-TCP

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-tcp

### Service-TCP Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-service_TCP_simple.json

```json
```

### Service-TCP Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/ltm/as3-service_TCP_simple.csv

|device|application|Class:Service_TCP|virtualPort|pool|remark|virtualAddresses|multi:iRules|allowVlans|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|vs-uks-dns-telemetry-local|6514|pool-uks-telemetry-tcp6514|Telemetry Streaming|255.255.255.254|irule-telemetry-local-rule|*not used*

## Class: Service-UDP

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-udp

### Service-UDP Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-service_UDP.json

```json
```

### Service-UDP Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/ltm/as3-service_UDP.csv

|device|application|Class:Service_UDP|virtualPort|multi:allowVlans|remark|virtualAddresses|shareAddresses|profile_type|profile_use|profile_name|iRules_use|multi:iRules|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|vs-uks-vm001-bigip-listener-f5-trusted-udp53|53|f5-trusted-ipv4|Internal DNS listener|172.16.227.132|true|profileDNS|use|prof-dns-int|*not used*
vm-test-dev-uks-bigip-001|Shared|vs-uks-vm001-gslb-listener-f5-untrusted-udp53|53|f5-untrusted-ipv4|GSLB DNS listener|172.16.227.5|false|profileDNS|use|prof-dns-gslb|use|irule-dm-telemetry-dnsreqlog<br>irule-dm-telemetry-dnsrsplog

## Class: Log-Publisher

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#log-publisher

### Log-Publisher Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/telemetry/as3-logging.json

```json
```

### Log-Publisher Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/telemetry/as3-logging.csv

|device|application|Class:Log_Publisher|Log_Destination|remote-high-speed-log|pool|
|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|log-pub-telemetry|log-dest-telemetry-syslog|log-dest-telemetry-hsl|pool-uks-telemetry-tcp6514

## Class: Security-Log-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#security-log-profile

### Security-Log-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/telemetry/as3-Security_Log_Profile.json

```json
```

### Security-Log-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/telemetry/as3-Security_Log_Profile.csv

|device|application|Class:Security_Log_Profile|publisher|
|---|---|---|---|
group:prod|Shared|sec-logprof|log-pub-telemetry

## Class: Traffic-Log-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#traffic-log-profile

### Traffic-Log-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/telemetry/as3-Traffic_Log_Profile.json

```json
```

### Traffic-Log-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_1/Common/telemetry/as3-Traffic_Log_Profile.csv

|device|application|Class:Traffic_Log_Profile|requestEnabled|requestPool|responseEnabled|responsePool|
|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|prof-reqlog|true|pool-uks-telemetry-tcp6514|true|pool-uks-telemetry-tcp6514
# AS3 Configuration for Partition: azure_tenant_2


## Class: DOS-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#dos-profile

### DOS-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/afm/as3-DOS_profile_dns.json

```json
```

### DOS-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/afm/as3-DOS_profile_dns.csv

|device|application|Class:DOS_Profile|allowlist|remark|subtable:DOS_vectors|
|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|sec-pol-ddos-dns|*not used*|DDOS DNS Profile|dns

## Class: Firewall-Address-List

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#firewall-address-list

### Firewall-Address-List Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/afm/as3-firewall_address_list.json

```json
```

### Firewall-Address-List Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/afm/as3-firewall_address_list.csv

|device|application|Class:Firewall_Address_List|multi:fw_cidr|
|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|fwal-external|0.0.0.0/0
vm-test-dev-uks-bigip-001|Shared|fwal-vip-dns|192.168.1.1
vm-test-dev-uks-bigip-001|Shared|fwal-vip-dmapps|192.168.1.10
vm-test-dev-uks-bigip-001|Shared|fwal-int-azure_dns|168.63.129.16
vm-test-dev-uks-bigip-001|Shared|fwal-int-any|192.168.2.0/24
vm-test-dev-uks-bigip-001|Shared|fwal-int-bigip_selfip|192.168.2.10
vm-test-dev-uks-bigip-001|Shared|fwal-defaultdeny|0.0.0.0/0

## Class: Firewall-Policy

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#firewall-policy

### Firewall-Policy Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/afm/as3-firewall_policy.json

```json
```

### Firewall-Policy Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/afm/as3-firewall_policy.csv

|device|application|Class:Firewall_Policy|subtable:policy_rulelists|
|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|nwfw-pol-uks-global|rulelist-001

### policy_rulelists Subtable Data

### Firewall-Policy Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/afm/sub-policy_rulelists.json.json

```json
```

### Firewall-Policy Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/afm/sub-policy_rulelists.csv

|policy_rulelists|ruleName|
|---|---|
rulelist-001|nwfw-rulelist-systemrules-global
rulelist-001|nwfw-rulelist-global

## Class: Firewall-Port-List

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#firewall-port-list

### Firewall-Port-List Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/afm/as3-firewall_port_list.json

```json
```

### Firewall-Port-List Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/afm/as3-firewall_port_list.csv

|device|application|Class:Firewall_Port_List|multi:port|
|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|fwpl-iquery|4353
vm-test-dev-uks-bigip-001|Shared|fwpl-dns|53
vm-test-dev-uks-bigip-001|Shared|fwpl-api|443

## Class: Firewall-Rule-List

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#firewall-rule-list

### Firewall-Rule-List Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/afm/as3-firewall_rule_list.json

```json
```

### Firewall-Rule-List Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/afm/as3-firewall_rule_list.csv

|device|application|Class:Firewall_Rule_List|subtable:firewall_rule|
|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|nwfw-rulelist-systemrules-global|global-systemrules
vm-test-dev-uks-bigip-001|Shared|nwfw-rulelist-global|global-all

### firewall_rule Subtable Data

### Firewall-Rule-List Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/afm/sub-firewall_rule.json.json

```json
```

### Firewall-Rule-List Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/afm/sub-firewall_rule.csv

|firewall_rule|name|remark|protocol|multi:source_addresslist|multi:source_portlist|source_vlan|multi:dest_addresslist|multi:dest_portlist|iRule|action|log|
|---|---|---|---|---|---|---|---|---|---|---|---|
global-systemrules|fwrule-trust-bigip-iquery|BIG-IP iQuery Sync|tcp|fwal-int-bigip_selfip|*not used*|f5-trusted-ipv4|fwal-int-bigip_selfip|fwpl-iquery|*not used*|accept|false
global-systemrules|fwrule-trust-azuredns|Azure DNS|udp|fwal-int-azure_dns|fwpl-dns|f5-trusted-ipv4|fwal-vip-internal_dns|*not used*|*not used*|accept|false
global-systemrules|fwrule-trust-azurefw_dns|Azure Firewall DNS|udp|fwal-int-azure_fw|*not used*|f5-trusted-ipv4|fwal-vip-internal_dns|fwpl-dns|*not used*|accept|false
global-systemrules|fwrule-untrust-dsp_dns|DX.1780 Sec:2.2 DSP to DM GSLB|udp|fwal-ext-dsp_dns<br>fwal-ext-dsp_tri_portal|*not used*|f5-untrusted-ipv4|fwal-vip-dns|fwpl-dns|*not used*|accept|true
global-all|fwrule-untrust-webapp-in|Incoming to Web App|tcp|fwal-external|*not used*|f5-untrusted-ipv4|fwal-vip-dmapps|fwpl-api|*not used*|accept|true
global-all|default-deny-all|default deny|any|fwal-defaultdeny|*not used*|*not used*|fwal-defaultdeny|*not used*|*not used*|drop|true

## Class: DNS-Cache

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#dns-cache

### DNS-Cache Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/as3-DNS_Cache_resolver.json

```json
```

### DNS-Cache Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/as3-DNS_Cache_resolver.csv

|device|application|Class:DNS_Cache|type|subtable:DNS_Cache_forwardZones|subtable:DNS_Cache_localZones|
|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|dns-cache-azinternal|resolver|dns_forwardzones|dns_localzones

### DNS_Cache_forwardZones Subtable Data

### DNS-Cache Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/sub-DNS_Cache_forwardZones.json.json

```json
```

### DNS-Cache Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/sub-DNS_Cache_forwardZones.csv

|DNS_Cache_forwardZones|forwardZone|multi:nameservers|
|---|---|---|
dns_forwardzones|.|168.63.129.16:53

### DNS_Cache_localZones Subtable Data

### DNS-Cache Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/sub-DNS_Cache_localZones.json.json

```json
```

### DNS-Cache Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/sub-DNS_Cache_localZones.csv

|DNS_Cache_localZones|localZone|type|dns:zonefile|
|---|---|---|---|
dns_localzones|in-addr.arpa|transparent|reverse_dns
dns_localzones|mytenant.onmicrosoft.com|transparent|internal_dns

###  Zone File: reverse_dns

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/dns-zone/reverse_dns

```
```

###  Zone File: internal_dns

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/dns-zone/internal_dns

```
```

## Class: GSLB-Data-Center

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-data-center

### GSLB-Data-Center Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/as3-GSLB_Data_Center.json

```json
```

### GSLB-Data-Center Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/as3-GSLB_Data_Center.csv

|device|application|Class:GSLB_Data_Center|location|remark|proberPreferred|proberFallback|
|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|gslb-dc-azure-uksouth-dm|London|Azure UK South|inside-datacenter|any-available

## Class: GSLB-Server

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-server

### GSLB-Server Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/as3-GSLB_Server.json

```json
```

### GSLB-Server Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/as3-GSLB_Server.csv

|device|application|Class:GSLB_Server|dataCenter|subtable:GSLB_Server_Device|GSLB_Monitor|serverType|virtualServerDiscoveryMode|subtable:GSLB_Server_vips|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|gslb-srv-vm-test-dev-uks-bigip-001|gslb-dc-azure-uksouth-dm|uks001|/Common/bigip|bigip|enabled-no-delete|*not used*

### GSLB_Server_Device Subtable Data

### GSLB-Server Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/sub-GSLB_Server_Device.json.json

```json
```

### GSLB-Server Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/sub-GSLB_Server_Device.csv

|GSLB_Server_Device|address|addressTranslation|remark|
|---|---|---|---|
uks001|172.16.227.132|*not used*|vm-test-dev-uks-bigip-001

## Class: GSLB-Topology-Region

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-topology-region

### GSLB-Topology-Region Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/as3-GSLB_Topology_Region.json

```json
```

### GSLB-Topology-Region Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/as3-GSLB_Topology_Region.csv

|device|application|Class:GSLB_Topology_Region|label|subtable:GSLB_Topology_Region_members|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|gslb-region-azurefw_uks|Azure Firewall UKS Subnet|azurefw_uks_subnet
vm-test-dev-uks-bigip-001|Shared|gslb-region-internal|Azure Firewall UKW Subnet|dminternal_subnet

### GSLB_Topology_Region_members Subtable Data

### GSLB-Topology-Region Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/dns/sub-GSLB_Topology_Region_members.json.json

```json
```

### GSLB-Topology-Region Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/dns/sub-GSLB_Topology_Region_members.csv

|GSLB_Topology_Region_members|matchType|matchOperator|matchValue|
|---|---|---|---|
azurefw_uks_subnet|subnet|equals|172.16.226.0/26
azurefw_ukw_subnet|subnet|equals|172.16.242.0/26
dminternal_subnet|subnet|equals|172.16.224.0/19
dsp_subnet|subnet|equals|172.18.32.8/29

## Class: Certificate

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#certificate

### Certificate Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-certificate_file.json

```json
```

### Certificate Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/ltm/as3-certificate_file.csv

|device|application|Class:Certificate|cert:certificate|cert:privateKey|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|cert-trustchain-dccki|[default.cer](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/certificates/default.cer)|*not used*

## Class: iRule

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#irule

### iRule Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-irule.json

```json
```

### iRule Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/ltm/as3-irule.csv

|device|application|Class:iRule|remark|irule:base64|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|irule-telemetry-dnsreqlog|DNS Request Logging|[irule-telemetry-dnsreqlog.tcl](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/irules/irule-telemetry-dnsreqlog.tcl)
vm-test-dev-uks-bigip-001|Shared|irule-telemetry-dnsrsplog|DNS Response Logging|[irule-telemetry-dnsrsplog.tcl](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/irules/irule-telemetry-dnsrsplog.tcl)
vm-test-dev-uks-bigip-001|Shared|irule-telemetry-local-rule|Telemetry Streaming|[irule-ts.tcl](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/irules/irule-ts.tcl)

## Class: Pool

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#pool

### Pool Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-pool_simple.json

```json
```

### Pool Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/ltm/as3-pool_simple.csv

|device|application|Class:Pool|remark|multi:serverAddresses|servicePort|multi:monitor|minimumMonitors|shareNodes|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|pool-uks-telemetry-tcp6514|Telemetry Streaming to Azure Sentinel|255.255.255.254|6514|*not used*|*not used*|*not used*
vm-test-dev-uks-bigip-001|Shared|pool-uks-telemetry-rsplog-tcp6514|Separate pool for HSL logging for DNS responses|255.255.255.254|6514|*not used*|*not used*|*not used*

## Class: DNS-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#dns-profile

### DNS-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-profile_dns.json

```json
```

### DNS-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/ltm/as3-profile_dns.csv

|device|application|Class:DNS_Profile|cacheEnabled|remark|cache|unhandledQueryAction|globalServerLoadBalancingEnabled|recursionDesiredEnabled|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|prof-dns-int|true|DNS Internal Profile|dns-cache-azinternal|reject|true|true
vm-test-dev-uks-bigip-001|Shared|prof-dns-gslb|false|DNS External Profile|*not used*|reject|true|true

## Class: Service-TCP

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-tcp

### Service-TCP Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-service_TCP_simple.json

```json
```

### Service-TCP Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/ltm/as3-service_TCP_simple.csv

|device|application|Class:Service_TCP|virtualPort|pool|remark|virtualAddresses|multi:iRules|allowVlans|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|vs-uks-dns-telemetry-local|6514|pool-uks-telemetry-tcp6514|Telemetry Streaming|255.255.255.254|irule-telemetry-local-rule|*not used*

## Class: Service-UDP

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-udp

### Service-UDP Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/ltm/as3-service_UDP.json

```json
```

### Service-UDP Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/ltm/as3-service_UDP.csv

|device|application|Class:Service_UDP|virtualPort|multi:allowVlans|remark|virtualAddresses|shareAddresses|profile_type|profile_use|profile_name|iRules_use|multi:iRules|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|vs-uks-vm001-bigip-listener-f5-trusted-udp53|53|f5-trusted-ipv4|Internal DNS listener|172.16.227.132|true|profileDNS|use|prof-dns-int|*not used*
vm-test-dev-uks-bigip-001|Shared|vs-uks-vm001-gslb-listener-f5-untrusted-udp53|53|f5-untrusted-ipv4|GSLB DNS listener|172.16.227.5|false|profileDNS|use|prof-dns-gslb|use|irule-dm-telemetry-dnsreqlog<br>irule-dm-telemetry-dnsrsplog

## Class: Log-Publisher

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#log-publisher

### Log-Publisher Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/telemetry/as3-logging.json

```json
```

### Log-Publisher Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/telemetry/as3-logging.csv

|device|application|Class:Log_Publisher|Log_Destination|remote-high-speed-log|pool|
|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|log-pub-telemetry|log-dest-telemetry-syslog|log-dest-telemetry-hsl|pool-uks-telemetry-tcp6514

## Class: Security-Log-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#security-log-profile

### Security-Log-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/telemetry/as3-Security_Log_Profile.json

```json
```

### Security-Log-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/telemetry/as3-Security_Log_Profile.csv

|device|application|Class:Security_Log_Profile|publisher|
|---|---|---|---|
group:prod|Shared|sec-logprof|log-pub-telemetry

## Class: Traffic-Log-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#traffic-log-profile

### Traffic-Log-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/Common/telemetry/as3-Traffic_Log_Profile.json

```json
```

### Traffic-Log-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/Common/telemetry/as3-Traffic_Log_Profile.csv

|device|application|Class:Traffic_Log_Profile|requestEnabled|requestPool|responseEnabled|responsePool|
|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|Shared|prof-reqlog|true|pool-uks-telemetry-tcp6514|true|pool-uks-telemetry-tcp6514

## Class: DOS-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#dos-profile

### DOS-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/afm/as3-DOS_profile_http.json

```json
```

### DOS-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/afm/as3-DOS_profile_http.csv

|device|application|Class:DOS_Profile|applicationAllowlist|remark|TPS_operationMode|TPS_thresholdsMode|TPS_escalationPeriod|TPS_deEscalationPeriod|Stress_operationMode|Stress_thresholdsMode|Stress_escalationPeriod|Stress_deEscalationPeriod|
|---|---|---|---|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|sec-pol-ddos-app01-http|*not used*|DDOS HTTP Profile|transparent|automatic|120|7200|transparent|automatic|120|7200

## Class: Protocol-Inspection-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#protocol-inspection-profile

### Protocol-Inspection-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/afm/as3-IDPS_profile.json

```json
```

### Protocol-Inspection-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/afm/as3-IDPS_profile.csv

|device|application|Class:Protocol_Inspection_Profile|remark|type|multi:ports|
|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|sec-pol-ips-app01-http|DCC-DM HTTP DM App Inspection Profile|http|443

## Class: WAF-Policy

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#waf-policy

### WAF-Policy Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/asm/as3-WAF_Policy.json

```json
```

### WAF-Policy Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/asm/as3-WAF_Policy.csv

|device|application|Class:WAF_Policy|enforcementMode|waf:policy|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|sec-pol-app01-waf|transparent|[uks-waf-app01.json](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/asm/uks-waf-app01.json)

## Class: GSLB-Domain

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-domain

### GSLB-Domain Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/dns/as3-GSLB_Domain.json

```json
```

### GSLB-Domain Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/dns/as3-GSLB_Domain.csv

|device|application|Class:GSLB_Domain|domainName|resourceRecordType|multi:pools|poolLbMode|
|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|gslb-wip-app001|app001.wip.mytenant.onmicrosoft.com|A|gslb-pool-uks-prod-dmfmware-v6<br>gslb-pool-ukw-proddr-dmfmware-v6|global-availability

## Class: GSLB-Pool

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-pool

### GSLB-Pool Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/dns/as3-GSLB_Pool.json

```json
```

### GSLB-Pool Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/dns/as3-GSLB_Pool.csv

|device|application|Class:GSLB_Pool|resourceRecordType|remark|subtable:GSLB_Pool_members|lbModePreferred|lbModeAlternate|lbModeFallback|ttl|
|---|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|gslb-pool-uks-prod-dmapps-ext|A|DM Applications WIP|gslb-pool-uks-prod-dmapps-ext|ratio|global-availability|none|300
vm-test-dev-uks-bigip-001|App001|gslb-pool-uks-prod-dmapps-int|A|DM Applications WIP|gslb-pool-uks-prod-dmapps-int|ratio|global-availability|none|300

### GSLB_Pool_members Subtable Data

### GSLB-Pool Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/dns/sub-GSLB_Pool_members.json.json

```json
```

### GSLB-Pool Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/dns/sub-GSLB_Pool_members.csv

|GSLB_Pool_members|ratio|use|server|virtualServer|
|---|---|---|---|---|
gslb-pool-uks-prod-dmapps-ext|50|bigip|/Common/gslb-srv-con-prod-dm-uks-f5-001|/dccdm-prod/dmapps/vs-uks-vm001-uks-apim-dmapps-prod-tcp443
gslb-pool-uks-prod-dmapps-ext|50|bigip|/Common/gslb-srv-con-prod-dm-uks-f5-002|/dccdm-prod/dmapps/vs-uks-vm002-uks-apim-dmapps-prod-tcp443
gslb-pool-uks-prod-dmapps-int|50|bigip|/Common/gslb-srv-con-prod-dm-uks-f5-001|/dccoms-prod/omsapps/vs-uks-vm001-omsapps-uks-dmapps-prod-tcp443
gslb-pool-uks-prod-dmapps-int|50|bigip|/Common/gslb-srv-con-prod-dm-uks-f5-002|/dccoms-prod/omsapps/vs-uks-vm002-omsapps-uks-dmapps-prod-tcp443

## Class: GSLB-Topology-Records

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#gslb-topology-records

### GSLB-Topology-Records Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/dns/as3-GSLB_Topology_Records.json

```json
```

### GSLB-Topology-Records Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/dns/as3-GSLB_Topology_Records.csv

|device|application|Class:GSLB_Topology_Records|label|subtable:GSLB_Topology_Records|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|splitbrain-topology|DM Internal/External Pool Selection|dns_top

### GSLB_Topology_Records Subtable Data

### GSLB-Topology-Records Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/dns/sub-GSLB_Topology_Records.json.json

```json
```

### GSLB-Topology-Records Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/dns/sub-GSLB_Topology_Records.csv

|GSLB_Topology_Records|source_matchType|source_matchOperator|source_matchValue_use|source_matchValue|destination_matchType|destination_matchOperator|destination_matchValue_use|destination_matchValue|weight|
|---|---|---|---|---|---|---|---|---|---|
dns_top|region|equals|bigip|/Common/gslb-region-dsp|pool|equals|use|gslb-pool-uks-prod-dmapps-ext|150
dns_top|region|equals|bigip|/Common/gslb-region-dsp|pool|equals|use|gslb-pool-ukw-proddr-dmapps-ext|100
dns_top|region|equals|bigip|/Common/gslb-region-azurefw_ukw|pool|equals|use|gslb-pool-ukw-proddr-dmapps-int|30
dns_top|region|equals|bigip|/Common/gslb-region-dminternal|pool|equals|use|gslb-pool-uks-prod-dmapps-int|20
dns_top|region|equals|bigip|/Common/gslb-region-dminternal|pool|equals|use|gslb-pool-ukw-proddr-dmapps-int|10
dns_top|region|not-equals|bigip|/Common/gslb-region-dminternal|pool|equals|use|gslb-pool-uks-prod-dmapps-ext|2
dns_top|region|not-equals|bigip|/Common/gslb-region-dminternal|pool|equals|use|gslb-pool-ukw-proddr-dmapps-ext|1

## Class: Certificate

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#certificate

### Certificate Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-certificate.json

```json
```

### Certificate Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-certificate.csv

|device|application|Class:Certificate|certificate|privateKey|chainCA|
|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|cert-prod|/Common/cert-dmapps-dccki-prod|/Common/cert-dmapps-dccki-prod|/Common/Shared/cert-trustchain-dccki.crt
vm-test-dev-uks-bigip-001|App001|dmapps|cert-dm_omsapps-bigip-int-prod|/Common/cert-dm_omsapps-bigip-int-prod|/Common/cert-dm_omsapps-bigip-int-prod|*not used*

## Class: iRule

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#irule

### iRule Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-irule.json

```json
```

### iRule Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-irule.csv

|device|application|Class:iRule|remark|irule:base64|
|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|irule-headerinsert-app001|Azure App Header Rewrite Rule|[irule-headerinsert-app001.tcl](https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/irules/irule-headerinsert-app001.tcl)

## Class: Monitor

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#monitor

### Monitor Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-monitor_https.json

```json
```

### Monitor Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-monitor_https.csv

|device|application|Class:Monitor|remark|targetPort|receiveDown|receive|send|interval|timeout|clientTLS|
|---|---|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|mon-dm-apim-prod-tcp443|Health Monitor for APIM|443|503 Service Unavailable|200 Service Operational|GET /status-0123456789abcdef HTTP/1.1\r\nHost: prod-prod-dm-uks-core-apim-001.azure-api.net\r\nFrom: con-prod-dm-uks-f5-001.dccplatform.onmicrosoft.com\r\n|20|61|servertls-uks-dmapps-prod

## Class: Pool

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#pool

### Pool Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-pool_simple.json

```json
```

### Pool Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-pool_simple.csv

|device|application|Class:Pool|remark|multi:serverAddresses|servicePort|multi:monitor|minimumMonitors|shareNodes|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|pool-uks-apim-prod-tcp443|Azure UK South APIM PROD|172.16.232.4|443|mon-dm-apim-prod-tcp443<br>mon-ext-azurepaas-cosmos<br>mon-ext-azurepaas-chstorage<br>mon-ext-azurepaas-smstorage<br>mon-ext-azurepaas-sqlserver|*not used*|true

## Class: HTTP-Profile

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#http-profile

### HTTP-Profile Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-profile_http.json

```json
```

### HTTP-Profile Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-profile_http.csv

|device|application|Class:HTTP_Profile|serverHeaderValue|remark|multi:knownMethods|insertHeader_name|insertHeader_value|
|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|prof-dm-http-app001|uksvm001|DM HTTP Profile|GET<br>POST|*not used*|*not used*

## Class: Service-HTTPS

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#service-https

### Service-HTTPS Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-service_HTTPS.json

```json
```

### Service-HTTPS Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-service_HTTPS.csv

|device|application|Class:Service_HTTPS|virtualAddresses|shareAddresses|profileHTTP_use|profileHTTP|profileTrafficLog|multi:iRules|pool|remark|allowVlans|virtualPort|snat|serverTLS|clientTLS|policyFirewallStaged|policyFirewallEnforced|policyWAF|profileDOS|profileProtocolInspection|securityLogProfiles|
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
con-prod-dm-uks-f5-001|dmapps|vip-vm001-uks-app01|192.168.1.1|false|use|prof-dm-http-app001|/Common/Shared/prof-reqlog|irule-headerinsert-app001|/dccdm-prod/Shared/pool-uks-app001|Azure APIM|f5-untrusted-ipv4|443|auto|clienttls-dsp-dmapps-prod|servertls-uks-dmapps-prod|*not used*|*not used*|sec-pol-app01-prod-waf|sec-pol-ddos-app01-http|sec-pol-ips-app01-http|/Common/Shared/sec-logprof-dccdm

## Class: TLS-Client

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#tls-client

### TLS-Client Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-tls_client.json

```json
```

### TLS-Client Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-tls_client.csv

|device|application|Class:TLS_Client|clientCertificate|cipherGroup|trustCA|validateCertificate|sendSNI|cacheTimeout|
|---|---|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|servertls-dsp-dmapps-prod|cert-dmapps-dccki-prod|*not used*|/Common/Shared/cert-trustchain-dccki.crt|true|*not used*|*not used*

## Class: TLS-Server

API Ref: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/refguide/schema-reference.html#tls-server

### TLS-Server Template

Template File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/templates/tenant01/ltm/as3-tls_server.json

```json
```

### TLS-Server Data

Data File Location: https://dev.azure.com/test/test/_git/test?path=/buildAs3/data/azure_tenant_2/tenant01/ltm/as3-tls_server.csv

|device|application|Class:TLS_Server|certificate|authenticationTrustCA|authenticationMode|cacheTimeout|
|---|---|---|---|---|---|---|
vm-test-dev-uks-bigip-001|App001|clienttls-dsp-dmapps-prod|cert-dmapps-dccki-prod|/Common/Shared/cert-trustchain-dccki|require|*not used*
