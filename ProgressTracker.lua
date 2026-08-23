local ADDON, Addon = ...
local Mod = Addon:NewModule('ProgressTracker')
local progressBar
local playerGUIDs = {}
local playerDeaths = {}

local function OnTooltipSetUnit(tooltip)
	local scenarioType = select(10, C_Scenario.GetInfo())
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE and Addon.Config.progressTooltip then

		local actualValue, percentValue, percentValueString = C_ScenarioInfo.GetUnitCriteriaProgressValues("mouseover")

		if actualValue and percentValueString then
			local forcesFormat = "(%s)"
			local text
			if Addon.Config.progressFormat == 1 or Addon.Config.progressFormat == 4 then
				text = format( format(forcesFormat, "+%s%%"), percentValueString)
			elseif Addon.Config.progressFormat == 2 or Addon.Config.progressFormat == 5 then
				text = format( format(forcesFormat, "+%d"), actualValue)
			elseif Addon.Config.progressFormat == 3 or Addon.Config.progressFormat == 6 then
				text = format( format(forcesFormat, "+%s%% - +%d"), percentValueString, actualValue)
			end

			local tiptext = _G["GameTooltipTextLeft6"]
			if tiptext then
				-- Replace tooltip line.
				tiptext:SetText(text)
			else
				-- Add tooltip line.
				tooltip:AddLine(text, 1, 1, 1)
			end

			tooltip:Show()

		end
	end
end

local function ProgressBar_SetValue(self, percent)
	local scenarioType = select(10, C_Scenario.GetInfo())

	if scenarioType ~= LE_SCENARIO_TYPE_CHALLENGE_MODE then return end

	local numCriteria = select(3, C_Scenario.GetStepInfo())
	local criteriaInfo

	for criteriaIndex = 1, numCriteria do
		local cInfo = C_ScenarioInfo.GetCriteriaInfo(criteriaIndex)
		if cInfo and cInfo.isWeightedProgress then
			criteriaInfo = cInfo
			break
		end
	end

	if not criteriaInfo then return end

	local totalQuantity = criteriaInfo.totalQuantity
	local quantityString = criteriaInfo.quantityString
	local currentQuantity = quantityString and tonumber( quantityString:match("%d+") )

	if currentQuantity and totalQuantity then
		if Addon.Config.progressFormat == 1 then
			self.Bar.Label:SetFormattedText("%.2f%%", currentQuantity/totalQuantity*100)
		elseif Addon.Config.progressFormat == 2 then
			self.Bar.Label:SetFormattedText("%d/%d", currentQuantity, totalQuantity)
		elseif Addon.Config.progressFormat == 3 then
			self.Bar.Label:SetFormattedText("%.2f%% - %d/%d", currentQuantity/totalQuantity*100, currentQuantity, totalQuantity)
		elseif Addon.Config.progressFormat == 4 then
			self.Bar.Label:SetFormattedText("%.2f%% (%.2f%%)", currentQuantity/totalQuantity*100, (totalQuantity-currentQuantity)/totalQuantity*100)
		elseif Addon.Config.progressFormat == 5 then
			self.Bar.Label:SetFormattedText("%d/%d (%d)", currentQuantity, totalQuantity, totalQuantity - currentQuantity)
		elseif Addon.Config.progressFormat == 6 then
			self.Bar.Label:SetFormattedText("%.2f%% (%.2f%%) - %d/%d (%d)", currentQuantity/totalQuantity*100, (totalQuantity-currentQuantity)/totalQuantity*100, currentQuantity, totalQuantity, totalQuantity - currentQuantity)
		end
	end
end

local function FindProgressBar()

	if progressBar then return end

	local usedBars = ScenarioObjectiveTracker.usedProgressBars or {}

	for _, bar in pairs(usedBars) do
		if bar.used then
			progressBar = bar
			hooksecurefunc(bar, "SetValue", ProgressBar_SetValue)
			break
		end
	end
end

hooksecurefunc(ScenarioObjectiveTracker.ObjectivesBlock, "AddProgressBar", FindProgressBar )

local function DeathCount_OnEnter(self)
	local parent = self:GetParent()

	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(parent.deathCount), 1, 1, 1)
	GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(SecondsToClock(parent.timeLost, false)))
	GameTooltip:AddLine(" ")

	local list = {}
	for playerGUID, count in pairs(playerDeaths) do
		local _, classFileName, _, _, _, name = GetPlayerInfoByGUID(playerGUID)
		table.insert(list, { count = count, name = name, classFileName = classFileName })
	end

	table.sort(list, function(a, b)
		if a.count ~= b.count then
			return a.count > b.count
		else
			return a.name < b.name
		end
	end)

	for _,item in ipairs(list) do
		local color = not issecretvalue(item.classFileName) and RAID_CLASS_COLORS[item.classFileName] or HIGHLIGHT_FONT_COLOR
		GameTooltip:AddDoubleLine(item.name, item.count, color.r, color.g, color.b, HIGHLIGHT_FONT_COLOR:GetRGB())
	end

	GameTooltip:Show()
end

local function StorePlayerGUIDs()
	wipe(playerGUIDs)

	playerGUIDs[UnitGUID("player")] = "player"

	for i = 1, 4 do
		local unit = "party"..i
		local playerGUID = UnitGUID(unit)
		if playerGUID then
			playerGUIDs[playerGUID] = unit
		end
	end
end

function Mod:PLAYER_ENTERING_WORLD()
	if not C_ChallengeMode.IsChallengeModeActive() then return end
	StorePlayerGUIDs()
end

function Mod:CHALLENGE_MODE_START()
	StorePlayerGUIDs()
end

function Mod:CHALLENGE_MODE_RESET()
	wipe(playerDeaths)
end

function Mod:UNIT_DIED(unitGUID)
	if not C_ChallengeMode.IsChallengeModeActive() then return end
	if issecretvalue(unitGUID) then return end
	if not playerGUIDs[unitGUID] then return end
	
	local unit = playerGUIDs[unitGUID]
	if UnitIsPlayer(unit) and not UnitIsFeignDeath(unit) then
		playerDeaths[unitGUID] = playerDeaths[unitGUID] and playerDeaths[unitGUID]+1 or 1
	end
		
end

function Mod:Blizzard_ObjectiveTracker()
	ScenarioObjectiveTracker.ChallengeModeBlock.DeathCount:SetScript("OnEnter", DeathCount_OnEnter)
end

function Mod:Startup()
	if not AngryKeystones_Data then
		AngryKeystones_Data = {}
	end
	if not AngryKeystones_Data.progress then
		AngryKeystones_Data = { progress = AngryKeystones_Data }
	end
	if not AngryKeystones_Data.state then AngryKeystones_Data.state = {} end
	local mapID = C_ChallengeMode.GetActiveChallengeMapID()
	if select(10, C_Scenario.GetInfo()) == LE_SCENARIO_TYPE_CHALLENGE_MODE and mapID and mapID == AngryKeystones_Data.state.mapID and AngryKeystones_Data.state.playerDeaths then
		playerDeaths = AngryKeystones_Data.state.playerDeaths
	else
		AngryKeystones_Data.state.mapID = nil
		AngryKeystones_Data.state.playerDeaths = playerDeaths
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHALLENGE_MODE_START")
	self:RegisterEvent("CHALLENGE_MODE_RESET")
	self:RegisterEvent("UNIT_DIED")
	self:RegisterAddOnLoaded("Blizzard_ObjectiveTracker")
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)

	Addon.Config:RegisterCallback('progressFormat', function()
		if progressBar then
			ProgressBar_SetValue(progressBar)
		end
	end)
end
