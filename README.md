
pipe demo: `bundle exec ruby main.rb -v -u https://github.com/NoTengoBattery/changelog-scraper/pull/1 -p pipe | awk -F'\\x1d' '{printf "#%3d:\t%s\n", $2 + 1, $3}'`
