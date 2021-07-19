local ADDON, Addon = ...
local Mod = Addon:NewModule('Schedule')

local rowCount = 3

local requestPartyKeystones

local currentKeystoneMapID
local currentKeystoneLevel
local unitKeystones = {}

local function GetNameForKeystone(keystoneMapID, keystoneLevel)
	local keystoneMapName = keystoneMapID and C_ChallengeMode.GetMapUIInfo(keystoneMapID)
	if keystoneMapID and keystoneMapName then
		return string.format("%s (%d)", keystoneMapName, keystoneLevel)
	end
end

local function UpdatePartyKeystones()
	Mod:CheckCurrentKeystone()
	if requestPartyKeystones then
		Mod:SendPartyKeystonesRequest()
	end

	if not IsAddOnLoaded("Blizzard_ChallengesUI") then return end

	local playerRealm = select(2, UnitFullName("player"))

	local e = 1
	for i = 1, 4 do
		local entry = Mod.PartyFrame.Entries[e]
		local name, realm = UnitName("party"..i)

		if name then
			local fullName
			if not realm or realm == "" then
				fullName = name.."-"..playerRealm
			else
				fullName = name.."-"..realm
			end

			if unitKeystones[fullName] ~= nil then
				local keystoneName
				if unitKeystones[fullName] == 0 then
					keystoneName = NONE
				else
					keystoneName = GetNameForKeystone(unitKeystones[fullName][1], unitKeystones[fullName][2])
				end
				if keystoneName then
					entry:Show()
					local _, class = UnitClass("party"..i)
					local color = RAID_CLASS_COLORS[class]
					entry.Text:SetText(name)
					entry.Text:SetTextColor(color:GetRGBA())

					local _, suffix = strsplit("-", keystoneName)
					if suffix then
						keystoneName = suffix
					end
					entry.Text2:SetText(keystoneName)

					e = e + 1
				end
			end
		end
	end
	if e == 1 then
		Mod.AffixFrame:ClearAllPoints()
		Mod.AffixFrame:SetPoint("LEFT", ChallengesFrame.WeeklyInfo.Child.WeeklyChest, "RIGHT", 130, 0)
		Mod.PartyFrame:Hide()
	else
		Mod.AffixFrame:ClearAllPoints()
		Mod.AffixFrame:SetPoint("TOPLEFT", ChallengesFrame.WeeklyInfo.Child.WeeklyChest, "TOPRIGHT", 130, 55)
		Mod.PartyFrame:Show()
	end
	while e <= 4 do
		Mod.PartyFrame.Entries[e]:Hide()
		e = e + 1
	end
end

local function UpdateFrame()
	Mod.PartyFrame:Show()
	Mod.KeystoneText:Show()

	local weeklyChest = ChallengesFrame.WeeklyInfo.Child.WeeklyChest
	weeklyChest:ClearAllPoints()
	weeklyChest:SetPoint("LEFT", 150, 0)

	local description = ChallengesFrame.WeeklyInfo.Child.Description
	description:SetWidth(240)
	description:ClearAllPoints()
	description:SetPoint("TOP", weeklyChest, "TOP", 0, 75)

	local currentKeystoneName = GetNameForKeystone(C_MythicPlus.GetOwnedKeystoneChallengeMapID(), C_MythicPlus.GetOwnedKeystoneLevel())
	if currentKeystoneName then
		Mod.KeystoneText:Show()
		Mod.KeystoneText:SetText( string.format(Addon.Locale.currentKeystoneText, currentKeystoneName) )
	else
		Mod.KeystoneText:Hide()
	end

	UpdatePartyKeystones()
end

local function makeAffix(parent)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(16, 16)

	local border = frame:CreateTexture(nil, "OVERLAY")
	border:SetAllPoints()
	border:SetAtlas("ChallengeMode-AffixRing-Sm")
	frame.Border = border

	local portrait = frame:CreateTexture(nil, "ARTWORK")
	portrait:SetSize(14, 14)
	portrait:SetPoint("CENTER", border)
	frame.Portrait = portrait

	frame.SetUp = ScenarioChallengeModeAffixMixin.SetUp
	frame:SetScript("OnEnter", ScenarioChallengeModeAffixMixin.OnEnter)
	frame:SetScript("OnLeave", GameTooltip_Hide)

	return frame
end

function Mod:Blizzard_ChallengesUI()
	-- Party keys
	local frame2 = CreateFrame("Frame", nil, ChallengesFrame)
	frame2:SetSize(246, 110)
	frame2:SetPoint("TOPLEFT", ChallengesFrame.WeeklyInfo.Child.WeeklyChest, "TOPRIGHT", 70, 0)
	Mod.PartyFrame = frame2

	local bg2 = frame2:CreateTexture(nil, "BACKGROUND")
	bg2:SetAllPoints()
	bg2:SetAtlas("ChallengeMode-guild-background")
	bg2:SetAlpha(0.4)

	local title2 = frame2:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	title2:SetText(Addon.Locale.partyKeysTitle)
	title2:SetPoint("TOPLEFT", 15, -7)

	local line2 = frame2:CreateTexture(nil, "ARTWORK")
	line2:SetSize(232, 9)
	line2:SetAtlas("ChallengeMode-RankLineDivider", false)
	line2:SetPoint("TOP", 0, -20)

	local entries2 = {}
	for i = 1, 4 do
		local entry = CreateFrame("Frame", nil, frame2)
		entry:SetSize(216, 18)

		local text = entry:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		text:SetWidth(120)
		text:SetJustifyH("LEFT")
		text:SetWordWrap(false)
		text:SetText()
		text:SetPoint("LEFT")
		entry.Text = text

		local text2 = entry:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		text2:SetWidth(180)
		text2:SetJustifyH("RIGHT")
		text2:SetWordWrap(false)
		text2:SetText()
		text2:SetPoint("RIGHT")
		entry.Text2 = text2

		if i == 1 then
			entry:SetPoint("TOP", line2, "BOTTOM")
		else
			entry:SetPoint("TOP", entries2[i-1], "BOTTOM")
		end

		entries2[i] = entry
	end
	frame2.Entries = entries2

	-- Current key name
	local keystoneText = ChallengesFrame.WeeklyInfo.Child:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
	keystoneText:SetPoint("TOP", ChallengesFrame.WeeklyInfo.Child.WeeklyChest, "BOTTOM", 170, -100)
	keystoneText:SetWidth(400)
	Mod.KeystoneText = keystoneText

	hooksecurefunc("ChallengesFrame_Update", UpdateFrame)
end

function Mod:GetInventoryKeystone()
	for container=BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = GetContainerNumSlots(container)
		for slot=1, slots do
			local _, _, _, _, _, _, slotLink = GetContainerItemInfo(container, slot)
			local itemString = slotLink and slotLink:match("|Hkeystone:([0-9:]+)|h(%b[])|h")
			if itemString then
				return slotLink, itemString
			end
		end
	end
end

local bagUpdateTimerStarted = false
function Mod:BAG_UPDATE()
	if not bagUpdateTimerStarted then
		bagUpdateTimerStarted = true
		C_Timer.After(1, function()
			Mod:CheckCurrentKeystone()
			bagUpdateTimerStarted = false
		end)
	end
end

function Mod:CHAT_MSG_LOOT(...)
	local lootString, _, _, _, unit = ...
	if string.match(lootString, "|Hitem:158923:") then
		if UnitName("player") == unit then
			self:CheckCurrentKeystone()
		else
			self:SetPartyKeystoneRequest()
		end
	end
end

function Mod:SetPartyKeystoneRequest()
	requestPartyKeystones = true
	if IsAddOnLoaded("Blizzard_ChallengesUI") and ChallengesFrame:IsShown() then
		self:SendPartyKeystonesRequest()
		UpdatePartyKeystones()
	end
end

function Mod:SendPartyKeystonesRequest()
	requestPartyKeystones = false
	self:SendAddOnComm("request", "PARTY")
end

local hadKeystone = false
function Mod:CheckCurrentKeystone(announce)
	local keystoneMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()

	if keystoneMapID ~= currentKeystoneMapID or keystoneLevel ~= currentKeystoneLevel then
		currentKeystoneMapID = keystoneMapID
		currentKeystoneLevel = keystoneLevel

		if hadKeystone and announce ~= false and Addon.Config.announceKeystones then
			local itemLink = self:GetInventoryKeystone()
			if itemLink and IsInGroup(LE_PARTY_CATEGORY_HOME) then
				SendChatMessage(string.format(Addon.Locale.newKeystoneAnnounce, itemLink), "PARTY")
			end
		end

		hadKeystone = true
		self:SendCurrentKeystone()
	end
end

function Mod:SendCurrentKeystone()
	local keystoneMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
	
	local message = "0"
	if keystoneLevel and keystoneMapID then
		message = string.format("%d:%d", keystoneMapID, keystoneLevel)
	end

	self:SendAddOnComm(message, "PARTY")
end

function Mod:ReceiveAddOnComm(message, type, sender)
	if message == "request" then
		requestPartyKeystones = false
		self:SendCurrentKeystone()
	elseif message == "0" then
		if unitKeystones[sender] ~= 0 then
			unitKeystones[sender] = 0
			UpdatePartyKeystones()
		end
	else
		local arg1, arg2 = message:match("^(%d+):(%d+)$")
		local keystoneMapID = arg1 and tonumber(arg1)
		local keystoneLevel = arg2 and tonumber(arg2)
		if keystoneMapID and keystoneLevel and (unitKeystones[sender] == nil or unitKeystones[sender] == 0
				or not (unitKeystones[sender][1] == keystoneMapID and unitKeystones[sender][2] == keystoneLevel)) then
			unitKeystones[sender] = { keystoneMapID, keystoneLevel }
			UpdatePartyKeystones()
		end
	end
end

function Mod:CHALLENGE_MODE_START()
	self:CheckCurrentKeystone(false)
	C_Timer.After(2, function() self:CheckCurrentKeystone(false) end)
	self:SetPartyKeystoneRequest()
end

function Mod:CHALLENGE_MODE_COMPLETED()
	self:CheckCurrentKeystone()
	C_Timer.After(2, function() self:CheckCurrentKeystone() end)
	self:SetPartyKeystoneRequest()
end

function Mod:CHALLENGE_MODE_UPDATED()
	self:CheckCurrentKeystone()
end

function Mod:Startup()
	self:RegisterAddOnLoaded("Blizzard_ChallengesUI")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "SetPartyKeystoneRequest")
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	self:RegisterEvent("CHALLENGE_MODE_START")
	self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", "CHALLENGE_MODE_UPDATED")
	self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE", "CHALLENGE_MODE_UPDATED")
	self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED", "CHALLENGE_MODE_UPDATED")
	self:RegisterAddOnComm()
	self:CheckCurrentKeystone()

	C_Timer.After(3, function()
		C_MythicPlus.RequestCurrentAffixes()
		C_MythicPlus.RequestRewards()
	end)

	C_Timer.NewTicker(60, function() self:CheckCurrentKeystone() end)
	
	requestPartyKeystones = true
end
