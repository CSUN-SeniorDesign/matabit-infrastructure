# Configure Datadog-Agent

```YAML
---
  - name: Change http_check template
    become: true
    template:
      src: http_check.yaml
      dest: /etc/datadog-agent/conf.d/http_check.d/conf.yaml
  - name: Change nginx template
    become: true
    template:
      src: nginx.yaml
      dest: /etc/datadog-agent/conf.d/nginx.d/conf.yaml
  - name: Change ssh_check template
    become: true
    template:
      src: ssh_check.yaml
      dest: /etc/datadog-agent/conf.d/ssh_check.d/conf.yaml
  - name: Restart DataDog
    become: true
    command: systemctl restart datadog-agent
```

Here we're using the `template` module to update the correct configurations and enable the correct metrics.

We are enabling `http_check` `nginx` and `ssh_check`.

Lastly, we're using the `command` module to restart the `datadog-agent` to enable all the configurations.

### HTTP-CHECK
```YAML
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

### NGINX
```YAML
init_config:
  # Change default path of trusted certificates
  # ca_certs: /etc/ssl/certs/ca-certificates.crt

instances:
  # Check for nubmer of requests to the website
  - nginx_status_url: http://localhost:81/nginx_status/
```

### SSH-CHECK
```YAML
init_config:

instances:
  - host: 127.0.0.1 # required
    username: root # required
```