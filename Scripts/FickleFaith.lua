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

computer_init_player(_gsi.Players[TRIBE_YELLOW])
computer_init_player(_gsi.Players[TRIBE_PINK])

ai_Tribes = {TRIBE_YELLOW, TRIBE_PINK}

--Variables
defendTimerUntilNewDefend = 240
AIShamanYellow = AIShaman:new(nil, TRIBE_YELLOW, 1, 0, 0, 0, 0)
AIShamanPink = AIShaman:new(nil, TRIBE_PINK, 1, 0, 0, 0, 0)

spell_delay_yellow = 0
smartCastsBlastYellow = 0
yellowBuildIncreased = 0
yellowDefended = 0
yellowShamanDefX = 174
yellowShamanDefZ = 76
defend_tick_yellow = 0
yellowAutoHouseAfterDefendTimer = 0

spell_delay_green = 0
smartCastsBlastGreen = 0
greenDefended = 0
greenShamanDefX = 0
greenShamanDefZ = 0
defend_tick_green = 0
greenAutoHouseAfterDefendTimer = 0

spell_delay_cyan = 0
smartCastsBlastCyan = 0
cyanDefended = 0
cyanShamanDefX = 0
cyanShamanDefZ = 0
defend_tick_cyan = 0
cyanAutoHouseAfterDefendTimer = 0

spell_delay_pink = 0
smartCastsBlastPink = 0
pinkDefended = 0
pinkShamanDefX = 60
pinkShamanDefZ = 152
defend_tick_pink = 0
pinkAutoHouseAfterDefendTimer = 0

spell_delay_black = 0
smartCastsBlastBlack = 0
blackDefended = 0
blackShamanDefX = 0
blackShamanDefZ = 0
defend_tick_black = 0
blackAutoHouseAfterDefendTimer = 0

spell_delay_orange = 0
smartCastsBlastOrange = 0
orangeDefended = 0
orangeShamanDefX = 0
orangeShamanDefZ = 0
defend_tick_orange = 0
orangeAutoHouseAfterDefendTimer = 0

shaman_tick_yellow = GetTurn() + (2048 + G_RANDOM(2048))
shaman_tick_pink = GetTurn() + (2048 + G_RANDOM(2048))

botSpellsPink = {M_SPELL_CONVERT_WILD,
                    M_SPELL_BLAST
}
botBldgsPink = {M_BUILDING_TEPEE,
                   M_BUILDING_DRUM_TOWER,
                   M_BUILDING_SPY_TRAIN
}
botBldgsYellow = {M_BUILDING_TEPEE,
                   M_BUILDING_DRUM_TOWER,
                   M_BUILDING_TEMPLE
}
botSpellsYellow = {M_SPELL_CONVERT_WILD,
                    M_SPELL_BLAST}

for u,v in ipairs(botSpellsYellow) do
    PThing.SpellSet(TRIBE_YELLOW, v, TRUE, FALSE)
end

for y,v in ipairs(botBldgsYellow) do
    PThing.BldgSet(TRIBE_YELLOW, v, TRUE)
end


for u,v in ipairs(botSpellsPink) do
    PThing.SpellSet(TRIBE_PINK, v, TRUE, FALSE)
end

for y,v in ipairs(botBldgsPink) do
    PThing.BldgSet(TRIBE_PINK, v, TRUE)
end

--Set all Internal attributes and states for Yellow
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_EXPANSION, 25)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_HOUSE_PERCENTAGE, 180)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_MAX_BUILDINGS_ON_GO, 8)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_PREF_RELIGIOUS_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_PREF_RELIGIOUS_PEOPLE, 25)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_MAX_TRAIN_AT_ONCE, 6)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_BRAVE, 65)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_RELIGIOUS, 35)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_MEDICINE_MAN, 100)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_MAX_ATTACKS, 999)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_SHAMEN_BLAST, 64)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_USE_PREACHER_FOR_DEFENCE, 1)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_MAX_DEFENSIVE_ACTIONS, 999)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_RANDOM_BUILD_SIDE, 1)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_RETREAT_VALUE, 5)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_SPY_CHECK_FREQUENCY, 128)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_SPY_DISCOVER_CHANCE, 20)
WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_ENEMY_SPY_MAX_STAND, 128)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_DEFEND_BASE)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_FETCH_WOOD)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_CONSTRUCT_BUILDING)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_TRAIN_PEOPLE)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_AUTO_ATTACK)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_POPULATE_DRUM_TOWER)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_SUPER_DEFEND)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_FETCH_LOST_PEOPLE)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_BRING_NEW_PEOPLE_BACK)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_HOUSE_A_PERSON)
STATE_SET(TRIBE_YELLOW, TRUE, CP_AT_TYPE_PREACH)

SET_BUCKET_USAGE(TRIBE_YELLOW, TRUE)

SET_SPELL_ENTRY(TRIBE_YELLOW, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 0)
SET_SPELL_ENTRY(TRIBE_YELLOW, 1, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 1)

SET_DEFENCE_RADIUS(TRIBE_YELLOW, 8)

SET_MARKER_ENTRY(TRIBE_YELLOW, 0, 1, 1, 0, 0, 0, 0)

SHAMAN_DEFEND(TRIBE_YELLOW, yellowShamanDefX, yellowShamanDefZ, TRUE)
SET_DRUM_TOWER_POS(TRIBE_YELLOW, 174, 76)

--Set all Internal attributes and states for Pink
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_EXPANSION, 80)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_HOUSE_PERCENTAGE, 110)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_MAX_BUILDINGS_ON_GO, 12)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_MAX_TRAIN_AT_ONCE, 6)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_PREF_SPY_TRAINS, 1)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_PREF_SPY_PEOPLE, 8)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_MAX_ATTACKS, 999)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_SHAMEN_BLAST, 64)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_MAX_DEFENSIVE_ACTIONS, 999)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_RANDOM_BUILD_SIDE, 1)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_SPY_CHECK_FREQUENCY, 128)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_SPY_DISCOVER_CHANCE, 20)
WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_ENEMY_SPY_MAX_STAND, 128)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_DEFEND_BASE)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_FETCH_WOOD)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_CONSTRUCT_BUILDING)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_AUTO_ATTACK)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_POPULATE_DRUM_TOWER)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_MED_MAN_GET_WILD_PEEPS)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_BRING_NEW_PEOPLE_BACK)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_SUPER_DEFEND)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_FETCH_LOST_PEOPLE)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_TRAIN_PEOPLE)
STATE_SET(TRIBE_PINK, TRUE, CP_AT_TYPE_HOUSE_A_PERSON)

SET_BUCKET_USAGE(TRIBE_PINK, TRUE)

SET_SPELL_ENTRY(TRIBE_PINK, 0, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 0)
SET_SPELL_ENTRY(TRIBE_PINK, 1, M_SPELL_BLAST, SPELL_COST(M_SPELL_BLAST), 64, 1, 1)

SET_DEFENCE_RADIUS(TRIBE_PINK, 8)

SET_MARKER_ENTRY(TRIBE_PINK, 1, 3, 4, 8+G_RANDOM(4), 0, 0, 0)
SET_MARKER_ENTRY(TRIBE_PINK, 2, 7, 8, 6+G_RANDOM(3), 0, 0, 0)

SHAMAN_DEFEND(TRIBE_PINK, pinkShamanDefX, pinkShamanDefZ, TRUE)
SET_DRUM_TOWER_POS(TRIBE_PINK, 60, 152)

function OnTurn()
        if (everyPow(360, 1)) then
            for aiNumber = 1, 2 do
                if (_gsi.Players[ai_Tribes[aiNumber]].NumPeople < 79) then
                    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_BLAST, 8)
                    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_CONVERT_WILD, 8)
                else
                    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_BLAST, 4)
                    SET_BUCKET_COUNT_FOR_SPELL(ai_Tribes[aiNumber], M_SPELL_CONVERT_WILD, 4)
                end
            end
        end
        
        --Reset defend values
        ResetYellowDefend()
        ResetGreenDefend()
        ResetCyanDefend()
        ResetPinkDefend()
        ResetBlackDefend()
        ResetOrangeDefend()

        --Put a delay on defending to reduce lag
        if (everyPow(36, 1)) then
            --Intelligent Defense for Yellow
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 228, 80, 1, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 230, 110, 2, 6, 3, defendTimerUntilNewDefend)
            --[[DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 190, 86, 11, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 208, 78, 12, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 194, 64, 13, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 170, 76, 14, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 158, 60, 15, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 164, 104, 16, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_BLUE, 212, 98, 26, 6, 3, defendTimerUntilNewDefend)

            DefendBase(TRIBE_YELLOW, TRIBE_RED, 228, 80, 1, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 230, 110, 2, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 190, 86, 11, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 208, 78, 12, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 194, 64, 13, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 170, 76, 14, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 158, 60, 15, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 164, 104, 16, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_RED, 212, 98, 26, 6, 3, defendTimerUntilNewDefend)

            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 228, 80, 1, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 230, 110, 2, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 190, 86, 11, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 208, 78, 12, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 194, 64, 13, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 170, 76, 14, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 158, 60, 15, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 164, 104, 16, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_YELLOW, TRIBE_PINK, 212, 98, 26, 6, 3, defendTimerUntilNewDefend)--]]

           --[[ --Intelligent Defense for Pink
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 22, 116, 3, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 40, 130, 17, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 70, 124, 18, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 68, 154, 19, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 32, 152, 20, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 66, 178, 21, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 38, 174, 22, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 78, 194, 23, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_BLUE, 56, 194, 24, 6, 3, defendTimerUntilNewDefend)

            DefendBase(TRIBE_PINK, TRIBE_RED, 22, 116, 3, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 40, 130, 17, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 70, 124, 18, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 68, 154, 19, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 32, 152, 20, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 66, 178, 21, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 38, 174, 22, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 78, 194, 23, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_RED, 56, 194, 24, 6, 3, defendTimerUntilNewDefend)

            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 22, 116, 3, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 40, 130, 17, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 70, 124, 18, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 68, 154, 19, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 32, 152, 20, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 66, 178, 21, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 38, 174, 22, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 78, 194, 23, 6, 3, defendTimerUntilNewDefend)
            DefendBase(TRIBE_PINK, TRIBE_YELLOW, 56, 194, 24, 6, 3, defendTimerUntilNewDefend)--]]
        end

        --Yellow attacks
        --Decide who to attack
        if (GetTurn() > shaman_tick_yellow) then
            enemyTribeYellow = 0
            enemyToAttackYellow = G_RANDOM(3)+1
            local yellowPreachers = PLAYERS_PEOPLE_OF_TYPE(TRIBE_YELLOW, M_PERSON_RELIGIOUS)

            if (enemyToAttackYellow == 1) then
                enemyTribeYellow = TRIBE_PINK
            elseif (enemyToAttackYellow == 2) then
                enemyTribeYellow = TRIBE_BLUE
            elseif (enemyToAttackYellow == 3) then
                enemyTribeYellow = TRIBE_RED
            end
        end

        --Check if the enemy has a building to target
        if(GetTurn() > shaman_tick_yellow) then
            if (PLAYERS_BUILDING_OF_TYPE(enemyTribeYellow, M_BUILDING_TEPEE) > 0) then
                if (GetTurn() > shaman_tick_yellow and PLAYERS_PEOPLE_OF_TYPE(TRIBE_YELLOW, M_PERSON_SPY) > 1) then
                    if (NAV_CHECK(TRIBE_YELLOW, enemyTribeYellow, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_RELIGIOUS, 0)
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_MEDICINE_MAN, 0)
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_BRAVE, 0)
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_SPY, 100)
                        ATTACK(TRIBE_YELLOW, enemyTribeYellow, PLAYERS_PEOPLE_OF_TYPE(TRIBE_YELLOW, M_PERSON_SPY)-1, ATTACK_BUILDING, -1, 999, 0, 0, 0, ATTACK_NORMAL, 0, 11, -1, -1)

                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_RELIGIOUS, 35)
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_MEDICINE_MAN, 100)
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_BRAVE, 65)
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_SPY, 0)
                        log("Yellow Spy Attack")
                        shaman_tick_yellow = GetTUrn() + 360 + G_RANDOM(360)
                    end
                end
                --Scale attack based on population
                if (GetTurn() > shaman_tick_yellow and _gsi.Players[TRIBE_YELLOW].NumPeople > 80 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_YELLOW, M_PERSON_RELIGIOUS) > 6 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_YELLOW) and MANA(TRIBE_YELLOW) > 50000 and yellowDefended == 0) then
                    if (NAV_CHECK(TRIBE_YELLOW, enemyTribeYellow, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_RELIGIOUS, 35)
                        ATTACK(TRIBE_YELLOW, enemyTribeYellow, 16+G_RANDOM(20), ATTACK_BUILDING, -1, 450+G_RANDOM(550), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 27, -1, -1)
                        log("Yellow attack 3")
                        shaman_tick_yellow = GetTurn() + (3300 + G_RANDOM(2048))
                    end
                elseif (GetTurn() > shaman_tick_yellow and _gsi.Players[TRIBE_YELLOW].NumPeople > 65 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_YELLOW, M_PERSON_RELIGIOUS) > 6 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_YELLOW) and MANA(TRIBE_YELLOW) > 50000 and yellowDefended == 0) then
                    if (NAV_CHECK(TRIBE_YELLOW, enemyTribeYellow, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_RELIGIOUS, 35)
                        ATTACK(TRIBE_YELLOW, enemyTribeYellow, 10+G_RANDOM(15), ATTACK_BUILDING, -1, 350+G_RANDOM(350), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 27, -1, -1)
                        log("Yellow attack 2")
                        shaman_tick_yellow = GetTurn() + (2800 + G_RANDOM(2048))
                    end
                elseif (GetTurn() > shaman_tick_yellow and _gsi.Players[TRIBE_YELLOW].NumPeople > 40 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_YELLOW, M_PERSON_RELIGIOUS) > 4 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_YELLOW) and MANA(TRIBE_YELLOW) > 50000 and yellowDefended == 0) then
                    if (NAV_CHECK(TRIBE_YELLOW, enemyTribeYellow, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                        WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_RELIGIOUS, 35)
                        ATTACK(TRIBE_YELLOW, enemyTribeYellow, 6+G_RANDOM(9), ATTACK_BUILDING, -1, 250+G_RANDOM(250), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 27, -1, -1)
                        log("Yellow attack 1")
                        shaman_tick_yellow = GetTurn() + (2048 + G_RANDOM(2048))
                    end
                end
            end
        end

        --Pink attacks
        --Decide who to attack and what kind of attack
        if (GetTurn() > shaman_tick_pink) then
            enemyTribePink = 0
            enemyToAttackPink = G_RANDOM(3)+1
            attackTypePink = G_RANDOM(3)+1

            if (enemyToAttackPink == 1) then
                enemyTribePink = TRIBE_YELLOW
            elseif (enemyToAttackPink == 2) then
                enemyTribePink = TRIBE_BLUE
            elseif (enemyToAttackPink == 3) then
                enemyTribePink = TRIBE_RED
            end

            local pinkSpies = PLAYERS_PEOPLE_OF_TYPE(TRIBE_PINK, M_PERSON_SPY)
        end

        --Check if the enemy has a building to target
        if (GetTurn() > shaman_tick_pink) then
            if (PLAYERS_BUILDING_OF_TYPE(enemyTribePink, M_BUILDING_TEPEE) > 0) then
                 --Attack only Spies
                if (attackTypePink == 1) then
                    if (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 80 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_PINK, M_PERSON_SPY) > 14 and pinkDefended == 0) then
                        if (NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 0)
                            ATTACK(TRIBE_PINK, enemyTribePink, 6+G_RANDOM(6), ATTACK_BUILDING, -1, 450+G_RANDOM(550), 0, 0, 0, ATTACK_NORMAL, 0, 25, -1, -1)

                            log("Pink attack Spies 2")
                            shaman_tick_pink = GetTurn() + (3000 + G_RANDOM(2048))

                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                        end
                    elseif (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 40 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_PINK, M_PERSON_SPY) > 6 and pinkDefended == 0) then
                        if (NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 0)
                            ATTACK(TRIBE_PINK, enemyTribePink, 2+G_RANDOM(3), ATTACK_BUILDING, -1, 250+G_RANDOM(750), 0, 0, 0, ATTACK_NORMAL, 0, 25, -1, -1)

                            log("Pink attack Spies 1")
                            shaman_tick_pink = GetTurn() + (2048 + G_RANDOM(2048))

                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                        end
                    end
                --Attack only Braves + Shaman
                elseif (attackTypePink == 3) then
                    if (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 100 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_PINK) and MANA(TRIBE_PINK) > 50000 and pinkDefended == 0) then
                        if(NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                            ATTACK(TRIBE_PINK, enemyTribePink, 25 + G_RANDOM(26), ATTACK_BUILDING, -1, 600+G_RANDOM(400), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 28, -1, -1)

                            log("Pink attack Braves 3")
                            shaman_tick_pink = GetTurn() + (3600 + G_RANDOM(2048))
                        end
                    elseif (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 70 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_PINK) and MANA(TRIBE_PINK) > 50000 and pinkDefended == 0) then
                        if(NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                            ATTACK(TRIBE_PINK, enemyTribePink, 15 + G_RANDOM(16), ATTACK_BUILDING, -1, 450+G_RANDOM(450), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 28, -1, -1)

                            log("Pink attack Braves 2")
                            shaman_tick_pink = GetTurn() + (2700 + G_RANDOM(2048))
                        end
                    elseif (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 40 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_PINK) and MANA(TRIBE_PINK) > 50000 and pinkDefended == 0) then
                        if(NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                            ATTACK(TRIBE_PINK, enemyTribePink, 10 + G_RANDOM(11), ATTACK_BUILDING, -1, 350+G_RANDOM(350), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 28, -1, -1)

                            log("Pink attack Braves 1")
                            shaman_tick_pink = GetTurn() + (2048 + G_RANDOM(2048))
                        end
                    end
                --Attack mixed
                elseif (attackTypePink == 3) then 
                    if (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 100 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_PINK) and MANA(TRIBE_PINK) > 50000 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_PINK, M_PERSON_SPY) > 10 and pinkDefended == 0) then
                        if(NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 90)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 10)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                            ATTACK(TRIBE_PINK, enemyTribePink, 25 + G_RANDOM(26), ATTACK_BUILDING, -1, 600+G_RANDOM(400), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 28, -1, -1)

                            log("Pink attack Mixed 3")
                            shaman_tick_pink = GetTurn() + (3600 + G_RANDOM(2048))
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                        end
                    elseif (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 70 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_PINK) and MANA(TRIBE_PINK) > 50000 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_PINK, M_PERSON_SPY) > 8 and pinkDefended == 0) then
                        if(NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 90)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 10)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                            ATTACK(TRIBE_PINK, enemyTribePink, 15 + G_RANDOM(16), ATTACK_BUILDING, -1, 450+G_RANDOM(450), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 28, -1, -1)

                            log("Pink attack Mixed 2")
                            shaman_tick_pink = GetTurn() + (2700 + G_RANDOM(2048))
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                        end
                    elseif (GetTurn() > shaman_tick_pink and _gsi.Players[TRIBE_PINK].NumPeople > 40 and IS_SHAMAN_AVAILABLE_FOR_ATTACK(TRIBE_PINK) and MANA(TRIBE_PINK) > 50000 and PLAYERS_PEOPLE_OF_TYPE(TRIBE_PINK, M_PERSON_SPY) > 4 and pinkDefended == 0) then
                        if(NAV_CHECK(TRIBE_PINK, enemyTribePink, ATTACK_BUILDING, M_BUILDING_TEPEE, 0)) then
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 90)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 10)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                            ATTACK(TRIBE_PINK, enemyTribePink, 10 + G_RANDOM(11), ATTACK_BUILDING, -1, 350+G_RANDOM(350), M_SPELL_BLAST, M_SPELL_BLAST, M_SPELL_BLAST, ATTACK_NORMAL, 0, 28, -1, -1)

                            log("Pink attack Mixed 1")
                            shaman_tick_pink = GetTurn() + (2048 + G_RANDOM(2048))
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_BRAVE, 100)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_SPY, 0)
                            WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
                        end
                    end
                end
            end
        end

        AIShamanYellow:smartCasting()
        AIShamanPink:smartCasting()

        --Fill up empty patrols
        if (every2Pow(9)) then
            PREACH_AT_MARKER(TRIBE_YELLOW, 1)
            PREACH_AT_MARKER(TRIBE_YELLOW, 2)
            PREACH_AT_MARKER(TRIBE_YELLOW, 11)
            PREACH_AT_MARKER(TRIBE_YELLOW, 12)
            PREACH_AT_MARKER(TRIBE_YELLOW, 13)
            PREACH_AT_MARKER(TRIBE_YELLOW, 15)
            MARKER_ENTRIES(TRIBE_PINK, 1, 2, -1, -1)
        end

        --Reset auto house timers
        if (GetTurn() < yellowAutoHouseAfterDefendTimer) then
            SET_AUTO_HOUSE(TRIBE_YELLOW, TRUE)
        else
            SET_AUTO_HOUSE(TRIBE_YELLOW, FALSE)
        end
        if (GetTurn() < greenAutoHouseAfterDefendTimer) then
            SET_AUTO_HOUSE(TRIBE_GREEN, TRUE)
        else
            SET_AUTO_HOUSE(TRIBE_GREEN, FALSE)
        end
        if (GetTurn() < cyanAutoHouseAfterDefendTimer) then
            SET_AUTO_HOUSE(TRIBE_CYAN, TRUE)
        else
            SET_AUTO_HOUSE(TRIBE_CYAN, FALSE)
        end
        if (GetTurn() < pinkAutoHouseAfterDefendTimer) then
            SET_AUTO_HOUSE(TRIBE_PINK, TRUE)
        else
            SET_AUTO_HOUSE(TRIBE_PINK, FALSE)
        end
        if (GetTurn() < blackAutoHouseAfterDefendTimer) then
            SET_AUTO_HOUSE(TRIBE_BLACK, TRUE)
        else
            SET_AUTO_HOUSE(TRIBE_BLACK, FALSE)
        end
        if (GetTurn() < orangeAutoHouseAfterDefendTimer) then
            SET_AUTO_HOUES(TRIBE_ORANGE, TRUE)
        else
            SET_AUTO_HOUSE(TRIBE_ORANGE, FALSE)
        end

        AIShamanYellow:rechargeSpells()
        --AIShamanPink:rechargeSpells()
end

--Handle each AIs defences
function DefendBase(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, radius, defendersFractionOfAllUnits, defendTickCooldown)
    local enemyCount = CountEnemyPeopleInArea(tribe, enemyTribe, defendMarkerX, defendMarkerZ, radius)
    local myCount = CountMyPeopleInArea(tribe, defendMarkerX, defendMarkerZ, radius)

    --If there are enemies spotted around a marker check if you already have units there, if you have enough units then move Shaman only (otherwise she runs back to her tower) otherwise move Shaman and a force
    if (enemyCount > 0) then
                if (yellowDefended == 0 and tribe == TRIBE_YELLOW and myCount > 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    yellowDefended = 1
                    defend_tick_yellow = GetTurn() + defendTickCooldown
                elseif (yellowDefended == 0 and tribe == TRIBE_YELLOW and myCount < 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    SendDefendForce(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, defendersFractionOfAllUnits)
                    yellowDefended = 1
                    defend_tick_yellow = GetTurn() + defendTickCooldown
                end
                if (greenDefended == 0 and tribe == TRIBE_GREEN and myCount > 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    greenDefended = 1
                    defend_tick_green = GetTurn() + defendTickCooldown
                elseif (greenDefended == 0 and tribe == TRIBE_GREEN and myCount < 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    SendDefendForce(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, defendersFractionOfAllUnits)
                    greenDefended = 1
                    defend_tick_green = GetTurn() + defendTickCooldown
                end
                if (cyanDefended == 0 and tribe == TRIBE_CYAN and myCount > 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    cyanDefended = 1
                    defend_tick_cyan = GetTurn() + defendTickCooldown
                elseif (cyanDefended == 0 and tribe == TRIBE_CYAN and myCount < 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    SendDefendForce(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, defendersFractionOfAllUnits)
                    cyanDefended = 1
                    defend_tick_cyan = GetTurn() + defendTickCooldown
                end
                if (pinkDefended == 0 and tribe == TRIBE_PINK and myCount > 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    pinkDefended = 1
                    defend_tick_pink = GetTurn() + defendTickCooldown
                elseif (pinkDefended == 0 and tribe == TRIBE_PINK and myCount < 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    SendDefendForce(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, defendersFractionOfAllUnits)
                    pinkDefended = 1
                    defend_tick_pink = GetTurn() + defendTickCooldown
                end
                if (blackDefended == 0 and tribe == TRIBE_BLACK and myCount > 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    blackDefended = 1
                    defend_tick_black = GetTurn() + defendTickCooldown
                elseif (blackDefended == 0 and tribe == TRIBE_BLACK and myCount < 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    SendDefendForce(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, defendersFractionOfAllUnits)
                    blackDefended = 1
                    defend_tick_black = GetTurn() + defendTickCooldown
                end
                if (orangeDefended == 0 and tribe == TRIBE_ORANGE and myCount > 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    orangeDefended = 1
                    defend_tick_orange = GetTurn() + defendTickCooldown
                elseif (orangeDefended == 0 and tribe == TRIBE_ORANGE and myCount < 12) then
                    SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
                    SendDefendForce(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, defendersFractionOfAllUnits)
                    orangeDefended = 1
                    defend_tick_orange = GetTurn() + defendTickCooldown
                end
            end
end

--Count enemy followers in area around location inside a radius (preferably around marker to combine with defences)
function CountEnemyPeopleInArea(tribe, enemyTribe, defendMarkerX, defendMarkerZ, radius)
    local count = 0
    markerPos = MAP_XZ_2_WORLD_XYZ(defendMarkerX, defendMarkerZ)

      SearchMapCells(CIRCULAR, 0, 0, radius, world_coord3d_to_map_idx(markerPos), function(me)
        me.MapWhoList:processList(function (t)
          if (t.Type == T_PERSON) then
            if (t.Owner == enemyTribe and t.State ~= S_PERSON_BEING_PREACHED and is_person_a_spy_disguised_as_me(t, tribe) == 0 ) then
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
function CountMyPeopleInArea(tribe, defendMarkerX, defendMarkerZ, radius)
    local count = 0
    markerPos = MAP_XZ_2_WORLD_XYZ(defendMarkerX, defendMarkerZ)

      SearchMapCells(CIRCULAR, 0, 0, radius, world_coord3d_to_map_idx(markerPos), function(me)
        me.MapWhoList:processList(function (t)
          if (t.Type == T_PERSON) then
            if (t.Owner == tribe) then
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
function SendDefendShaman(tribe, marker, defendMarkerX, defendMarkerZ)
    WRITE_CP_ATTRIB(tribe, ATTR_AWAY_MEDICINE_MAN, 0)
    WRITE_CP_ATTRIB(tribe, ATTR_AWAY_RELIGIOUS, 0)
    WRITE_CP_ATTRIB(tribe, ATTR_DONT_GROUP_AT_DT, 1)
    WRITE_CP_ATTRIB(tribe, ATTR_GROUP_OPTION, 2)
    WRITE_CP_ATTRIB(tribe, ATTR_BASE_UNDER_ATTACK_RETREAT, 0)
    WRITE_CP_ATTRIB(tribe, ATTR_FIGHT_STOP_DISTANCE, 16)

    MOVE_SHAMAN_TO_MARKER(tribe, marker)
    SHAMAN_DEFEND(tribe, defendMarkerX, defendMarkerZ, TRUE)
end

--Send defence force
function SendDefendForce(tribe, enemyTribe, defendMarkerX, defendMarkerZ, marker, defendersFractionOfAllUnits)
    local defendAmount = _gsi.Players[tribe].NumPeople//defendersFractionOfAllUnits
    ATTACK(tribe, enemyTribe, defendAmount, ATTACK_MARKER, marker, 900, 0, 0, 0, ATTACK_NORMAL, 0, -1, -1, -1)
end

function ResetYellowDefend()
         if (GetTurn() == defend_tick_yellow and yellowDefended == 1) then
             yellowDefended = 0
             SHAMAN_DEFEND(TRIBE_YELLOW, yellowShamanDefX, yellowShamanDefZ, TRUE)
             WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_DONT_GROUP_AT_DT, 0)
             WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_GROUP_OPTION, 0)
             WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
             WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_FIGHT_STOP_DISTANCE, 26)
             WRITE_CP_ATTRIB(TRIBE_YELLOW, ATTR_AWAY_MEDICINE_MAN, 100)
             yellowAutoHouseAfterDefendTimer = GetTurn() + 360
         end
end

function ResetGreenDefend()
         if (GetTurn() == defend_tick_green and greenDefended == 1) then
             greenDefended = 0
             SHAMAN_DEFEND(TRIBE_GREEN, greenShamanDefX, greenShamanDefZ, TRUE)
             WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_DONT_GROUP_AT_DT, 0)
             WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_GROUP_OPTION, 0)
             WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
             WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_FIGHT_STOP_DISTANCE, 26)
             WRITE_CP_ATTRIB(TRIBE_GREEN, ATTR_AWAY_MEDICINE_MAN, 100)
             greenAutoHouseAfterDefendTimer = GetTurn() + 360
         end
end

function ResetCyanDefend()
         if (GetTurn() == defend_tick_cyan and cyanDefended == 1) then
             cyanDefended = 0
             SHAMAN_DEFEND(TRIBE_CYAN, cyanShamanDefX, cyanShamanDefZ, TRUE)
             WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_DONT_GROUP_AT_DT, 0)
             WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_GROUP_OPTION, 0)
             WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
             WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_FIGHT_STOP_DISTANCE, 26)
             WRITE_CP_ATTRIB(TRIBE_CYAN, ATTR_AWAY_MEDICINE_MAN, 100)
             cyanAutoHouseAfterDefendTimer = GetTurn() + 360
         end
end

function ResetPinkDefend()
         if (GetTurn() == defend_tick_pink and pinkDefended == 1) then
             pinkDefended = 0
             SHAMAN_DEFEND(TRIBE_PINK, pinkShamanDefX, pinkShamanDefZ, TRUE)
             WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_DONT_GROUP_AT_DT, 0)
             WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_GROUP_OPTION, 0)
             WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
             WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_FIGHT_STOP_DISTANCE, 26)
             WRITE_CP_ATTRIB(TRIBE_PINK, ATTR_AWAY_MEDICINE_MAN, 100)
             pinkAutoHouseAfterDefendTimer = GetTurn() + 360
         end
end

function ResetBlackDefend()
         if (GetTurn() == defend_tick_black and blackDefended == 1) then
             blackDefended = 0
             SHAMAN_DEFEND(TRIBE_BLACK, blackShamanDefX, blackShamanDefZ, TRUE)
             WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_DONT_GROUP_AT_DT, 0)
             WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_GROUP_OPTION, 0)
             WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
             WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_FIGHT_STOP_DISTANCE, 26)
             WRITE_CP_ATTRIB(TRIBE_BLACK, ATTR_AWAY_MEDICINE_MAN, 100)
             blackAutoHouseAfterDefendTimer = GetTurn() + 360
         end
end

function ResetOrangeDefend()
         if (GetTurn() == defend_tick_orange and orangeDefended == 1) then
             orangeDefended = 0
             SHAMAN_DEFEND(TRIBE_ORANGE, orangeShamanDefX, orangeShamanDefZ, TRUE)
             WRITE_CP_ATTRIB(TRIBE_ORANGE, ATTR_DONT_GROUP_AT_DT, 0)
             WRITE_CP_ATTRIB(TRIBE_ORANGE, ATTR_GROUP_OPTION, 0)
             WRITE_CP_ATTRIB(TRIBE_ORANGE, ATTR_BASE_UNDER_ATTACK_RETREAT, 1)
             WRITE_CP_ATTRIB(TRIBE_ORANGE, ATTR_FIGHT_STOP_DISTANCE, 26)
             WRITE_CP_ATTRIB(TRIBE_ORANGE, ATTR_AWAY_MEDICINE_MAN, 100)
             orangeAutoHouseAfterDefendTimer = GetTurn() + 360
         end
end