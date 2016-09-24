local ADDON, Addon = ...
local Mod = Addon:NewModule('ProgressTracker')

local lastQuantity
local lastUnitDied

function Mod:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags)
	if event == "UNIT_DIED" then
		if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0 and bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 and bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
			local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", destGUID)
			lastUnitDied = npc_id
			print("died", npc_id)
		end
	end
end

function Mod:SCENARIO_CRITERIA_UPDATE()
	local scenarioType = select(10, C_Scenario.GetInfo())
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local numCriteria = select(3, C_Scenario.GetStepInfo())
		for criteriaIndex = 1, numCriteria do
			local criteriaString, criteriaType, _, quantity, totalQuantity, _, _, quantityString, _, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)
			if isWeightedProgress then
				local currentQuantity = quantityString and tonumber( strub(quantityString, 1, -2) )
				if lastQuantity and lastUnitDied and currentQuantity > lastQuantity then
					local amount = currentQuantity - lastQuantity
					if not AngryKeystones_Data[lastUnitDied] then AngryKeystones_Data[lastUnitDied] = {} end
					if AngryKeystones_Data[lastUnitDied][amount] then
						AngryKeystones_Data[lastUnitDied][amount] = AngryKeystones_Data[lastUnitDied][amount] + 1
					else
						AngryKeystones_Data[lastUnitDied][amount] = 1
					end
					print(lastUnitDied, amount)
					lastUnitDied = nil
					lastQuantity = currentQuantity
				end
			end
		end
	end
end

function Mod:Startup()
	if not AngryKeystones_Data then
		AngryKeystones_Data = {}
	end
	self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
end
