Config = {}

Config.Strefy = {
    Pole1 = {
        Pos = { x = 300.26428222656, y = 4311.1333007812, z = 46.721260070801},
        Size = 25.0
    },

    Pole2 = {
        Pos = { x = -2358.904296875, y = 2696.2639160156, z = 2.9664077758789},
        Size = 25.0
    },

    Pole3 = {
        Pos = { x = 1449.427734375, y = -2645.0627441406, z = 45.201583862305},
        Size = 35.0
    }
}

Config.Itemy = {
    nasiono_marichuany = {
        props = {
            'prop_weed_02',
            'prop_weed_01',
        },

        delay = 1000 * 40000,

        items = {
            {name = 'weed_widow', min = 5, max = 15},
            {name = 'weed_berry', min = 5, max = 15},
            {name = 'weed_lemon', min = 5, max = 15},
            {name = 'weed_amensia', min = 5, max = 15},
        }
    },

    nasiono_kokainy = {
        props = {
            'prop_plant_cane_01b',
            'prop_plant_cane_02b',
        },

        delay = 1000 * 60000,

        items = {
            {name = 'liscie_opium', min = 5, max = 15},
        }
    },

    nasiono_opium = {
        props = {
            'prop_plant_fern_02c',
            'prop_plant_fern_02b',
        },

        delay = 1000 * 50000,

        items = {
            {name = 'liscie_koki', min = 5, max = 15},
        }
    }
}

Config.Przerobki = {
    Koka = {
        itemsNeed = {
            {
                Name = 'liscie_koki',
                Count = 5
            },
        },
        itemsAdd = {
            {
                Name = 'koka_przerobiona',
                Count = 1
            }
        },

        Pos = { x = 1092.1311035156, y = -3195.6108398438, z = -39.897273254395},
        Size = 5.0,
        Delay = 1000 * 8
    },

    Opium = {
        itemsNeed = {
            {
                Name = 'liscie_opium',
                Count = 5
            }
        },
        itemsAdd = {
            {
                Name = 'opium_przerobione',
                Count = 1
            }
        },


        Pos = { x = 1976.6550292969, y = 3820.5280761719, z = 32.550107574463},

        Size = 2.5,
        delay = 1000 * 6
    }
}