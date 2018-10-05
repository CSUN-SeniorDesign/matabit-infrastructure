# Install AWS CLI

```YAML
---
  - name: Install AWS CLI
    become: true
    pip:
      name: "{{ item }}"
      state: present
      extra_args: --upgrade
    with_items:
      - awscli
```

Here we use the `pip` module to install the AWS CLI as per official AWS documentation.

The `--upgrade` argument tells `pip` to update any of the requirements that awscli might need.
This way everything is up-to-date.

