fx_version 'cerulean'
game 'gta5'

author 'Jorn#0008'
description 'qbx_customs'
repository 'https://github.com/Qbox-project/qbx_customs'
version '1.0.0'

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

ui_page 'web/index.html'

files {
    'client/**/*.lua',
    'web/**/*',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta',
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'

lua54 'yes'
use_experimental_fxv2_oal 'yes'