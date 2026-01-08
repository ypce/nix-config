{ config, lib, ... }:

{
  # Import the common config first
  imports = [ ./aria2-common.nix ];
  
  # Add personal/torrent-specific settings
  programs.aria2.settings = {
    # RPC Settings - PERSONAL ONLY
    enable-rpc = true;
    rpc-allow-origin-all = true;
    rpc-listen-all = true;
    rpc-listen-port = 6800;
    rpc-secret = "token";
    
    # BT Settings - PERSONAL ONLY
    follow-torrent = true;
    enable-dht = true;
    enable-dht6 = true;
    dht-listen-port = "6881-6999";
    bt-max-peers = 100;
    bt-metadata-only = true;
    bt-hash-check-seed = false;
    bt-enable-lpd = true;
    seed-ratio = 0.1;
    enable-peer-exchange = true;
    bt-seed-unverified = true;
    dht-file-path = "${config.home.homeDirectory}/.aria2/dht.dat";
    dht-file-path6 = "${config.home.homeDirectory}/.aria2/dht6.dat";
    
    bt-tracker = "udp://tracker.opentrackr.org:1337/announce,https://tracker1.ctix.cn:443/announce,udp://open.demonii.com:1337/announce,udp://open.stealth.si:80/announce,udp://tracker.torrent.eu.org:451/announce,udp://tracker-udp.gbitt.info:80/announce,https://tracker.loligirl.cn:443/announce,https://tracker.gbitt.info:443/announce,http://tracker.gbitt.info:80/announce,udp://tracker.tiny-vps.com:6969/announce,udp://retracker01-msk-virt.corbina.net:80/announce,udp://opentracker.io:6969/announce,udp://explodie.org:6969/announce,udp://exodus.desync.com:6969/announce,https://tracker.tamersunion.org:443/announce,https://tracker.renfei.net:443/announce,http://tracker.skyts.net:6969/announce,http://tracker.renfei.net:8080/announce,http://open.tracker.ink:6969/announce,http://1337.abcvg.info:80/announce";
  };
}
