 # Install tailscale on lxc
 
Before you start the created lxc add the following lines to the lxc config:

The config can be found on the pve node at `/etc/pve/lxc/<id>.conf`

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```
 
Generate a script on https://login.tailscale.com/admin/machines/new-linux