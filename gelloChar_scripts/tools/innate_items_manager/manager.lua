local InnateItems = {}
GelloCharMod.InnateItems = InnateItems

if not (REPENTOGON and REPENTANCE_PLUS) then
    local HiddenItemManager = GelloCharMod.Include("tools.innate_items_manager.hidden_item_manager")
    HiddenItemManager:Init(GelloCharMod)

    Add
    AddForRoom
    AddForFloor
    CheckStack
    Remove
    RemoveStack
    RemoveAll
    Has
    CountStack
    GetStacks
else
    :SetInnateCollectibleCount(Collectible, NewCount, GroupKey, AddCostume)
    :SetInnateCollectibleGroup(GroupKey, NewCounts, AddCostume)

    :RemoveInnateCollectible(Collectible, Amount, GroupKey)
    
    :GetInnateCollectibleCount(Collectible, GroupKey)
    :GetInnateCollectibleGroup(GroupKey)
    function InnateItems:AddItem(player, itemID, amount, group, dur, addCostume)
        player:AddInnateCollectible(itemID, amount, group, dur, addCostume)
    end
end