#!/bin/bash

IN=in
OUT=out

if [ -z "$1" ];then
# echo "No inventory path give"
  exit 1
fi

if [ ! -d "$IN" ];then
# echo "create $IN"
  mkdir $IN
fi

if [ ! -d "$OUT" ];then
# echo "create $OUT"
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
  sleep 1
done

rm -rf $OUT

for id in $(echo $list)
do
  if [ ! -f "$IN/$id" ]; then
    touch $IN/$id
    echo  '>>>'
    echo "https://www.wowhead.com/classic/item=$id&xml"
    result=$(curl -Ls https://www.wowhead.com/classic/fr/item\=$id\&xml)
    # json=""
    # echo $result | yq -p=xml '.wowhead.item.class'
    class=$(echo $result | yq -p=xml '.wowhead.item.class.+@id')
    echo $class
    color=$(echo $result | yq -p=xml '.wowhead.item.quality.+@id')
    if [ "$color" == "1" ];then
      dcolor="9807270"
    elif [ "$color" == "2" ];then
      dcolor="5763719"
    elif [ "$color" == "3" ];then
      dcolor="3447003"
    elif [ "$color" == "4" ];then
      dcolor="10181046"
    else
      dcolor="#adadad"
    fi
    if [ "$class" == "4" ] || [ "$class" == "2" ];then
      # echo  "Name: $(echo $result | yq -p=xml '.wowhead.item.name')"
      export name=$(echo $result | yq -p=xml '.wowhead.item.name')
      # echo  "link : https://www.wowhead.com/classic/item=$id"
      export link="https://www.wowhead.com/classic/item=$id"
      # echo  "Level: $(echo $result | yq -p=xml '.wowhead.item.level')"
      export level=$(echo $result | yq -p=xml '.wowhead.item.jsonEquip' | grep -E '\"reqlevel\":[0-9]+' -o | cut -d ":" -f 2)
      # echo  "Quality: $(echo $result | yq -p=xml '.wowhead.item.quality.+content')"
      export quality=$(echo $result | yq -p=xml '.wowhead.item.quality.+content')
      # echo  "slot: $(echo $result | yq -p=xml '.wowhead.item.inventorySlot.+content')"
      export slot=$(echo $result | yq -p=xml '.wowhead.item.inventorySlot.+content')
      # echo  "Subclass: $(echo $result | yq -p=xml '.wowhead.item.subclass.+content')"
      export subclass=$(echo $result | yq -p=xml '.wowhead.item.subclass.+content')
      # echo  "Armor: $(echo $result | yq -p=xml '.wowhead.item.htmlTooltip' | pup 'table span json{}' -c  | jq '.[] | select(.comment=="amr").text' -r | cut -d ":" -f 2 | sed 's/[[:space:]]//g')"
      export armor=$(echo $result | yq -p=xml '.wowhead.item.htmlTooltip' | pup 'table span json{}' -c  | jq '.[] | select(.comment=="amr").text' -r | cut -d ":" -f 2 | sed 's/[[:space:]]//g')
      # echo  -e "stat: \n$(echo $result | yq -p=xml '.wowhead.item.htmlTooltip' | pup 'table span json{}' -c  | jq '.[] | select(.comment>"stat").text' -r)"
      export stat=$(echo $result | yq -p=xml '.wowhead.item.htmlTooltip' | pup 'table span json{}' -c  | jq '.[] | select(.comment>"stat").text' -r | tr '\n' ' ')
      export damage=$(echo $result | yq -p=xml '.wowhead.item.htmlTooltip' | pup 'table span json{}' | jq '.[] | select(.comment=="dmg").text' -r | cut -d ":" -f 2 | sed 's/[ ]//g')
      export spell=$(echo $result | yq -p=xml '.wowhead.item.htmlTooltip' | pup 'table span json{}' | jq '.[] | select(.class=="q2")' | jq '[.] | (.[].text)//false+" "+(.[].children | .[].text)' -r | tr '\n' ' - ')
      echo $spell
      export webcolor=$dcolor
      json=$(envsubst < template/armor.json)
    elif [ "$class" == "9" ];then
      # echo  "Name: $(echo $result | yq -p=xml '.wowhead.item.name')"
      export name=$(echo $result | yq -p=xml '.wowhead.item.name')
      # echo  "Level: $(echo $result | yq -p=xml '.wowhead.item.level')"
      export level=$(echo $result | yq -p=xml '.wowhead.item.jsonEquip' | grep -E '\"reqlevel\":[0-9]+' -o | cut -d ":" -f 2)
      # echo  "Quality: $(echo $result | yq -p=xml '.wowhead.item.quality.+content')"
      export quality=$(echo $result | yq -p=xml '.wowhead.item.quality.+content')
      export spell=$(echo $result | yq -p=xml '.wowhead.item.htmlTooltip' | pup 'table span json{}' | jq '.[] | select(.class=="q2")' | jq '[.] | (.[].text)+" "+(.[].children | .[].text)' -r | tr '\n' ' - ')
      # echo  "link : https://www.wowhead.com/classic/item=$id"
      export link="https://www.wowhead.com/classic/item=$id"
      export webcolor=$dcolor
      json=$(envsubst < template/receipe.json)
    else
      # echo  "Name: $(echo $result | yq -p=xml '.wowhead.item.name')"
      export name=$(echo $result | yq -p=xml '.wowhead.item.name')
      # echo  "link : https://www.wowhead.com/classic/item=$id"
      export link="https://www.wowhead.com/classic/item=$id"
      export webcolor=$dcolor
      json=$(envsubst < template/other.json)
    fi
    echo $dcolor
    echo $json | jq .
    # curl -sS -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$json" "$WEBHOOK?wait=true"
    messageid=$(curl -sS -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "$json" "$WEBHOOK?wait=true" | jq .id -r)
    echo $messageid
    echo $messageid > $IN/$id
    echo "start sleep 1 sec"
    sleep 1
  fi
done

