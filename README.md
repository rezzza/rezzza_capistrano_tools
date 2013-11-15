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


Apc cache clear
---------------

Configuration

```
set :apc_keys_clear, ['key', '^foo']
set :apc_clear_host, "http://myhosttoapcapp/app.php"
set :apc_clear_security, "http_basic" # none available too.
set :apc_clear_security_user, "user"
set :apc_clear_security_pass, "pass"
```

On `before deploy:create_symlink`, it'll call `curl --user user:pass "http://myhosttoapcapp/app.php?keys=key,^foo" -o /dev/null`
