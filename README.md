# dream2nix-home-assistant

Packaging experiments with dream2nix to package home-assistant with all dependencies.

USAGE:

```console
$ nix build github:Mic92/dream2nix-home-assistant
$ ./result/bin/hass --open-ui --skip-pip
```

Total closure size including all dependencies

```console
$ nix path-info -Srh ./result | tail -n1
/nix/store/wkn9hv4fhcbrwqwjqa1f652wm5wcfkal-python3.11-homeassistant-2023.10.0                     2.2G
```
