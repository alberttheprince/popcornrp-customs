return {
    -- If you experience issues with your zones not working, please ensure the Z value of your vec3 points match. Using different heights may cause problems.
    ---@type ZoneOptions[]
    zones = {
    --  Benny's Example Zone
    --     {
    --         freeRepair = { 'police' }, -- Provides free repairs to specified job
    --         freeMods = { 'police' }, -- provides free modifications to specified job
    --         job = { 'police' }, -- Restricts customs access to a specific job (useful for restricting to mechanics, police, ambulance, etc)
    --         blipLabel = "EXAMPLE ZONE",
    --         blipColor = 5, -- https://docs.fivem.net/docs/game-references/blips/#blip-colors
    --         points = {
    --             vec3(-344.36, -121.92, 38.60),
    --             vec3(-319.43, -130.65, 38.60),
    --             vec3(-324.77, -147.93, 38.60),
    --             vec3(-348.59, -139.1, 38.60),
    --         }
    --     },
    
    -- Default GTA 5 Customs and Benny's Locations
        {
    	blipLabel = "Los Santos Customs - Vinewood",
    	blipColor = 5,
            points = {
                vec3(-344.36, -121.92, 38.60),
                vec3(-319.43, -130.65, 38.60),
                vec3(-324.77, -147.93, 38.60),
                vec3(-348.59, -139.1, 38.60),
            }
        },
        {
    	blipLabel = "Los Santos Customs - Airport",
    	blipColor = 5,
            points = {
                vec3(-1147.7, -1990.31, 13.15),
                vec3(-1171.05, -2013.96, 13.15),
                vec3(-1158.38, -2026.03, 13.15),
                vec3(-1139.17, -2007.18, 13.15),
                vec3(-1144.73, -1992.89, 13.15),
            }
        },
        {
    	blipLabel = "Los Santos Customs - East",
    	blipColor = 5,
            points = {
                vec3(724.93, -1092.04, 22.15),
                vec3(738.52, -1094.83, 22.15),
                vec3(737.36, -1064.56, 22.15),
                vec3(724.14, -1063.71, 22.15),
            }
        },
        {
    	blipLabel = "Los Santos Customs - Sandy Shores",
    	blipColor = 5,
            points = {
                vec3(1172.12, 2644.76, 38.55),
                vec3(1171.39, 2635.66, 38.55),
                vec3(1189.77, 2636.08, 38.55),
                vec3(1189.74, 2644.07, 38.55),
            }
        },
        {
    	blipLabel = "Los Santos Customs - Paleto",
    	blipColor = 5,
            points = {
                vec3(115.55, 6625.32, 31.75),
                vec3(109.19, 6631.69, 31.75),
                vec3(97.39, 6620.02, 31.75),
                vec3(102.72, 6613.48, 31.75),
            }
        },
        {
    	blipLabel = "Benny's Motorworks",
    	blipColor = 5,
            points = {
                vec3(-203.55, -1311.26, 30.85),
                vec3(-228.06, -1319.24, 30.85),
                vec3(-228.25, -1334.25, 30.85),
                vec3(-214.18, -1341.38, 30.85),
    	    vec3(-195.42, -1321.19, 30.85),
    	    vec3(-195.26, -1314.11, 30.85),
            }
        }
    },

    prices = {
        ['cosmetic'] = 500,
        ['colors'] = 1000,
        [11] = {0, 10000, 20000, 30000, 40000},     -- Engine
        [12] = {0, 2500, 5000, 7500},               -- Brakes
        [13] = {0, 5000, 10000, 15000, 20000},      -- Transmission
        [15] = {0, 3000, 6000, 9000, 12000, 15000}, -- Suspension
        [18] = 10000                                  -- Turbo
    }
}
