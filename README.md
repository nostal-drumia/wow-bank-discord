# wow-bank-discord

Retrieve info from bagon addons and push it to discord webhook.

Only for linux, if you want to use it on window you need to use WSL.

## binaries requirements

* jq
* curl

## Introduction

The goal is to manage bank account for a guild in Wow Classic

## Step to use this script

### on your local

* install bagon wow addon from curse or your favorite site (beware of crappy site)
* Connect to your bank/player account
* Active Bagon from addon menu
* Start Wow session
* Open your bags
* got to your bank and open your bank
* close WoW
* got to app Wow fodler 
* check that you have file path `WTF/Account/HORSBANK/SavedVariables/Bagnon_Forever.lua`

### on discord server

* create a channel
* go to settings
* create webhook (https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)[https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks]

## run script

### before running

add env var WEBHOOK with your webhook URL or add this variabel at the beginning of script

```
export WEBHOOK=https://discord.com/api/webhooks/<server>/<key>
```

### run script

```
chmod +x inventory-to-discord.sh
./inventory-to-discord.sh <path to wow folder>/WTF/Account/<account>/SavedVariables/Bagnon_Forever.lua
```