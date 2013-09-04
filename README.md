Rezzza Capistrano Tools
=======================


Vaultage
--------

Configuration

```
set :vaultage,              true
set(:vaultage_files) {[
    ["/app/config/parameters/#{rails_env}.yml.gpg", "/app/config/parameters.yml"]
]}
```

1) Decrypt:
~~~~~~~~~~~

After `composer:install`:

- Fetch parameters files in /tmp/...
- Decrypt them.
- Upload them in specific location.


2) Diff
~~~~~~~~~~~

`cap staging vaultage:diff`
