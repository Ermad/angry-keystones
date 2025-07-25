local ADDON, Addon = ...
local Mod = Addon:NewModule('Gossip')

local npcBlacklist = {
	[107435] = true, [112697] = true, [112699] = true, -- Suspicous Noble
	[101462] = true, -- Reaves
	[166663] = true, -- Kyrian Steward
}
local npcWhitelist = {
	[197300] = true, -- Azure Vault, Book of Translocation
}

local cosRumorNPC = 107486

local function GossipNPCID()
	local guid = UnitGUID("npc")
	local npcid = guid and select(6, strsplit("-", guid))
	return tonumber(npcid)
end

local function IsStaticPopupShown()
	for index = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..index]
		if frame and frame:IsShown() then
			return true
		end
	end
	return false
end

local function IsInActiveChallengeMode()
	local scenarioType = select(10, C_Scenario.GetInfo())
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local timerIDs = {GetWorldElapsedTimers()}
		for i, timerID in ipairs(timerIDs) do
			local _, elapsedTime, type = GetWorldElapsedTime(timerID)
			if type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then
				local mapID = C_ChallengeMode.GetActiveChallengeMapID()
				if mapID then
					return true
				end
			end
		end
	end
	return false
end

function Mod:CoSRumor()
	local clue = C_GossipInfo.GetText()
	local shortClue = Addon.Locale:Rumor(clue)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		SendChatMessage(shortClue or clue, "INSTANCE_CHAT")
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		SendChatMessage(shortClue or clue, "PARTY")
	else
		SendChatMessage(shortClue or clue, "SAY")
	end
end

function Mod:GOSSIP_SHOW()
	local npcId = GossipNPCID()
	local options = C_GossipInfo.GetOptions()
	local numOptions = #options

	if Addon.Config.cosRumors and Addon.Locale:HasRumors() and npcId == cosRumorNPC and numOptions == 0 then
		self:CoSRumor()
		C_GossipInfo.CloseGossip()
	end

	if numOptions ~= 1 then return end -- only automate one gossip option

	if Addon.Config.autoGossip and IsInActiveChallengeMode() and not npcBlacklist[npcId] then
		if npcWhitelist[npcId] or options[1].icon == 132053 or options[1].icon == 1019848 then -- the gossip icon, prevents auto-opening repair options etc
			local popupWasShown = IsStaticPopupShown()
			C_GossipInfo.SelectOption(options[1].gossipOptionID)
			local popupIsShown = IsStaticPopupShown()
			if popupIsShown then
				if not popupWasShown then
					StaticPopup1Button1:Click()
					C_GossipInfo.CloseGossip()
				end
			else
				C_GossipInfo.CloseGossip()
			end
		end
	end	
end

local function PlayCurrent()
	if IsInActiveChallengeMode() and Addon.Config.hideTalkingHead then
		TalkingHeadFrame:CloseImmediately()
	end
end

function Mod:Blizzard_TalkingHeadUI()
	hooksecurefunc("TalkingHeadFrame_PlayCurrent", PlayCurrent)
end

function Mod:Startup()
	if not AngryKeystones_Data then AngryKeystones_Data = {} end

	self:RegisterEvent("GOSSIP_SHOW")

	self:RegisterAddOnLoaded("Blizzard_TalkingHeadUI")
end
