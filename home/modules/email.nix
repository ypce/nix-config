# home/modules/email.nix
#
# Proton mail sync through Proton Bridge: isync (mbsync) <-> Bridge on 127.0.0.1.
# There is no background job. Start Bridge, then run `mbsync -a` when you need
# new mail. Bridge shows the host, ports and password in its GUI. Export the
# TLS certificate from Bridge (Settings -> Export TLS certificates).

{ config, ... }:

let
  bridgeCert = "${config.home.homeDirectory}/.config/protonmail/bridge/cert.pem";
in
{
  accounts.email = {
    maildirBasePath = "Mail";                       # -> ~/Mail
    accounts.proton = {
      primary  = true;
      realName = "Vytautas";
      address  = "wtz@protonmail.ch";
      userName = "wtz@protonmail.ch";

      # Bridge password (NOT your Proton login), read from Keychain. Add it
      # once with:
      #   security add-generic-password -s proton-bridge -a vp@paulaus.com -w '<bridge-password>' -U
      passwordCommand = "security find-generic-password -s proton-bridge -a vp@paulaus.com -w";

      imap = {
        host = "127.0.0.1"; port = 1143;
        tls = { enable = true; useStartTls = true; certificatesFile = bridgeCert; };
      };

      mbsync = { enable = true; create = "both"; expunge = "both"; patterns = [ "*" ]; };
    };
  };

  programs.mbsync.enable = true;
}
