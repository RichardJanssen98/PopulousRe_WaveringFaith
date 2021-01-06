import(Module_System)
import(Module_Players)
import(Module_Defines)
import(Module_PopScript)
import(Module_Game)
import(Module_Objects)
import(Module_Map)
import(Module_Person)
include("UtilPThings.lua")
include("UtilRefs.lua")

AIDefend = {tribe = 0, shamanDefaultDefX = 0, shamanDefaultDefZ = 0, defendTickCooldown = 0, defendersFractionOfAllUnits = 0}
AIDefend.__index = AIDefend

function AIDefend:new (o, tribe, shamanDefaultDefX, shamanDefaultDefZ, defendTickCooldown, defendersFractionOfAllUnits)
    local o = o or {}
    setmetatable(o, AIDefend)
    o.tribe = tribe
    o.shamanDefaultDefX = shamanDefaultDefX
    o.shamanDefaultDefZ = shamanDefaultDefZ
    o.defendTickCooldown = defendTickCooldown
    o.defendersFractionOfAllUnits = defendersFractionOfAllUnits

    o.defended = 0
    o.defendTick = 0
    o.autoHouseAfterDefendTimer = 0
    return o
end

--Handle each AIs defences
function AIDefend:defendBase(enemyTribe, defendMarkerX, defendMarkerZ, marker, radius)
    local enemyCount = self:countEnemyPeopleInArea(enemyTribe, defendMarkerX, defendMarkerZ, radius)
    local myCount = self:countMyPeopleInArea(defendMarkerX, defendMarkerZ, radius)

    --If there are enemies spotted around a marker check if you already have units there, if you have enough units then move Shaman only (otherwise she runs back to her tower) otherwise move Shaman and a force
    if (enemyCount > 0) then
        if (self.defended == 0 and myCount > 12) then
            self:sendDefendShaman(marker, defendMarkerX, defendMarkerZ)
            self.defended = 1
            self.defendTick = GetTurn() + self.defendTickCooldown
        elseif (self.defended == 0 and myCount < 12) then
            self:sendDefendShaman(marker, defendMarkerX, defendMarkerZ)
            self:sendDefendForce(enemyTribe, defendMarkerX, defendMarkerZ, marker)
            self.defended = 1
            self.defendTick = GetTurn() + self.defendTickCooldown
        end
    end
end

--Count enemy followers in area around location inside a radius (preferably around marker to combine with defences)
function AIDefend:countEnemyPeopleInArea(enemyTribe, defendMarkerX, defendMarkerZ, radius)
    local count = 0
    markerPos = MAP_XZ_2_WORLD_XYZ(defendMarkerX, defendMarkerZ)
    
    SearchMapCells(CIRCULAR, 0, 0, radius, world_coord3d_to_map_idx(markerPos), function(me)
        me.MapWhoList:processList(function (t)
            if (t.Type == T_PERSON) then
                if (t.Owner == enemyTribe and t.State ~= S_PERSON_BEING_PREACHED and is_person_a_spy_disguised_as_me(t, self.tribe) == 0 ) then
                    count = count+1
                end
            end
        return true
        end)
    return true
    end)
    return count
end

--Count my followers in area around location inside a radius (preferably around marker to combine with defences)
function AIDefend:countMyPeopleInArea(defendMarkerX, defendMarkerZ, radius)
    local count = 0
    markerPos = MAP_XZ_2_WORLD_XYZ(defendMarkerX, defendMarkerZ)

    SearchMapCells(CIRCULAR, 0, 0, radius, world_coord3d_to_map_idx(markerPos), function(me)
        me.MapWhoList:processList(function (t)
            if (t.Type == T_PERSON) then
                if (t.Owner == self.tribe) then
                    count = count+1
                end
            end
        return true
        end)
    return true
    end)
    return count
end

--Send Shaman to defend alone, attributes are changed here too since the Shaman always goes first
function AIDefend:sendDefendShaman(marker, defendMarkerX, defendMarkerZ)
    WRITE_CP_ATTRIB(self.tribe, ATTR_AWAY_MEDICINE_MAN, 0)
    WRITE_CP_ATTRIB(self.tribe, ATTR_AWAY_RELIGIOUS, 0)
    WRITE_CP_ATTRIB(self.tribe, ATTR_DONT_GROUP_AT_DT, 1)
    WRITE_CP_ATTRIB(self.tribe, ATTR_GROUP_OPTION, 2)
    WRITE_CP_ATTRIB(self.tribe, ATTR_BASE_UNDER_ATTACK_RETREAT, 0)
    WRITE_CP_ATTRIB(self.tribe, ATTR_FIGHT_STOP_DISTANCE, 16)

    MOVE_SHAMAN_TO_MARKER(self.tribe, marker)
    SHAMAN_DEFEND(self.tribe, defendMarkerX, defendMarkerZ, TRUE)
end

--Send defence force
function AIDefend:sendDefendForce(enemyTribe, defendMarkerX, defendMarkerZ, marker)
    local defendAmount = _gsi.Players[self.tribe].NumPeople//self.defendersFractionOfAllUnits
    ATTACK(self.tribe, enemyTribe, defendAmount, ATTACK_MARKER, marker, 900, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, -1)
end

function AIDefend:resetDefend()
    if (GetTurn() == self.defendTick and self.defended == 1) then
        self.defended = 0
        SHAMAN_DEFEND(self.tribe, self.shamanDefaultDefX, self.shamanDefaultDefZ, TRUE)
        WRITE_CP_ATTRIB(self.tribe, ATTR_DONT_GROUP_AT_DT, 0)
        WRITE_CP_ATTRIB(self.tribe, ATTR_GROUP_OPTION, 0)
        WRITE_CP_ATTRIB(self.tribe, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
        WRITE_CP_ATTRIB(self.tribe, ATTR_FIGHT_STOP_DISTANCE, 26)
        WRITE_CP_ATTRIB(self.tribe, ATTR_AWAY_MEDICINE_MAN, 100)
        self.autoHouseAfterDefendTimer = GetTurn() + 360
    end
end

function AIDefend:checkToResetAutoHouseAfterDefendTimer()
    if (GetTurn() < self.autoHouseAfterDefendTimer) then
        SET_AUTO_HOUSE(self.tribe, TRUE)
    else
        SET_AUTO_HOUSE(self.tribe, FALSE)
    end
end