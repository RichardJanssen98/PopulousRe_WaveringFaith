import(Module_DataTypes)
import(Module_Globals)
import(Module_Table)
import(Module_Players)
import(Module_Level)

PThing = {}

PThing.SpellSet = function (player, spell, input, charge)
  if (input == 0) then
    _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable ~ (1<<spell);
	else
		if (charge == 0) then
			_gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging = _gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging | (1<<spell-1);
		else
			_gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging = _gsi.ThisLevelInfo.PlayerThings[player].SpellsNotCharging ~ (1<<spell-1);
		end

		_gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailable | (1<<spell);
	end
end

PThing.BldgSet = function (player, building, input)
  if (input == 0) then
		_gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable ~ (1<<building);
	else
		_gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable = _gsi.ThisLevelInfo.PlayerThings[player].BuildingsAvailable | (1<<building);
	end
end

PThing.GiveShot = function (player, spell, amount)
  if (amount > 4) then
    _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailableOnce[spell] = 4
  else
    _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailableOnce[spell] = _gsi.ThisLevelInfo.PlayerThings[player].SpellsAvailableOnce[spell] + amount
  end
end
