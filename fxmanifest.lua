fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'Jorn#0008'
name 'qbx_customs'
description 'Customs script using ox_lib'
repository 'https://github.com/Qbox-project/qbx_customs'
version '1.0.0'

ui_page 'web/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_script 'server.lua'

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/menus/main.lua',
    'client/zones.lua',
}

files {
    'client/**/*.lua',
    'web/**/*',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta',
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'