fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'DobleDev'
description 'Vertex - Coins'
discord 'https://discord.gg/4BHVYpjEAp'
tebex 'https://vertex-studios.tebex.io/'
github 'https://github.com/Dobledev'

shared_script 'config/config.lua'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependency 'oxmysql'

export 'removeCoins'
export 'addCoins'
export 'getCoins'