#!/usr/bin/env -S fish --no-config

if contains -- 1728x1080 (betterdisplaycli get --name="Screen Sharing" --resolution)
    betterdisplaycli set --name="Screen Sharing" --resolution="2560x1440"
else
    betterdisplaycli set --name="Screen Sharing" --resolution="1728x1080"
end
