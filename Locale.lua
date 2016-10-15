local ADDON, Addon = ...
local Locale = Addon:NewModule('Locale')

local default_locale = "enUS"
local current_locale

local langs = {}
langs.enUS = {
	config_characterConfig = "Per-character configuration",
	config_progressTooltip = "Show progress each enemy gives on their tooltip",
	config_progressFormat = "Enemies Forces Format",
	config_progressFormat_1 = "24.19%",
	config_progressFormat_2 = "90/372",
	config_progressFormat_3 = "24.19% - 90/372",
	config_splitsFormat = "Objective Splits Display",
	config_splitsFormat_1 = "Disabled",
	config_splitsFormat_2 = "Time from start",
	config_splitsFormat_3 = "Relative to previous",
	config_autoGossip = "Automatically select gossip entries during Mythic Keystone dungeons (ex: Odyn)",
	config_cosRumors = "Output to party chat clues from \"Chatty Rumormonger\" during Court of Stars",
	config_silverGoldTimer = "Show timer for both 2 and 3 bonus chests at same time",
	config_completionMessage = "Show message with final times on completion of Mythic Keystone dungeon",
	config_showSplits = "Show split time for each objective in objective tracker",
	keystoneFormat = "[Keystone: %s - Level %d]",
	forcesFormat = " - Enemy Forces: %s",
	completion0 = "Timer expired for %s with %s, you were %s over the time limit.",
	completion1 = "Beat the timer for %s in %s. You were %s ahead of the timer, and missed +2 by %s.",
	completion2 = "Beat the timer for +2 %s in %s. You were %s ahead of the +2 timer, and missed +3 by %s.",
	completion3 = "Beat the timer for +3 %s in %s. You were %s ahead of the +3 timer.",
}
langs.enGB = langs.enUS

langs.esES = {
	config_characterConfig = "Configuración por personaje",
	config_progressTooltip = "Mostrar cantidad de progreso de cada enemigo en su tooltip",
	config_progressFormat = "Formato de \"Fuerzas enemigas\"",
	keystoneFormat = "[Piedra angular: %s - Nivel %d]",
	forcesFormat = " - Fuerzas enemigas: %s",
}
langs.esMX = langs.esES

langs.ruRU = {
	config_characterConfig = "Настройки персонажа",
	config_progressTooltip = "Показывать прогресс за каждого врага в подсказках",
	config_progressFormat = "Формат отображения прогресса",
	keystoneFormat = "[Ключ: %s - Уровень %d]",
	forcesFormat = " - Врагов убито: %s",
}

langs.deDE = {
	config_characterConfig = "Charakterspezifische Konfiguration",
	config_progressTooltip = "Zeige Fortschritt den Gegner geben in ihrem Tooltip",
	config_progressFormat = "Format für \"Feindliche Streitkräfte\"",
	keystoneFormat = "[Schlüsselstein: %s - Level %d]",
	forcesFormat = " - Feindliche Streitkräfte: %s",
}

langs.koKR = {
	config_characterConfig = "캐릭터별 설정",
	config_progressTooltip = "각각의 적이 주는 진행도를 툴팁에 표시",
	config_progressFormat = "적 병력 표시 형식",
	config_autoGossip = "신화 쐐기돌 던전에서 자동으로 대화 넘김 (예: 오딘)",
	config_cosRumors = "별의 궁정에서 \"수다쟁이 호사가\"가 알려주는 단서 표시",
	config_silverGoldTimer = "추가 상자 2와 3의 남은 시간을 함께 표시",
	keystoneFormat = "[쐐기돌: %s - %d 레벨]",
	forcesFormat = " - 적 병력: %s",
}

langs.zhCN = {
	config_characterConfig = "为角色进行独立的配置",
	config_progressTooltip = "聊天中的史诗钥匙直接显示副本名称和层数",
	config_progressFormat = "敌方部队进度格式",
	config_autoGossip = "奥丁战斗中提示选择符文阵",
	config_cosRumors = "群星庭院造谣者线索输出到小队聊天中",
	keystoneFormat = "[%s - 等级 %d]",
	forcesFormat = " - 敌方部队 %s",
}

langs.zhTW = {
	config_characterConfig = "為角色進行獨立的配置",
	config_progressTooltip = "聊天中的傳奇鑰匙直接顯示副本名稱和層數",
	config_progressFormat = "敵方部隊進度格式",
	config_autoGossip = "歐丁戰鬥中提示選擇符文陣",
	config_cosRumors = "衆星之廷造謠者線索輸出到小隊聊天中",
	keystoneFormat = "[%s - 等級 %d]",
	forcesFormat = " - 敵方部隊 %s",
}

function Locale:Get(key)
	if langs[current_locale] and langs[current_locale][key] ~= nil then
		return langs[current_locale][key]
	else
		return langs[default_locale][key]
	end
end

function Locale:Local(key)
	return langs[current_locale] and langs[current_locale][key]
end

function Locale:Exists(key)
	return langs[default_locale][key] ~= nil
end

setmetatable(Locale, {__index = Locale.Get})

local clues = {}
clues.enUS = {
	male = MALE,
	female = FEMALE,
	lightVest = "Light Vest",
	darkVest = "Dark Vest",
	shortSleeves = "Short Sleeves",
	longSleeves = "Long Sleeves",
	cloak = "Cloak",
	noCloak = "No Cloak",
	gloves = "Gloves",
	noGloves = "No Gloves",
	noPotion = "No Potion",
	book = "Book",
	coinpurse = "Coinpurse",
	potion = "Potion",
}
clues.enGB = clues

local rumors = {}
rumors.enUS = {
	["I heard somewhere that the spy isn't female."]="male",
	["I heard the spy is here and he's very good looking."]="male",
	["A guest said she saw him entering the manor alongside the Grand Magistrix."]="male",
	["One of the musicians said he would not stop asking questions about the district."]="male",

	["Someone's been saying that our new guest isn't male."]="female",
	["A guest saw both her and Elisande arrive together earlier."]="female",
	["They say that the spy is here and she's quite the sight to behold."]="female",
	["I hear some woman has been constantly asking about the district..."]="female",

	["The spy definitely prefers the style of light colored vests."]="lightVest",
	["I heard that the spy is wearing a lighter vest to tonight's party."]="lightVest",
	["People are saying the spy is not wearing a darker vest tonight."]="lightVest",

	["The spy definitely prefers darker clothing."]="darkVest",
	["I heard the spy's vest is a dark, rich shade this very night."]="darkVest",
	["The spy enjoys darker colored vests... like the night."]="darkVest",
	["Rumor has it the spy is avoiding light colored clothing to try and blend in more."]="darkVest",

	["Someone told me the spy hates wearing long sleeves."]="shortSleeves",
	["I heard the spy wears short sleeves to keep their arms unencumbered."]="shortSleeves",
	["I heard the spy enjoys the cool air and is not wearing long sleeves tonight."]="shortSleeves",
	["A friend of mine said she saw the outfit the spy was wearing. It did not have long sleeves."]="shortSleeves",

	["I heard the spy's outfit has long sleeves tonight."]="longSleeves",
	["A friend of mine mentioned the spy has long sleeves on."]="longSleeves",
	["Someone said the spy is covering up their arms with long sleeves tonight."]="longSleeves",
	["I just barely caught a glimpse of the spy's long sleeves earlier in the evening."]="longSleeves",

	["Someone mentioned the spy came in earlier wearing a cape."]="cloak",
	["I heard the spy enjoys wearing capes."]="cloak",

	["I heard that the spy left their cape in the palace before coming here."]="noCloak",
	["I heard the spy dislikes capes and refuses to wear one."]="noCloak",

	["There's a rumor that the spy always wears gloves."]="gloves",
	["I heard the spy carefully hides their hands."]="gloves",
	["Someone said the spy wears gloves to cover obvious scars."]="gloves",
	["I heard the spy always dons gloves."]="gloves",

	["You know... I found an extra pair of gloves in the back room. The spy is likely to be bare handed somewhere around here."]="noGloves",
	["There's a rumor that the spy never has gloves on."]="noGloves",
	["I heard the spy avoids having gloves on, in case some quick actions are needed."]="noGloves",
	["I heard the spy dislikes wearing gloves."]="noGloves",

	["Rumor has is the spy loves to read and always carries around at least one book."]="book",
	["I heard the spy always has a book of written secrets at the belt."]="book",

	["A musician told me she saw the spy throw away their last potion and no longer has any left."]="noPotion",
	["I heard the spy is not carrying any potions around."]="noPotion",

	["I'm pretty sure the spy has potions at the belt."]="potion",
	["I heard the spy brought along potions, I wonder why?"]="potion",
	["I heard the spy brought along some potions... just in case."]="potion",
	["I didn't tell you this... but the spy is masquerading as an alchemist and carrying potions at the belt."]="potion",

	["I heard the spy's belt pouch is lined with fancy threading."]="coinpurse",
	["A friend said the spy loves gold and a belt pouch filled with it."]="coinpurse",
	["I heard the spy's belt pouch is filled with gold to show off extravagance."]="coinpurse",
	["I heard the spy carries a magical pouch around at all times."]="coinpurse",
}
rumors.enGB = rumors.enUS

function Locale:HasRumors()
	return rumors[current_locale] ~= nil and clues[current_locale] ~= nil
end

function Locale:Rumor(gossip)
	if rumors[current_locale] and rumors[current_locale][gossip] then
		return clues[current_locale] and clues[current_locale][rumors[current_locale][gossip]]
	end
end

current_locale = GetLocale()
