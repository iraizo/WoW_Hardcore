local _G = _G
local _achievement = CreateFrame("Frame")
_G.passive_achievements.Counterattack = _achievement

-- General info
_achievement.name = "Counterattack"
_achievement.title = "Finishing of the Kolkar"
_achievement.class = "All"
_achievement.icon_path = "Interface\\Addons\\Hardcore\\Media\\icon_counterattack.blp"
_achievement.level_cap = 20
_achievement.quest_num = 4021
_achievement.quest_name = "Counterattack!"
_achievement.zone = "The Barrens"
_achievement.kill_target = "Warlord Krom'zar"
_achievement.faction = "Horde"
_achievement.description = HCGeneratePassiveAchievementKillDescription(_achievement.kill_target, _achievement.quest_name, _achievement.zone, _achievement.level_cap, "Horde")
_achievement.restricted_game_versions = {
	["WotLK"] = 1,
}

-- Registers
function _achievement:Register(succeed_function_executor)
	_achievement:RegisterEvent("QUEST_TURNED_IN")
	_achievement.succeed_function_executor = succeed_function_executor 
end

function _achievement:Unregister()
	_achievement:UnregisterEvent("QUEST_TURNED_IN")
end
-- Register Definitions
_achievement:SetScript("OnEvent", function(self, event, ...)
	local arg = { ... }
	HCCommonPassiveAchievementKillCheck(_achievement, event, arg)
end)
