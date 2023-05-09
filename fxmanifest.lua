fx_version 'cerulean'
game 'gta5'
author 'Jorn#0008'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

ui_page 'web/index.html'

server_script 'server.lua'
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