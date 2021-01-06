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

AIShaman = {tribe = 0, blastAllowed = 0, lightningAllowed = 0, ghostsAllowed = 0, insectPlagueAllowed = 0, spellDelay = 0, ghostsSpecialDelay = 0, insectPlagueSpecialDelay = 0, dodgeLightning = 0}
AIShaman.__index = AIShaman

function AIShaman:new (o, tribe, blastAllowed, lightningAllowed, ghostsAllowed, insectPlagueAllowed, dodgeLightning)
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

    o.manaCostBlast = SPELL_COST(M_SPELL_BLAST)
    o.manaCostGhostArmy = SPELL_COST(M_SPELL_GHOST_ARMY)
    o.manaCostInsectPlague = SPELL_COST(M_SPELL_INSECT_PLAGUE)
    o.manaCostLightning = SPELL_COST(M_SPELL_LIGHTNING_BOLT)
    return o
end

function AIShaman:handleShamanCombat ()
        local shaman = getShaman(self.tribe)
        local wasInFight = 0 --Use this to stop moving very far
        local shamanPos = MAP_XZ_2_WORLD_XYZ(shaman.Pos.D3.Xpos, shaman.Pos.D3.Zpos)
        local enemyIWasFighting = 0

        if (shaman ~= nil) then
            ProcessGlobalTypeList(T_PERSON, function(t)
                   if (t.Owner ~= self.tribe and t.Model == M_PERSON_MEDICINE_MAN) then 
                        --Destroy ghost armies near me with swarm
                        if (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 2400 + shaman.Pos.D3.Ypos*3 and t.Flags2 & TF2_THING_IS_A_GHOST_PERSON ~= 0 and self.insectPlagueAllowed == 1 and MANA(self.tribe) > self.manaCostInsectPlague and self.spellDelay == 0 and self.insectPlagueSpecialDelay == 0) then
                            if(is_thing_on_ground(shaman) == 1) then
                               createThing(T_SPELL, M_SPELL_INSECT_PLAGUE, shaman.Owner, t.Pos.D3, false, false)
                                    self.spellDelay = 24
                                    self.insectPlagueSpecialDelay = 240
                                    GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostInsectPlague * -1)
                                    return false
                            end
                        end

                        --Dodge lightning if needed, otherwise only try to dodge blast
                        if (self.dodgeLightning == 1) then
                            if (get_world_dist_xyz(t.Pos.D3, shaman.Pos.D3) < 6000 + t.Pos.D3.Ypos*3 and t.Model == M_PERSON_MEDICINE_MAN) then  
                                SearchMapCells(CIRCULAR, 0, 0, 1, world_coord3d_to_map_idx(shamanPos), function(me)
                                    if (is_map_elem_coast(me) > 0 or is_map_elem_all_land(me) > 0) then
                                        local c2d = Coord2D.new()
                                        map_ptr_to_world_coord2d(me, c2d)
                                        command_person_go_to_coord2d(shaman, c2d)
                                        enemyIWasFighting = t
                                        wasInFight = 1
                                        return false
                                    end
                                return true
                                end)
                            else
                                if (wasInFight == 1 and get_world_dist_xyz(enemyIWasFighting.Pos.D3, shaman.Pos.D3) >= 6000) then
                                    remove_all_persons_commands(shaman)
                                    wasInFight = 0
                                end
                            end
                        else   
                            if (get_world_dist_xyz(t.Pos.D3, shaman.Pos.D3) < 3092 + t.Pos.D3.Ypos*3 and t.Model == M_PERSON_MEDICINE_MAN) then 
                                    SearchMapCells(CIRCULAR, 0, 0, 1, world_coord3d_to_map_idx(shamanPos), function(me)
                                        if (is_map_elem_coast(me) > 0 or is_map_elem_all_land(me) > 0) then
                                            local c2d = Coord2D.new()
                                            map_ptr_to_world_coord2d(me, c2d)
                                            command_person_go_to_coord2d(shaman, c2d)
                                            enemyIWasFighting = t
                                            wasInFight = 1
                                            return false
                                        end
                                    return true
                                    end)
                            else
                                if (wasInFight == 1 and get_world_dist_xyz(enemyIWasFighting.Pos.D3, shaman.Pos.D3) >= 3092) then
                                    remove_all_persons_commands(shaman)
                                    wasInFight = 0
                                end
                            end
                        end
                        
                        --First try to lock down the enemy shaman with ghost army if allowed
                        if (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 4092 + shaman.Pos.D3.Ypos*3 and (t.Model == M_PERSON_MEDICINE_MAN) and self.ghostsAllowed == 1 and MANA(self.tribe) > self.manaCostGhostArmy and self.spellDelay == 0 and self.ghostsSpecialDelay == 0) then  
                            if (is_thing_on_ground(shaman) == 1) then
                                createThing(T_SPELL, M_SPELL_GHOST_ARMY, shaman.Owner, t.Pos.D3, false, false)
                                    self.spellDelay = 24
              		                self.ghostsSpecialDelay = 144
                                    GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostGhostArmy * -1)
              		                return false
                                end    
                        --If I'm allowed and can cast lightning cast it
                        elseif (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 6000 + shaman.Pos.D3.Ypos*3 and (t.Model == M_PERSON_MEDICINE_MAN or t.Model == M_PERSON_RELIGIOUS) and self.lightningAllowed == 1 and MANA(self.tribe) > self.manaCostLightning and self.spellDelay == 0) then
                            if (is_thing_on_ground(shaman) == 1) then
                                createThing(T_SPELL, M_SPELL_LIGHTNING_BOLT, shaman.Owner, t.Pos.D3, false, false)
              		                self.spellDelay = 60
                                    GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostLightning * -1)
              		                return false
                                end 
                        --If I'm allowed and can cast blast cast it
                        elseif (get_world_dist_xyz(shaman.Pos.D3, t.Pos.D3) < 3092 + shaman.Pos.D3.Ypos*3 and (t.Model == M_PERSON_MEDICINE_MAN or t.Model == M_PERSON_RELIGIOUS) and self.blastAllowed == 1 and MANA(self.tribe) > self.manaCostBlast and self.spellDelay == 0) then
                            if (is_thing_on_ground(shaman) == 1) then
                                createThing(T_SPELL, M_SPELL_BLAST, shaman.Owner, t.Pos.D3, false, false)
              		                self.spellDelay = 24
                                    GIVE_MANA_TO_PLAYER(self.tribe, self.manaCostBlast * -1)
              		                return false
                                end
                        end
                   end
            return true
            end)
        end
end

function AIShaman:checkSpellDelay()
        --Update spellDelay each turn
        if (self.spellDelay > 0) then
            self.spellDelay = self.spellDelay - 1
        end
        
        --Update ghostsSpecialDelay each turn
        if (self.ghostsSpecialDelay > 0) then
            self.ghostsSpecialDelay = self.ghostsSpecialDelay -1
        end

        if (self.insectPlagueSpecialDelay > 0) then
            self.insectPlagueSpecialDelay = self.insectPlagueSpecialDelay -1
        end

        --Old code to give AI an artificial cooldown on spells instead of using actual mana, keeping it here just in case the AI using mana messes with their attack times
        --[[--Can increase charge rate if more followers in future?
        --Half time at 80+ followers
        --Recharge smart casts of Blast (8 seconds)
        if (everyPow(96, 1)) then
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
        end--]]
end