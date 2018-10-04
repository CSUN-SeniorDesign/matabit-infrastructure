# Creating the environment folders

```YAML
---
- name: make prod and staging folder
  become: true
  file:
    path: "/var/www/{{item}}/matabit-blog/public"
    state: directory
    owner: www-data
    group: www-data
    mode: 0775
    recurse: yes
  with_items: ["prod", "staging"]
```  

Using the `file` module, we can create files and/or directories!

The `state` defines whether we are about to create a directory or a file.

Since we are creating two directories called `prod` and `staging` in the `/var/www/` folder,
we are using a path with the `{{item}}` variable, which can take as many arguments as we give it.
the `with_items` array actually defines the items that we need to create those folders.

The file module will also create all the folders that we have defined along the path, if they don't exist.

We make sure that the owner/group of those folder are recursively set to `www-data`.


  
  
