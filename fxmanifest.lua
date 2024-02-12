fx_version 'cerulean'
game 'gta5'

author 'Jorn#0008'
description 'qbx_customs'
repository 'https://github.com/Qbox-project/qbx_customs'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    '@qbx_core/modules/lib.lua',
    'client/utils.lua',
    'client/menus/main.lua',
    'client/zones.lua',
}

server_script 'server/main.lua'

files {
    'locales/*.json',
    'config/*.lua',
    'client/**/*.lua',
    'carcols_gen9.meta',
    'carmodcols_gen9.meta',
}

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'

lua54 'yes'
use_experimental_fxv2_oal 'yes'