import(Module_System)
import(Module_Players)
import(Module_Defines)
import(Module_PopScript)
import(Module_Game)
import(Module_Objects)
import(Module_Map)
import(Module_Person)
import(Module_Commands)
include("UtilPThings.lua")
include("UtilRefs.lua")
include("DrumTower.lua")
include("Tile.lua")

AIDefending = {tribe = 0, allies = 0, shamanDefaultDefX = 0, shamanDefaultDefZ = 0, defendTickCooldown = 0, shouldCounterShaman = 0, shouldCounterBraves = 0, shouldCounterWarriors = 0, shouldCounterFws = 0, shouldCounterPreachers = 0, shouldCounterSpies = 0}
AIDefending.__index = AIDefending

function AIDefending:new (o, tribe, allies, shamanDefaultDefX, shamanDefaultDefZ, defendTickCooldown, shouldCounterShaman, shouldCounterBraves, shouldCounterWarriors, shouldCounterFws, shouldCounterPreachers, shouldCounterSpies)
    local o = o or {}
    setmetatable(o, AIDefending)
    o.tribe = tribe
    o.allies = allies
    o.shamanDefaultDefX = shamanDefaultDefX
    o.shamanDefaultDefZ = shamanDefaultDefZ
    o.defendTickCooldown = defendTickCooldown

    o.counterWarriorsTick = 0
    o.counterShamanTick = 0
    o.counterPreachersTick = 0
    o.resetShaman = false
    o.shamanCounterWithBravesAndFwTick = 0
    o.counterFwsTick = 0
    o.counterBravesTick = 0
    o.counterSpiesTick = 0

    o.shouldCounterShaman = shouldCounterShaman
    o.shouldCounterBraves = shouldCounterBraves
    o.shouldCounterWarriors = shouldCounterWarriors
    o.shouldCounterFws = shouldCounterFws
    o.shouldCounterPreachers = shouldCounterPreachers
    o.shouldCounterSpies = shouldCounterSpies

    o.drumTowers = {}
    o.tiles = {}
    o.atLandBridgePos = 0
    o.movingTowardsRepair = 0
    o.movingTowardsRepairTick = 0

    return o
end

function tableLength(Table)
    local count = 0
    for _ in pairs(Table) do count = count + 1 end
    return count
end

function AIDefending:setupTiles(defendMarkerX, defendMarkerZ, radius)
    local c2d = Coord2D.new()
    map_xz_to_world_coord2d(defendMarkerX, defendMarkerZ, c2d)

    SearchMapCells(CIRCULAR, 0, 0, radius, world_coord2d_to_map_idx(c2d), function(me)
        local tileC2d = Coord2D.new()
        map_ptr_to_world_coord2d(me, tileC2d)
        local altitude = point_altitude(tileC2d.Xpos, tileC2d.Zpos)

        local tile = Tile:new(nil, self.tribe, tileC2d, altitude)
        table.insert(self.tiles, tile)
    return true
    end)
end

function AIDefending:repairDamagedTiles() 
    local result = {}

    if (MANA(self.tribe) > SPELL_COST(M_SPELL_LAND_BRIDGE)) then
        local currentAltitude = ""
        local damageTypeToRepair = ""
        local damagedTiles = {}

    for _, tile in pairs(self.tiles) do
        currentAltitude = tile:tileAltitudeChange()
        
        --Set damageTypeToRepair to first damage found so AI can focus on one at a time
        if (damageTypeToRepair == "" and currentAltitude ~= "nothing") then
            damageTypeToRepair = currentAltitude
        end
        --If damageTypeToRepair isn't empty then start adding the tiles with the same currentAltitude into the array
        if (damageTypeToRepair ~= "") then
            if (damageTypeToRepair == currentAltitude) then
                table.insert(damagedTiles, tile)
            end
        end
    end

    --Start looking for a way to fix the land that turned into water
    if (damageTypeToRepair == "water" and self.movingTowardsRepair == 0) then
        local distanceBetweenPoints = 0
        local firstPoint = 0
        local secondPoint = 0

        log("Look for way to repair water")
        for _, tile in pairs(damagedTiles) do
            local tempC2D = Coord2D.new()
            local firstPointC3d = Coord3D.new()
            local secondPointC3d = Coord3D.new()
            local tempSecondPointC3d = Coord3D.new()
            
            SearchMapCells(CIRCULAR, 0, 0, 1, world_coord2d_to_map_idx(tile.c2d), function(me)
                if (is_map_elem_land_or_coast(me) > 0) then
                    if (firstPoint == 0) then
                        firstPoint = me
                        map_ptr_to_world_coord2d(me, tempC2D)
                        log("foundFirstPoint")
                        coord2D_to_coord3D(tempC2D, firstPointC3d)
                        result[1] = firstPointC3d
                    else
                        if (secondPoint == 0) then
                            map_ptr_to_world_coord2d(me, tempC2D)
                            log("foundSecondPoint")
                            coord2D_to_coord3D(tempC2D, secondPointC3d)
                            distanceBetweenPoints = get_world_dist_xyz(firstPointC3d, secondPointC3d)

                            if (distanceBetweenPoints < 5600) then
                                result[2] = secondPointC3d
                                secondPoint = me
                            end
                        else
                            local distanceBetweenNewPoints = 0
                            map_ptr_to_world_coord2d(me, tempC2D)
                            coord2D_to_coord3D(tempC2D, tempSecondPointC3d)
                            distanceBetweenNewPoints = get_world_dist_xyz(firstPointC3d, tempSecondPointC3d)
                            if (distanceBetweenPoints < distanceBetweenNewPoints) then
                                coord2D_to_coord3D(tempC2D, secondPointC3d)
                                distanceBetweenPoints = get_world_dist_xyz(firstPointC3d, secondPointC3d)

                                if (distanceBetweenNewPoints < 5600) then
                                    result[2] = secondPointC3d
                                    secondPoint = me
                                end
                            end
                        end
                    end
                end
                return true
            end)
        end
    end
    end
    return result
end

function AIDefending:repairBetweenPoints(point1, point2) 
    local shaman = getShaman(self.tribe)

    if (shaman ~= nil and self.movingTowardsRepair == 0 and point1 ~= 0 and point2 ~= 0) then
        local c2d = Coord2D.new()
        coord3D_to_coord2D(point1, c2d)
        command_person_go_to_coord2d(shaman, c2d)
        self.movingTowardsRepair = 1
        self.movingTowardsRepairTick = 240
        log("Moving Towards Point")
        return 0
    end

    if (shaman ~= nil) then
        if (get_world_dist_xyz(shaman.Pos.D3, point1) < 520) then
        log("Standing on point")
        createThing(T_SPELL, M_SPELL_LAND_BRIDGE, shaman.Owner, point2, false, false)

        local manaCostLandBridge = SPELL_COST(M_SPELL_LAND_BRIDGE)
        GIVE_MANA_TO_PLAYER(self.tribe, manaCostLandBridge * -1)
        self.movingTowardsRepair = 0
        return 1
        end
    end
end

function AIDefending:defendMarkerLocation(defendMarkerX, defendMarkerZ, marker, radius, repairTiles)
    if (GetTurn() == 36 and GetTurn() < 64 and repairTiles == 1) then
        self:setupTiles(defendMarkerX, defendMarkerZ, radius)
    end

    if (self.shouldCounterShaman == 1) then
        self:counterShaman(defendMarkerX, defendMarkerZ, marker, radius)
    end
    if (self.shouldCounterPreachers == 1 and self.counterPreachersTick == 0) then
        self:counterPreachers(defendMarkerX, defendMarkerZ, marker, radius)
    end
    if (self.shouldCounterWarriors == 1 and self.counterWarriorsTick == 0) then
        self:counterWarriors(defendMarkerX, defendMarkerZ, marker, radius)
    end
    if (self.shouldCounterFws == 1 and self.counterFwsTick == 0) then
        self:counterFws(defendMarkerX, defendMarkerZ, marker, radius)
    end
    if (self.shouldCounterSpies == 1 and self.counterSpiesTick == 0) then
        self:counterSpies(defendMarkerX, defendMarkerZ, marker, radius)
    end
    if (self.shouldCounterBraves == 1 and self.counterBravesTick == 0) then
        self:counterBraves(defendMarkerX, defendMarkerZ, marker, radius)
    end
end

function AIDefending:countMyPeopleOfModel(unitModel)
    local myPeople = {}
    ProcessGlobalTypeList(T_PERSON, function(t)
        if (t.Owner == self.tribe and t.Model == unitModel and (t.State == S_PERSON_AWAITING_COMMAND or t.State == S_PERSON_WANDER or t.State == S_PERSON_WAIT_IN_BLDG or t.State == S_PERSON_WAIT_FIRST_APPEAR or t.State == S_PERSON_WAIT_AT_POINT or t.State == S_PERSON_UNDER_COMMAND)) then
            table.insert(myPeople, t)
        end
        return true
    end)

    local myPeopleCount = tableLength(myPeople)
    return myPeopleCount
end
 
--Counter and defend against an enemy shaman coming close
function AIDefending:counterShaman(defendMarkerX, defendMarkerZ, marker, radius)
    local enemyShamans = self:countSpecificEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius, M_PERSON_MEDICINE_MAN)
    local enemyCount = tableLength(enemyShamans)

    if (enemyCount > 0) then
        local myShaman = getShaman(self.tribe)
         --Send shaman if she's alive and send FWs and braves to slow enemy down
        if (self.counterShamanTick == 0 and myShaman ~= nil) then
            self:sendDefendShaman(marker, defendMarkerX, defendMarkerZ)
            self.counterShamanTick = self.defendTickCooldown   
            self.resetShaman = false
        elseif (self.shamanCounterWithBravesAndFwTick == 0) then
            self:sendUnits(enemyShamans, enemyCount, M_PERSON_BRAVE, 0)
            self:sendUnits(enemyShamans, enemyCount, M_PERSON_SUPER_WARRIOR, 1)
            self.shamanCounterWithBravesAndFwTick = 36
        end
    end
end

function AIDefending:counterWarriors(defendMarkerX, defendMarkerZ, marker, radius)
    local enemies = self:countSpecificEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius, M_PERSON_WARRIOR)
    local enemyCount = tableLength(enemies)
    
    if (enemyCount > 0) then
        if (self.counterFwsTick == 0) then
            self:sendUnits(enemies, enemyCount, M_PERSON_WARRIOR, 0)
            self.counterFwsTick = self.defendTickCooldown
        end
    end
end

function AIDefending:counterFws(defendMarkerX, defendMarkerZ, marker, radius) 
    local enemies = self:countSpecificEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius, M_PERSON_SUPER_WARRIOR)
    local enemyCount = tableLength(enemies)
    
    if (enemyCount > 0) then
        if (self.counterFwsTick == 0) then
            self:sendUnits(enemies, enemyCount, M_PERSON_WARRIOR, 0)
            self.counterFwsTick = self.defendTickCooldown
        end
    end
end

function AIDefending:counterBraves(defendMarkerX, defendMarkerZ, marker, radius)
    local enemies = self:countSpecificEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius, M_PERSON_BRAVE)
    local enemyCount = tableLength(enemies)
    
    if (enemyCount > 0) then
        if (self.counterBravesTick == 0) then
            local myWarriorCount = self:countMyPeopleOfModel(M_PERSON_WARRIOR)
            if (myWarriorCount > 0) then
                self:sendUnits(enemies, enemyCount, M_PERSON_WARRIOR, 0)
            else
                self:sendUnits(enemies, enemyCount, M_PERSON_BRAVE, 1)
            end

            self.counterBravesTick = self.defendTickCooldown
        end
    end
end

function AIDefending:counterSpies(defendMarkerX, defendMarkerZ, marker, radius)
    local enemies = self:countSpecificEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius, M_PERSON_SPY)
    local enemyCount = tableLength(enemies)
    
    if (enemyCount > 0) then
        if (self.counterSpiesTick == 0) then
            self:sendUnits(enemies, enemyCount, M_PERSON_BRAVE, 0)
            self.counterSpiesTick = self.defendTickCooldown
        end
    end
end

function AIDefending:counterPreachers(defendMarkerX, defendMarkerZ, marker, radius)
    local enemies = self:countSpecificEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius, M_PERSON_RELIGIOUS)
    local enemyCount = tableLength(enemies)
    
    if (enemyCount > 0) then
        if (self.counterPreachersTick == 0) then
            self:sendUnits(enemies, enemyCount, M_PERSON_RELIGIOUS, 0)
            self.counterPreachersTick = self.defendTickCooldown
        end
    end
end

function AIDefending:sendUnits(enemies, enemyCount, unitModelToSend, twoUnits)
    local myUnits = {}

    ProcessGlobalTypeList(T_PERSON, function(t)
        if (t.Owner == self.tribe and t.Model == unitModelToSend and (t.State == S_PERSON_AWAITING_COMMAND or t.State == S_PERSON_WANDER or t.State == S_PERSON_WAIT_IN_BLDG or t.State == S_PERSON_WAIT_FIRST_APPEAR or t.State == S_PERSON_WAIT_AT_POINT or t.State == S_PERSON_BASE_WANDER or t.State == S_PERSON_UNDER_COMMAND)) then
            table.insert(myUnits, t)
        end
        return true
    end)

    myUnitCount = tableLength(myUnits)

    if (twoUnits == 0) then --Only send one brave to each enemy (for Spies for example)
        if (myUnitCount > 0) then
            for i, unit in pairs(myUnits) do
                if (i <= enemyCount) then
                    local cmd = Commands.new()
                    cmd.CommandType = CMD_ATTACK_TARGET
                    cmd.u.TargetIdx:set(enemies[i].ThingNum)
                    unit.Flags = unit.Flags | (1<<4)
                    add_persons_command(unit, cmd, 0)
                end         
            end
        end
    elseif (twoUnits == 1) then
        local sentTwo = false
        local doubleEnemyCount = enemyCount * 2

        for i, unit in pairs(myUnits) do
            if (i <= doubleEnemyCount) then
                local cmd = Commands.new()
                cmd.CommandType = CMD_ATTACK_TARGET

                --Send two FWs each to the enemy Shaman when this is called
                if (sentTwo == false) then
                    cmd.u.TargetIdx:set(enemies[i].ThingNum)
                    sentTwo = true
                elseif (sentTwo == true) then
                    cmd.u.TargetIdx:set(enemies[i-1].ThingNum)
                end
                
                unit.Flags = unit.Flags | (1<<4)
                add_persons_command(unit, cmd, 0)
            end
        end
    end
    
end

--Count enemy followers in area around location inside a radius (preferably around marker to combine with defences)
function AIDefending:countEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius)
    local enemies = {}
    local isAlly = false
    markerPos = MAP_XZ_2_WORLD_XYZ(defendMarkerX, defendMarkerZ)
    
    SearchMapCells(CIRCULAR, 0, 0, radius, world_coord3d_to_map_idx(markerPos), function(me)
        me.MapWhoList:processList(function (t)
            if (t.Type == T_PERSON) then
                if (self.allies ~= 0) then
                       for _,v in pairs(self.allies) do
                            if v == t.Owner then
                                isAlly = true
                                break
                            else
                                isAlly = false
                            end
                       end
                   end 

                if (isAlly == false and t.Owner ~= self.tribe and t.State ~= S_PERSON_BEING_PREACHED and is_person_a_spy_disguised_as_me(t, self.tribe) == 0 ) then
                    table.insert(enemies, t)
                end
            end
        return true
        end)
    return true
    end)
    return enemies
end

function AIDefending:countSpecificEnemyPeopleInArea(defendMarkerX, defendMarkerZ, radius, peopleType)
    local enemies = {}
    local isAlly = false
    markerPos = MAP_XZ_2_WORLD_XYZ(defendMarkerX, defendMarkerZ)
    
    SearchMapCells(CIRCULAR, 0, 0, radius, world_coord3d_to_map_idx(markerPos), function(me)
        me.MapWhoList:processList(function (t)
            if (self.allies ~= 0) then
                       for _,v in pairs(self.allies) do
                            if v == t.Owner then
                                isAlly = true
                                break
                            else
                                isAlly = false
                            end
                       end
                   end 
            if (t.Type == T_PERSON) then
                if (isAlly == false and t.Owner ~= self.tribe and t.State ~= S_PERSON_BEING_PREACHED and t.Model == peopleType and ((peopleType == M_PERSON_SPY and is_person_a_spy_disguised_as_me(t, self.tribe) == 0) or peopleType ~= M_PERSON_SPY)) then
                    table.insert(enemies, t)
                end
            end
        return true
        end)
    return true
    end)
    return enemies
end

function AIDefending:addDrumTower(xPos, zPos) 
    local drumTower = DrumTower:new(nil, self.tribe, xPos, zPos)
    table.insert(self.drumTowers, drumTower)
end

function AIDefending:checkAllDrumTowerStatuses()
    for _, tower in ipairs(self.drumTowers) do
        tower:towerStatus()
    end
end

--Send Shaman to defend alone, attributes are changed here too since the Shaman always goes first
function AIDefending:sendDefendShaman(marker, defendMarkerX, defendMarkerZ)
    MOVE_SHAMAN_TO_MARKER(self.tribe, marker)
    SHAMAN_DEFEND(self.tribe, defendMarkerX, defendMarkerZ, FALSE)
end

function AIDefending:resetDefend()
    if (self.movingTowardsRepairTick > 0) then
        self.movingTowardsRepairTick = self.movingTowardsRepairTick - 1
    else
        self.movingTowardsRepair = 0
    end

    if (self.counterWarriorsTick > 0) then
        self.counterWarriorsTick = self.counterWarriorsTick - 1
    end
    if (self.counterShamanTick > 0 ) then
        self.counterShamanTick = self.counterShamanTick - 1
    end
    if (self.shamanCounterWithBravesAndFwTick > 0) then
        self.shamanCounterWithBravesAndFwTick = self.shamanCounterWithBravesAndFwTick - 1
    end
    if (self.counterPreachersTick > 0) then
        self.counterPreachersTick = self.counterPreachersTick - 1
    end
    if (self.counterFwsTick > 0) then
        self.counterFwsTick = self.counterFwsTick - 1
    end
    if (self.counterBravesTick > 0) then
        self.counterBravesTick = self.counterBravesTick - 1
    end
    if (self.counterSpiesTick > 0) then
        self.counterSpiesTick = self.counterSpiesTick - 1
    end

    if (self.counterShamanTick == 0 and self.resetShaman == false) then
        self.resetShaman = true
        SHAMAN_DEFEND(self.tribe, self.shamanDefaultDefX, self.shamanDefaultDefZ, TRUE)
    end
end