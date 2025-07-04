# NFSv4 Server and Client Setup Guide

This guide provides step-by-step instructions for setting up an NFS server on a Fedora-based system and connecting to it from a Linux client. The client setup uses a modern and reliable `systemd`-based automount method.

---

## Part 1: NFS Server Setup (Fedora)

Follow these steps on the machine that will act as the server.

### Step 1: Install NFS Packages

First, install the necessary NFS utilities on your Fedora server.

```bash
sudo dnf install nfs-utils
```

### Step 2: Create the Share Directory

Create the directory you wish to share over the network. It's good practice to set ownership to `nobody:nobody` to prevent permission issues.

```bash
# Create the directory
sudo mkdir -p /srv/nfs/share

# Set ownership
sudo chown -R nobody:nobody /srv/nfs/share

# Set permissions
sudo chmod 755 /srv/nfs/share
```

### Step 3: Configure Exports

Define which directories to share and which clients can access them by editing the `/etc/exports` file.

```bash
sudo nano /etc/exports
```

Add a new line for each directory you want to share. The format is `[directory] [client(options)]`.

**Example:** To share `/srv/nfs/share` with any client on the `10.0.0.0/16` network with read/write permissions:

```
/srv/nfs/share  10.0.0.0/16(rw,sync)
```

-   `/srv/nfs/share`: The directory to share.
-   `10.0.0.0/16`: The allowed client IP address range. You can also use a single IP address.
-   `rw`: Allows read and write access.
-   `sync`: Ensures all changes are written to disk before a request is considered complete (safer).

### Step 4: Start and Enable NFS Services

Start the NFS server and enable it to launch automatically on boot.

```bash
sudo systemctl enable --now nfs-server
```

### Step 5: Apply and Verify Exports

Apply the changes you made to `/etc/exports` without needing a reboot and verify that the share is active.

```bash
# Apply all exports
sudo exportfs -a

# Verify active shares
sudo exportfs -v
```

The output should list your shared directory and its permissions. Your NFS server is now configured.

---

## Part 2: NFS Client Setup

Follow these steps on any client machine that needs to access the NFS share.

### Step 1: Install NFS Client Packages

Install the necessary utilities for your client's distribution.

**On a Fedora/RHEL-based client:**
```bash
sudo dnf install nfs-utils
```

**On a Debian/Ubuntu-based client:**
```bash
sudo apt update && sudo apt install nfs-common
```

### Step 2: Create a Mount Point

Create a local directory where the remote NFS share will be mounted.

```bash
sudo mkdir -p /mnt/nfs/share
```

### Step 3: Configure Automatic Mounting

To ensure the NFS share mounts reliably (especially after a reboot), edit the `/etc/fstab` file to use `systemd`'s automount feature. This prevents issues where the system tries to mount the share before the network is ready.

```bash
sudo nano /etc/fstab
```

Add the following line to the end of the file. **Remember to replace `SERVER_IP`** with your NFS server's actual IP address.

```
SERVER_IP:/srv/nfs/share   /mnt/nfs/share   nfs   x-systemd.automount,noauto,timeo=14,x-systemd.idle-timeout=1min   0   0
```

-   `SERVER_IP:/srv/nfs/share`: The remote NFS share.
-   `/mnt/nfs/share`: The local mount point.
-   `nfs`: The filesystem type.
-   `x-systemd.automount,noauto`: This is the key part. It tells `systemd` to manage the mount and only mount it on first access. `noauto` prevents the traditional boot-time mount.
-   `timeo=14`: Sets a timeout of 1.4 seconds for RPC requests.
-   `x-systemd.idle-timeout=1min`: (Optional) Automatically unmounts the share after 1 minute of inactivity to save resources.

### Step 4: Apply Changes and Verify

Reload the `systemd` configuration to apply the new `fstab` entry.

```bash
# Reload the systemd manager configuration
sudo systemctl daemon-reload

# Restart the remote filesystem services to ensure everything is up to date
sudo systemctl restart remote-fs.target
```

The share is not mounted immediately. It will be mounted automatically the first time you try to access the `/mnt/nfs/share` directory. You can test this with:

```bash
# This command will trigger the automount
ls -l /mnt/nfs/share

# Verify that it is now mounted
df -h
```

The output of `df -h` should now show the NFS share mounted on `/mnt/nfs/share`. The mount will persist across reboots.
