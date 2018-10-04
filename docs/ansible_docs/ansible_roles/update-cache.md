# Update-Cache

```YAML
---
  - name: Update cache
    become: true
    apt:
      update_cache: yes
```

The `apt` module is reponsible for the package-manager on our modified Ubuntu image.
Setting `update_cache` to `yes` will make sure that all our packages are up-to-date.