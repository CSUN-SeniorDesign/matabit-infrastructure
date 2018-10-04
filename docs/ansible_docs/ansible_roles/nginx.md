# Installing NGINX

```YAML
---
  - name: Install Nginx and Dependencies
    become: true
    apt:
      name: "{{ item }}"
      state: present
    with_items:
      - nginx
```

Using the `apt` module we can install nginx by simply defining the name of the package and defining its `state` to `present`.