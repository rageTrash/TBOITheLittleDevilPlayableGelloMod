local Mod = GelloCharMod
local game = Mod.Game
local tTools = Mod.TableTools

Mod.AddModPath("FiendFolio", function()
    local modItem = Mod.Enum.Item
    local ffItem = FiendFolio.ITEM.COLLECTIBLE
    local ffRock = FiendFolio.ITEM.ROCK
    local ffPickup = FiendFolio.PICKUP
    local ffCard = FiendFolio.ITEM.CARD

    FiendFolio.RockTrinkets[Mod.Enum.Trinket.STRANGE_STONE] = 1 --rare
    FiendFolio:AddStackableItems({
        modItem.BEELZEBUB,
        modItem.USE_PLACENTA, -- it just stacks the hp up(?)
        modItem.CURSED_PLUSHIE,
        modItem.LARRY_JR_JR,
        modItem.LIL_BITER,
        modItem.LIL_COW,
    })

    --ffItem.CORN_KERNEL
    --ffItem.OPHIUCHUS
    --ffItem.DEIMOS
    --ffItem.LIL_MINX
    --ffItem.SIBLING_SYL
    --ffItem.FAMILIAR_FLY
    --ffItem.WIMPY_BRO
    --ffItem.D3
    --ffItem.HORNCOB
    --ffItem.BABY_CRATER
    --ffItem.RANDY_THE_SNAIL
    --ffItem.GRABBER
    --ffItem.PEACH_CREEP
    --[[
    Mod:AddFamiliarToBlackList({
        ffItem.PET_ROCK,
        ffItem.PET_PEEVE,
        ffItem.GORGON,
        ffItem.CLUTCHS_CURSE,
    })]]
    
    local diceChance = { {ffCard.GLASS_D6, Weight = 5}, {ffCard.GLASS_D4, Weight = 3}, {ffCard.GLASS_D8, Weight = 4}, {ffCard.GLASS_D100, Weight =1}, {ffCard.GLASS_D10, Weight = 4}, {ffCard.GLASS_D20, Weight = 6}, {ffCard.GLASS_D12, Weight = 4}, {ffCard.GLASS_SPINDOWN, Weight = 1}, {ffCard.GLASS_AZURITE_SPINDOWN, Weight = 2}, {ffCard.GLASS_D2, Weight = 3} }
    Mod:AddConsumeItemEffect(
        { Id = ffItem.LIL_FIEND,
            Fun = function(player, rng)
                local room = game:GetRoom()
                for _=1, 3 do
                    Mod:Spawn(5, ffPickup.VARIANT.IMMORAL_HEART, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player, rng:Next())
                end
            end,
            EID = { en_us = "Spawns 3 Immoral Hearts", spa = "Genera 3 Corazones Imorales" }
        }
        ,{ Id = ffItem.DICE_BAG,
            Fun = function(player, rng)
                local room = game:GetRoom()
                for _=1, 2 do
                    Mod:Spawn(5, 300, tTools.GetRandomContent(diceChance, rng), room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player)
                end
            end,
            EID = { en_us = "Spawns 2 Glass Dices", spa = "Genera 2 Dados de Vidrio" }
        }
        ,{ Id = ffItem.SACK_OF_SPICY,
            Fun = function(player, rng)
                local room = game:GetRoom()
                for _=1, 3 do
                    Mod:Spawn(5, 30, ffPickup.KEY.SPICY_PERM, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player)
                end
            end,
            EID = { en_us = "Spawns 3 Spicy Keys", spa = "Genera 3 Llaves Picantes" }
        }
        ,{ Id = ffItem.TOKEN_BAG,
            Fun = function(player, rng)
                local room = game:GetRoom()
                for _=1, 2 do
                    Mod:Spawn(5, ffPickup.VARIANT.TOKEN, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player)
                end
            end,
            EID = { en_us = "Spawns 2 Tokens", spa = "Genera 2 Tokens" }
        }
        ,{ Id = ffItem.ROBOBABY3,
            Fun = function(player, rng)
                local room = game:GetRoom()
                Mod:Spawn(5, 90, 1, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player)
            end,
            EID = { en_us = "Spawns a Battery", spa = "Genera una Bateria" }
        }
        ,{ Id = ffItem.BAG_OF_BOBBIES,
            Fun = function(player, rng)
                for _=1, 3 do
                    local bobby = Isaac.Spawn(3, FiendFolio.ITEM.FAMILIAR.FRAGILE_BOBBY, 0, player.Position, Vector.Zero, player)
                    bobby:Update()
                end
            end,
            EID = { en_us = "Spawns 3 Fragile Bobbies", spa = "Genera 3 Bobbies Fragiles" }
        }
        ,{ Id = ffItem.GREG_THE_EGG,
            Fun = function(player, rng)-- yes, this is copy pasted
                local babyChoice = game:GetItemPool():GetCollectible(ItemPoolType.POOL_BABY_SHOP, true, rng:GetSeed() )

                if not FiendFolio.ACHIEVEMENT.DEVILLED_EGG:IsUnlocked(true) and FiendFolio.CanRunUnlockAchievements() then
                    FiendFolio.ACHIEVEMENT.DEVILLED_EGG:Unlock()
                    babyChoice = CollectibleType.COLLECTIBLE_DEVILLED_EGG
                end

                local pick = Mod:Spawn(5, 100, babyChoice, fam.Position, Vector.Zero)
                pick:GetSprite():ReplaceSpritesheet(5, "gfx/familiar/greg/yolk_pedestal.png")
                pick:GetSprite():LoadGraphics()
                pick:Update()
                pick:Update()
                pick:Update()
            end,
            EID = { en_us = "Spawns an item from the Baby Pool", spa = "Genera un objeto de la Baby Pool" }
        }
        ,{ Id = ffItem.LIL_LAMB, Stats = {DmgOffset = 0.5} }
    )
    


    table.insert(FiendFolio.RandomSouls, Mod.Enum.Card.SOUL_OF_GELLO)
    table.insert(FiendFolio.PocketObjectWeights, { Mod.Enum.Card.SACRIFICIAL_DAGGER, 1 })
    FiendFolio.PocketObjectMimicCharges[ Mod.Enum.Card.SACRIFICIAL_DAGGER ] = 5
    
end)