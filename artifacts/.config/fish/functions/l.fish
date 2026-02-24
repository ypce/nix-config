function l
    set date (date +"%Y-%m-%d")
    set time (date +"%H:%M")
    set daily_file $HOME/Notes/daily/$date.org
    echo "** $time $argv" >>$daily_file
end
