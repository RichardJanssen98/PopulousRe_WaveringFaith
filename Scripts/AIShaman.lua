import(Module_System)
import(Module_Players)
import(Module_Defines)
import(Module_PopScript)
import(Module_Game)
import(Module_Objects)
import(Module_Map)
import(Module_Commands)
include("UtilPThings.lua")
include("UtilRefs.lua")

AIShaman = {tribe = 0, blastAllowed = 0, lightningAllowed = 0, ghostsAllowed = 0, insectPlagueAllowed = 0, spellDelay = 0, ghostsSpecialDelay = 0, insectPlagueSpecialDelay = 0, dodgeLightning = 0, 
    allies = 0, dodgeBlast = 0, blastTrickAllowed = 0, overrideRechargeSpeed = 0, aggroRange = 0, maxDistanceFromWater = 0}
AIShaman.__index = AIShaman

function AIShaman:new (o, tribe, blastAllowed, lightningAllowed, ghostsAllowed, insectPlagueAllowed, dodgeLightning, allies, dodgeBlast, blastTrickAllowed, overrideRechargeSpeed, aggroRange, maxDistanceFromWater)
    local o = o or {}
    setmetatable(o, AIShaman)
    o.tribe = tribe
    o.blastAllowed = blastAllowed
    o.lightningAllowed = lightningAllowed
    o.ghostsAllowed = ghostsAllowed
    o.insectPlagueAllowed = insectPlagueAllowed
    o.dodgeLightning = dodgeLightning

    o.spellDelay = 0
    o.ghostsSpecialDelay = 0
    o.insectPlagueSpecialDelay = 0
    o.lightningSpecialDelay = 0

    o.enemyCastDelay = 0

    o.maxDistanceFromWater = maxDistanceFromWater

    o.allies = allies

    o.manaCostBlast = SPELL_COST(M_SPELL_BLAST)
    o.manaCostGhostArmy = SPELL_COST(M_SPELL_GHOST_ARMY)
    o.manaCostInsectPlague = SPELL_COST(M_SPELL_INSECT_PLAGUE)
    o.manaCostLightning = SPELL_COST(M_SPELL_LIGHTNING_BOLT)

    o.smartCastsBlast = 0
    o.smartCastsGhosts = 0
    o.smartCastsLightning = 0

    o.maxSmartCastsBlast = 4
    o.maxSmartCastsGhosts = 4
    o.maxSmartCastsLightning = 4

    o.didDodgeOnCast = 0
    o.didDodgeOnCastTick = 0
    o.dodgeDelay = 12
    o.followEnemyDelay = 0

    o.flyingDuration = 0
    o.blastTrickDelay = 0

    o.overrideRechargeSpeed = overrideRechargeSpeed
    o.aggroRange = aggroRange
    o.blastTrickAllowed = blastTrickAllowed
    o.dodgeBlast = dodgeBlast

    o.nearWaterBool = 0
    o.targetThatIsInAir = nil
    o.chanceToHitAir = 0
    o.enemyShamanNearby = 0

    return o
end


function AIShaman:handleShamanCombat ()
        local shaman = getShaman(self.tribe)

        isAlly = false
        local target = nil

        if (shaman ~= nil) then

            ProcessGlobalTypeList(T_PERSON, function(t)
                   --Check if the person is one of my allies
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

                   if (t.Owner ~= self.tribe and t.Model == M_PERSON_MEDICINE_MAN and isAlly == false and get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < self.aggroRange) then
                        target = t
                        self.enemyShamanNearby = 1
                   end
        
                   --Check if I can cast Swarm, if not then cast Blast if someone is fighting me
                   --Insect Plague will only be cast if the tribe has 4 times the cost, this due to Lightning Bolt being more important and it costs twice as much as Insect Plague. 
                   --Thus the Shaman will only cast Insect Plague if they would be able to cast two Lightning Bolts.
                   if (shaman.State == S_PERSON_FIGHT_PERSON_2 and self.insectPlagueAllowed == 1 and MANA(self.tribe) > (self.manaCostInsectPlague * 4) and self.spellDelay == 0 and self.insectPlagueSpecialDelay == 0) then
                       createThing(T_SPELL, M_SPELL_INSECT_PLAGUE, shaman.Owner, shaman.Pos.D3, false, false)
                               self.spellDelay = 24
                               self.insectPlagueSpecialDelay = 240
                               self.blastTrickDelay = 12
                               GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostInsectPlague * -1)
                               return false
                   elseif (shaman.State == S_PERSON_FIGHT_PERSON_2 and self.blastAllowed == 1 and MANA(self.tribe) > self.manaCostBlast and self.spellDelay == 0  and self.smartCastsBlast < self.maxSmartCastsBlast) then
                       createThing(T_SPELL, M_SPELL_BLAST, shaman.Owner, shaman.Pos.D3, false, false)
              		           self.spellDelay = 24
                               self.smartCastsBlast = self.smartCastsBlast + 1
                               self.blastTrickDelay = 12
                               GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostBlast * -1)
              		           return false
                   end

                   if (target ~= nil) then
                        if (target.Owner ~= self.tribe and target.Model == M_PERSON_MEDICINE_MAN and isAlly == false) then 
                            if (target.Model == M_PERSON_MEDICINE_MAN) then
                                --Do the Blast Trick
                            if (self.flyingDuration > 7 and self.flyingDuration < 9 and self.blastTrickAllowed == 1 and shaman.State ~= S_PERSON_ELECTROCUTED and get_world_dist_xyz(shaman.Pos.D3, target.Pos.D3) < 4000 and self.blastTrickDelay == 0 and self.smartCastsBlast < self.maxSmartCastsBlast) then
                                local blast = createThing(T_SPELL, M_SPELL_BLAST, shaman.Owner, target.Pos.D3, false, false)
                                        local rng_s_click = G_RANDOM(3) + 1
                                        if (rng_s_click == 1) then --Give the AI a 1/3 chance to S click the Blast Trick on the enemy
                                            blast.u.Spell.TargetThingIdx:set(target.ThingNum)
                                        end
              		                    self.spellDelay = 24 + G_RANDOM(11)
                                        self.blastTrickDelay = 12
                                        self.smartCastsBlast = self.smartCastsBlast + 1
                                        GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostBlast * -1)
              		                    return false
                            elseif (self.flyingDuration > 7 and self.flyingDuration < 9 and self.blastTrickAllowed == 1 and shaman.State ~= S_PERSON_ELECTROCUTED and self.blastTrickDelay == 0 and self.smartCastsBlast < self.maxSmartCastsBlast) then --Blast myself if enemy is too far
                                    createThing(T_SPELL, M_SPELL_BLAST, shaman.Owner, shaman.Pos.D3, false, false)
              		                    self.spellDelay = 24 + G_RANDOM(11)
                                        self.blastTrickDelay = 12
                                        self.smartCastsBlast = self.smartCastsBlast + 1
                                        GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostBlast * -1)
              		                    return false
                            end

                            if (target.Model == M_PERSON_MEDICINE_MAN and is_thing_on_ground(target) == 0) then
                                self.targetThatIsInAir = target
                            end

                            if (target.State == S_PERSON_SPELL_TRANCE) then
                                self.enemyCastDelay = 48
                            end

                            --Dodge lightning if needed, otherwise only try to dodge blast
                            if (self.dodgeLightning == 1 and shaman.State ~= S_PERSON_FIGHT_PERSON_2) then
                                --Dodge lightning being cast on me
                                
                                if (get_world_dist_xyz(target.Pos.D3, shaman.Pos.D3) < 5900 + target.Pos.D3.Ypos*3 and target.Model == M_PERSON_MEDICINE_MAN and target.State == S_PERSON_SPELL_TRANCE) then
                                    SearchMapCells(CIRCULAR, 0, 0, 4, world_coord2d_to_map_idx(shaman.Pos.D2), function(me)
                                        if (is_map_elem_land_or_coast(me) > 0) then 
                                            local c2d = Coord2D.new()
                                            map_ptr_to_world_coord2d(me, c2d)
                                            local c3d = Coord3D.new()
                                            coord2D_to_coord3D(c2d, c3d)
                                            if (get_world_dist_xyz(shaman.Pos.D3, c3d) >= 2000 and self.didDodgeOnCast == 0) then
                                                self.didDodgeOnCastTick = GetTurn() + 16
                                                command_person_go_to_coord2d(shaman, c2d)
                                                self.didDodgeOnCast = 1
                                                return false
                                            end
                                        end
                                        return true
                                        end)
                                elseif (get_world_dist_xyz(target.Pos.D3, shaman.Pos.D3) < self.aggroRange and target.Model == M_PERSON_MEDICINE_MAN and self.followEnemyDelay == 0 and MANA(self.tribe) > self.manaCostLightning * 2 and self.blastAllowed == 1) then --If enemy in aggro range and I don't have enough mana for 2 lightning bolts walk to them,  but only if I can use blast
                                    local c2d = Coord2D.new()
                                    local m = MapPosXZ.new()
                                    m.Pos = world_coord3d_to_map_idx(target.Pos.D3)
                                    map_xz_to_world_coord2d(m.XZ.X, m.XZ.Z, c2d)
                                    command_person_go_to_coord2d(shaman, c2d)
                                    self.followEnemyDelay = 24
                                    self.dodgeDelay = 28
                                elseif (everyPow(self.dodgeDelay, 1) and get_world_dist_xyz(target.Pos.D3, shaman.Pos.D3) < 6000 + target.Pos.D3.Ypos*3 and target.Model == M_PERSON_MEDICINE_MAN) then  
                                    SearchMapCells(CIRCULAR, 0, 0, 4, world_coord2d_to_map_idx(shaman.Pos.D2), function(me)
                                        if (is_map_elem_land_or_coast(me) > 0) then
                                            local c2d = Coord2D.new()
                                            map_ptr_to_world_coord2d(me, c2d)
                                            SearchMapCells(CIRCULAR, 0, 0, self.maxDistanceFromWater, world_coord2d_to_map_idx(c2d), function(meRoundTwo) --Check if this location is near water, if so do NOT dodge there
                                                if (is_map_elem_all_sea(meRoundTwo) > 0) then
                                                    self.nearWaterBool = 1
                                                    return false
                                                else
                                                    return true
                                                end
                                            end)
                                            if (self.nearWaterBool == 1) then
                                                self.nearWaterBool = 0
                                                return true
                                            else
                                                local c3d = Coord3D.new()
                                                coord2D_to_coord3D(c2d, c3d)
                                                if (get_world_dist_xyz(shaman.Pos.D3, c3d) >= 2000 and self.didDodgeOnCast == 0) then
                                                    command_person_go_to_coord2d(shaman, c2d)
                                                    self.dodgeDelay = G_RANDOM(11)+20 --Dodge at least every second with a max delay of 2 seconds
                                                    return false
                                                end
                                            end 
                                        end
                                    return true
                                    end)
                                elseif (get_world_dist_xyz(target.Pos.D3, shaman.Pos.D3) < self.aggroRange and target.Model == M_PERSON_MEDICINE_MAN and self.followEnemyDelay == 0) then --If enemy in aggro range walk towards them
                                    local c2d = Coord2D.new()
                                    local m = MapPosXZ.new()
                                    m.Pos = world_coord3d_to_map_idx(target.Pos.D3)
                                    map_xz_to_world_coord2d(m.XZ.X, m.XZ.Z, c2d)
                                    command_person_go_to_coord2d(shaman, c2d)
                                    self.followEnemyDelay = 36
                                end
                            elseif (self.dodgeBlast == 1 and shaman.State ~= S_PERSON_FIGHT_PERSON_2) then   --Dodging blasts
                                if (everyPow(self.dodgeDelay, 1) and get_world_dist_xyz(target.Pos.D3, shaman.Pos.D3) < 3092 + target.Pos.D3.Ypos*3 and target.Model == M_PERSON_MEDICINE_MAN) then 
                                        SearchMapCells(CIRCULAR, 0, 0, 4, world_coord2d_to_map_idx(shaman.Pos.D2), function(me)
                                            if (is_map_elem_land_or_coast(me) > 0) then
                                                local c2d = Coord2D.new()
                                                map_ptr_to_world_coord2d(me, c2d)
                                                SearchMapCells(CIRCULAR, 0, 0, self.maxDistanceFromWater, world_coord2d_to_map_idx(c2d), function(meRoundTwo) --Check if this location is near water, if so do NOT dodge there
                                                    if (is_map_elem_all_sea(meRoundTwo) > 0) then
                                                        self.nearWaterBool = 1
                                                        return false
                                                    else
                                                        return true
                                                    end
                                                end)
                                                if (self.nearWaterBool == 1) then
                                                    self.nearWaterBool = 0
                                                    return true
                                                else
                                                    local c3d = Coord3D.new()
                                                    coord2D_to_coord3D(c2d, c3d)
                                                    if (get_world_dist_xyz(shaman.Pos.D3, c3d) >= 2000 and self.didDodgeOnCast == 0) then
                                                        command_person_go_to_coord2d(shaman, c2d)
                                                        self.dodgeDelay = G_RANDOM(11)+20 --Dodge at least every second with a max delay of 2 seconds
                                                        return false
                                                    end
                                                end
                                            end
                                        return true
                                        end)
                                elseif (get_world_dist_xyz(target.Pos.D3, shaman.Pos.D3) < self.aggroRange and target.Model == M_PERSON_MEDICINE_MAN and self.followEnemyDelay == 0) then
                                    local c2d = Coord2D.new()
                                    local m = MapPosXZ.new()
                                    m.Pos = world_coord3d_to_map_idx(target.Pos.D3)
                                    map_xz_to_world_coord2d(m.XZ.X, m.XZ.Z, c2d)
                                    command_person_go_to_coord2d(shaman, c2d)
                                    self.followEnemyDelay = 36
                                end
                            end
                        
                            --First try to lock down the enemy shaman with ghost army if allowed
                            if (get_world_dist_xyz(shaman.Pos.D3, target.Pos.D3) < 3400 + shaman.Pos.D3.Ypos*3 and (target.Model == M_PERSON_MEDICINE_MAN) and self.ghostsAllowed == 1 and MANA(self.tribe) > self.manaCostGhostArmy and self.spellDelay == 0 and self.ghostsSpecialDelay == 0 and self.smartCastsGhosts < self.maxSmartCastsGhosts and self.enemyCastDelay > 13 and self.enemyCastDelay < 36) then  
                                if (is_thing_on_ground(shaman) == 1) then
                                    createThing(T_SPELL, M_SPELL_GHOST_ARMY, shaman.Owner, target.Pos.D3, false, false)
                                        self.spellDelay = 24 + G_RANDOM(13)
              		                    self.ghostsSpecialDelay = 120 + G_RANDOM(30)
                                        self.blastTrickDelay = 12
                                        self.smartCastsGhosts = self.smartCastsGhosts + 1
                                        GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostGhostArmy * -1)
              		                    return false
                                    end    
                            --If I'm allowed and can cast lightning cast it
                            elseif (get_world_dist_xyz(shaman.Pos.D3, target.Pos.D3) < 5000 + shaman.Pos.D3.Ypos*3 and (target.Model == M_PERSON_MEDICINE_MAN) and self.lightningAllowed == 1 and MANA(self.tribe) > self.manaCostLightning and self.spellDelay == 0 and self.lightningSpecialDelay == 0 and self.smartCastsLightning < self.maxSmartCastsLightning) then
                                if (is_thing_on_ground(shaman) == 1) then
                                    local light = createThing(T_SPELL, M_SPELL_LIGHTNING_BOLT, shaman.Owner, target.Pos.D3, false, false)
                                        light.u.Spell.TargetThingIdx:set(target.ThingNum)
              		                    self.spellDelay = 24 + G_RANDOM(6)
                                        self.lightningSpecialDelay = 30 + G_RANDOM(20)
                                        self.blastTrickDelay = 12
                                        self.smartCastsLightning = self.smartCastsLightning + 1
                                        GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostLightning * -1)
              		                    return false
                                    end 
                            --If I'm allowed and can cast blast cast it
                            elseif (get_world_dist_xyz(shaman.Pos.D3, target.Pos.D3) < 2600 + shaman.Pos.D3.Ypos*3 and (target.Model == M_PERSON_MEDICINE_MAN) and self.blastAllowed == 1 and MANA(self.tribe) > self.manaCostBlast and self.spellDelay == 0  and self.smartCastsBlast < self.maxSmartCastsBlast) then
                                if (is_thing_on_ground(shaman) == 1 and ((self.targetThatIsInAir == target and self.chanceToHitAir == 1) or self.targetThatIsInAir ~= target)) then
                                    local blast = createThing(T_SPELL, M_SPELL_BLAST, shaman.Owner, target.Pos.D3, false, false)
                                        blast.u.Spell.TargetThingIdx:set(target.ThingNum)
              		                    self.spellDelay = 24 + G_RANDOM(13)
                                        self.blastTrickDelay = 12
                                        self.smartCastsBlast = self.smartCastsBlast + 1

                                        --Set chance for blasting enemy in the sky for the next blast
                                        self.chanceToHitAir = G_RANDOM(10) +1

                                        GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostBlast * -1)
              		                    return false
                                    end
                            end
                            end                      
                        end
                    end
                    if (t.Owner ~= self.tribe and t.Model == M_PERSON_RELIGIOUS and isAlly == false and self.enemyShamanNearby == 0) then
                        if (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 2600 + shaman.Pos.D3.Ypos*3 and t.Model == M_PERSON_RELIGIOUS and self.blastAllowed == 1 and MANA(self.tribe) > self.manaCostBlast and self.spellDelay == 0  and self.smartCastsBlast < self.maxSmartCastsBlast) then
                            if (is_thing_on_ground(shaman) == 1) then
                                local blast = createThing(T_SPELL, M_SPELL_BLAST, shaman.Owner, t.Pos.D3, false, false)
                                    blast.u.Spell.TargetThingIdx:set(t.ThingNum)
              		                self.spellDelay = 24 + G_RANDOM(13)
                                    self.blastTrickDelay = 12
                                    self.smartCastsBlast = self.smartCastsBlast + 1
                                    --Set chance for blasting enemy in the sky for the next blast
                                    self.chanceToHitAir = G_RANDOM(10) +1

                                    GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostBlast * -1)
              		                return false
                                end
                        end
                        if (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < self.aggroRange and t.Model == M_PERSON_RELIGIOUS and self.followEnemyDelay == 0 and MANA(self.tribe) > self.manaCostBlast and self.blastAllowed == 1) then
                                local c2d = Coord2D.new()
                                local m = MapPosXZ.new()
                                m.Pos = world_coord3d_to_map_idx(t.Pos.D3)
                                map_xz_to_world_coord2d(m.XZ.X, m.XZ.Z, c2d)
                                command_person_go_to_coord2d(shaman, c2d)
                                self.followEnemyDelay = 24
                        end
                    end

                   if (t.Owner ~= self.tribe and isAlly == false and get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 3100 + shaman.Pos.D3.Ypos*3 and t.Flags2 & TF2_THING_IS_A_GHOST_PERSON ~= 0) then
                       --Destroy ghost armies near me with ghost armies or blast if ghost armies are not ready
                       if (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 3000 + shaman.Pos.D3.Ypos*3 and self.ghostsAllowed == 1 and MANA(self.tribe) > self.manaCostGhostArmy and self.spellDelay == 0 and self.enemyCastDelay > 25 and self.enemyCastDelay < 36 and self.ghostsSpecialDelay == 0) then
                           if(is_thing_on_ground(shaman) == 1) then
                               local ghosts = createThing(T_SPELL, M_SPELL_GHOST_ARMY, shaman.Owner, t.Pos.D3, false, false)
                                   ghosts.u.Spell.TargetThingIdx:set(t.ThingNum)
                                   self.spellDelay = 12
                                   self.blastTrickDelay = 12
                                   self.ghostsSpecialDelay = 48
                                   GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostInsectPlague * -1)
                                   return false
                           end
                       elseif (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 1500 + shaman.Pos.D3.Ypos*3 and self.blastAllowed == 1 and MANA(self.tribe) > self.manaCostBlast and self.spellDelay == 0 and self.enemyCastDelay > 25 and self.enemyCastDelay < 36) then
                           if(is_thing_on_ground(shaman) == 1) then
                               local blast = createThing(T_SPELL, M_SPELL_BLAST, shaman.Owner, t.Pos.D3, false, false)
                                   blast.u.Spell.TargetThingIdx:set(t.ThingNum)
                                   self.spellDelay = 12 + G_RANDOM(13)
                                   self.blastTrickDelay = 12
                                   GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostBlast * -1)
                                   return false
                           end
                           --Or use Ghost army myself if they are very close to me
                       elseif (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 700 and self.ghostsAllowed == 1 and MANA(self.tribe) > self.manaCostGhostArmy and self.spellDelay == 0 and self.ghostsSpecialDelay == 0) then
                            if(is_thing_on_ground(shaman) == 1) then
                               local ghosts = createThing(T_SPELL, M_SPELL_GHOST_ARMY, shaman.Owner, t.Pos.D3, false, false)
                                   ghosts.u.Spell.TargetThingIdx:set(t.ThingNum)
                                   self.spellDelay = 12
                                   self.blastTrickDelay = 12
                                   self.ghostsSpecialDelay = 36
                                   GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostInsectPlague * -1)
                                   return false
                           end
                       end
                   end

                --Send ghosts to enemy shaman, if enemy shaman is out of range then set enemyShamanNearby to 0 so this shaman can start blasting preachers
                if (target ~= nil and shaman ~= nil) then
                    if (everyPow(36, 1)) then
                        self:sendGhostsToEnemyShaman(target)
                    end

                    if (get_world_dist_xyz(shaman.Pos.D3, target.Pos.D3) > self.aggroRange) then
                        self.enemyShamanNearby = 0
                    end
                end
                if (shaman == nil) then
                    self.enemyShamanNearby = 0
                end
                

                return true
                end)
        end
end

function AIShaman:sendGhostsToEnemyShaman(enemyShaman)
    local myGhosts = {}

    ProcessGlobalTypeList(T_PERSON, function(t)
        if (t.Owner == self.tribe and t.Flags2 & TF2_THING_IS_A_GHOST_PERSON ~= 0 and (t.State == S_PERSON_AWAITING_COMMAND or t.State == S_PERSON_WANDER or t.State == S_PERSON_WAIT_IN_BLDG or t.State == S_PERSON_WAIT_FIRST_APPEAR or t.State == S_PERSON_WAIT_AT_POINT or t.State == S_PERSON_BASE_WANDER or t.State == S_PERSON_UNDER_COMMAND)) then
            table.insert(myGhosts, t)
        end
        return true
    end)

    myUnitCount = tableLength(myGhosts)

    if (myUnitCount > 0) then
        for i, unit in pairs(myGhosts) do             
            local cmd = Commands.new()
            cmd.CommandType = CMD_ATTACK_TARGET
            cmd.u.TargetIdx:set(enemyShaman.ThingNum)
            unit.Flags = unit.Flags | (1<<4)
            add_persons_command(unit, cmd, 0)    
        end
    end
end

function tableLength(Table)
    local count = 0
    for _ in pairs(Table) do count = count + 1 end
    return count
end

function AIShaman:checkSpellDelay()
        local shaman = getShaman(self.tribe)

        if (self.flyingDuration > 0) then
            if (shaman ~= nil) then
                if (self.flyingDuration > 0 and is_thing_on_ground(shaman) == 1) then
                    self.flyingDuration = 0
                end
            end
        end

        if (shaman ~= nil ) then
            if (is_thing_on_ground(shaman) == 0) then
                self.flyingDuration = self.flyingDuration + 1
            end
        end

        if (self.targetThatIsInAir ~= nil) then
            if (is_thing_on_ground(self.targetThatIsInAir) == 1) then
                self.targetThatIsInAir = nil
            end
        end
        
        --Update spellDelay each turn
        if (self.spellDelay > 0) then
            self.spellDelay = self.spellDelay - 1
        end

        if (self.blastTrickDelay > 0) then
            self.blastTrickDelay = self.blastTrickDelay - 1
        end
        
        --Update ghostsSpecialDelay each turn
        if (self.ghostsSpecialDelay > 0) then
            self.ghostsSpecialDelay = self.ghostsSpecialDelay - 1
        end

        if (self.lightningSpecialDelay > 0) then
            self.lightningSpecialDelay = self.lightningSpecialDelay - 1
        end

        if (self.enemyCastDelay > 0 ) then
            self.enemyCastDelay = self.enemyCastDelay - 1
        end

        if (self.insectPlagueSpecialDelay > 0) then
            self.insectPlagueSpecialDelay = self.insectPlagueSpecialDelay - 1
        end

        if (GetTurn() >= self.didDodgeOnCastTick) then
            self.didDodgeOnCast = 0
        end

        if (self.followEnemyDelay > 0 ) then
           self.followEnemyDelay = self.followEnemyDelay - 1
        end

        --Old code to give AI an artificial cooldown on spells instead of using actual mana, keeping it here just in case the AI using mana messes with their attack times
        --Can increase charge rate if more followers in future?
        --Half time at 80+ followers
        --Recharge smart casts of Blast (6 seconds)
        if (_gsi.Players[self.tribe].NumPeople < 80 and self.overrideRechargeSpeed == 0) then
            if (everyPow(72, 1)) then
                if (self.smartCastsBlast ~= 0) then
                    self.smartCastsBlast = self.smartCastsBlast -1
                end
            end
            --Recharge smart casts of Lightning (30 seconds)
            if (everyPow(360, 1)) then
                if (self.smartCastsLightning ~= 0) then
                    self.smartCastsLightning = self.smartCastsLightning -1  
                end
            end

            --Recharge smart casts of Ghost Army (2 seconds)
            if (everyPow(24, 1)) then
                if (self.smartCastsGhosts ~= 0) then
                    self.smartCastsGhosts = self.smartCastsGhosts -1
                end
            end
        elseif (_gsi.Players[self.tribe].NumPeople >= 80 or self.overrideRechargeSpeed == 1) then
            --Recharge smart casts of Blast (3 seconds)
            if (everyPow(36, 1)) then
                if (self.smartCastsBlast ~= 0) then
                    self.smartCastsBlast = self.smartCastsBlast -1
                end
            end
            --Recharge smart casts of Lightning (15 seconds)
            if (everyPow(180, 1)) then
                if (self.smartCastsLightning ~= 0) then
                    self.smartCastsLightning = self.smartCastsLightning -1  
                end
            end

            --Recharge smart casts of Ghost Army (1 seconds)
            if (everyPow(12, 1)) then
                if (self.smartCastsGhosts ~= 0) then
                    self.smartCastsGhosts = self.smartCastsGhosts -1
                end
            end
        end
end
