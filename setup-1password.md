# After normal install

Add shortcut for quick access by adding this to the `.config/kglobalshortcutsrc` file

```
[services][net.local.1password.desktop]
_launch=Ctrl+Shift+Space
```

## Setup with vivaldi browser

1password doesn't officially support vivaldi as a browser. To enable connection between the desktop application and browser extension please do the following. (Last tested 11.06.2025)

[Source](https://forum.vivaldi.net/topic/91288/1password-extension-doesn-t-unlock-in-step-w-the-1password-desktop-application)

1. Quit 1Password for Linux (desktop app) and Vivaldi
2. Open a terminal, and run sudo mkdir /etc/1password (if you've done this already, you can skip it).
3. Run sudo nano /etc/1password/custom_allowed_browsers (i.e., open in text editor)
4. Paste in the appropriate browser binary name, in this case `vivaldi-bin`

Set permissions for the created file
```bash
sudo chown root:root /etc/1password/custom_allowed_browsers && sudo chmod 755 /etc/1password/custom_allowed_browsers
```

Restart your device (According to the source, in my case restarting Vivaldi and 1Password was enough)
