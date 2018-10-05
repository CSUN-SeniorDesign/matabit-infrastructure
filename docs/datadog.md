# DataDog 

Datadog is a monitoring service for cloud-scale applications, providing monitoring of servers, databases, tools, and services, through a SaaS-based data analytics platform. Formally python based, DataDog now uses a GO based agent that will deliver metrics and events across the full devops stack such as: 

    ⋅⋅* Automation tools
    ⋅⋅*Monitoring and instrumentation
    ⋅⋅*Source control and bug tracking
    ⋅⋅*Databases and common server components
    ⋅⋅*All listed integration's are supported by Datadog
    ⋅⋅*SaaS and Cloud providers

    Simple metrics such as:

    ⋅⋅*CPU usage
    ⋅⋅*CPU load averages (1 minutes, 5 minute, 15 minute)
    ⋅⋅*Memory usage by the system
    ⋅⋅*Disk usage on the system
    ⋅⋅*Process Uptime

Can be tracked easily with DataDog since they are built in. Simply navigate to the dashboard tap on the left hand side, choose new dashboard, choose the timestamp option. From there a tab at the top will give you a graph option from where you can gather the metrics mentioned above built into DataDog itself. 

Additional metrics need to be tracked were: 

    • The number of requests to your website
    • The latency for requests to your website
    • Status codes of requests to your server (2xx, 3xx, 4xx, 5xx)

A custom config file needs to be created in order to track theses metrics through DataDog.

## http_check.yaml

```
init_config:
  # Change default path of trusted certificates
  # ca_certs: /etc/ssl/certs/ca-certificates.crt

instances:
  - name: My staging env
    url: https://staging.matabit.org
  
  - name: My prod env
    url: https://matabit.org

    timeout: 1

    # The (optional) http_response_status_code parameter will instruct the check
    # to look for a particular HTTP response status code or a Regex identifying
    # a set of possible status codes.
    # The check will report as DOWN if status code returned differs.
    # This defaults to 1xx, 2xx and 3xx HTTP status code: (1|2|3)\d\d.
    http_response_status_code: (2|3|4|5)\d\d

    # The (optional) collect_response_time parameter will instruct the
    # check to create a metric 'network.http.response_time', tagged with
    # the url, reporting the response time in seconds.
    
    # The latency for requests to the website
    collect_response_time: true
```

Here is the HTTP Check config file to track the http request status codes and the collect response time to track the latency. 

## nginx.yaml

```
init_config:
  # Change default path of trusted certificates
  # ca_certs: /etc/ssl/certs/ca-certificates.crt

instances:
  # Check for nubmer of requests to the website
  - nginx_status_url: http://localhost:81/nginx_status/
```

The nginx.yaml config file checks for the number of requests to the website. 
