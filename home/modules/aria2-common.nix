{ config, lib, ... }:

{
  programs.aria2 = {
    enable = true;
    
    settings = {
      # Disk Settings
      dir = "${config.home.homeDirectory}/Downloads/Completed";
      daemon = false;
      enable-mmap = true;
      disk-cache = "64M";
      file-allocation = "none";
      
      # Download Settings
      continue = true;
      split = 16;
      min-split-size = "1M";
      max-tries = 3;
      max-connection-per-server = 16;
      max-download-limit = 0;
      
      # Advanced Options
      allow-overwrite = true;
      log-level = "notice";
    };
  };
}
