#sc_archiver.sh

I wanted to see if I could wrap youtube-dl in pure bash to archive my soundcloud likes. I thought it would take 30 mintues.
It did not take 30 minutes


#Useage
* Running ./sc_archiver.sh will first attempt to download dependencies. You will be prompted for each
* Running ./sc_archiver.sh by itself will prompt you for your soundcloud username,
* Running ./sc_archiver.sh <soundcloud> will bypass prompt
* By default the script will ask you before installing dependencies, creating folders, or starting a download.
 * You can set the script to run non-interactively by commenting the $interactive_mode variable at the top of the script
 * when in non-interactive mode the script inserts pauses. This is only because you have to spam ^c to break out of the main loop and I'm not writing traps at 0400


Dependencies:
 * [brew](https://www.brew.sh)
 * [youtube-dl](https://rg3.github.io/youtube-dl/)
 * [jq](https://stedolan.github.io/jq/)

The script will try to install it's own dependencies, but this will only work on osx.
