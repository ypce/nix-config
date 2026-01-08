{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      isDefault = true;

      # Set preferences
      settings = {
        # Compact mode
        "browser.uidensity" = 1;
        "browser.warnOnQuit" = false;

        # Search bar
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.history" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.recentsearches" = false;

        # Toolbar
        "identity.fxaccounts.toolbar.enabled" = false;

        # Delete key goes back
        "browser.backspace_action" = 0;

        # Privacy
        "privacy.trackingprotection.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "signon.rememberSignons" = false;

        # Disable sidebar
        "browser.sidebar.enabled" = false;
        "browser.sidebar.position_start" = false;
        "sidebar.revamp" = false;

        # Set startup homepage to new tab
        "browser.startup.page" = 3; # 3 = restore previous session, 0 = blank, 1 = homepage
        "browser.startup.homepage" = "about:newtab";

        # Clean new tab (search bar only)
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = true;
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
        "browser.newtabpage.activity-stream.showTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.showSearch" = true;
        "browser.newtabpage.enabled" = true;
      };
      extensions = [ ];
    };
  };
}
