local ADDON, Addon = ...
local Mod = Addon:NewModule('ObjectiveTracker')

local TIME_FOR_3 = 0.6
local TIME_FOR_2 = 0.8

local function timeFormat(seconds)
	local hours = floor(seconds / 3600)
	local minutes = floor((seconds / 60) - (hours * 60))
	seconds = seconds - hours * 3600 - minutes * 60

	if hours == 0 then
		return format("%d:%.2d", minutes, seconds)
	else
		return format("%d:%.2d:%.2d", hours, minutes, seconds)
	end
end

local TimerFrame
local function UpdateTime(self, elapsedTime)
	local time3 = self.timeLimit * TIME_FOR_3
	local time2 = self.timeLimit * TIME_FOR_2

	TimerFrame.Bar3:SetShown(elapsedTime < time3)
	TimerFrame.Bar2:SetShown(elapsedTime < time2)

	if elapsedTime < time3 then
		TimerFrame.Text:SetText( timeFormat(time3 - elapsedTime) )
		TimerFrame.Text:SetTextColor(1, 0.843, 0)
		TimerFrame.Text:Show()
	elseif elapsedTime < time2 then
		TimerFrame.Text:SetText( timeFormat(time2 - elapsedTime) )
		TimerFrame.Text:SetTextColor(0.78, 0.78, 0.812)
		TimerFrame.Text:Show()
	else
		TimerFrame.Text:Hide()
	end
end

local function StartTime(timerID, mapID, timeLimit, elapsedTime)
	TimerFrame.timerID = timerID
	TimerFrame.timeLimit = timeLimit
	TimerFrame.baseTime = elapsedTime
	TimerFrame.timeSinceBase = 0
	TimerFrame.mapID = mapID
	TimerFrame:Show()
	UpdateTime(TimerFrame, elapsedTime)
end	

local function StopTime(timerID)
	if ( (not timerID or TimerFrame.timerID == timerID) ) then
		TimerFrame.timerID = nil
		TimerFrame.baseTime = nil
		TimerFrame.timeSinceBase = nil
		TimerFrame.mapID = nil
		TimerFrame:Hide()
	end
end

local function CheckTime(...)
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID)
		if type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then
			local _, _, _, _, _, _, _, mapID = GetInstanceInfo()
			if mapID then
				local _, _, timeLimit = C_ChallengeMode.GetMapInfo(mapID)
				StartTime(timerID, mapID, timeLimit, elapsedTime)
				return
			end
		end
	end

	StopTime()
end

local function TimerFrame_OnUpdate(self, elapsed)
	self.timeSinceBase = self.timeSinceBase + elapsed
	UpdateTime(TimerFrame, floor(self.baseTime + self.timeSinceBase))
end

local function TimerFrame_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		CheckTime(GetWorldElapsedTimers())
	elseif event == "WORLD_STATE_TIMER_START" then
		local timerID = ...
		CheckTime(timerID)
	elseif event == "WORLD_STATE_TIMER_STOP" then
		local timerID = ...
		StopTime(timerID)
	elseif event == "CHALLENGE_MODE_START" then
    	CheckTime(GetWorldElapsedTimers())
	end
end

function Mod:CreateTime()
	TimerFrame = CreateFrame("Frame", ADDON.."Frame", ScenarioChallengeModeBlock)
	TimerFrame:SetAllPoints(ScenarioChallengeModeBlock)
	-- TimerFrame:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
	-- TimerFrame:SetBackdropColor( 0.616, 0.149, 0.114, 0.9)
	
	TimerFrame.Text = TimerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	TimerFrame.Text:SetPoint("BOTTOMLEFT", ScenarioChallengeModeBlock.TimeLeft, "BOTTOMRIGHT", 2, 2)

	TimerFrame.Bar3 = TimerFrame:CreateTexture(nil, "OVERLAY")
	TimerFrame.Bar3:SetPoint("TOPLEFT", ScenarioChallengeModeBlock.StatusBar, "TOPLEFT", ScenarioChallengeModeBlock.StatusBar:GetWidth() * (1 - TIME_FOR_3) - 4, 0)
	TimerFrame.Bar3:SetSize(8, 10)
	TimerFrame.Bar3:SetTexture("Interface\\Addons\\AngryKeystones\\bar")
	TimerFrame.Bar3:SetTexCoord(0, 0.5, 0, 1)

	TimerFrame.Bar2 = TimerFrame:CreateTexture(nil, "OVERLAY")
	TimerFrame.Bar2:SetPoint("TOPLEFT", ScenarioChallengeModeBlock.StatusBar, "TOPLEFT", ScenarioChallengeModeBlock.StatusBar:GetWidth() * (1 - TIME_FOR_2) - 4, 0)
	TimerFrame.Bar2:SetSize(8, 10)
	TimerFrame.Bar2:SetTexture("Interface\\Addons\\AngryKeystones\\bar")
	TimerFrame.Bar2:SetTexCoord(0.5, 1, 0, 1)

	-- TimerFrame:Show()
	-- TimerFrame.Text:Show()
	-- TimerFrame.Text:SetText("13:01")

	TimerFrame:SetScript("OnEvent", TimerFrame_OnEvent)
	TimerFrame:SetScript("OnUpdate", TimerFrame_OnUpdate)

	TimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TimerFrame:RegisterEvent("WORLD_STATE_TIMER_START")
	TimerFrame:RegisterEvent("WORLD_STATE_TIMER_STOP")
	TimerFrame:RegisterEvent("CHALLENGE_MODE_START")
end

local function ProgressBar_SetValue(self, percent)
	if self.criteriaIndex then
		local _, _, _, _, totalQuantity, _, _, quantityString, _, _, _, _, _ = C_Scenario.GetCriteriaInfo(self.criteriaIndex)
		local currentQuantity = quantityString and tonumber( strsub(quantityString, 1, -2) )
		if currentQuantity and totalQuantity then
			self.Bar.Label:SetFormattedText("%.1f%% - %d/%d", currentQuantity/totalQuantity*100, currentQuantity, totalQuantity)
		end
	end
end

Mod:CreateTime()
hooksecurefunc("ScenarioTrackerProgressBar_SetValue", ProgressBar_SetValue)
