if not MinimapAPI then return end
local Mod = GelloCharMod

local config = Isaac.GetItemConfig()
local icons = Sprite()
icons:Load("gfx/ui_gello/minimapapi/icons.anm2", true)

MinimapAPI:AddIcon("SacrificialDaggerCard", icons, "cards", 0)
MinimapAPI:AddIcon("SoulGello",             icons, "cards", 1)
MinimapAPI:AddIcon("SlotMissingPost",       icons, "slots", 0)
MinimapAPI:AddIcon("SlotMissingPostBeggar", icons, "slots", 1)

MinimapAPI:AddPickup("SacrificialDaggerCard", "SacrificialDaggerCard",
   EntityType.ENTITY_PICKUP,
   PickupVariant.PICKUP_TAROTCARD,
   -1,
   MinimapAPI.PickupNotCollected,
   "cards",
   9001,
  function(p) return Isaac.GetChallenge() ~= Challenge.CHALLENGE_CANTRIPPED and config:GetCard(p.SubType).PickupSubtype == 3500 end)

MinimapAPI:AddPickup("SoulGello", "SoulGello", 
    EntityType.ENTITY_PICKUP,
    PickupVariant.PICKUP_TAROTCARD,
    Mod.Enum.Card.SOUL_OF_GELLO,
    MinimapAPI.PickupNotCollected,
    "runes",
    10050)


MinimapAPI:AddPickup("SlotMissingPost", "SlotMissingPost", 
    6,
    Mod.Enum.Slot.MISSING_POSTER,
    0,
    function(s) return true end,
    "slots",
    1100)

MinimapAPI:AddPickup("SlotMissingPostBeggar", "SlotMissingPostBeggar", 
    6,
    Mod.Enum.Slot.MISSING_POSTER,
    1,
    function(s)
        local sp = s:GetSprite()
        return not (sp:IsPlaying("Payout") or sp:IsFinished("Payout"))
    end,
    "beggars",
    2500)