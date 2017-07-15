#sc_archiver.sh

I wanted to see if I could wrap youtube-dl in pure bash to archive my soundcloud likes. I thought it would take 30 mintues.
It did not take 30 minutes


#Useage
* Running ./sc_archiver.sh will first attempt to download dependencies. You will be prompted for each
* Running ./sc_archiver.sh by itself will prompt you for your soundcloud username,
* Running ./sc_archiver.sh <soundcloud> will bypass prompt
* By default the script will ask you before installing dependencies, creating folders, or starting a download.
 * You can set the script to run non-interactively by commenting the $interactive_mode variable at the top of the script
 * Even when in non-interactive mode the script inserts pauses. This is only because you have to spam ^c to break out of the main loop and I'm not writing traps at 0400
 * TL;DR, download the script, run it once to make sure all your dependencies are met, and let it prompt you to download your likes and an artist or two. If that works fine, and you don'w wnat to confirm every artist, kill the script and comment the `interactive_mode` variable. (you can also un comment `skip_likes` to save some time.) and kick it off again.
 * the script only downloads the first 100 artists you follow. I'm almost certainly not going back to write pagination (I follow <100 artists) but you can change the curl command in `get_collection` to either grab more artists or change the offset. 


Dependencies:
 * [brew](https://www.brew.sh)
 * [youtube-dl](https://rg3.github.io/youtube-dl/)
 * [jq](https://stedolan.github.io/jq/)

The script will try to install it's own dependencies, but this will only work on osx.
