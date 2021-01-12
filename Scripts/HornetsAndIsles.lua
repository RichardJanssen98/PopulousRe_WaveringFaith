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
include("AIShaman.lua")
include("AIDefend.lua")

computer_init_player(_gsi.Players[TRIBE_GREEN])
computer_init_player(_gsi.Players[TRIBE_CYAN])
computer_init_player(_gsi.Players[TRIBE_BLACK])

ai_Tribes = {TRIBE_GREEN, TRIBE_CYAN, TRIBE_BLACK}

--Variables
defendTimerUntilNewDefend = 240

greenDefended = 0
cyanDefended = 0
blackDefended = 0

AIShamanGreen = AIShaman:new(nil, TRIBE_GREEN, 1, 0, 0, 0, 0)
AIShamanCyan = AIShaman:new(nil, TRIBE_CYAN, 1, 0, 0, 0, 0)
AIShamanBlack = AIShaman:new(nil, TRIBE_BLACK, 1, 0, 0, 1, 0)

AIDefendGreen = AIDefend:new(nil, TRIBE_GREEN, 226, 140, defendTimerUntilNewDefend, 3, 1, 500, 1)
AIDefendCyan = AIDefend:new(nil, TRIBE_CYAN, 164, 152, defendTimerUntilNewDefend, 3, 1, 500, 1)
AIDefendBlack = AIDefend:new(nil, TRIBE_BLACK, 34, 10, defendTimerUntilNewDefend, 3, 1, 500, 1)

shaman_tick_green = GetTurn() + (2048 + G_RANDOM(2048))
shaman_tick_cyan = GetTurn() + (2048 + G_RANDOM(2048))
shaman_tick_black = GetTurn() + (2048 + G_RANDOM(2048))

--Ally Red and Blue since the World Editor alliances don't seem to carry over to the game.
set_players_allied(TRIBE_BLUE, TRIBE_RED)
set_players_allied(TRIBE_RED, TRIBE_BLUE)
set_players_allied(TRIBE_GREEN, TRIBE_CYAN)
set_players_allied(TRIBE_CYAN, TRIBE_GREEN)

botSpellsGreen = {M_SPELL_CONVERT_WILD,
                    M_SPELL_BLAST
}
botBldgsGreen = {M_BUILDING_TEPEE,
                   M_BUILDING_DRUM_TOWER,
                   M_BUILDING_TEMPLE
}

botSpellsCyan = {M_SPELL_CONVERT_WILD,
                    M_SPELL_BLAST,
                    M_SPELL_LAND_BRIDGE
}

botBldgsCyan = {M_BUILDING_TEPEE,
                    M_BUILDING_DRUM_TOWER,
                    M_BUILDING_TEMPLE,
                    M_BUILDING_BOAT_HUT_1
}

botSpellsBlack = {M_SPELL_CONVERT_WILD,
                    M_SPELL_BLAST,
                    M_SPELL_INSECT_PLAGUE
}

botBldgsBlack = {M_BUILDING_TEPEE,
                    M_BUILDING_DRUM_TOWER,
                    M_BUILDING_TEMPLE
}

enemyTribesGreen = {TRIBE_BLUE, TRIBE_RED, TRIBE_BLACK}
enemyTribesCyan = {TRIBE_BLUE, TRIBE_RED, TRIBE_BLACK}
enemyTribesBlack = {TRIBE_BLUE, TRIBE_RED, TRIBE_GREEN, TRIBE_CYAN}

for u,v in ipairs(botSpellsGreen) do
    PThing.SpellSet(TRIBE_GREEN, v, TRUE, FALSE)
end

for y,v in ipairs(botBldgsGreen) do
    PThing.BldgSet(TRIBE_GREEN, v, TRUE)
end

for u,v in ipairs(botSpellsCyan) do
    PThing.SpellSet(TRIBE_CYAN, v, TRUE, FALSE)
end

for y,v in ipairs(botBldgsCyan) do
    PThing.BldgSet(TRIBE_CYAN, v, TRUE)
end

for u,v in ipairs(botSpellsBlack) do
    PThing.SpellSet(TRIBE_BLACK, v, TRUE, FALSE)
end

for y,v in ipairs(botBldgsBlack) do
    PThing.BldgSet(TRIBE_BLACK, v, TRUE)
end

--Set all Internal attributes and states for Green
WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_EXPANSION, 25)
WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_HOUSE_PERCENTAGE, 46)
WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_MAX_BUILDINGS_ON_GO, 4)
WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_PREF_RELIGIOUS_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_PREF_RELIGIOUS_PEOPLE, 30)

SHAMAN_DEFEND(TRIBE_GREEN, 226, 140, TRUE)
SET_DRUM_TOWER_POS(TRIBE_GREEN, 226, 140)

--Set all Internal attributes and states for Cyan
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_EXPANSION, 25)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_HOUSE_PERCENTAGE, 85)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_MAX_BUILDINGS_ON_GO, 4)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_RELIGIOUS_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_RELIGIOUS_PEOPLE, 35)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_EMPTY_AT_WAYPOINT, 1)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_BOAT_HUTS, 1)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_BOAT_DRIVERS, 6)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PEOPLE_PER_BOAT, 7)
STATE_SET(TRIBE_CYAN, TRUE, CP_AT_TYPE_BUILD_VEHICLE)

SHAMAN_DEFEND(TRIBE_CYAN, 164, 152, TRUE)
SET_DRUM_TOWER_POS(TRIBE_CYAN, 164, 152)

--Set all Internal attributes and states for Black
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_EXPANSION, 25)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_HOUSE_PERCENTAGE, 50)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_MAX_BUILDINGS_ON_GO, 4)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_PREF_RELIGIOUS_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_PREF_RELIGIOUS_PEOPLE, 35)

SET_MARKER_ENTRY(TRIBE_BLACK, 0, 0, 1, 6+G_RANDOM(7), 0, 0, 1)

SHAMAN_DEFEND(TRIBE_BLACK, 34, 10, TRUE)
SET_DRUM_TOWER_POS(TRIBE_BLACK, 34, 10)

for aiNumber = 1, 3 do
    SET_BUCKET_USAGE(ai_Tribes[aiNumber], TRUE)

    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_BLAST, 4)
    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_CONVERT_WILD, 4)

    SET_SPELL_ENTRY(ai_Tribes[aiNumber], 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 0)
    SET_SPELL_ENTRY(ai_Tribes[aiNumber], 1, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 1)

    SET_DEFENCE_RADIUS(ai_Tribes[aiNumber], 8)

    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_MAX_TRAIN_AT_ONCE, 6)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_MAX_ATTACKS, 999)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_SHAMEN_BLAST, 64)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_USE_PREACHER_FOR_DEFENCE, 1)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_MAX_DEFENSIVE_ACTIONS, 999)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_RANDOM_BUILD_SIDE, 1)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_RETREAT_VALUE, 5)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_SPY_CHECK_FREQUENCY, 128)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_SPY_DISCOVER_CHANCE, 20)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_ENEMY_SPY_MAX_STAND, 128)
    WRITE_CP_ATTRIB(ai_Tribes[aiNumber], ATTR_DONT_USE_BOATS, 0)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_PREACH)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_DEFEND)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_DEFEND_BASE)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_BUILD_OUTER_DEFENCES)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_FETCH_WOOD)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_CONSTRUCT_BUILDING)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_TRAIN_PEOPLE)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_AUTO_ATTACK)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_POPULATE_DRUM_TOWER)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_SUPER_DEFEND)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_FETCH_LOST_PEOPLE)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_BRING_NEW_PEOPLE_BACK)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_HOUSE_A_PERSON)
end

SET_BUCKET_COUNT_FOR_SPELL(TRIBE_BLACK, M_SPELL_INSECT_PLAGUE, 16)

SET_SPELL_ENTRY(TRIBE_BLACK, 2, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE), 64, 3, 0)
SET_SPELL_ENTRY(TRIBE_BLACK, 3, M_SPELL_INSECT_PLAGUE, SPELL_COST(M_SPELL_INSECT_PLAGUE), 64, 3, 1)

function OnTurn()
        --Reset defend timers for all AIs
       AIDefendGreen:resetDefend()
       AIDefendCyan:resetDefend()
       AIDefendBlack:resetDefend()

       greenDefended = AIDefendGreen:getDefended()
       cyanDefended = AIDefendCyan:getDefended()
       blackDefended = AIDefendBlack:getDefended()

        --Put a delay on defending to reduce lag
        if (everyPow(36, 1)) then
            for enemyNumber = 1, 3 do
                AIDefendGreen:defendBase(enemyTribesGreen[enemyNumber], 254, 150, 8, 6)
                AIDefendGreen:defendBase(enemyTribesGreen[enemyNumber], 250, 128, 9, 6)
                AIDefendGreen:defendBase(enemyTribesGreen[enemyNumber], 234, 144, 10, 6)
                AIDefendGreen:defendBase(enemyTribesGreen[enemyNumber], 226, 158, 11, 6)
                AIDefendGreen:defendBase(enemyTribesGreen[enemyNumber], 216, 144, 12, 6)
                AIDefendGreen:defendBase(enemyTribesGreen[enemyNumber], 222, 130, 13, 6)
                AIDefendGreen:defendBase(enemyTribesGreen[enemyNumber], 206, 152, 14, 6)
            end

            for enemyNumber = 1, 3 do
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 194, 120, 15, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 188, 144, 16, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 174, 134, 17, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 174, 156, 18, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 158, 156, 19, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 166, 170, 20, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 150, 170, 21, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 144, 154, 22, 6)
                AIDefendCyan:defendBase(enemyTribesCyan[enemyNumber], 156, 142, 23, 6)
            end

            for enemyNumber = 1, 4 do
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 36, 252, 0, 6)
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 32, 48, 2, 6)
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 30, 30, 3, 6)
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 40, 18, 4, 6)
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 28, 6, 5, 6)
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 18, 236, 6, 6)
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 38, 234, 7, 6)
            end
        end

        

        AIShamanGreen:handleShamanCombat()
        AIShamanCyan:handleShamanCombat()
        AIShamanBlack:handleShamanCombat()

        --Fill up empty patrols
        if (every2Pow(9)) then
            MARKER_ENTRIES(TRIBE_BLACK, 0, -1, -1, -1)
            PREACH_AT_MARKER(TRIBE_BLACK, 2)
            PREACH_AT_MARKER(TRIBE_BLACK, 3)
            PREACH_AT_MARKER(TRIBE_BLACK, 4)
            PREACH_AT_MARKER(TRIBE_BLACK, 5)
            PREACH_AT_MARKER(TRIBE_BLACK, 6)

            PREACH_AT_MARKER(TRIBE_GREEN, 8)
            PREACH_AT_MARKER(TRIBE_GREEN, 9)
            PREACH_AT_MARKER(TRIBE_GREEN, 10)
            PREACH_AT_MARKER(TRIBE_GREEN, 11)
            PREACH_AT_MARKER(TRIBE_GREEN, 12)
            PREACH_AT_MARKER(TRIBE_GREEN, 13)
            PREACH_AT_MARKER(TRIBE_GREEN, 14)

            PREACH_AT_MARKER(TRIBE_CYAN, 15)
            PREACH_AT_MARKER(TRIBE_CYAN, 16)
            PREACH_AT_MARKER(TRIBE_CYAN, 17)
            PREACH_AT_MARKER(TRIBE_CYAN, 18)
            PREACH_AT_MARKER(TRIBE_CYAN, 19)
            PREACH_AT_MARKER(TRIBE_CYAN, 20)
            PREACH_AT_MARKER(TRIBE_CYAN, 21)
            PREACH_AT_MARKER(TRIBE_CYAN, 22)
            PREACH_AT_MARKER(TRIBE_CYAN, 23)
        end

       --Reset auto house timers this is so when the AI used braves they go back to their huts and produce mana again. Without this they'd stand around for a long time
       AIDefendGreen:checkToResetAutoHouseAfterDefendTimer()
       AIDefendCyan:checkToResetAutoHouseAfterDefendTimer()
       AIDefendBlack:checkToResetAutoHouseAfterDefendTimer()

       --Check spell delays for Shaman duels
       AIShamanGreen:checkSpellDelay()
       AIShamanCyan:checkSpellDelay()
       AIShamanBlack:checkSpellDelay()
end