when DNS_REQUEST priority 500 {
    set hostname [info hostname]
    set ldns [IP::client_addr]
    set vs_name [virtual name]
    set q_name [DNS::question name]
    set q_type [DNS::question type]
    set now [clock seconds]
    set ts [clock format $now -format {%a, %d %b %Y %H:%M:%S %Z}]
    if { $q_type == "A" } {
        set hsl_reqlog [HSL::open -proto TCP -pool "/Common/Shared/pool-telemetry"]
        HSL::send $hsl_reqlog "event_source=\"dns_request_logging\",hostname=\"$hostname\",client_ip=\"$ldns\",server_ip=\"\",http_method=\"\",http_uri=\"\",virtual_name=\"$vs_name\",dns_query_name=\"$q_name\",dns_query_type=\"$q_type\",dns_query_answer=\"\",event_timestamp=\"$ts\"\n"
        unset -- "hsl_reqlog"
    }
    unset -- "ldns"
    unset -- "vs_name"
    unset -- "q_name"
    unset -- "q_type"
    unset -- "now"
    unset -- "ts"
   }

   when DNS_RESPONSE priority 501 {
    
    set hostname [info hostname]
    set ldns [IP::client_addr]
    set vs_name [virtual name]
    set q_name [DNS::question name]
    set q_type [DNS::question type]
    set q_answer [DNS::answer]
    set now [clock seconds]
    set ts [clock format $now -format {%a, %d %b %Y %H:%M:%S %Z}]
    
    if { $q_type == "A" } {
        set hsl_reslog [HSL::open -proto TCP -pool "/Common/Shared/pool-telemetry"]
        HSL::send $hsl_reslog "event_source=\"dns_response_logging\",hostname=\"$hostname\",client_ip=\"$ldns\",server_ip=\"\",http_method=\"\",http_uri=\"\",virtual_name=\"$vs_name\",dns_query_name=\"$q_name\",dns_query_type=\"$q_type\",dns_query_answer=\"$q_answer\",event_timestamp=\"$ts\"\n"
        unset -- "hsl_reslog"
    }
    
    unset -- "ldns"
    unset -- "vs_name"
    unset -- "q_name"
    unset -- "q_type"
    unset -- "q_answer"
    unset -- "now"
    unset -- "ts"
   }
