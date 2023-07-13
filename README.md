# Duplicator
## Built on NixOS
- Packages:
  - parted
  - partimage
  - moreutils
- Options:
  - ssh
  - syncthing
  - xserver to chromium in kiosk mode (optional, web interface should be enough)
## Frontend
- Python web server
- Show what drives are plugged in, allow selection
- Show different image options
  - Student
  - Student (Clonezilla)
  - Staff (Image Assist)  
  Allow driver pack selection:
      - Latitiude 3310
      - Latitiude 3330
      - Optiplex 5000
  - Boxlight upgrades
  - Ventoy  
  Allow ISO selection:
    - memtest
    - NixOS distro with utilities (HCPoS)
      - Gparted
      - nslookup
    - Hiren's
- Link to Endpoint Utilities
## Network traffic
- http
- ssh
- Syncthing
- cache.nixos.org needs no SSL injection; issues with certificate acceptance for nix
  - Tried [global certificate](https://search.nixos.org/options?show=security.pki.certificates), works in web browsers but not nix
  - Tried [environment variable](https://nixos.org/manual/nix/stable/installation/env-variables.html#nix_ssl_cert_file), no apparent change
