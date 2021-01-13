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

alliesGreen = {TRIBE_CYAN}
alliesCyan = {TRIBE_GREEN}

AIShamanGreen = AIShaman:new(nil, TRIBE_GREEN, 1, 0, 0, 0, 0, alliesGreen)
AIShamanCyan = AIShaman:new(nil, TRIBE_CYAN, 1, 0, 0, 0, 0, alliesCyan)
AIShamanBlack = AIShaman:new(nil, TRIBE_BLACK, 1, 0, 0, 1, 0, 0)

AIDefendGreen = AIDefend:new(nil, TRIBE_GREEN, 226, 140, defendTimerUntilNewDefend, 3, 1, 500, 1)
AIDefendCyan = AIDefend:new(nil, TRIBE_CYAN, 164, 152, defendTimerUntilNewDefend, 3, 1, 500, 1)
AIDefendBlack = AIDefend:new(nil, TRIBE_BLACK, 34, 10, defendTimerUntilNewDefend, 3, 1, 500, 1)

shaman_tick_green = GetTurn() + (2048 + G_RANDOM(2048))
shaman_tick_cyan = GetTurn() + (2048 + G_RANDOM(2048))
shaman_tick_black = GetTurn() + (2048 + G_RANDOM(2048))

heightCache = {GET_HEIGHT_AT_POS(38), GET_HEIGHT_AT_POS(39), GET_HEIGHT_AT_POS(40), GET_HEIGHT_AT_POS(41)}

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
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PREF_BOAT_DRIVERS, 8)
WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_PEOPLE_PER_BOAT, 6)
STATE_SET(TRIBE_CYAN, TRUE, CP_AT_TYPE_BUILD_VEHICLE)

SHAMAN_DEFEND(TRIBE_CYAN, 164, 152, TRUE)
SET_DRUM_TOWER_POS(TRIBE_CYAN, 164, 152)

--Set all Internal attributes and states for Black
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_EXPANSION, 25)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_HOUSE_PERCENTAGE, 50)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_MAX_BUILDINGS_ON_GO, 4)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_PREF_RELIGIOUS_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_PREF_RELIGIOUS_PEOPLE, 35)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_PREF_BOAT_DRIVERS, 6)
WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_PEOPLE_PER_BOAT, 7)

SHAMAN_DEFEND(TRIBE_BLACK, 34, 10, TRUE)
SET_DRUM_TOWER_POS(TRIBE_BLACK, 34, 10)

for aiNumber = 1, 3 do
    SET_BUCKET_USAGE(ai_Tribes[aiNumber], TRUE)

    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_BLAST, 4)
    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_CONVERT_WILD, 4)

    SET_SPELL_ENTRY(ai_Tribes[aiNumber], 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 0)
    SET_SPELL_ENTRY(ai_Tribes[aiNumber], 1, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 1)

    SET_DEFENCE_RADIUS(ai_Tribes[aiNumber], 4)

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
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_FETCH_FAR_VEHICLE)
    STATE_SET(ai_Tribes[aiNumber], TRUE, CP_AT_TYPE_FETCH_LOST_VEHICLE)
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
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 18, 238, 6, 5)
                AIDefendBlack:defendBase(enemyTribesBlack[enemyNumber], 38, 234, 7, 6)
            end
        end

        if (everyPow(1440, 1)) then
            local h1 = GET_HEIGHT_AT_POS(38)
            local h2 = GET_HEIGHT_AT_POS(39)
            local h3 = GET_HEIGHT_AT_POS(40)
            local h4 = GET_HEIGHT_AT_POS(41)

            enemyToAttackBridge = enemyTribesCyan[G_RANDOM(#enemyTribesCyan)+1]

            --Make path to Stone Head as Cyan 
            if (MANA(TRIBE_CYAN) >= SPELL_COST(M_SPELL_LAND_BRIDGE)) then
                if (_gsi.Players[enemyToAttackBridge].NumPeople > 0) then
                    if (h1 == heightCache[1]) then
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
                        ATTACK(TRIBE_CYAN, enemyToAttackBridge, 0, ATTACK_PERSON, -1, 0, M_SPELL_LAND_BRIDGE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, 24, 25, -1)
                    elseif (h2 == heightCache[2]) then
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
                        ATTACK(TRIBE_CYAN, enemyToAttackBridge, 0, ATTACK_PERSON, -1, 0, M_SPELL_LAND_BRIDGE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, 26, 27, -1)
                    elseif (h3 == heightCache[3]) then
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
                        ATTACK(TRIBE_CYAN, enemyToAttackBridge, 0, ATTACK_PERSON, -1, 0, M_SPELL_LAND_BRIDGE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, 28, 29, -1)
                    end
                end
            end

            --Make path to Blue as Black
            if (MANA(TRIBE_BLACK) >= SPELL_COST(M_SPELL_LAND_BRIDGE)) then
                if (_gsi.Players[enemyToAttackBridge].NumPeople > 0) then
                    if (h4 == heightCache[4]) then
                        WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_MEDICINE_MAN, 100)
                        ATTACK(TRIBE_BLACK, enemyToAttackBridge, 0, ATTACK_PERSON, -1, 0, M_SPELL_LAND_BRIDGE, M_SPELL_NONE, M_SPELL_NONE, ATTACK_NORMAL, 0, 35, 36, -1)
                    end
                end
            end

            --Let Green or Cyan pray at the stone head, bigger chance for Green.
            local CyanOrGreen = G_RANDOM(3)+1 
            if (CyanOrGreen == 1) then
                if (NAV_CHECK(TRIBE_CYAN, enemyToAttackBridge, ATTACK_MARKER, 37, 0)) then
                    PRAY_AT_HEAD(TRIBE_CYAN, 5, 37)
                end
            elseif (CyanOrGreen >= 2) then
                if (NAV_CHECK(TRIBE_GREEN, enemyToAttackBridge, ATTACK_MARKER, 37, 0)) then
                    PRAY_AT_HEAD(TRIBE_GREEN, 5, 37)
                end
            end
        end
        
        --Cyan attacks
        --Decide who to attack
        if (GetTurn() > shaman_tick_cyan) then
            enemyToAttackCyan = enemyTribesCyan[G_RANDOM(#enemyTribesCyan)+1]

            attackMethodCyan = G_RANDOM(2) + 1

            if (I_HAVE_ONE_SHOT(TRIBE_CYAN, T_SPELL, M_SPELL_SWAMP) == 1) then
                firstSpellCyan = M_SPELL_SWAMP
            else
                firstSpellCyan = M_SPELL_BLAST
            end
        end

        --Attack on foot, for everyone, but most likely Red
        if (attackMethodCyan == 1) then
            if (GetTurn() > shaman_tick_cyan and PLAYERS_BUILDING_OF_TYPE(enemyToAttackCyan, M_BUILDING_TEPEE) > 0) then
                if (NAV_CHECK(TRIBE_CYAN, enemyToAttackCyan, ATTACK_BUILDING, -1, 0)) then
                    if (_gsi.Players[TRIBE_CYAN].NumPeople > 60 and cyanDefended == 0 and MANA(TRIBE_CYAN) > 50000) then
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_BRAVE, 60)
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_RELIGIOUS, 40)
                        ATTACK(TRIBE_CYAN, enemyToAttackCyan, 15+G_RANDOM(20), ATTACK_BUILDING, -1, 600+G_RANDOM(400), firstSpellCyan, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, -1, -1, -1)
                        shaman_tick_cyan = GetTurn() + 2048 + G_RANDOM(2048)
                    elseif (_gsi.Players[TRIBE_CYAN].NumPeople > 40 and cyanDefended == 0 and MANA(TRIBE_CYAN) > 50000) then
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_BRAVE, 60)
                        WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_RELIGIOUS, 40)
                        ATTACK(TRIBE_CYAN, enemyToAttackCyan, 10+G_RANDOM(11), ATTACK_BUILDING, -1, 250+G_RANDOM(500), firstSpellCyan, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, -1, -1, -1)
                        shaman_tick_cyan = GetTurn() + 2048 + G_RANDOM(2048)
                    end
                end
            end
        --Attack by boat
        elseif (attackMethodCyan == 2) then
            --Don't bring back boats if it's Black to give them the opportunity to attack others too.
            local bringBackBoats = 1
            local markerToLand = 0

            if (enemyToAttackCyan == TRIBE_BLACK) then
                bringBackBoats = 0
            end

            --Set landing point based on enemy
            if (enemyToAttackCyan == TRIBE_BLUE) then
                local rnd = G_RANDOM(2) + 1
                if (rnd == 1) then
                    markerToLand = 31
                else
                    markerToLand = 32
                end
            end
            if (enemyToAttackCyan == TRIBE_RED) then
                local rnd = G_RANDOM(2) + 1
                if (rnd == 1) then
                    markerToLand = 33
                else
                    markerToLand = 34
                end
            end
            if (enemyToAttackCyan == TRIBE_BLACK) then
                markerToLand = 30
            end

            --Attack with boats and bring them back if the enemy is not Black
            if (GetTurn() > shaman_tick_cyan and _gsi.Players[TRIBE_CYAN].NumPeople > 60 and GET_NUM_OF_AVAILABLE_BOATS(TRIBE_CYAN) > 3 and MANA(TRIBE_CYAN) > 50000 and cyanDefended == 0) then
                WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
                WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_BRAVE, 60)
                WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_RELIGIOUS, 40)
                ATTACK(TRIBE_CYAN, enemyToAttackCyan, 12+G_RANDOM(20), ATTACK_BUILDING, -1, 600+G_RANDOM(400), firstSpellCyan, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_BY_BOAT, bringBackBoats, markerToLand, -1, -1)
                shaman_tick_cyan = GetTurn() + 2048 + G_RANDOM(2048)
            elseif (GetTurn() > shaman_tick_cyan and _gsi.Players[TRIBE_CYAN].NumPeople > 40 and GET_NUM_OF_AVAILABLE_BOATS(TRIBE_CYAN) > 5 and MANA(TRIBE_CYAN) > 50000 and cyanDefended == 0) then
                WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
                WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_BRAVE, 60)
                WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_RELIGIOUS, 40)
                ATTACK(TRIBE_CYAN, enemyToAttackCyan, 8+G_RANDOM(11), ATTACK_BUILDING, -1, 250+G_RANDOM(400), firstSpellCyan, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_BY_BOAT, bringBackBoats, markerToLand, -1, -1)
                shaman_tick_cyan = GetTurn() + 2048 + G_RANDOM(2048)
            end
        end

        --Green attacks
        --Decide who to attack
        if (GetTurn() > shaman_tick_green) then
            enemyToAttackGreen = enemyTribesGreen[G_RANDOM(#enemyTribesGreen)+1]

            if (I_HAVE_ONE_SHOT(TRIBE_GREEN, T_SPELL, M_SPELL_SWAMP) == 1) then
                firstSpellGreen = M_SPELL_SWAMP
            else
                firstSpellGreen = M_SPELL_BLAST
            end
        end

        if (GetTurn() > shaman_tick_green and PLAYERS_BUILDING_OF_TYPE(enemyToAttackGreen, M_BUILDING_TEPEE) > 0) then
            if (NAV_CHECK(TRIBE_GREEN, enemyToAttackGreen, ATTACK_BUILDING, -1, 0)) then
                if (_gsi.Players[TRIBE_GREEN].NumPeople > 60 and MANA(TRIBE_GREEN) > 50000 and greenDefended == 0) then
                    WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_AWAY_MEDICINE_MAN, 100)
                    WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_AWAY_BRAVE, 60)
                    WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_AWAY_RELIGIOUS, 40)
                    ATTACK(TRIBE_GREEN, enemyToAttackGreen, 10 + G_RANDOM(18), ATTACK_BUILDING, -1, 400+G_RANDOM(400), firstSpellGreen, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, -1, -1, -1)
                    shaman_tick_green = GetTurn() + 2048 + G_RANDOM(2048)
                elseif (_gsi.Players[TRIBE_GREEN].NumPeople > 40 and MANA(TRIBE_GREEN) > 50000 and greenDefended == 0) then
                    WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_AWAY_MEDICINE_MAN, 100)
                    WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_AWAY_BRAVE, 60)
                    WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_AWAY_RELIGIOUS, 40)
                    ATTACK(TRIBE_GREEN, enemyToAttackGreen, 8 + G_RANDOM(14), ATTACK_BUILDING, -1, 250+G_RANDOM(400), firstSpellGreen, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, -1, -1, -1)
                    shaman_tick_green = GetTurn() + 2048 + G_RANDOM(2048)
                end
            end
        end

        --Black attacks
        --Decide who to Attack
        if (GetTurn() > shaman_tick_black) then
            enemyToAttackBlack = enemyTribesBlack[G_RANDOM(#enemyTribesBlack)+1]

            attackMethodBlack = G_RANDOM(2) + 1
        end

        if (attackMethodBlack == 1) then
            if (GetTurn() > shaman_tick_black and PLAYERS_BUILDING_OF_TYPE(enemyToAttackBlack, M_BUILDING_TEPEE) > 0) then
                if (NAV_CHECK(TRIBE_BLACK, enemyToAttackBlack, ATTACK_BUILDING, -1, 0)) then
                    if (_gsi.Players[TRIBE_BLACK].NumPeople > 60 and MANA(TRIBE_BLACK) > 90000 and blackDefended == 0) then
                        WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_MEDICINE_MAN, 100)
                        WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_BRAVE, 60)
                        WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_RELIGIOUS, 40)
                        ATTACK(TRIBE_BLACK, enemyToAttackBlack, 15 + G_RANDOM(20), ATTACK_BUILDING, -1, 500+G_RANDOM(500), M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, M_SPELL_BLAST, ATTACK_NORMAL, 0, -1, -1, -1)
                        shaman_tick_black = GetTurn() + 2048 + G_RANDOM(2048)
                    elseif (_gsi.Players[TRIBE_BLACK].NumPeople > 40 and MANA(TRIBE_BLACK) > 60000 and blackDefended == 0) then
                        WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_MEDICINE_MAN, 100)
                        WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_BRAVE, 60)
                        WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_RELIGIOUS, 40)
                        ATTACK(TRIBE_BLACK, enemyToAttackBlack, 10 + G_RANDOM(17), ATTACK_BUILDING, -1, 500+G_RANDOM(500), M_SPELL_INSECT_PLAGUE, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, -1, -1, -1)
                        shaman_tick_black = GetTurn() + 2048 + G_RANDOM(2048)
                    end
                end
            end
        elseif (attackMethodBlack == 2 and GET_NUM_OF_AVAILABLE_BOATS(TRIBE_BLACK) > 3) then
            local markerToLand = 0

            --Set landing point based on enemy
            if (enemyToAttackBlack == TRIBE_BLUE) then
                local rnd = G_RANDOM(2) + 1
                if (rnd == 1) then
                    markerToLand = 31
                else
                    markerToLand = 32
                end
            end
            if (enemyToAttackBlack == TRIBE_RED) then
                local rnd = G_RANDOM(2) + 1
                if (rnd == 1) then
                    markerToLand = 33
                else
                    markerToLand = 34
                end
            end
            if (enemyToAttackBlack == TRIBE_CYAN) then
                local rnd = G_RANDOM(2) + 1
                if (rnd == 1) then
                    markerToLand = 44
                else
                    markerToLand = 45
                end
            end
            if (enemyToAttackBlack == TRIBE_GREEN) then
                local rnd = G_RANDOM(2) + 1
                if (rnd == 1) then
                    markerToLand = 42
                else
                    markerToLand = 43
                end
            end

            if (GetTurn() > shaman_tick_black and _gsi.Players[TRIBE_BLACK].NumPeople > 60 and GET_NUM_OF_AVAILABLE_BOATS(TRIBE_BLACK) > 3 and MANA(TRIBE_BLACK) > 90000 and blackDefended == 0) then
                WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_MEDICINE_MAN, 100)
                WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_BRAVE, 60)
                WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_RELIGIOUS, 40)
                ATTACK(TRIBE_BLACK, enemyToAttackBlack, 12+G_RANDOM(20), ATTACK_BUILDING, -1, 600+G_RANDOM(400), M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, M_SPELL_BLAST, ATTACK_BY_BOAT, 1, markerToLand, -1, -1)
                shaman_tick_black = GetTurn() + 2048 + G_RANDOM(2048)
            elseif (GetTurn() > shaman_tick_black and _gsi.Players[TRIBE_BLACK].NumPeople > 40 and GET_NUM_OF_AVAILABLE_BOATS(TRIBE_BLACK) > 5 and MANA(TRIBE_BLACK) > 60000 and blackDefended == 0) then
                WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_MEDICINE_MAN, 100)
                WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_BRAVE, 60)
                WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_RELIGIOUS, 40)
                ATTACK(TRIBE_BLACK, enemyToAttackBlack, 8+G_RANDOM(11), ATTACK_BUILDING, -1, 250+G_RANDOM(400), M_SPELL_INSECT_PLAGUE, M_SPELL_INSECT_PLAGUE, M_SPELL_BLAST, ATTACK_BY_BOAT, 1, markerToLand, -1, -1)
                shaman_tick_black = GetTurn() + 2048 + G_RANDOM(2048)
            end
        end

        AIShamanGreen:handleShamanCombat()
        AIShamanCyan:handleShamanCombat()
        AIShamanBlack:handleShamanCombat()

        --Fill up empty patrols
        if (every2Pow(9)) then
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