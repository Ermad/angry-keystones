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
	config_autoGossip = "Automatically select gossip entries during Mythic Keystone dungeons (ex: Odyn)",
	config_cosRumors = "Output to party chat clues from \"Chatty Rumormonger\" during Court of Stars",
	config_silverGoldTimer = "Show timer for both 2 and 3 bonus chests at same time",
	keystoneFormat = "[Keystone: %s - Level %d]",
	forcesFormat = " - Enemy Forces: %s",
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
	config_characterConfig = "캐릭터별로 설정하기",
	config_progressTooltip = "각각의 적이 주는 퍼센트를 툴팁에 표시",
	config_progressFormat = "적 병력 표시 방법",
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
    config_progressTooltip = "聊天中的史詩鑰匙直接顯示副本名稱和層數",
    config_progressFormat = "敵方部隊進度格式",
    config_autoGossip = "奧丁戰鬥中提示選擇符文陣",
    config_cosRumors = "群星庭院造謠者線索輸出到小隊聊天中",
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
	noBelt = "No Belt",
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

	["Rumor has is the spy loves to read and always carries around at least one book."]="book",
	["I heard the spy always has a book of written secrets at the belt."]="book",

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
