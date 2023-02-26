#!/bin/bash

cur_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
roms_dir="/home/adam/game-and-watch/game-and-watch-retro-go/roms"
covers_dir="/home/adam/game-and-watch/retro-go-covers"
offset_nes=16
offset_lynx=64
list_of_systems="col doom gb gbc gg lnx nes pce sms"

contains() {
  [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]] && return 0 || return 1
}

calc_crc32() {
  offset=16
  if [ "$2" = "nes" ] || [ "$2" = "lynx" ]; then
    if [ "$2" = "lynx" ]; then
      offset=64
    fi
    dd if="$1" of=/tmp/tmp.rom bs=1 skip=$offset 2> /dev/null
    crc=$(crc32 /tmp/tmp.rom | tr '[:lower:]' '[:upper:]')
    fc=${crc:0:1}
    if [ -f "$covers_dir/$2/$fc/$crc.png" ]; then
      cp "$covers_dir/$2/$fc/$crc.png" "$roms_dir/$2/${1%.*}.png"
    else
      echo "$1:$crc Cover not found!"
    fi
  else
    out_roms=${2}
    if [ "$2" = "gbc" ]; then
      out_roms="gb"
    fi
    crc=$(crc32 "$1" | tr '[:lower:]' '[:upper:]')
    fc=${crc:0:1}
    if [ -f "$covers_dir/$2/$fc/$crc.png" ]; then
      cp "$covers_dir/$2/$fc/$crc.png" "$roms_dir/$out_roms/${1%.*}.png"
    else
      echo "$1:$crc Cover not found!"
    fi
  fi  
}

if ! contains "${list_of_systems[@]}" $1; then
  echo "Unsupported system"
  exit 1
fi

if [ "$1" = "gbc" ]; then
  cd "$roms_dir/gb"
else 
  cd "$roms_dir/$1"
fi

for i in *.$1; do
  calc_crc32 "$i" $1
done

cd $cur_dir
