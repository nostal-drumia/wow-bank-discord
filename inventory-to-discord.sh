#!/bin/bash

IN=in
OUT=out

if [ -z "$1" ];then
  echo "No inventory path give"
  exit 1
fi

if [ ! -d "$IN" ];then
  echo "create $IN"
  mkdir $IN
fi

if [ ! -d "$OUT" ];then
  echo "create $OUT"
  mkdir $OUT
fi

inventory=$1
list=$(cat $inventory | egrep '^[[:space:]]*[[][0-9]{1,2}[]][[:space:]][[:space:]]*=[[:space:]]\"[0-9]*' -o | cut -d '"' -f 2)

for file in $(ls $IN)
do
  echo $file
  discord_id=$(cat $IN/$file)
  echo $discord_id
  curl -sS -H "Accept: application/json" -H "Content-Type:application/json" -X DELETE --data "{\"content\": \"delete\"}" "$WEBHOOK/messages/$discord_id"
  mv $IN/$file $OUT/
  echo "start sleep 1 sec"
  sleep 5
done

rm -rf $OUT

for id in $(echo $list)
do
  if [ ! -f "$id" ]; then
    touch $IN/$id
    echo "https://www.wowhead.com/classic/item=$id"
    messageid=$(curl -sS -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"https://www.wowhead.com/classic/fr/item=$id\"}" "$WEBHOOK?wait=true" | jq .id -r)
    echo $messageid > $IN/$id
    echo "start sleep 1 sec"
    sleep 5
  fi
done

