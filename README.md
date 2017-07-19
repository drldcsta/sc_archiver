# sc_archiver.sh

I wanted to see if I could wrap youtube-dl in pure bash to archive my SoundCloud likes. I thought it would take 30 mintues.
It did not take 30 minutes


# Usage
  * Every time you run ./sc_archiver.sh the script will first check if dependencies are present and attempt to download if not.
    * By default the script will ask you before installing, creating folders, or starting a download.
    * I _think_ this script is fully portable, but uses brew for grabbing dependencies so really this is somewhat osx specific (but if you have `jq` and `youtube-dl` it "should" work)
  * You can disable prompts by commenting the line `interactive_mode=true` at the top of the script
    * Even when in non-interactive mode the script inserts pauses. This is only because you have to spam ^c to break out of the main loop and I'm not writing traps at 4 in the morning
  * Running ./sc_archiver.sh by itself will prompt you for your SoundCloud username
    * you can also run ./sc_archiver `username` to skip prompt (useful if running in non-interactive mode)
    * You can set the script to run non-interactively by commenting the $interactive_mode variable at the top of the script
    * The script is effectively idempotent. You can run it multiple times and if you do not change the `sc_archive` directory structure it will not download a file more than once.
  * If you intend to move the mp3 files to a remote archive, if you keep the `artistname.txt` file in each directory the script will only download *new* liked tracks and tracks added to artist page since last run.     


## CAVEAT
The script only downloads the first 100 artists you follow. I'm almost certainly not going back to write pagination (I follow <100 artists) but you can change the curl command in `get_collection` to either grab more artists or change the offset.

Likely usage (**TL;DR**): download the script, run it once to make sure all your dependencies are met, and let it prompt you to download your likes and an artist or two. If that works fine, and you don'w wnat to confirm every artist, kill the script and comment the `interactive_mode` variable. (you can also un comment `skip_likes` to save some time.) and kick it off again.



Dependencies:
 * [brew](https://www.brew.sh)
 * [youtube-dl](https://rg3.github.io/youtube-dl/)
 * [jq](https://stedolan.github.io/jq/)
 * [ffmpeg](https://ffmpeg.org/)
