fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'Jorn#0008'
name 'popcornrp-customs'
description 'Customs script using ox_lib'
repository 'https://github.com/alberttheprince/popcornrp-customs'
version '1.4.2'

ui_page 'web/index.html'

server_scripts {
    'server.lua',
    '@oxmysql/lib/MySQL.lua'
}

client_scripts {
    'client/menus/main.lua',
    'client/zones.lua',
}
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

files {
    'client/**/*.lua',
    'web/**/*',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta',
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'

