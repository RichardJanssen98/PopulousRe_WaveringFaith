import(Module_DataTypes)
import(Module_Globals)
import(Module_Players)
import(Module_Table)

_gsi = gsi()
_sti = scenery_type_info()
_spti = spells_type_info()
_c = constants()

function GetTurn()
  return _gsi.Counts.GameTurn
end

function GetPlayerPeople(pn)
  return _gsi.Players[pn].NumPeople
end

function randSign()
  local a = -1
  if (G_RANDOM(2) == 0) then
    a = 1
  end
  return a
end

function everyPow(a,b)
  if (_gsi.Counts.GameTurn % a^b == 0) then
    return true else return false
  end
end

function every2Pow(a)
  if (_gsi.Counts.GameTurn % 2^a == 0) then
    return true else return false
  end
end

function DoesExist(table,input)
  for i,v in ipairs(table) do
    if (v == input) then
      return true
    end
  end

  return false
end

function GetPopLeader()
  local plr_pops = {}
  for i=0,7 do
    local pop = GetPlayerPeople(i)
    table.insert(plr_pops,pop)
  end

  local max = plr_pops[1];
  maxIndex = 1;

  for i,v in ipairs(plr_pops) do
    if (v > max) then
      maxIndex = i
      max = plr_pops[i]
    end
  end
  return maxIndex-1;
end

function tablelength(te)
  local count = 0
  for _ in pairs(te) do count = count + 1 end
  return count
end
