#!/usr/bin/env bash
###################
# sc_archiver.sh
# Auther: drl
# Contact: @drldcsta
# Purpose: Archives soundcloud
# Created 15 July
#

#comment interactive_mode to disable prompts TODO - add trap to kill script...
#...so you don't have to spam ^c
interactive_mode=true

#uncomment override_directory and set to a path to use an alternate download directory (untested)
#override_directory=~/Documents

#comment skip_likes to download liked tracks
#skip_likes=true

verbose_mode=true
#opts="ix" #use these opts if you want to see all of yt-dl's debug info
opts="qix"


###Functions

loading_bar () {
  #prints a loading bar, because I can't sleep
  printf "^c to exit - [";for (( i=1 ; i<${1:-5} ; i++));do printf ".";sleep 1;done;printf "]"
  echo
}

offer_break () {
  #Gives opportunity to break out of script if in interactive mode
  #Interacive mode is the default
  #If not interactive inserts loading bar (to give chance to break out of script)
  #expects a quoted string
  if [[ -n ${interactive_mode} ]];then read -p "if you hit anything other than ^c (ctrl + c) I'm going to ${1}";else echo "Pausing for ${2:-2} seconds, then I'm going to ${1}";loading_bar ${2:-2};fi
}

simple_logger () {
  #simple logger (duh)
  #expects a quoted string
  if [[ -n ${verbose_mode} ]];then echo "${1}";fi
}

is_installed () {
  #Checks if ${1} is installed
  #expects one arg, a CLI app name
  /usr/bin/which ${1} > /dev/null
  return $?
}

read_sc_un () {
  #Genuinely don't remember why I made this a function
  #Oh, it was in case lookup failed
  #making so default is read from std in
  #optional arg is a soundcloud username. If not provided function is interactive
  if [[ -n ${1} ]];then echo $1;return 0;fi
  while [[ -z ${sc_un} ]];do
    read -p "Enter your SoundCloud user name: " sc_un
  done
  echo "${sc_un}"
}

get_sc_id () {
  #gets the SC id from SC username
  #whole lotta ugly bashisms here
  local resp=$(/usr/bin/curl --silent  "http://api.soundcloud.com/resolve.json?url=http://soundcloud.com/${sc_un}&client_id=2t9loNQH90kzJcsFCODdigxfp325aq4z"|jq .)
  if [[ $(jq .status <<< "${resp}") =~ 302 ]];then resp=$(jq .location <<< ${resp});else echo "ERROR: Couldn't find your user ID, sorry";read_sc_un;fi
  local temp_var="${resp:34}"
  echo "${temp_var%%.*}"
}

get_collection () {
  #gets urls of artists in user's collection (limited to 100)
  #TODO - enable pagination (probably not going to happen)
  collection=$(/usr/bin/curl --silent "https://api-v2.soundcloud.com/users/${sc_id}/followings?offset=0&limit=100&client_id=2t9loNQH90kzJcsFCODdigxfp325aq4z&app_version=1500036064"|jq .collection[].permalink_url)
  echo "${collection//\"/}"
}

grab_artist () {
  #gets all songs by artist
  #expects one arg, a soundcloud artist URL
  local url="${1}"
  local artist=${1##*/}
  if [[ -n ${override_directory} ]];then local target_dir="${override_directory}/sc_arcive/${sc_un}/${artist}";else local target_dir="${HOME}/sc_arcive/${sc_un}/${artist}";fi
  offer_break "start downloading all tracks from ${artist} to ${target_dir}"
  if [[ ! -d ${target_dir} ]];then mkdir -p ${target_dir} && simple_logger "created folder for ${artist}";fi
  youtube-dl --download-archive ${target_dir}/${artist}.txt -${opts} --embed-thumbnail --add-metadata --no-mtime --audio-format "mp3" -o "${target_dir}/%(title)s.%(ext)s" ${url}
  #local count=$(find ${target_dir} -name "*.mp3"|wc -l)
  #simple_logger "downloaded ${count} tracks by ${artist}"
}

grab_user_likes () {
  #gets all of a given user's likes
  #expects one arg, a soundcloud user_name
  if [[ -n ${skip_likes} ]];then simple_logger "skipping likes (uncomment #skip_likes to download ${sc_un}'s liked tracks')";return ;fi
  if [[ -n ${override_directory} ]];then local target_dir="${override_directory}/sc_arcive/${sc_un}/likes";else local target_dir="${HOME}/sc_arcive/${sc_un}/likes";fi
  local url="https://soundcloud.com/${1}/likes"
  offer_break "start downloading ${sc_un}'s liked tracks to ${target_dir}"
  if [[ ! -d ${target_dir} ]];then mkdir -p ${target_dir} && simple_logger "created folder for ${sc_un}'s liked tracks";fi
  youtube-dl --download-archive ${target_dir}/likes.txt -${opts} --embed-thumbnail --add-metadata --no-mtime --audio-format "mp3" -o "${target_dir}/%(title)s.%(ext)s" ${url}
  #local count=$(find ${target_dir} -name "*.mp3"|wc -l)
  #simple_logger "downloaded ${count} tracks by"
}

#Dependency checks
if ! is_installed brew;then
  offer_break "install brew for you" 15
  /usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi



if ! is_installed youtube-dl;then
  offer_break "install youtube-dl for you" 15
  /usr/local/bin/brew youtube-dl
fi

if ! is_installed ffmpeg;then
  offer_break "install youtube-dl for you" 15
  /usr/local/bin/brew youtube-dl
fi

if ! is_installed jq;then
  offer_break "install jq for you" 15
  /usr/local/bin/brew jq
fi


###Time to start doing stuff

#get the user name
sc_un=$(read_sc_un ${1})

#Get the soundcloud ID based on the soundcloud username
sc_id=$(get_sc_id ${sc_un})

simple_logger "Soundcloud ID for ${sc_un} is: ${sc_id}"

#Download user's liked tracks
grab_user_likes ${sc_un}

#Padding the collection array so that if I paginate later the indexes will match
collection=(NULL $(get_collection))

simple_logger "Found $((${#collection[*]} -1 )) artists that ${sc_un} is following."

#DO WORK SON!
offer_break "start downloading tracks by artists ${sc_un} is following." 5

for (( x=1; x<${#collection[*]}; x++));do grab_artist ${collection[${x}]};done
