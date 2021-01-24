
pipe demo: `bundle exec ruby main.rb -v -u https://github.com/openwrt/openwrt/pull/3 -p pipe | awk -F'\\x1f' '{printf "#%3d:\t%s\n", $2 + 1, $3}'`
