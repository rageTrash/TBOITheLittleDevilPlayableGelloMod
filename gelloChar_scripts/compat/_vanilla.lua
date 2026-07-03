local Mod = GelloCharMod
local game = Mod.Game
local SAVE_PERMA_STATS_NAME = "Gello extra perma stats"

local itemPool = game:GetItemPool()
local itemConfig = Isaac.GetItemConfig()
local playerSave = Mod.SaveHandler.Player
local saveHand = Mod.SaveHandler.Save


local function spawnPickup(pos, v, s, spawner, seed)
	return Mod:Spawn(5, v, s, pos, Vector.Zero, spawner, seed)
end



local function spawnFlys(player, rng)
	player:AddBlueFlies(Mod:RandomInt(3, 5, rng), player.Position, player)
end
local flysDesc = {en_us = "Spawns 3 to 5 flies", spa = "Genera 3 a 5 moscas"}
Mod:AddConsumeItemEffect(
    -- blue flies drops
    { Id = CollectibleType.COLLECTIBLE_SKATOLE, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_DISTANT_ADMIRATION, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_FOREVER_ALONE, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BEST_BUD, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_FRIEND_ZONE, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_LOST_FLY, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_OBSESSED_FAN, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_SMART_FLY, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_PAPA_FLY, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_YO_LISTEN, Fun = spawnFlys, EID = flysDesc, Stats = {Luck = 1} }
    ,{ Id = CollectibleType.COLLECTIBLE_PSY_FLY, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_ROTTEN_BABY, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BIG_FAN, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_UNDERWEAR, Fun = spawnFlys, EID = flysDesc, Stats = {Range = 1.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_GUPPYS_HEAD,
        Fun = function(player, rng) player:AddBlueFlies(Mod:RandomInt(8, 14, rng), player.Position, player) end,
        EID = {en_us = "Spawns 8 to 14 flies", spa = "Genera 8 a 14 moscas"}, NoActive = true
    }
    ,{ Id = CollectibleType.COLLECTIBLE_INFESTATION, Fun = spawnFlys, EID = flysDesc, Stats = {DmgOffset = 0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_MULLIGAN,
        Fun = function(player, rng) player:AddBlueFlies(Mod:RandomInt(8, 14, rng), player.Position, player) end,
        EID = {en_us = "Spawns 8 to 14 flies", spa = "Genera 8 a 14 moscas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_GUPPYS_HAIRBALL, Fun = spawnFlys, EID = flysDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BLUE_BABYS_ONLY_FRIEND,
        Fun = function(player, rng) player:AddBlueFlies(8, player.Position, player) end,
        EID = {en_us = "Spawns 8 flies", spa = "Genera 8 moscas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BURSTING_SACK,
        Fun = function(player, rng) player:AddBlueFlies(Mod:RandomInt(8, 14, rng), player.Position, player) end,
        EID = {en_us = "Spawns 8 to 14 flies", spa = "Genera 8 a 14 moscas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_JAR_OF_FLIES,
        Fun = function(player, rng) player:AddBlueFlies(10, player.Position, player) end,
        EID = {en_us = "Spawns 10 flies", spa = "Genera 10 moscas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_PARASITOID, Fun = spawnFlys, EID = flysDesc, }
)


local function spawnSpiders(player, rng)
	for _=1, Mod:RandomInt(3, 5, rng) do
		player:AddBlueSpider(player.Position)
	end
end
local spiderDesc = {en_us = "Spawns 3 to 5 spiders", spa = "Genera 3 a 5 arañas"}
Mod:AddConsumeItemEffect(
    -- blue spiders drops
    { Id = CollectibleType.COLLECTIBLE_DADDY_LONGLEGS, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_TINYTOMA, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SISSY_LONGLEGS, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SPIDER_BITE, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SPIDER_BUTT, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SPIDERBABY, Fun = spawnSpiders, EID = spiderDesc, Stats = {DmgOffset = 0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_WIG, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_INFESTATION_2, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_JUICY_SACK, Fun = spawnSpiders, EID = spiderDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_BOX_OF_SPIDERS,
        Fun = function(player, rng)
            local pos = player.Position
            for _=1, Mod:RandomInt(8, 14, rng) do player:AddBlueSpider(pos) end
        end,
        EID = {en_us = "Spawns 8 to 14 spiders", spa = "Genera 8 a 14 arañas"}
    }
)


local function spawnBoneHeart(player, rng)
	local room = game:GetRoom()
	spawnPickup(room:FindFreePickupSpawnPosition(player.Position, 40, true), 10, 11, player, rng:Next())
end
local boneHeartDesc = {en_us = "Spawns a Bone Heart", spa = "Genera un Corazón de Hueso"}
Mod:AddConsumeItemEffect(
    -- bones hearts drops
    { Id = CollectibleType.COLLECTIBLE_DRY_BABY, Fun = spawnBoneHeart, EID = boneHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SLIPPED_RIB, Fun = spawnBoneHeart, EID = boneHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_POINTY_RIB, Fun = spawnBoneHeart, EID = boneHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_JAW_BONE, Fun = spawnBoneHeart, EID = boneHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE, Fun = spawnBoneHeart, EID = boneHeartDesc }
)


local function spawnEternalHeart(player, rng)
	local room = game:GetRoom()
	spawnPickup(room:FindFreePickupSpawnPosition(player.Position, 40, true), 10, 4, player, rng:Next())
end
local eternalHeartDesc = {en_us = "Spawns a Eternal Heart", spa = "Genera un Corazón Eterno"}
Mod:AddConsumeItemEffect(
    -- eternal hearts drops
    { Id = CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL, Fun = spawnEternalHeart, EID = eternalHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_HOLY_WATER, Fun = spawnEternalHeart, EID = eternalHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_SWORN_PROTECTOR, Fun = spawnEternalHeart, EID = eternalHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_CENSER, Fun = spawnEternalHeart, EID = eternalHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_SERAPHIM, Fun = spawnEternalHeart, EID = eternalHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_ANGELIC_PRISM, Fun = spawnEternalHeart, EID = eternalHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_HALLOWED_GROUND, Fun = spawnEternalHeart, EID = eternalHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_STAR_OF_BETHLEHEM, Fun = spawnEternalHeart, EID = eternalHeartDesc,
        Stats = {
            DmgOffset = 2.15,
            TempDmgOffset = 4.5,
            Tears = 0.2
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BIBLE, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_HALO, Fun = spawnEternalHeart, EID = eternalHeartDesc, Stats = {Tears = 0.08, Speed = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_1UP, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_CRACK_THE_SKY, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_FATE, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SACRED_HEART, Fun = spawnEternalHeart, EID = eternalHeartDesc, Stats = {ForceDmg = 3.5, ForceTempDmg = 2, Range = 1.5, Tears = -0.12, ShotSpeed = -0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_HOLY_GRAIL, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_KEY_PIECE_1, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_KEY_PIECE_2, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_BREATH_OF_LIFE, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_POLAROID, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_GODHEAD, Fun = spawnEternalHeart, EID = eternalHeartDesc, Stats = {Tears = -0.12, ShotSpeed =-0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_LAZARUS_RAGS, Fun = spawnEternalHeart, EID = eternalHeartDesc, Stats = {ForceDmg = 0.75, ForceTempDmg = 4.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_FATES_REWARD, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_HOLY_LIGHT, Fun = spawnEternalHeart, EID = eternalHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_CIRCLE_OF_PROTECTION, Fun = spawnEternalHeart, EID = eternalHeartDesc, Stats = {ForceDmg = 1, ForceTempDmg = 1} }
)


local spawnBlackHeart = function (player, rng)
	local room = game:GetRoom()
	spawnPickup(room:FindFreePickupSpawnPosition(player.Position, 40, true), 10, 6, player, rng:Next())
end
local blackHeartDesc = {en_us = "Spawns a Black Heart", spa = "Genera un Corazón Negro"}
Mod:AddConsumeItemEffect(
    -- black hearts drops
    { Id = CollectibleType.COLLECTIBLE_DEMON_BABY, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_LIL_BRIMSTONE, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_DARK_BUM, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_INCUBUS, Fun = spawnBlackHeart, EID = blackHeartDesc,
        Stats = {
            DmgOffset = 1.5,
            TempDmgOffset = -0.5,
            Tears = 0.22,
        }
    },
    { Id = CollectibleType.COLLECTIBLE_SUCCUBUS, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = { ForceDmg = 2.5, ForceTempDmg =1 } },
    { Id = CollectibleType.COLLECTIBLE_MY_SHADOW, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_SHADE, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_LIL_ABADDON, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = CollectibleType.COLLECTIBLE_TWISTED_PAIR, Fun = spawnBlackHeart, EID = blackHeartDesc,
        Stats = {
            DmgOffset = -1,
            TempDmgOffset = 2.5,
            Tears = 0.15,
        }
    },
    { Id = CollectibleType.COLLECTIBLE_MY_SHADOW, Fun = spawnBlackHeart, EID = blackHeartDesc },
    { Id = Mod.Enum.Item.BEELZEBUB, Fun = spawnBlackHeart, EID = blackHeartDesc },
    {
        Id = Mod.Enum.Item.LIL_BITER,
        Fun = spawnBlackHeart,
        EID = blackHeartDesc,
        Stats = {
            DmgOffset = -1.5,
            TempDmgOffset = 2.5,
        }
    }, { Id = CollectibleType.COLLECTIBLE_PENTAGRAM, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_NECRONOMICON, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_MARK, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {Speed = 0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_PACT, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {Tears = 0.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_DEAD_CAT, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {Tears = 0.25, Speed = 0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_BRIMSTONE, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {Tears = -0.25, ShotSpeed = 0.15, Range = 2.35, ForceDmg = 2.5, ForceTempDmg = 2.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {ForceDmg = 1, Speed = 0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_SPIRIT_OF_THE_NIGHT, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {ForceDmg = 2, ForceTempDmg = 1.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_ABADDON, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {ForceDmg = 2, ForceTempDmg = 1.5, Speed =0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_BLACK_CANDLE, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_MISSING_PAGE_2, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_JUDAS_SHADOW,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 3 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 6, player, rng:Next()) end
        end,
        EID = {en_us = "Spawns 3 Black Hearts", spa = "Genera 3 Corazones Negro"}, 
    }
    ,{ Id = CollectibleType.COLLECTIBLE_NEGATIVE, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SAFETY_PIN, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {Range = 1.5, ShotSpeed = 0.1, DmgOffset = 0.3} }
    ,{ Id = CollectibleType.COLLECTIBLE_CONTAGION, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_SERPENTS_KISS, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_MAW_OF_THE_VOID, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_ATHAME, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_EMPTY_VESSEL, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_EVIL_EYE, Fun = spawnBlackHeart, EID = blackHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_MEGA_BLAST,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 3 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 6, player, rng:Next()) end
        end,
        EID = {en_us = "Spawns 3 Black Hearts", spa = "Genera 3 Corazones Negro"}, Stats = {DmgOffset = 0.5}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN, Fun = spawnBlackHeart, EID = blackHeartDesc, Stats = {Tears = 0.2} }
)


local spawnRedHeart = function (player, rng)
	local room = game:GetRoom()
	spawnPickup(room:FindFreePickupSpawnPosition(player.Position, 40, true), 10, 1, player, rng:Next())
end
local redHeartDesc = {en_us = "Spawns a Red Heart", spa = "Genera un Corazón Rojo"}
Mod:AddConsumeItemEffect(
    {
        Id = CollectibleType.COLLECTIBLE_LITTLE_CHAD,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(3, 5, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 2, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 3 to 5 Half Red Hearts", spa = "Genera 3 a 5 Medio Corazones Rojos"},
    },
    {
        Id = CollectibleType.COLLECTIBLE_LEECH,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(2, 3, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 1, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 2 to 3 Red Hearts", spa = "Genera 2 a 3 Corazones Rojos"},
    },
    {
        Id = Mod.Enum.Item.LIL_COW,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 4 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 1, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 4 Red Hearts", spa = "Genera 4 Corazones Rojos"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BREAKFAST, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_HEART, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_LUNCH, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_DINNER, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_DESSERT, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_ROTTEN_MEAT, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_SNACK, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_MEAT, Fun = spawnRedHeart, EID = redHeartDesc, Stats = {DmgOffset = 0.5}}
    ,{ Id = CollectibleType.COLLECTIBLE_MIDNIGHT_SNACK, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_STEM_CELLS, Fun = spawnRedHeart, EID = redHeartDesc, Stats = {ShotSpeed = 0.1}}
    ,{ Id = CollectibleType.COLLECTIBLE_RAW_LIVER, Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 2 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 1, player, rng:Next())
            end
        end, EID = {en_us = "Spawns 2 Red Hearts", spa = "Genera 2 Corazones Rojos"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_PLACENTA, Fun = function(player, rng)
            spawnRedHeart(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            local failPrev = false
            for i=1, game.TimeCounter // Mod:TimeToFrame({M =1}) do
                if failPrev or rng:RandomInt(2) == 0 then
                    spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 2, player, rng:Next())
                    failPrev = false
                else failPrev = true end
            end
        end, EID = {
            en_us = "Spawn a Red Heart#Per each minute that has passed has a 50% to spawn a Half a Red Heart",
            spa = "Genera un Corazón Rojo#Por cada minuto que a pasado tiene un 50% generar Medio Corazón Rojo"
        },
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BLOOD_BAG, Fun = spawnRedHeart, EID = redHeartDesc, Stats = {Speed = 0.15}}
    ,{ Id = CollectibleType.COLLECTIBLE_BUCKET_OF_LARD, Fun = spawnRedHeart, EID = redHeartDesc, Stats = {Speed = -0.1}}
    ,{ Id = CollectibleType.COLLECTIBLE_ISAACS_HEART, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_THE_JAR, Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(1, 8, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 2, player, rng:Next())
            end
        end, EID = {en_us = "Spawns 1 to 8 Half Red Hearts", spa = "Genera 1 a 8 Medio Corazones Rojos"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_CONVERTER, Fun = spawnRedHeart, EID = redHeartDesc, NoActive = true}
    ,{ Id = CollectibleType.COLLECTIBLE_MAGGYS_BOW, Fun = spawnRedHeart, EID = redHeartDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_THUNDER_THIGHS, Fun = spawnRedHeart, EID = redHeartDesc, Stats = {Speed = -0.25}}
)


local spawnSoulHeart = function (player, rng)
	spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 10, 3, player, rng:Next())
end
local soulHeartDesc = {en_us = "Spawns a Soul Heart", spa = "Genera un Corazón de Alma"}
local spawnSoulHeart2 = function (player, rng)
	local room = game:GetRoom()
    local pos = player.Position
    for _=1, 2 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 3, player, rng:Next()) end
end
local soulHeart2Desc = {en_us = "Spawns 2 Soul Hearts", spa = "Genera 2 Corazones de Almas"}
local spawnSoulHeart3 = function (player, rng)
	local room = game:GetRoom()
    local pos = player.Position
    for _=1, 3 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 3, player, rng:Next()) end
end
local soulHeart3Desc = {en_us = "Spawns 3 Soul Hearts", spa = "Genera 3 Corazones de Almas"}
Mod:AddConsumeItemEffect(
    { Id = CollectibleType.COLLECTIBLE_ROSARY, Fun = spawnSoulHeart, EID = soulHeartDesc, Stats = {Tears = 0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS, Fun = spawnSoulHeart3, EID = soulHeart3Desc, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_RELIC,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(2, 3, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 3, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 2 to 3 Soul Hearts", spa = "Genera 2 a 3 Corazones de Alma"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SUPER_BANDAGE, Fun = spawnSoulHeart, EID = soulHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_WAFER,
        Fun = function(player, rng) spawnEternalHeart(player, rng); spawnSoulHeart3(player, rng) end,
        EID = {
            en_us = "Spawns an Eternal Heart and 3 Soul Hearts",
            spa = "Genera un Corazón Eterno y 3 Corazones de Alma"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_GUPPYS_PAW, Fun = spawnSoulHeart3, EID = soulHeart3Desc, NoActive = true
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SCAPULAR, Fun = spawnSoulHeart, EID = soulHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_ANKH, Fun = spawnSoulHeart3, EID = soulHeart3Desc }
    ,{ Id = CollectibleType.COLLECTIBLE_CELTIC_CROSS,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 4, player, rng:Next())
            for _=1, 2 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 3, player, rng:Next()) end
        end,
        EID = {
            en_us = "Spawns an Eternal Heart and 2 Soul Hearts",
            spa = "Genera un Corazón Eterno y 2 Corazones de Alma"
        },
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MITRE,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 4 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 3, player, rng:Next()) end
        end,
        EID = { en_us = "Spawns 4 Soul Hearts", spa = "Genera 4 Corazones de Alma" },
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SQUEEZY, Fun = spawnSoulHeart, EID = soulHeartDesc, Stats = {Tears = 0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_GNAWED_LEAF, Fun = spawnSoulHeart, EID = soulHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_GIMPY, Fun = spawnSoulHeart, EID = soulHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_INFAMY, Fun = spawnSoulHeart, EID = soulHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_TRINITY_SHIELD, Fun = spawnSoulHeart, EID = soulHeartDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_CANCER, Fun = spawnSoulHeart3, EID = soulHeart3Desc }
    ,{ Id = CollectibleType.COLLECTIBLE_VIRGO, Fun = spawnSoulHeart3, EID = soulHeart3Desc }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_PEARLS, Fun = spawnSoulHeart, EID = soulHeartDesc, Stats = {Luck = 1} }
    ,{ Id = CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT, Fun = spawnSoulHeart, EID = soulHeartDesc, Stats = {ForceDmg = 2.5, ForceTempDmg = 2.35, ShotSpeed = -0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_PJS, Fun = spawnSoulHeart2, EID = soulHeart2Desc }
    ,{ Id = CollectibleType.COLLECTIBLE_METAL_PLATE, Fun = spawnSoulHeart, EID = soulHeartDesc }
)


local spawnKey = function (player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 30, 1, player, rng:Next()) end
local keyDesc = {en_us = "Spawns a Key", spa = "Genera una Llave"}
Mod:AddConsumeItemEffect(
    { Id = CollectibleType.COLLECTIBLE_KEY_BUM, Fun = spawnKey, EID = keyDesc, }
    ,{
        Id = CollectibleType.COLLECTIBLE_SKELETON_KEY,
        Fun = function(player) player:AddKeys(20) end,
        EID = {en_us = "Grants 20 Keys", spa = "Da 20 Llaves"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_LATCH_KEY, Fun = spawnKey, EID = keyDesc, Stats = {Luck = 1} }
)


local spawnCoin = function (player, rng)
    local room = game:GetRoom()
    local pos = player.Position
    for _=1, 3 do
        spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
    end
end
local coinDesc = {en_us = "Spawns 3 coins", spa = "Genera 3 monedas"}
Mod:AddConsumeItemEffect(
    { Id = CollectibleType.COLLECTIBLE_DOLLAR,
        Fun = function(player) player:AddCoins(25) end,
        EID = {en_us = "Grants 25 Coins", spa = "Da 25 Monedas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_QUARTER,
        Fun = function(player) player:AddCoins(7) end,
        EID = {en_us = "Grants 7 Coins", spa = "Da 7 Monedas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_STEAM_SALE,
        Fun = function(player) player:AddCoins(15) end,
        EID = {en_us = "Grants 15 Coins", spa = "Da 15 Monedas"}
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_SACK_OF_PENNIES,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(5, 7, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 5 to 7 Coins", spa = "Genera 5 a 7 Monedas"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MONEY_EQUALS_POWER,
        Fun = function(player) player:AddCoins(15) end,
        EID = {en_us = "Grants 15 Coins", spa = "Da 15 Monedas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_PAGEANT_BOY, spawnCoin, EID = coinDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_BUM_FRIEND, Fun = coinDesc, EID = coinDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_PIGGY_BANK,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
            for i = player:GetHearts(), player:GetEffectiveMaxHearts() do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
            end
        end,
        EID = {
            en_us = "Spawns a coin#Per Each empty heart container, spawns a coin",
            spa = "Genera una moneda#Por cada contenedor de corazón vacío, generar una moneda"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MAGIC_FINGERS, Fun = coinDesc, EID = coinDesc, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_PAY_TO_PLAY,
        Fun = function(player) player:AddCoins(15) end,
        EID = {en_us = "Grants 15 Coins", spa = "Da 15 Monedas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BUMBO, Fun = coinDesc, EID = coinDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER, Fun = coinDesc, EID = coinDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_EYE_OF_GREED,
        Fun = function(player, rng)
            local room = game:GetRoom()
            spawnPickup(room:FindFreePickupSpawnPosition(player.Position, 40, true), 20, CoinSubType.COIN_DIME, player, rng:Next())
        end,
        EID = {en_us = "Spawns a dime", spa = "Genera un dime"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_DADS_LOST_COIN,
        Fun = function(player, rng)
            spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 20, CoinSubType.COIN_LUCKYPENNY, player, rng:Next())
        end,
        EID = {en_us = "Spawns a Lucky Penny", spa = "Genera una Moneda de la Suerte"}
    }
)



local spawnBomb = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 40, 0, player, rng:Next()) end
local bombDesc = {en_us = "Spawns a Bomb", spa = "Genera una Bomba"}
local spawnGigaBomb = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 40, 7, player, rng:Next()) end
local gigaBombDesc = {en_us = "Spawns a Giga Bomb", spa = "Genera una Giga Bomba"}
Mod:AddConsumeItemEffect(-- bombs
    { Id = CollectibleType.COLLECTIBLE_BEST_FRIEND, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BBF, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD, Fun = spawnBomb, EID = bombDesc, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_BOBS_BRAIN, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BOOM, Fun = spawnBomb, EID = bombDesc, Stats = {ForceDmg = 0.5}}
    ,{ Id = CollectibleType.COLLECTIBLE_MR_BOOM, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_KAMIKAZE, Fun = spawnBomb, EID = bombDesc, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_MR_MEGA, Fun = spawnBomb, EID = bombDesc, Stats = {DmgOffset = 0.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_BOBBY_BOMB, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BOBS_CURSE, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BUTT_BOMBS, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_SAD_BOMBS, Fun = spawnBomb, EID = bombDesc, Stats = {Tears = 0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_HOT_BOMBS, Fun = spawnBomb, EID = bombDesc, Stats = {DmgOffset = 0.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_BOMBER_BOY, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_SCATTER_BOMBS, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_STICKY_BOMBS,
        Fun = function(player, rng) spawnBomb(player, rng); spawnSpiders(player, rng) end,
        EID = {en_us = "Spawns a Bomb and 3 to 5 blue spiders", spa = "Genera una Bomba y 3 a 5 arañas azules"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_GLITTER_BOMBS,
        Fun = function(player, rng) spawnBomb(player, rng); spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 0, 4, player, rng:Next()) end,
        EID = {en_us = "Spawns a Bomb and a random pickup", spa = "Genera una Bomba y un recolectable"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_FAST_BOMBS, Fun = spawnBomb, EID = bombDesc, Stats = {ShotSpeed = 0.1, Speed = 0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_NANCY_BOMBS, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR, Fun = spawnBomb, EID = bombDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BLOOD_BOMBS,
        Fun = function(player, rng) spawnBomb(player, rng); spawnRedHeart(player, rng) end,
        EID = {en_us = "Spawns a Bomb and a Red Heart", spa = "Genera una Bomba y un Corazón Rojo"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS, Fun = spawnBomb, EID = bombDesc, Stats = {DmgOffset = 0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_GHOST_BOMBS, Fun = spawnBomb, EID = bombDesc, Stats = {Tears = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_PYRO,
        Fun = function(player) player:AddBombs(25) end,
        EID = {en_us = "Grants 25 Bombs", spa = "Da 25 Bombas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_REMOTE_DETONATOR, Fun = spawnGigaBomb, EID = gigaBombDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_PYROMANIAC, Fun = spawnGigaBomb, EID = gigaBombDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_DOCTORS_REMOTE, Fun = spawnGigaBomb, EID = gigaBombDesc, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_DR_FETUS, Fun = spawnGigaBomb, EID = gigaBombDesc, Stats = {ForceDmg = 2, ForceTempDmg = 1.5, Tears = -0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_EPIC_FETUS, Fun = spawnGigaBomb, EID = gigaBombDesc, Stats = {ForceDmg = 2, ForceTempDmg = 1.5, Tears = -0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_BOMB_BAG,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(5, 7, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 40, 0, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 5 to 7 Bombs", spa = "Genera 5 a 7 Bombas"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BEST_FRIEND, Fun = spawnBomb, EID = bombDesc, NoActive = true}
    ,{ Id = CollectibleType.COLLECTIBLE_BOGO_BOMBS,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 4 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 40, 0, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 4 Bombs", spa = "Genera 4 Bombas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_FIRE_MIND, Fun = spawnBomb, EID = bombDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_MATCH_BOOK, Fun = spawnBomb, EID = bombDesc, Stats = {ForceDmg = 0.75}}
    ,{ Id = CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER, Fun = spawnGigaBomb, EID = gigaBombDesc, Stats = {ForceDmg = 0.75}}
    ,{ Id = CollectibleType.COLLECTIBLE_HOST_HAT, Fun = spawnBomb, EID = bombDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_NUMBER_TWO, Fun = spawnBomb, EID = bombDesc}
    ,{ Id = CollectibleType.COLLECTIBLE_MINE_CRAFTER, Fun = spawnBomb, EID = bombDesc, NoActive = true}
)


local spawnBattery = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 90, 1, player, rng:Next()) end
local batteryDesc = {en_us = "Spawns a Battery", spa = "Genera una Bateria"}
local spawnMegaBattery = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 90, 3, player, rng:Next()) end
local megaBatteryDesc = {en_us = "Spawns a Mega Battery", spa = "Genera una Mega Bateria"}
Mod:AddConsumeItemEffect(-- batteries
    { Id = CollectibleType.COLLECTIBLE_ROBO_BABY, Fun = spawnBattery, EID = batteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_ROBO_BABY_2, Fun = spawnBattery, EID = batteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_9_VOLT, Fun = spawnMegaBattery, EID = megaBatteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_4_5_VOLT, Fun = spawnMegaBattery, EID = megaBatteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BATTERY, Fun = spawnMegaBattery, EID = megaBatteryDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_CHARGED_BABY, Fun = batteryDesc, EID = megaBatteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_TECHNOLOGY, Fun = spawnBattery, EID = batteryDesc, Stats = {Range = 2.5, ShotSpeed = 0.15, Tears = 0.24}}
    ,{ Id = CollectibleType.COLLECTIBLE_GAMEKID, Fun = spawnBattery, EID = batteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_TECHNOLOGY_2, Fun = spawnBattery, EID = batteryDesc, Stats = {Range = 2.5, Tears = -0.24} }
    ,{ Id = CollectibleType.COLLECTIBLE_HABIT, Fun = spawnBattery, EID = batteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_SHARP_PLUG,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 90, 1, player, rng:Next())
            for i = player:GetHearts(), player:GetEffectiveMaxHearts() do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 90, 2, player, rng:Next())
            end
        end,
        EID = {
            en_us = "Spawns a Battery#Per Each empty heart container, spawns a Micro Battery",
            spa = "Genera una Bateria#Por cada contenedor de corazón vacío, generar Micro Bateria"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_TECH_5, Fun = spawnBattery, EID = batteryDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_BOT_FLY,
        Fun = function(player, rng)
            spawnFlys(player, rng)
            spawnBattery(player, rng)
        end,
        EID = {en_us = "Spawns a Battery and 3 to 5 flies", spa = "Genera una Bateria y 3 a 5 moscas"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SPIDER_MOD,
        Fun = function(player, rng)
            spawnSpiders(player, rng)
            spawnBattery(player, rng)
        end,
        EID = {en_us = "Spawns a Battery and 3 to 5 spiders", spa = "Genera una Bateria y 3 a 5 arañas"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_TECH_X, Fun = spawnMegaBattery, EID = megaBatteryDesc, Stats = {ForceDmg = 2.3} }
)


local spawnPill = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 70, itemPool:GetPill(rng:Next()), player, rng:Next() ) end
local pillDesc = {en_us = "Spawns a Pill", spa = "Genera una Pildora"}
Mod:AddConsumeItemEffect(
    {
        Id = CollectibleType.COLLECTIBLE_ACID_BABY,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(2, 3, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 70, itemPool:GetPill(rng:Next()), player, rng:Next() )
            end
        end,
        EID = {en_us = "Spawns 2 to 3 Pills", spa = "Genera 2 a 3 Pildoras"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_LIL_SPEWER, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_PHD,
        Fun = function(player, rng)
            spawnRedHeart(player, rng)
            spawnPill(player, rng)
        end, EID = {en_us = "Spawns a Red Heart and a Pill", spa = "Genera un Corazón Rojo y una Pildora"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_VIRUS, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_ROID_RAGE, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_GROWTH_HORMONES, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_SPEED_BALL, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT,
        Fun = function(player, rng)
            spawnPill(player, rng)

            local permaStats = playerSave(SAVE_PERMA_STATS_NAME, player):Get({})
            local statUpType = rng:RandomInt(6)
            local cacheFlag =0
            if statUpType == 0 then
                permaStats.Damage = (permaStats.Damage or 0) + 0.5
                cacheFlag = CacheFlag.CACHE_DAMAGE
            elseif statUpType == 1 then
                permaStats.Tears = (permaStats.Tears or 0) + 0.2
                cacheFlag = CacheFlag.CACHE_FIREDELAY
            elseif statUpType == 2 then
                permaStats.Speed = (permaStats.Speed or 0) + 0.12
                cacheFlag = CacheFlag.CACHE_SPEED
            elseif statUpType == 3 then
                permaStats.ShotSpeed = (permaStats.ShotSpeed or 0) + 0.1
                cacheFlag = CacheFlag.CACHE_SHOTSPEED
            elseif statUpType == 4 then
                permaStats.Range = (permaStats.Range or 0) + 1.25
                cacheFlag = CacheFlag.CACHE_RANGE
            elseif statUpType == 5 then
                permaStats.Luck = (permaStats.Luck or 0) + 1
                cacheFlag = CacheFlag.CACHE_LUCK
            end
            playerSave(SAVE_PERMA_STATS_NAME, player):Set(permaStats)
            Mod.PlayerTools.DoCache(player, cacheflags)

        end, EID = {
            en_us = "Grants a random stat up#Spawns a Pill",
            spa = "Aumenta una de las estadisticas#Genera una pildora",
        },
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SYNTHOIL, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_ADRENALINE, Fun = spawnPill, EID = pillDesc, }
    ,{ Id = CollectibleType.COLLECTIBLE_EUTHANASIA,
        Fun = function(player, rng)
            spawnPill(player, rng)
            spawnBlackHeart(player, rng)
        end,
        EID = { en_us = "Spawns a Pill and a Black Heart", spa = "Genera una Pildora y un Corazón Negro" }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_ACID_BABY,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 2 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 70, itemPool:GetPill(rng:Next()), player, rng:Next() )
            end
        end,
        EID = {en_us = "Spawns 2 Pills", spa = "Genera 2 Pildoras"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_LITTLE_BAGGY,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 2 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 70, itemPool:GetPill(rng:Next()), player, rng:Next() )
            end
        end,
        EID = {en_us = "Spawns 2 Pills", spa = "Genera 2 Pildoras"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_CAFFEINE_PILL, Fun = spawnPill, EID = pillDesc, }
)


local spawnCard = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 300, itemPool:GetCard(rng:Next(), true, false, false), player, rng:Next() ) end
local cardDesc = {en_us = "Spawns a Card", spa = "Genera una Carta"}
Mod:AddConsumeItemEffect(
    { Id = CollectibleType.COLLECTIBLE_DECK_OF_CARDS, Fun = spawnCard, EID = cardDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_MAGIC_8_BALL, Fun = spawnCard, EID = cardDesc }
    ,{ Id = CollectibleType.COLLECTIBLE_STARTER_DECK,
        Fun = function(player, rng)
            spawnCard(player, rng)
            spawnCard(player, rng)
        end,
        EID = {en_us = "Spawns 2 Cards", spa = "Genera 2 Cartas"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_TAROT_CLOTH,
        Fun = function(player, rng)
            spawnCard(player, rng)
            spawnCard(player, rng)
        end,
        EID = {en_us = "Spawns 2 Cards", spa = "Genera 2 Cartas"}
    }
)


Mod:AddConsumeItemEffect( -- mostly stat things or setting an active off
    { Id = CollectibleType.COLLECTIBLE_SAD_ONION, Stats = {Tears = 0.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_INNER_EYE, Stats = {DmgOffset = 0.5, Tears = -0.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_CRICKETS_HEAD, Stats = {DmgOffset = 2.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_MY_REFLECTION, Stats = {Range = 0.75, ShotSpeed = 0.12, Luck = -0.33} }
    ,{ Id = CollectibleType.COLLECTIBLE_NUMBER_ONE, Stats = {DmgOffset = -0.25, Tears = 0.25, Range = -0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM, Stats = {DmgOffset = 0.75, Range = 1.25, Speed = 0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_HEELS, Stats = {Range = 1.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_WIRE_COAT_HANGER, Stats = {Tears = 0.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_TAMMYS_HEAD, Stats = {Tears = 0.3} }
    ,{ Id = CollectibleType.COLLECTIBLE_LUCKY_FOOT, Stats = {Luck = 0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_CUPIDS_ARROW, Stats = {ForceDmg = 0, Tears = 0.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_SHOOP_DA_WHOOP, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_CHOCOLATE_MILK, Stats = {Tears = 1} }
    ,{ Id = CollectibleType.COLLECTIBLE_GROWTH_HORMONES, Stats = {Speed = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_LIL_GURDY, Stats = {Speed = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_LITTLE_CHUBBY, Stats = { DmgOffset = -1.5, TempDmgOffset = 2.5, Speed = 0.15 } }
    ,{ Id = CollectibleType.COLLECTIBLE_BIG_CHUBBY, Stats = { DmgOffset = 0.5, TempDmgOffset = -1.5, Speed = -0.2 } }
    ,{ Id = CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, Stats = { Speed = 0.14 }}
    ,{ Id = CollectibleType.COLLECTIBLE_THE_NAIL, Stats = {DmgOffset = 0.5, Speed = -0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_LOKIS_HORNS, Stats = {Tears = 0.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_SMALL_ROCK, Stats = {DmgOffset = 0.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_PARASITE, Stats = {Tears = 0.1, ShotSpeed = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_PINKING_SHEARS, Stats = {ShotSpeed = 0.1, Speed = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_KNIFE, Stats = {ShotSpeed = 0.15, Tears = -0.12, ForceDmg = 4.5, ForceTempDmg = 1.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_OUIJA_BOARD, Stats = {Tears = 0.15, ShotSpeed = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN, Stats = {Tears = 0.5, Speed = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_ODD_MUSHROOM_LARGE, Stats = {ForceDmg = 0.75, Speed = -0.12, Range = 0.75} }
    ,{ Id = CollectibleType.COLLECTIBLE_PONY, Stats = {Speed = 0.25}}
    ,{ Id = CollectibleType.COLLECTIBLE_LUMP_OF_COAL, Stats = {ForceDmg = 1.5, ForceTempDmg = 1, Range = 1.5, ShotSpeed = 0.15}}
    ,{ Id = CollectibleType.COLLECTIBLE_IPECAC, Stats = {ForceDmg = 3.5, ForceTempDmg = 2.5, Range = -1.5, ShotSpeed = -0.2, Tears = -0.5}}
    ,{ Id = CollectibleType.COLLECTIBLE_MUTANT_SPIDER, Stats = {ForceDmg = 1.5, ForceTempDmg = 1.75, Tears = 0.28}}
    ,{ Id = CollectibleType.COLLECTIBLE_CHEMICAL_PEEL, Stats = {ForceDmg = 1}}
    ,{ Id = CollectibleType.COLLECTIBLE_PEEPER, Stats = {ForceDmg = 1, ForceTempDmg = 0.75}}
    ,{ Id = CollectibleType.COLLECTIBLE_CAT_O_NINE_TAILS, Stats = {ShotSpeed = 0.12}}
    ,{ Id = CollectibleType.COLLECTIBLE_HARLEQUIN_BABY, Stats = {Tears = 0.12}}
    ,{ Id = CollectibleType.COLLECTIBLE_POLYPHEMUS, Stats = {ForceDmg = 6.5, ForceTempDmg = 2.35, Tears = -1}}
    ,{ Id = CollectibleType.COLLECTIBLE_RAINBOW_BABY, Stats = {ForceDmg = 0.5, Tears = 0.12, Range = 1.25, ShotSpeed = 0.1, Speed = 0.1}}
    ,{ Id = CollectibleType.COLLECTIBLE_WHITE_PONY, Stats = {Speed = 0.25}}
    ,{ Id = CollectibleType.COLLECTIBLE_TOOTH_PICKS, Stats = {Tears = 0.25}}
    ,{ Id = CollectibleType.COLLECTIBLE_BLOOD_RIGHTS, Stats = {ForceDmg = 0.66, Tears = 0.15}, NoActive = true}
    ,{ Id = CollectibleType.COLLECTIBLE_SMB_SUPER_FAN, Stats = {Tears = 0.1, Range = 1.25}}
    ,{ Id = CollectibleType.COLLECTIBLE_GUILLOTINE, Stats = {Tears = 0.25}}
    ,{ Id = CollectibleType.COLLECTIBLE_LOST_CONTACT, Stats = {ShotSpeed = -0.15}}
    ,{ Id = CollectibleType.COLLECTIBLE_ANEMIC, Stats = {Range = 0.75}}
    ,{ Id = CollectibleType.COLLECTIBLE_RUBBER_CEMENT, Stats = {Range = 1.5, ShotSpeed = 0.2}}
    ,{ Id = CollectibleType.COLLECTIBLE_ANTI_GRAVITY, Stats = {Tears = 0.35}}
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_PERFUME, Stats = {Tears = 0.15}}
    ,{ Id = CollectibleType.COLLECTIBLE_MONSTROS_LUNG, Stats = {ForceDmg = 2, ForceTempDmg = 1.5, Tears = 0.15}}
    ,{ Id = CollectibleType.COLLECTIBLE_STOP_WATCH, Stats = {Speed = 0.12}}
    ,{ Id = CollectibleType.COLLECTIBLE_TINY_PLANET, Stats = {Tears = 0.2}}
    ,{ Id = CollectibleType.COLLECTIBLE_20_20, Stats = {ForceDmg = -0.75, Tears = 0.5}}
    ,{ Id = CollectibleType.COLLECTIBLE_BFFS, Stats = {ForceDmg = 1, Tears = 0.2}}
    ,{ Id = CollectibleType.COLLECTIBLE_BLOOD_CLOT, Stats = {DmgOffset = 0.25, Range = 1}}
    ,{ Id = CollectibleType.COLLECTIBLE_SCREW, Stats = {Tears = 0.15}}
    ,{ Id = CollectibleType.COLLECTIBLE_PROPTOSIS, Stats = {ForceTempDmg = 2.25, Range = -3.5}}
    ,{ Id = CollectibleType.COLLECTIBLE_PUNCHING_BAG, Stats = {Speed = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_HOW_TO_JUMP, Stats = {Range = 3.5}, NoActive = true}
    ,{ Id = CollectibleType.COLLECTIBLE_D4, NoActive = true}
    ,{ Id = CollectibleType.COLLECTIBLE_UNICORN_STUMP, Stats = {Speed = 0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_TAURUS, Stats = {Speed = -0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_ARIES, Stats = {Speed = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_LEO, Stats = {ForceDmg = 0.75, Speed = -0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_SCORPIO, Stats = {DmgOffset = 0.75, TempDmgOffset = 0} }
    ,{ Id = CollectibleType.COLLECTIBLE_SAGITTARIUS, Stats = {Speed = 0.1, ShotSpeed = 0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_CAPRICORN, Stats = {Tears = 0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_AQUARIUS, Stats = {Tears = 0.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_PISCES, Stats = {Tears = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_EVES_MASCARA, Stats = {ForceDmg = 3.5, ForceTempDmg =1, Tears = -0.75, ShotSpeed = -0.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_CURSED_EYE, Stats = {Tears = 0.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_INCUBUS, Stats = { DmgOffset = 0.5, TempDmgOffset = -0.5, Tears = 0.22, } }
    ,{ Id = CollectibleType.COLLECTIBLE_SAMSONS_CHAINS, Stats = {ForceDmg = 0.65, Speed = -0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_ISAACS_TEARS, Stats = {Tears = 0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE, Stats = {Tears = 0.2, ShotSpeed = 0.15, Range = 2.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_SOY_MILK, Stats = {Tears = 2.5, ForceDmg = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_DEAD_ONION, Stats = {ShotSpeed = -0.25, Range = -1.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_BROKEN_WATCH, Stats = {Speed = 0.12, ForceTempDmg = 2.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_TORN_PHOTO, Stats = {Tears = 0.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_BLUE_CAP, Stats = {Tears = 0.25, ShotSpeed = -0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_THE_WIZ, Stats = {Tears = 0.35} }
    ,{ Id = CollectibleType.COLLECTIBLE_8_INCH_NAILS, Stats = {ForceDmg = 1.5, ForceTempDmg = 1.25} }
    ,{ Id = CollectibleType.COLLECTIBLE_EPIPHORA, Stats = {Tears = 1.24} }
    ,{ Id = CollectibleType.COLLECTIBLE_DEAD_EYE, Stats = {ForceTempDmg = 3.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_TEAR_DETONATOR, Stats = {Tears = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_BETRAYAL, Stats = {ForceDmg = 0.75} }
    ,{ Id = CollectibleType.COLLECTIBLE_MARKED, Stats = {Tears = 0.3, Range = 1.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_VENTRICLE_RAZOR, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_TRACTOR_BEAM, Stats = {Tears = 0.3, Range = 1.5, ShotSpeed = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_GODS_FLESH, Stats = {Tears = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_SPEAR_OF_DESTINY, Stats = {Range = 1.25, ForceDmg =1} }
    ,{ Id = CollectibleType.COLLECTIBLE_BLACK_POWDER, Stats = {ForceDmg =0.5, ForceTempDmg = 2} }
    ,{ Id = CollectibleType.COLLECTIBLE_LIL_LOKI, Stats = {Tears = 0.1} }
    ,{ Id = CollectibleType.COLLECTIBLE_MILK, Stats = {Tears = 0.15} }
    ,{ Id = CollectibleType.COLLECTIBLE_D7, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_BINKY, Stats = {Tears = 0.2} }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_BOX, Stats = {Luck = 1} }
    ,{ Id = CollectibleType.COLLECTIBLE_APPLE, Stats = {Tears = 0.12} }
    ,{ Id = CollectibleType.COLLECTIBLE_LEAD_PENCIL, Stats = {TempDmgOffset = 2.5} }
    ,{ Id = CollectibleType.COLLECTIBLE_EYE_OF_BELIAL, Stats = {Range = 1} }
    ,{ Id = CollectibleType.COLLECTIBLE_DEPRESSION, Stats = {Tears = 0.34} }
    ,{ Id = CollectibleType.COLLECTIBLE_PLAN_C, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_VOID, NoActive = true }
    ,{ Id = CollectibleType.COLLECTIBLE_VOID, EID = {en_us = "Does the effect of a random dice", spa = "Hace el efecto de un dado"} }
)



Mod:AddConsumeItemEffect(
    -- unique effects
    {
        Id = CollectibleType.COLLECTIBLE_MYSTERY_SACK,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(4, 6, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 0, 4, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 4 to 6 pickups", spa = "Genera 4 a 6 recolectables"},
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_RUNE_BAG,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(2, 3, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 300, itemPool:GetCard(rng:Next(), false, true, true), player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 2 to 3 Runes", spa = "Genera 2 a 3 Runas"},
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_SACK_OF_SACKS,
        Fun = function(player, rng)
		    local room = game:GetRoom()
            local pos = player.Position
            for _=1, Mod:RandomInt(2, 3, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 69, 0, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 2 to 3 Sacks", spa = "Genera 2 a 3 Bolsas"},
    }
    ,{  Id = CollectibleType.COLLECTIBLE_SACK_HEAD,
        Fun = function(player, rng)
		    local room = game:GetRoom()
            local pos = player.Position
            for _=1, 3 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 69, 0, player, rng:Next()) end
        end,
        EID = {en_us = "Spawns 3 Sacks", spa = "Genera 3 Bolsas"},
    }

    
    ,{
        Id = CollectibleType.COLLECTIBLE_LIL_CHEST,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 6 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 0, 4, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 6 pickups", spa = "Genera 6 recolectables"},
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_GB_BUG,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for _=1, 2 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 0, 4, player, rng:Next())
            end

            game:AddPixelation(10 * 30) -- 10 seconds
        end,
        EID = {
            en_us = "Spawns 2 pickups#Pixelates the screen for 10 seconds",
            spa = "Genera 2 recolectables#Pixela la pantalla por 10 segundos"
        }
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_BOOK_OF_SIN,
        Fun = function(player, rng)
            local room = game:GetRoom()
            spawnPickup(room:FindFreePickupSpawnPosition(player.Position, 40, true), 0, 4, player, rng:Next())
        end,
        EID = {en_us = "Spawns a pickup", spa = "Genera un recolectable"},
    }

    
    ,{
        Id = CollectibleType.COLLECTIBLE_7_SEALS,
        Fun = function(player) 
            for _=1, 10 do
                Mod:Spawn(3, FamiliarVariant.BLUE_FLY, Mod:RandomInt(1, 5, rng) , player.Position, Vector.Zero, player)
            end
        end,
        EID = {en_us = "Spawns 10 locust", spa = "Genera 10 langostas"},
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_HUSHY,
        Fun = function(player, rng) spawnSpiders(player, rng); spawnFlys(player, rng) end,
        EID = {en_us = "Spawns 3 to 5 flys and spawns 3 to 5 spiders", spa = "Genera 3 a 5 moscas y genera 3 a 5 arañas"},
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_HIVE_MIND,
        Fun = function(player, rng) spawnSpiders(player, rng); spawnSpiders(player, rng); spawnFlys(player, rng); spawnFlys(player, rng) end,
        EID = {en_us = "Spawns 6 to 10 flys and spawns 6 to 10 spiders", spa = "Genera 6 a 10 moscas y genera 6 a 10 arañas"},
    }
    

    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_LIPSTICK,
        Fun = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 10, 0, player, rng:Next()) end,
        Stats = {Range = 2.45},
        EID = {en_us = "Spawns a random heart", spa = "Genera un corazón"}
    }

    ,{ Id = CollectibleType.COLLECTIBLE_FORGET_ME_NOW,
        Fun = function()
            local sav = saveHand("Consume - Forget me now")
            sav:Set(sav:Get(0) +1)
        end,
        EID = {
            en_us = "Clearing all of the normal rooms will activate {{Collectible"..CollectibleType.COLLECTIBLE_FORGET_ME_NOW.."}} Forget Me Now",
            spa = "Limpiar todos los cuartos normales va activar {{Collectible"..CollectibleType.COLLECTIBLE_FORGET_ME_NOW.."}} Olvídame Ya"
        }, NoActive = true
    }
    ,{ Id = CollectibleType.COLLECTIBLE_GUPPYS_TAIL,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 50, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 50, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 60, 0, player, rng:Next())
        end,
        EID = {
            en_us = "Spawns 2 chests and a Golden Chest",
            spa = "Genera 2 cofres y un Cofre Dorado"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_IV_BAG,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            for i = player:GetHearts(), player:GetEffectiveMaxHearts() do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
            end
        end,
        EID = {
            en_us = "Per each empty heart container, spawn a random coin",
            spa = "Por cada contenedor de corazón vacío, genera una moneda",
        }, NoActive = true
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_PURSE,
        Fun = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 350, 0, player, rng:Next()) end,
        EID = {en_us = "Spawns a random trinket", spa = "Genera un trinket"}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_DADS_KEY,
        Fun = function()
            local sav = saveHand("Consume - Dads Key")
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "Clearing or entering on a non hostile room with a locked door, will activate {{Collectible"..CollectibleType.COLLECTIBLE_DADS_KEY.."}} Dad's Key",
            spa = "Limpiar o entrar a un cuarto no hostil con una puerta cerrada, activara {{Collectible"..CollectibleType.COLLECTIBLE_DADS_KEY.."}} Llave de Papá"
        }, NoActive = true
    }
    ,{
        Id = CollectibleType.COLLECTIBLE_PORTABLE_SLOT,
        Fun = function(player, rng)
            local pos = player.Position
            local room = game:GetRoom()
            for _=1, Mod:RandomInt(1, 7, rng) do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 0, 4, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 1 to 7 pickups", spa = "Genera 1 a 7 recolectables"}, NoActive = true
    }


    ,{  Id = CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
        Fun = function(player)
            local sav = playerSave("Consume - Book of Belial", player)
            sav:Set(sav:Get(0) +15)
        end,
        EID = {
            en_us = "For the next 15 hostile rooms:#Activate {{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL.."}} Book of Belial",
            spa = "Por los siguientes 15 cuartos hostiles:#Activara {{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL.."}} Libro de Belial"
        }, NoActive = true
    }
    ,{  Id = CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS,
        Fun = function(player)
            local sav = playerSave("Consume - Book of Shadows", player)
            sav:Set(sav:Get(0) +15)
        end,
        EID = {
            en_us = "For the next 15 hostile rooms:#Activate {{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS.."}} Book of Shadows",
            spa = "Por los siguientes 15 cuartos hostiles:#Activara {{Collectible"..CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS.."}} Libro de las Sombras"
        }, NoActive = true
    }
    ,{  Id = CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK,
        Fun = function(player)
            local sav = playerSave("Consume - Anarchist Cookbook", player)
            sav:Set(sav:Get(0) +5)
        end,
        EID = {
            en_us = "For the next 5 hostile rooms:#Activate {{Collectible"..CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK.."}} Anarchist Cookbook",
            spa = "Por los siguientes 5 cuartos hostiles:#Activara {{Collectible"..CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK.."}} Recetario de Anarquista"
        }, NoActive = true
    }
    ,{  Id = CollectibleType.COLLECTIBLE_TELEPATHY_BOOK,
        Fun = function(player)
            local sav = playerSave("Consume - Telepathy for Dummies", player)
            sav:Set(sav:Get(0) +15)
        end,
        EID = {
            en_us = "For the next 15 hostile rooms:#Activate {{Collectible"..CollectibleType.COLLECTIBLE_TELEPATHY_BOOK.."}} Telepathy for Dummies",
            spa = "Por los siguientes 15 cuartos hostiles:#Activara {{Collectible"..CollectibleType.COLLECTIBLE_TELEPATHY_BOOK.."}} Telepatía para Tontos"
        }, NoActive = true
    }
    ,{  Id = CollectibleType.COLLECTIBLE_BOOK_OF_SECRETS,
        Fun = function()
            local sav = saveHand("Consume - Book of Secrets")
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "For the next 3 floors:#Reveals all the rooms of the floor (except {{SuperSecretRoom}} Super / {{UltraSecretRoom}} Ultra Secret Room)",
            spa = "Por los siguientes 3 pisos:#Revela todos los cuartos del piso (excepto las {{SuperSecretRoom}} Habitaciónes Super / {{UltraSecretRoom}} Ultra Secretas)"
        }, NoActive = true
    }


    ,{
        Id = CollectibleType.COLLECTIBLE_BOX,
        Fun = function(player, rng)
            local pos = player.Position
            local room = game:GetRoom()
            for _=1, 7 do spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 0, 4, player, rng:Next()) end
        end,
        EID = {en_us = "Spawns 7 pickups", spa = "Genera 7 recolectables"},
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MOMS_KEY,
        Fun = function(player)
            local room = game:GetRoom()
            local pos = player.Position
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 50, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 50, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 50, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 50, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 60, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 60, 0, player, rng:Next())
        end,
        EID = {
            en_us = "Spawns 4 chests and 2 Golden Chests",
            spa = "Genera 4 cofres y 2 Cofres Dorado"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MIDAS_TOUCH,
        Fun = function()
            local sav = saveHand("Consume - Midas Touch")
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "On the next 3 floors#Spawns a Golden Key and a Golden Bomb",
            spa = "En el siguiente 3 pisos#Genera una Llave Dorada y una Bomba Dorada"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_GOAT_HEAD,
        Fun = function()
            local sav = saveHand("Consume - Goat Head")
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "When defeating the boss of the floor and neither deal room spawn#Isaac is teleported to the devil room#This can trigger up to 3 times",
            spa = "Al derrotal al jefe del piso y ninguno de los cuartos del trato se genera#Isaac es teletransportado al cuarto del diablo#Esto puede activarse hasta 3 veces"
        }
    }


    ,{ Id = CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 30, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 40, 0, player, rng:Next())
        end,
        EID = {
            en_us = "Spawns a heart, coin, key and bomb",
            spa = "Genera un corazón, moneda, llave y bomba"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_FANNY_PACK,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 0, 4, player, rng:Next())
            
            for i = player:GetHearts(), player:GetEffectiveMaxHearts() do
                if rng:RandomInt(2) ==0 then spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 0, 4, player, rng:Next()) end
            end
        end,
        EID = {
            en_us = "Spawns a random pickup#Per Each empty heart container, has a 50% to spawn another pickup",
            spa = "Genera un recolectable#Por cada contenedor de corazón vacío, tiene un 50% de generar otro recolectable"
        }
    }


    ,{ Id = CollectibleType.COLLECTIBLE_GUPPYS_COLLAR,
        Fun = function(player, rng) spawnEternalHeart(player); spawnSoulHeart(player) end,
        EID = { en_us = "Spawns an Eternal Heart and a Soul Heart", spa = "Genera un Corazón Eterno y un Corazón de Alma" }
    }

    ,{ Id = CollectibleType.COLLECTIBLE_THERES_OPTIONS,
        Fun = function(player, rng, pickup)
            local pool = game:IsGreedMode() and ItemPoolType.POOL_GREED_BOSS or ItemPoolType.POOL_BOSS
            local pos = pickup.Position
            pos.Y = pos.Y +40
            pos.X = pos.X -80

            if Mod.PlayerTools.AnyPlayerHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
                pool = -1
            end
            
            local optionIndex = Mod:GetFreeGroup()
            local room = game:GetRoom()
            for i=0, 2 do
                pos.X = pos.X + 80 *i

                local item = Mod:SpawnItem(
                    Mod:GetRandomCollectible(pool, true, rng:Next(), nil, true),
                    room:FindFreePickupSpawnPosition(pos, 0, true),
                    player)
                Mod:SetPickupNonEat(item)
                item.OptionsPickupIndex = optionIndex
            end
        end,
        EID = {
            en_us = "Spawns 3 items from the boss pool that cannot be consume#Only one can be pickup",
            spa = "Genera 3 objetos de la sala del jefe que no se puede consumir#Solo uno se puede tomar"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MORE_OPTIONS,
        Fun = function(player, rng, pickup)
            local pool = game:IsGreedMode() and ItemPoolType.POOL_GREED_TREASURE or ItemPoolType.POOL_TREASURE
            local pos = pickup.Position
            pos.Y = pos.Y +40
            pos.X = pos.X -80

            if Mod.PlayerTools.AnyPlayerHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
                pool = -1
            end
            
            local optionIndex = Mod:GetFreeGroup()
            local room = game:GetRoom()
            for i=0, 2 do
                pos.X = pos.X + 80 *i

                local item = Mod:SpawnItem(
                    Mod:GetRandomCollectible(pool, true, rng:Next(), nil, true),
                    room:FindFreePickupSpawnPosition(pos, 0, true),
                    player)
                Mod:SetPickupNonEat(item)
                item.OptionsPickupIndex = optionIndex
            end
        end,
        EID = {
            en_us = "Spawns 3 items from the treasure pool that cannot be consume#Only one can be pickup",
            spa = "Genera 3 objetos de la sala del tesoro que no se puede consumir#Solo uno se puede tomar"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_RESTOCK,
        Fun = function(player, rng, pickup)
            local pool = game:IsGreedMode() and ItemPoolType.POOL_GREED_SHOP or ItemPoolType.POOL_SHOP
            local pos = pickup.Position
            pos.Y = pos.Y +40
            pos.X = pos.X -80

            if Mod.PlayerTools.AnyPlayerHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
                pool = -1
            end
            
            local optionIndex = Mod:GetFreeGroup()
            local room = game:GetRoom()
            for i=0, 1 do
                if pool >=0 then
                    if rng:RandomInt(8) == 0 then
                        pool = ItemPoolType.POOL_BABY_SHOP
                    else
                        pool = game:IsGreedMode() and ItemPoolType.POOL_GREED_SHOP or ItemPoolType.POOL_SHOP
                    end
                end

                pos.X = pos.X + 80 *i

                local item = Mod:SpawnItem(
                    Mod:GetRandomCollectible(pool, true, rng:Next(), nil, true),
                    room:FindFreePickupSpawnPosition(pos, 0, true),
                    player)
                Mod:SetPickupNonEat(item)
                item.OptionsPickupIndex = optionIndex
            end
        end,
        EID = {
            en_us = "Spawns 3 items from the shop pool that cannot be consume#Only one can be pickup",
            spa = "Genera 3 objetos de la sala de la tienda que no se puede consumir#Solo uno se puede tomar"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_EDENS_BLESSING,
        Fun = function(player, rng, pickup)
            local pool = -1
            local pos = pickup.Position
            pos.Y = pos.Y +40
            
            local room = game:GetRoom()
            local item = Mod:SpawnItem(
                Mod:GetRandomCollectible(pool, true, rng:Next(), nil, true),
                room:FindFreePickupSpawnPosition(pos, 0, true),
                player)
        end,
        EID = {
            en_us = "Spawns an item",
            spa = "Genera un objeto",
        }, Stats = {Tears = 0.25}
    }

    ,{ Id = CollectibleType.COLLECTIBLE_MISSING_NO,
        Fun = function(player, rng)
            local totalStatAmount = 1

            local permaStats = playerSave(SAVE_PERMA_STATS_NAME, player):Get({})
            local cacheFlag = CacheFlag.CACHE_ALL
            
            totalStatAmount = totalStatAmount + (permaStats.Damage or 0)
            totalStatAmount = totalStatAmount + (permaStats.Tears or 0) * 2.45
            totalStatAmount = totalStatAmount + (permaStats.Speed or 0)
            totalStatAmount = totalStatAmount + (permaStats.ShotSpeed or 0)
            totalStatAmount = totalStatAmount + (permaStats.Range or 0) * 0.5
            totalStatAmount = totalStatAmount + (permaStats.Luck or 0) * 0.65
            
            permaStats.Speed = math.min( Mod:RandomFloat(0, totalStatAmount,rng), 4.5)
            totalStatAmount = totalStatAmount -permaStats.Speed
            if totalStatAmount >0 then
                permaStats.Tears = math.min( Mod:RandomFloat(0, totalStatAmount,rng)/2.45, 17.5)
                totalStatAmount = totalStatAmount -(permaStats.Tears * 2.45)
            end
            if totalStatAmount >0 then
                permaStats.ShotSpeed = math.min( Mod:RandomFloat(0, totalStatAmount,rng), 5)
                totalStatAmount = totalStatAmount -permaStats.ShotSpeed
            end
            if totalStatAmount >0 then
                permaStats.Range = math.min( Mod:RandomFloat(0, totalStatAmount,rng)/0.45, 20.5)
                totalStatAmount = totalStatAmount -(permaStats.Range * 0.45)
            end
            if totalStatAmount >0 then
                permaStats.Luck = math.min( Mod:RandomFloat(0, totalStatAmount,rng)/5, 25)
                totalStatAmount = totalStatAmount -(permaStats.Luck * 5)
            end
            if totalStatAmount >0 then
                permaStats.Damage = totalStatAmount
            end

            playerSave(SAVE_PERMA_STATS_NAME, player):Set(permaStats)
            Mod.PlayerTools.DoCache(player, cacheflags)
            
            game:AddPixelation(30 *30)
        end, Stats = {ForceDmg = 0, ForceTempDmg = 1.25 },
        EID = {
            en_us ="Rerolls all the stats gain by consuming items",
            spa ="Cambia todas las estadisticas ganadas al comsumir objetos",
        }
    }

    ,{ Id = CollectibleType.COLLECTIBLE_D8,
        Fun = function(player, rng)
            local totalStatAmount = Mod:RandomInt(-3, 5,rng)

            local permaStats = playerSave(SAVE_PERMA_STATS_NAME, player):Get({})
            local cacheFlag = CacheFlag.CACHE_ALL
            
            totalStatAmount = totalStatAmount + (permaStats.Damage or 0)
            totalStatAmount = totalStatAmount + (permaStats.Tears or 0) * 2.45
            totalStatAmount = totalStatAmount + (permaStats.Speed or 0)
            totalStatAmount = totalStatAmount + (permaStats.ShotSpeed or 0)
            totalStatAmount = totalStatAmount + (permaStats.Range or 0) * 0.45
            totalStatAmount = totalStatAmount + (permaStats.Luck or 0) * 5
            
            permaStats.Speed = math.min( Mod:RandomFloat(0, totalStatAmount,rng), 4.5)
            totalStatAmount = totalStatAmount -permaStats.Speed
            if totalStatAmount >0 then
                permaStats.Tears = math.min( Mod:RandomFloat(0, totalStatAmount,rng)/2.45, 17.5)
                totalStatAmount = totalStatAmount -(permaStats.Tears * 2.45)
            end
            if totalStatAmount >0 then
                permaStats.ShotSpeed = math.min( Mod:RandomFloat(0, totalStatAmount,rng), 5)
                totalStatAmount = totalStatAmount -permaStats.ShotSpeed
            end
            if totalStatAmount >0 then
                permaStats.Range = math.min( Mod:RandomFloat(0, totalStatAmount,rng)/0.45, 20.5)
                totalStatAmount = totalStatAmount -(permaStats.Range * 0.45)
            end
            if totalStatAmount >0 then
                permaStats.Luck = math.min( Mod:RandomFloat(0, totalStatAmount,rng)/5, 25)
                totalStatAmount = totalStatAmount -(permaStats.Luck * 5)
            end
            if totalStatAmount >0 then
                permaStats.Damage = totalStatAmount
            end

            playerSave(SAVE_PERMA_STATS_NAME, player):Set(permaStats)
            Mod.PlayerTools.DoCache(player, cacheflags)
            
        end, Stats = {ForceDmg = 0, ForceTempDmg = 1.25 },
        EID = {
            en_us ="Rerolls all the stats gain by consuming items",
            spa ="Cambia todas las estadisticas ganadas al comsumir objetos",
        }
    }

    ,{  Id = CollectibleType.COLLECTIBLE_CLEAR_RUNE,
        Fun = function(player, rng)
		    local room = game:GetRoom()
            local pos = player.Position
            for _=1, 5 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 300, itemPool:GetCard(rng:Next(), false, true, true), player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 5 Runes", spa = "Genera 5 Runas"},
    }
    ,{  Id = CollectibleType.COLLECTIBLE_BLANK_CARD,
        Fun = function(player, rng)
		    local room = game:GetRoom()
            local pos = player.Position
            for _=1, 5 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 300, itemPool:GetCard(rng:Next(), true, false, false), player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 5 Cards", spa = "Genera 5 Cartas"},
    }
    ,{  Id = CollectibleType.COLLECTIBLE_PLACEBO,
        Fun = function(player, rng)
		    local room = game:GetRoom()
            local pos = player.Position
            for _=1, 5 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 70, itemPool:GetPill(rng:Next()), player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 5 Pills", spa = "Genera 5 Pildoras"},
    }


    ,{  Id = CollectibleType.COLLECTIBLE_D10,
        Fun = function()
            local sav = saveHand("Consume - d10")
            sav:Set(sav:Get(0) +4)
        end,
        EID = {
            en_us = "For the next 4 hostile rooms:#Activate {{Collectible"..CollectibleType.COLLECTIBLE_D10.."}} D10",
            spa = "Por los siguientes 4 cuartos hostiles:#Activara {{Collectible"..CollectibleType.COLLECTIBLE_D10.."}} D10"
        }, NoActive = true
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SATANIC_BIBLE,
        Fun = function(player, rng)
            spawnBlackHeart(player, rng)
            pool = game:IsGreedMode() and ItemPoolType.POOL_GREED_DEVIL or ItemPoolType.POOL_DEVIL
            if Mod.PlayerTools.AnyPlayerHasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
                pool = -1
            end

            local item1 = Mod:SpawnItem(Mod:GetRandomCollectible(pool, true, rng:Next(), nil, true), game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), player)
            Mod:SetPickupNonEat(item1)
            item1.Price = -1
            item1.ShopItemId = -2
            item1.AutoUpdatePrice = true
        end,
        EID = {
            en_us = "Spawns a Black Heart and a item from the devil pool that cannot be consume#The item will be price",
            spa = "Genera un Corazón Negro y un objeto de la sala del diablo que no se puede consumir#El objeto tendra precio"
        }, NoActive = true
    }
    ,{ Id = CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS,
        Fun = function(player)
            local sav = playerSave("Consume - Head of Krampus", player)
            sav:Set(sav:Get(0) +4)
        end,
        EID = {
            en_us = "For the next 4 hostile rooms:#Activate {{Collectible"..CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS.."}} Head of Krampus",
            spa = "Por los siguientes 4 cuartos hostiles:#Activara {{Collectible"..CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS.."}} Cabeza de Krampus"
        }, NoActive = true
    }


    ,{  Id = CollectibleType.COLLECTIBLE_LIBRA,
        Fun = function(player, rng)
		    local room = game:GetRoom()
            local pos = player.Position
            for _=1, 3 do
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 30, 0, player, rng:Next())
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 40, 0, player, rng:Next())
            end
        end,
        EID = {en_us = "Spawns 3 coins, 3 keys and 3 bombs", spa = "Genera 3 monedas, 3 llaves y 3 bombas"},
        Stats ={ ForceDmg = 0.5, Tears = 0.12, Range = 1.5, ShotSpeed = 0.12}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_HOLY_MANTLE,
        Fun = function(player, rng)
            spawnEternalHeart(player, rng)
            spawnSoulHeart3(player, rng)
        end,
        EID = { en_us = "Spawns an Eternal Heart and 3 Soul Hearts", spa = "Genera un Corazón Eterno y 3 Corazones de Alma" }
    }

    ,{ Id = CollectibleType.COLLECTIBLE_NOTCHED_AXE, -- base on the suggestion of "Burguer king" on discord
        Fun = function(player, rng)
            playerSave("Consume - Notched Axe - Active", player):Set(true)
            Mod.HiddenItemManager:AddForFloor(player, CollectibleType.COLLECTIBLE_THUNDER_THIGHS, nil, 1, NOTCHED_AXE_INNATE_EFFECT)
            local sav = playerSave("Consume - Notched Axe", player)
            sav:Set(sav:Get(0) +2)
            game:AddPixelation(5 *30)
        end,
        EID = {
            en_us = "For this and the next 2 floors:#Isaac gains the ability to destroy obstacles by walking into them#It will pixelate the screen for 5 seconds",
            spa = "Por este y los siguientes 2 pisos:#Isaac gana la habilidad de destruir obtaculos al caminar ante ellos#Pixelara la pantalla por 5 segundos"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MIND,
        Fun = function(player, rng)
            local sav = saveHand("Consume - The Mind")
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "On the next 3 floors:#Reveals all the room and removes any visility curse",
            spa = "En los siguientes 3 pisos#Revela todos los cuartos y removera cualquier maldición de visibilidad"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BODY,
        Fun = function(player, rng)
            local sav = playerSave("Consume - The Body", player)
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "Grants 3 Red Hearts on a new floor if Isaac has at least a fully empty container#This can trigger up to 3 times",
            spa = "Da 3 Corazones Rojos al ir a un nuevo piso si Isaac tiene almenos un contenedor totalmente vacio#Esto puede activarse hasta 3 veces"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SOUL,
        Fun = function(player, rng)
            local sav = playerSave("Consume - The Soul", player)
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "Grants 3 Soul Hearts on a new floor#This can trigger up to 3 times",
            spa = "Da 3 Corazones de Alma al ir a un nuevo piso#Esto puede activarse hasta 3 veces"
        }
    }

    ,{  Id = CollectibleType.COLLECTIBLE_DIPLOPIA, -- suggestion from "Goi*umbrela emoji*di*umbrela emoji*" on discord
        Fun = function(player)
            Isaac.ExecuteCommand("addplayer " .. player:GetPlayerType() .. " " .. player.ControllerIndex)
            local copyPlayer = Isaac.GetPlayer(game:GetNumPlayers() -1)
            copyPlayer.Parent = player
            copyPlayer:AnimateAppear()
            game:GetHUD():AssignPlayerHUDs()

            for id, num in pairs(Mod.PlayerTools.GetPlayerItems(player)) do
                for _=1, num do
                    copyPlayer:AddCollectible(id, nil, false)
                end
            end

            copyPlayer:RemoveCollectible(copyPlayer:GetActiveItem(0))
            copyPlayer:RemoveCollectible(copyPlayer:GetActiveItem(1))
            copyPlayer:RemoveCollectible(copyPlayer:GetActiveItem(2))
            if REPENTOGON then -- just in case some mod changes the length of the appear animation
                local sp = copyPlayer:GetSprite()
                copyPlayer.ControlsCooldown = sp:GetAnimationData("Appear"):GetLength() *2
            else
                copyPlayer.ControlsCooldown = 40 *2
            end

            if CustomHealthAPI then
                local idx = CustomHealthAPI.Helper.GetPlayerIndex(player)
                local copyidx = CustomHealthAPI.Helper.GetPlayerIndex(copyPlayer)
                CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup[copyidx] = CustomHealthAPI.PersistentData.HiddenPlayerHealthBackup[idx]

                CustomHealthAPI.Helper.CheckHealthIsInitializedForPlayer(copyPlayer, false)
            else
                local health = {
                    MaxHearts = player:GetMaxHearts() /2,
                    Golden = player:GetGoldenHearts(),
                    Hearts = player:GetHearts(),
                    Rotten = player:GetRottenHearts(),
                    Broken = player:GetBrokenHearts(),
                    Eternal =player:GetEternalHearts(),
                    AddOrder = {},
                }

                local oddSoulHearts = player:GetSoulHearts() % 2 ==1
                local soulHeartsPassed = false
                for idx=0, math.ceil(player:GetSoulHearts()/2) + player:GetBoneHearts() -1 do
                    local tabIdx = #health.AddOrder
                    local last = health.AddOrder[tabIdx]
                    if player:IsBlackHeart(idx *2 +1) then
                        if not soulHeartsPassed and oddSoulHearts then
                            health.AddOrder[tabIdx +1] = {Type = "Black", Num = 1}
                        elseif tabIdx > 0 and health.AddOrder[tabIdx].Type == "Black" then
                            health.AddOrder[tabIdx].Num = health.AddOrder[tabIdx].Num +2
                        else
                            health.AddOrder[tabIdx +1] = {Type = "Black", Num = 2}
                        end
                        soulHeartsPassed = true
                    elseif player:IsBoneHeart(idx) then
                        if tabIdx > 0 and health.AddOrder[tabIdx].Type == "Bone" then
                            health.AddOrder[tabIdx].Num = health.AddOrder[tabIdx].Num +1
                        else
                            health.AddOrder[tabIdx +1] = {Type = "Bone", Num = 1}
                        end
                    else
                        if not soulHeartsPassed and oddSoulHearts then
                            health.AddOrder[tabIdx +1] = {Type = "Soul", Num = 1}
                        elseif tabIdx > 0 and health.AddOrder[tabIdx].Type == "Soul" then
                            health.AddOrder[tabIdx].Num = health.AddOrder[tabIdx].Num +2
                        else
                            health.AddOrder[tabIdx +1] = {Type = "Soul", Num = 2}
                        end
                        soulHeartsPassed = true
                    end
                end

                Mod.PlayerTools.ReplacePlayerHealth(copyPlayer, health)
            end
        end,
        EID = {
            en_us = "Duplicates Isaac",
            spa = "Diplica a Isaac"
        }, NoActive = true
    }

    ,{ Id = CollectibleType.COLLECTIBLE_RAZOR_BLADE,
        Fun = function(player)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)

            if player:GetHearts() - (player:GetRottenHearts() *2) >0 then player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT) end
        end,
        EID = {
            en_us = "Trigger twice all on-hit items#If Isaac has a red heart it will start bleeding",
            spa = "Activa 2 veces todos objetos que requieran recibir daño#Si Isaac tiene un corazón rojo empezara a desangrar"
        }, NoActive = true, Stats = {ForceDmg = 0.66}
    }
    ,{ Id = CollectibleType.COLLECTIBLE_SHARD_OF_GLASS, -- suggestion of "GamePule" on discord
        Fun = function(player)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)

            if player:GetHearts() - (player:GetRottenHearts() *2) >0 then player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT) end
        end,
        EID = {
            en_us = "Trigger twice all on-hit items#If Isaac has a red heart it will start bleeding",
            spa = "Activa 2 veces todos objetos que requieran recibir daño#Si Isaac tiene un corazón rojo empezara a desangrar"
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BROKEN_GLASS_CANNON,
        Fun = function(player)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)

            if player:GetHearts() - (player:GetRottenHearts() *2) >0 then player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT) end
        end,
        EID = {
            en_us = "Trigger twice all on-hit items#If Isaac has a red heart it will start bleeding",
            spa = "Activa 2 veces todos objetos que requieran recibir daño#Si Isaac tiene un corazón rojo empezara a desangrar"
        }, NoActive = true
    }

    ,{ Id = CollectibleType.COLLECTIBLE_KIDNEY_STONE,
        Fun = function(player)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, UseFlag.USE_NOANIM)

            if player:GetHearts() - (player:GetRottenHearts() *2) >0 then player:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT) end
        end,
        EID = {
            en_us = "Trigger twice all on-hit items#If Isaac has a red heart it will start bleeding",
            spa = "Activa 2 veces todos objetos que requieran recibir daño#Si Isaac tiene un corazón rojo empezara a desangrar"
        }, Stats = {Tears = 0.5}
    }


    ,{ Id = CollectibleType.COLLECTIBLE_WOODEN_NICKEL,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
            for _=1, 5 do
                if rng:RandomInt(2) == 0 then
                    spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 20, 0, player, rng:Next())
                end
            end
        end,
        EID = {
            en_us = "Spawns 1 to 6 pennies",
            spa = "Genera 1 a 6 monedas",
        }, NoActive = true
    }
    ,{ Id = CollectibleType.COLLECTIBLE_CRACK_JACKS,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, 0, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 350, 0, player, rng:Next())
        end,
        EID = {
            en_us = "Spawns a heart and a trinket",
            spa = "Genera un corazón y un trinket",
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS,
        Fun = function(player)
            local sav = playerSave("Consume - Box of Friends", player)
            sav:Set(sav:Get(0) +3)
        end,
        EID = {
            en_us = "Doubles Isaacs familiars for this and the next 3 floors",
            spa = "Duplica los familiares de Isaac por este y los siguientes 3 pisos",
        }
    }
    ,{ Id = CollectibleType.COLLECTIBLE_MR_DOLLY,
        Fun = function(player, rng)
            spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 10, 0, player, rng:Next())
        end,
        EID = {
            en_us = "Spawns a heart",
            spa = "Genera un corazón",
        }, Stats ={ Tears = 0.25, Range = 1.25 }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_FRIEND_BALL,
        Fun = function(player, rng)
            local ref = EntityRef(player)
            for _=1, 4 do
                local ent = Mod:Spawn(EntityType.ENTITY_GAPER, 0, 0, player.Position, nil, player, nil)
                ent:AddCharmed(ref, -1)
            end
        end,
        EID = {
            en_us = "Spawns 4 friendly Gapers",
            spa = "Genera 4 Gapers amistosos",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_ZODIAC,
        Fun = function(player, rng)
            local sav = playerSave("Consume - Zodiac", player)
            local zodiacs = sav:Get({})

            local items = {
                CollectibleType.COLLECTIBLE_TAURUS,
                CollectibleType.COLLECTIBLE_ARIES,
                CollectibleType.COLLECTIBLE_CANCER,
                CollectibleType.COLLECTIBLE_LEO,
                CollectibleType.COLLECTIBLE_VIRGO,
                CollectibleType.COLLECTIBLE_LIBRA,
                CollectibleType.COLLECTIBLE_SCORPIO,
                CollectibleType.COLLECTIBLE_SAGITTARIUS,
                CollectibleType.COLLECTIBLE_CAPRICORN,
                CollectibleType.COLLECTIBLE_AQUARIUS,
                CollectibleType.COLLECTIBLE_PISCES,
                CollectibleType.COLLECTIBLE_GEMINI,
            }

            local itemId = items[rng:RandomInt(#items)]
            local data = Mod:GetConsumeItemEffect(itemId)
            local cacheflags = CacheFlag.CACHE_DAMAGE
            local dmg = (itemConfig:GetCollectible(itemId).Quality+1) /4

            local permaStats = playerSave(SAVE_PERMA_STATS_NAME, player):Get({})
            if data and data.Stats then
                if data.Stats.ForceDmg then
                    dmg = data.Stats.ForceDmg
                elseif data.Stats.DmgOffset then
                    dmg = dmg + data.Stats.DmgOffset
                end
                if data.Stats.Tears then
                    permaStats.Tears = (permaStats.Tears or 0) + (data.Stats.Tears or 0)
                    cacheflags = cacheflags | CacheFlag.CACHE_FIREDELAY
                end
                if data.Stats.Speed then
                    permaStats.Speed = (permaStats.Speed or 0) + (data.Stats.Speed or 0)
                    cacheflags = cacheflags | CacheFlag.CACHE_SPEED
                end
                if data.Stats.Range then
                    permaStats.Range = (permaStats.Range or 0) + (data.Stats.Range or 0)
                    cacheflags = cacheflags | CacheFlag.CACHE_RANGE
                end
                if data.Stats.ShotSpeed then
                    permaStats.ShotSpeed = (permaStats.ShotSpeed or 0) + (data.Stats.ShotSpeed or 0)
                    cacheflags = cacheflags | CacheFlag.CACHE_SHOTSPEED
                end
                if data.Stats.Luck then
                    permaStats.Luck = (permaStats.Luck or 0) + (data.Stats.Luck or 0)
                    cacheflags = cacheflags | CacheFlag.CACHE_LUCK
                end
            end
            permaStats.Damage = (permaStats.Damage or 0) + (dmg or 0)

            playerSave(SAVE_PERMA_STATS_NAME, player):Set(permaStats)
            Mod.PlayerTools.DoCache(player, cacheflags)

            table.insert(zodiacs, itemId)

            sav:Set(zodiacs)
        end,
        EID = {
            en_us = "Grants the consume stats of a random zodiac#The stats change when going to a new floor",
            spa = "Da las estadisticas de consumir de un zodiaco#Estas estadisticas canbian al ir a un nuevo piso",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_PURITY,
        Fun = function(player, rng)
            local sav = playerSave("Consume - Purity", player)
            local statsTypes = sav:Get({})

            table.insert(statsTypes, -1)
            sav:Set(statsTypes)
        end,
        EID = {
            en_us = "Entering a hostile room will grant one of these:#{{ArrowUp}} {{Damage}} +2 Damage#{{ArrowUp}} {{Tears}} +1.25 Tears#{{ArrowUp}} {{Range}} +1.25 Range#{{ArrowUp}} {{Speed}} +0.2 Speed",
            spa = "Entrar a un cuarto hostil dará uno de estos:#{{ArrowUp}} {{Damage}} +2 Daño#{{ArrowUp}} {{Tears}} +1.25 Lágrimas#{{ArrowUp}} {{Range}} +1.25 Rango#{{ArrowUp}} {{Speed}} +0.2 Velocidad",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_CAMBION_CONCEPTION,
        Fun = function(player)
            player:UseCard(Card.CARD_SOUL_LILITH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            player:UseCard(Card.CARD_SOUL_LILITH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            player:UseCard(Card.CARD_SOUL_LILITH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end,
        EID = { en_us = "Permanently grants 3 random familiars", spa = "Añade de forma permanente 3 familiares aleatorios", }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_IMMACULATE_CONCEPTION,
        Fun = function(player)
            player:UseCard(Card.CARD_SOUL_LILITH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            player:UseCard(Card.CARD_SOUL_LILITH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            player:UseCard(Card.CARD_SOUL_LILITH, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end,
        EID = { en_us = "Permanently grants 3 random familiars", spa = "Añade de forma permanente 3 familiares aleatorios", }
    }

    ,{  Id = CollectibleType.COLLECTIBLE_DEEP_POCKETS,
        Fun = function(player)
            local sav = saveHand("Consume - Deep Pockets")
            sav:Set(sav:Get(0) + 2)
        end,
        EID = {
            en_us = "For this and the next 2 floors:#Spawns a coin upon clearing a room",
            spa = "Por este y los siguientes 2 pisos:#Genera una moneda al limpiar un cuarto",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_KIDNEY_BEAN,
        Fun = function(player)
            local sav = saveHand("Consume - Kidney Bean")
            sav:Set(sav:Get(0) + 10)
        end,
        EID = {
            en_us = "On the next 10 hostile rooms:#Charms all enemies for 5 seconds",
            spa = "En los siguientes 10 cuaros hortiles:#Encanta a todos los enemigos por 5 segundos",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS,
        Fun = function(player)
            local sav = playerSave("Consume - Glowing Hour Glass", player)
            sav:Set(sav:Get(0) + 3)
        end,
        EID = {
            en_us = "When Isaac is going to get hit, he uses {{Collectible"..CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS.."}} Glowing Hour Glass#This only happens up to 3 times",
            spa = "Cuando Isaac va a ser golpeado, él usará {{Collectible"..CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS.."}} Reloj de Arena brillante#Solo puede pasar hasta 3 veces",
        }
    }

    ,{  Id = CollectibleType.COLLECTIBLE_DEAD_TOOTH,
        Fun = function(player)
            local sav = playerSave("Consume - Dead Tooth", player)
            sav:Set(sav:Get(0) + 4)
        end,
        EID = {
            en_us = "When entering to a hostile room, poison 3 enemies#This only happens up to 4 times",
            spa = "Al entrar a un cuarto hostíl, envenenara 3 enemigos#Esto solo pará hastá 4 veces",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_CONTAGION,
        Fun = function(player, rng)
            local sav = playerSave("Consume - Dead Tooth", player)
            sav:Set(sav:Get(0) + 4)
            spawnBlackHeart(player, rng)
        end,
        EID = {
            en_us = "Spawn a Black Heart#When entering to a hostile room, poison 3 enemies#This only happens up to 4 times",
            spa = "Genera un Corazón Negro#Al entrar a un cuarto hostíl, envenenara 3 enemigos#Esto solo pará hastá 4 veces",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_TOXIC_SHOCK,
        Fun = function(player)
            local sav = playerSave("Consume - Dead Tooth", player)
            sav:Set(sav:Get(0) + 6)
            spawnBlackHeart(player, rng)
        end,
        EID = {
            en_us = "Spawn a Black Heart#When entering to a hostile room, poison 3 enemies#This only happens up to 6 times",
            spa = "Genera un Corazón Negro#Al entrar a un cuarto hostíl, envenenara 3 enemigos#Esto solo pará hastá 6 veces",
        }
    }

    ,{  Id = CollectibleType.COLLECTIBLE_POLYDACTYLY,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position

            for i=1, 3 do
                local var = 300
                if rng:RandomInt(2) == 0 then var = 70 end
                spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), var, 0, player, rng:Next())
            end
        end,
        EID = {
            en_us = "Spawns 3 card or pill",
            spa = "Genera 3 cartas o pildoras",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_BELLY_BUTTON,
        Fun = function(player, rng) spawnPickup(game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true), 350, 0, player, rng:Next()) end,
        EID = {
            en_us = "Spawns a Trinket",
            spa = "Genera un Trinket",
        }
    }
    ,{  Id = CollectibleType.COLLECTIBLE_GLYPH_OF_BALANCE,
        Fun = function(player, rng)
            local room = game:GetRoom()
            local pos = player.Position

            local redHearts = player:GetHearts()
            local heartContainters = player:GetEffectiveMaxHearts()
            local soulHearts = player:GetSoulHearts()
            local coins = player:GetNumCoins()
            local bombs = player:GetNumBombs()
            local keys = player:GetNumKeys()
            local playerType = player:GetPlayerType()
            local checkHearts = true
            if REPENTOGON then
                checkHearts = player:GetHealthType() == HealthType.RED or player:GetHealthType() == HealthType.BONE
            elseif playerType == PlayerType.PLAYER_BLUEBABY or playerType == PlayerType.PLAYER_BLUEBABY_B or
                playerType == PlayerType.PLAYER_BLACKJUDAS or playerType == PlayerType.PLAYER_JUDAS_B or
                playerType == PlayerType.PLAYER_THELOST or playerType == PlayerType.PLAYER_THELOST_B or
                playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B or
                playerType == PlayerType.PLAYER_BETHANY_B or playerType == PlayerType.PLAYER_JACOB2_B then
                    checkHearts = false
            end

            local var = 0
            local sub = 2 -- doesn't spawns collectibles

            if checkHearts and heartContainters <=0 and soulHearts < 4 then
                var = PickupVariant.PICKUP_HEART
                sub = HeartSubType.HEART_SOUL
            elseif checkHearts and redHearts == 1 then
                var = PickupVariant.PICKUP_HEART
                sub = HeartSubType.HEART_FULL
            elseif keys == 0 then
                var = PickupVariant.PICKUP_KEY
                sub = 0
            elseif bombs == 0 then
                var = PickupVariant.PICKUP_BOMB
                sub = 0
            elseif coins == 0 then
                var = PickupVariant.PICKUP_COIN
                sub = 0
            elseif (checkHearts and heartContainters - redHearts >= 1) or (playerType == PlayerType.PLAYER_BETHANY_B and player:GetBloodCharge() < 12) then
                var = PickupVariant.PICKUP_HEART
                sub = HeartSubType.HEART_FULL
            elseif coins < 15 then
                var = PickupVariant.PICKUP_COIN
                sub = 0
            elseif keys < 5 then
                var = PickupVariant.PICKUP_KEY
                sub = 0
            elseif bombs < 5 then
                var = PickupVariant.PICKUP_BOMB
                sub = 0
            elseif player:GetTrinket(0) == 0 and player:GetTrinket(1) == 0 and #Isaac.FindByType(5, 350) == 0 then
                var = PickupVariant.PICKUP_TRINKET
                sub = 0
            elseif (checkHearts and soulHearts < 12) or (playerType == PlayerType.PLAYER_BETHANY and player:GetSoulCharge() < 12) or (playerType == PlayerType.PLAYER_BETHANY_B and player:GetBloodCharge() < 12) then
                var = PickupVariant.PICKUP_HEART
                if playerType == PlayerType.PLAYER_BETHANY_B then
                    sub = HeartSubType.HEART_FULL
                else
                    sub = HeartSubType.HEART_SOUL
                end
            end

            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 10, HeartSubType.HEART_SOUL, player, rng:Next())
            spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), var, sub, player, rng:Next())
        end,
        EID = {
            en_us = "Spawns a Soul Heart and a pickup using Glyph of Balance conditions",
            spa = "Genera un Corazón de Alma y un recolectable usando la formula de Glifo del equilibrio",
        }
    }

    --CollectibleType.COLLECTIBLE_KING_BABY
    --CollectibleType.COLLECTIBLE_CHAOS
)




-- functions for effects

local dadsKeyTargetDoors = {
    [RoomType.ROOM_ARCADE] = true,
    [RoomType.ROOM_SHOP] = true,
    [RoomType.ROOM_TREASURE] = true,
    [RoomType.ROOM_PLANETARIUM] = true,
    [RoomType.ROOM_DICE] = true,
    [RoomType.ROOM_CHEST] = true,
    [RoomType.ROOM_SECRET_EXIT] = true,
}
local GENERIC_ROOM_RNG = RNG()
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, -100, function()
    local room = game:GetRoom()
    local level = game:GetLevel()
    local genericPlayer = Isaac.GetPlayer()

    local forgetMeNowSav = saveHand("Consume - Forget me now")
    if forgetMeNowSav:Get(0) > 0 then
        local levelRooms = level:GetRooms()
        
        local allclear = true
        for i = 0, levelRooms.Size -1 do
            local roomDesc = levelRooms:Get(i)
            if roomDesc.Data and roomDesc.Data.Type == RoomType.ROOM_DEFAULT then
                if not roomDesc.Clear and roomDesc.ClearCount <= 0 then allclear = false; break end
            end
        end
        
        if allclear then
            genericPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM)
            forgetMeNowSav:Set(forgetMeNowSav:Get(0)-1)
        end
    end

    local dadsKeySav = saveHand("Consume - Dads Key")
    if dadsKeySav:Get(0) > 0 then
        for i=0, DoorSlot.NUM_DOOR_SLOTS-1 do
            local doorGrid = room:GetDoor(i)

            if doorGrid and dadsKeyTargetDoors[doorGrid.TargetRoomType] then
                genericPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM)
                dadsKeySav:Set(dadsKeySav:Get(0)-1)
            end
        end
    end

    local goatHeadSav = saveHand("Consume - Goat Head")
    if goatHeadSav:Get(0) >0 then
        if room:GetType() == RoomType.ROOM_BOSS and room:IsCurrentRoomLastBoss() then
            local devilSpawn = false
            for i=0, DoorSlot.NUM_DOOR_SLOTS-1 do
                local doorGrid = room:GetDoor(i)

                if doorGrid and (doorGrid.TargetRoomType == RoomType.ROOM_DEVIL or doorGrid.TargetRoomType == RoomType.ROOM_ANGEL) then
                    devilSpawn = true
                    break
                end
            end
            if not devilSpawn then
                genericPlayer:UseCard(Card.CARD_JOKER, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                goatHeadSav:Set(goatHeadSav:Get(0)-1)
            end
        end
    end

    local deepPocketSav = saveHand("Consume - Deep Pockets")
    if deepPocketSav:Get(0) >0 then
        spawnPickup(room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0), 20, 1, nil, genericPlayer:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DEEP_POCKETS):Next())
    end
end)


local function forEachPlayer_room(player)
    local belialBookSav = playerSave("Consume - Book of Belial", player)
    if belialBookSav:Get(0)>0 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL, UseFlag.USE_NOANIM)
        belialBookSav:Set(belialBookSav:Get(0)-1)
    end

    local shadowBookSav = playerSave("Consume - Book of Shadows", player)
    if shadowBookSav:Get(0)>0 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, UseFlag.USE_NOANIM)
        shadowBookSav:Set(shadowBookSav:Get(0)-1)
    end

    local anarchistBookSav = playerSave("Consume - Anarchist Cookbook", player)
    if anarchistBookSav:Get(0)>0 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK, UseFlag.USE_NOANIM)
        anarchistBookSav:Set(anarchistBookSav:Get(0)-1)
    end

    local telepathyDummySav = playerSave("Consume - Telepathy for Dummies", player)
    if telepathyDummySav:Get(0)>0 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPATHY_BOOK, UseFlag.USE_NOANIM)
        telepathyDummySav:Set(telepathyDummySav:Get(0)-1)
    end

    local krampusHeadSav = playerSave("Consume - Head of Krampus", player)
    if krampusHeadSav:Get(0)>0 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_HEAD_OF_KRAMPUS, UseFlag.USE_NOANIM)
        krampusHeadSav:Set(krampusHeadSav:Get(0)-1)
    end

    local boxOfFriendsSav = playerSave("Consume - Box of Friends", player)
    if boxOfFriendsSav:Get(0) >0 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS, UseFlag.USE_NOANIM)
    end

    local puritySav = playerSave("Consume - Purity", player)
    if puritySav:Get(0) >0 then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PURITY)
        local statsTypes = puritySav:Get({})

        local permaStats = playerSave(SAVE_PERMA_STATS_NAME, player):Get({})
        for i=1, #statsTypes do
            local ogT = statsTypes[i]
            if ogT == 0 then
                permaStats.Damage = (permaStats.Damage or 0) - 2
            elseif ogT == 1 then
                permaStats.Tears = (permaStats.Tears or 0) - 1.25
            elseif ogT == 2 then
                permaStats.Speed = (permaStats.Speed or 0) - 0.2
            elseif ogT == 3 then
                permaStats.Range = (permaStats.Range or 0) - 2.5
            end

            local t = rng:RandomInt(4)
            if t == 0 then
                permaStats.Damage = (permaStats.Damage or 0) + 2
            elseif t == 1 then
                permaStats.Tears = (permaStats.Tears or 0) + 1.25
            elseif t == 2 then
                permaStats.Speed = (permaStats.Speed or 0) + 0.2
            elseif t == 3 then
                permaStats.Range = (permaStats.Range or 0) + 2.5
            end
            statsTypes[i] = t
        end

        playerSave(SAVE_PERMA_STATS_NAME, player):Set(permaStats)
        Mod.PlayerTools.DoCache(player, CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE)
        puritySav:Set(statsTypes)
    end
    
    local deadToothSav = playerSave("Consume - Dead Tooth", player)
    if deadToothSav:Get(0) > 0 then
        local ref = EntityRef(genericPlayer)
        local list = Mod.TableTools.Exclude(Isaac.GetRoomEntities(), function(ent)
            return ent:ToNPC() ~= nil and ent:GetEntityFlags() & (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN) == 0 and ent:CanShutDoors() and ent:IsActiveEnemy()
        end)
        for _, ent in ipairs(Mod.TableTools.Shuffle(list, GENERIC_ROOM_RNG)) do
            ent:AddPoison(ref, 63, player.Damage * 1.5)
        end
        deadToothSav:Set(deadToothSav:Get(0)-1)
    end
end


Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, -100, function()
    local room = game:GetRoom()
    local genericPlayer = Isaac.GetPlayer()
    GENERIC_ROOM_RNG:SetSeed(room:GetDecorationSeed(), 24)

    if room:IsClear() then
        local dadsKeySav = saveHand("Consume - Dads Key")
        if dadsKeySav:Get(0) > 0 then
            for i=0, DoorSlot.NUM_DOOR_SLOTS-1 do
                local doorGrid = room:GetDoor(i)

                if doorGrid and dadsKeyTargetDoors[doorGrid.TargetRoomType] then
                    genericPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM)
                    dadsKeySav:Set(dadsKeySav:Get(0)-1)
                end
            end
        end
    else

        Mod.PlayerTools.ForEach(forEachPlayer_room)

        local d10Sav = saveHand("Consume - d10")
        if d10Sav:Get(0) > 0 then
            genericPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_D10, UseFlag.USE_NOANIM)
            d10Sav:Set(d10Sav:Get(0)-1)
        end

        local kidneyBeanSav = saveHand("Consume - Kidney Bean")
        if kidneyBeanSav:Get(0) > 0 then
            local ref = EntityRef(genericPlayer)
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if ent:ToNPC() ~= nil and ent:GetEntityFlags() & (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN) == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then
                    ent:AddCharmed(ref, 5 *30)
                end
            end
            kidneyBeanSav:Set(kidneyBeanSav:Get(0)-1)
        end

    end
end)


local NOTCHED_AXE_INNATE_EFFECT = "Consume Effect - NOTCHED AXE"
local configThunderThighs = itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_THUNDER_THIGHS)
local function forEachPlayer_level(player)
    local notchedAxeSav = playerSave("Consume - Notched Axe", player)
    if notchedAxeSav:Get(0)>0 then
        Mod.HiddenItemManager:AddForFloor(player, CollectibleType.COLLECTIBLE_THUNDER_THIGHS, -1, 1, NOTCHED_AXE_INNATE_EFFECT)
        notchedAxeSav:Set(notchedAxeSav:Get(0)-1)
        playerSave("Consume - Notched Axe - Active", player):Set(true)
        game:AddPixelation(5 *30)
    else
        playerSave("Consume - Notched Axe - Active", player):Set(false)
    end
    
    local bodySav = playerSave("Consume - The Body", player)
    if bodySav:Get(0)>0 then
        if player:GetEffectiveMaxHearts() - player:GetHearts() >= 2 then
            player:AddHearts(6)
            bodySav:Set(bodySav:Get(0)-1)
        end
    end
    
    local soulSav = playerSave("Consume - The Soul", player)
    if soulSav:Get(0)>0 then
        if player:CanPickSoulHearts() then
            player:AddSoulHearts(6)
            soulSav:Set(soulSav:Get(0)-1)
        end
    end

    local boxOfFriendsSav = playerSave("Consume - Box of Friends", player)
    if boxOfFriendsSav:Get(0) >0 then
        boxOfFriendsSav:Set(boxOfFriendsSav:Get(0) -1)
    end

    local zodiacSav = playerSave("Consume - Zodiac", player)
    if zodiacSav:Get() then
        local items = {
            CollectibleType.COLLECTIBLE_TAURUS,
            CollectibleType.COLLECTIBLE_ARIES,
            CollectibleType.COLLECTIBLE_CANCER,
            CollectibleType.COLLECTIBLE_LEO,
            CollectibleType.COLLECTIBLE_VIRGO,
            CollectibleType.COLLECTIBLE_LIBRA,
            CollectibleType.COLLECTIBLE_SCORPIO,
            CollectibleType.COLLECTIBLE_SAGITTARIUS,
            CollectibleType.COLLECTIBLE_CAPRICORN,
            CollectibleType.COLLECTIBLE_AQUARIUS,
            CollectibleType.COLLECTIBLE_PISCES,
            CollectibleType.COLLECTIBLE_GEMINI,
        }
        local zodiacs = zodiacSav:Get()
        local permaStats = playerSave(SAVE_PERMA_STATS_NAME, player):Get({})

        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ZODIAC)

        for i=1, #zodiacs do
            local prevItemId = zodiacs[i]
            local prevData = Mod:GetConsumeItemEffect(prevItemId)
            local prevDmg = (itemConfig:GetCollectible(prevItemId).Quality+1) /4

            local itemId = items[rng:RandomInt(#items)]
            local data = Mod:GetConsumeItemEffect(itemId)
            local dmg = (itemConfig:GetCollectible(itemId).Quality+1) /4

            if prevData.Stats.ForceDmg then
                prevDmg = prevData.Stats.ForceDmg
            elseif prevData.Stats.DmgOffset then
                prevDmg = prevDmg + prevData.Stats.DmgOffset
            end
            if prevDmg.Stats.Tears then
                permaStats.Tears = (permaStats.Tears or 0) + (prevDmg.Stats.Tears or 0)
            end
            if prevDmg.Stats.Speed then
                permaStats.Speed = (permaStats.Speed or 0) + (prevDmg.Stats.Speed or 0)
            end
            if prevDmg.Stats.Range then
                permaStats.Range = (permaStats.Range or 0) + (prevDmg.Stats.Range or 0)
            end
            if prevDmg.Stats.ShotSpeed then
                permaStats.ShotSpeed = (permaStats.ShotSpeed or 0) + (prevDmg.Stats.ShotSpeed or 0)
            end
            if prevDmg.Stats.Luck then
                permaStats.Luck = (permaStats.Luck or 0) + (prevDmg.Stats.Luck or 0)
            end

            if data and data.Stats then
                if data.Stats.ForceDmg then
                    dmg = data.Stats.ForceDmg
                elseif data.Stats.DmgOffset then
                    dmg = dmg + data.Stats.DmgOffset
                end
                if data.Stats.Tears then
                    permaStats.Tears = (permaStats.Tears or 0) + (data.Stats.Tears or 0)
                end
                if data.Stats.Speed then
                    permaStats.Speed = (permaStats.Speed or 0) + (data.Stats.Speed or 0)
                end
                if data.Stats.Range then
                    permaStats.Range = (permaStats.Range or 0) + (data.Stats.Range or 0)
                end
                if data.Stats.ShotSpeed then
                    permaStats.ShotSpeed = (permaStats.ShotSpeed or 0) + (data.Stats.ShotSpeed or 0)
                end
                if data.Stats.Luck then
                    permaStats.Luck = (permaStats.Luck or 0) + (data.Stats.Luck or 0)
                end
            end
            permaStats.Damage = (permaStats.Damage or 0) + (dmg or 0) - prevDmg
            zodiacs[i] = itemId
        end
        playerSave(SAVE_PERMA_STATS_NAME, player):Set(permaStats)
        Mod.PlayerTools.DoCache(player)

        zodiacSav:Set(zodiacs)
    end
end

local levelRNG = RNG()
Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -100, function()
    local level = game:GetLevel()
    local room = level:GetCurrentRoom()
    local genericPlayer = Isaac.GetPlayer()
    local pos = room:GetCenterPos()
    levelRNG:SetSeed(room:GetAwardSeed(), 30)

    Mod.PlayerTools.ForEach(forEachPlayer_level)


    local midasTouchSav = saveHand("Consume - Midas Touch")
    if midasTouchSav:Get(0) >0 then
        spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 30, 2, nil, levelRNG:Next())
        spawnPickup(room:FindFreePickupSpawnPosition(pos, 40, true), 40, 4, nil, levelRNG:Next())
        midasTouchSav:Set(midasTouchSav:Get(0)-1)
    end

    local bookOfSecretsSav = saveHand("Consume - Book of Secrets")
    if bookOfSecretsSav:Get(0) >0 then
        genericPlayer:UseCard(Card.CARD_WORLD, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        bookOfSecretsSav:Set(bookOfSecretsSav:Get(0)-1)
    end

    local goatHeadSav = saveHand("Consume - Goat Head")
    if goatHeadSav:Get(0) >0 and not level:CanSpawnDevilRoom() then
        for _=1, goatHeadSav:Get(0) do
            Mod:Spawn(5, 10, 6, room:FindFreePickupSpawnPosition(pos, 40, true), nil, nil, levelRNG:Next() )
        end
        goatHeadSav:Set(0)
    end

    local mindSav = saveHand("Consume - The Mind")
    if mindSav:Get(0) >0 then
        level:RemoveCurses(LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_THE_LOST | LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_BLIND)
        level:ApplyBlueMapEffect()
        level:ApplyCompassEffect(true)
        level:ApplyMapEffect()
        mindSav:Set(mindSav:Get(0)-1)
    end

    local deepPocketSav = saveHand("Consume - Deep Pockets")
    if deepPocketSav:Get(0) >0 then deepPocketSav:Set(deepPocketSav:Get(0)-1) end
end) 


Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    if playerSave("Consume - Notched Axe - Active", player):Get() and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THUNDER_THIGHS) <= 1 then player:RemoveCostume(configThunderThighs) end
end)


Mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 400, function(_, ent, _, dmgFlags)
    if dmgFlags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES) >0 then return end
    local player = ent:ToPlayer()
    if player == nil then return end
    local glowingHouGlassSav = playerSave("Consume - Glowing Hour Glass", player)
    if glowingHouGlassSav:Get(0) >0 then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
        glowingHouGlassSav:Set(glowingHouGlassSav:Get(0)-1)
        return false
    end
end)