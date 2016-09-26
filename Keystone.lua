local ADDON, Addon = ...
local Mod = Addon:NewModule('Keystone')

local events = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_TEXT_EMOTE",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
}

local function filter(self, event, msg, ...)
	local msg2 = msg:gsub("(|cffa335ee|Hitem:138019:([0-9:]+)|h%[(Mythic Keystone)%]|h|r)", function(msg, itemString, itemName)
		local info = { strsplit(":", itemString) }
		local mapID = tonumber(info[13])
		local mapLevel = tonumber(info[14])
		if mapID and mapLevel then
			local mapName = C_ChallengeMode.GetMapInfo(mapID)
			return msg:gsub(itemName, format("Keystone: %s Level %d", mapName, mapLevel))
		else
			return msg
		end
	end)
	if msg2 ~= msg then
		return false, msg2, ...
	end
end


for _, v in pairs(events) do
	ChatFrame_AddMessageEventFilter(v, filter)
end
