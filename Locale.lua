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

	keystoneFormat = "[Keystone: %s - Level %d]",
	forcesFormat = " - Enemy Forces: %s",

	rumorMale = MALE,
	rumorFemale = FEMALE,
	rumorLightVest = "Light Vest",
	rumorDarkVest = "Dark Vest",
	rumorShortSleeves = "Short Sleeves",
	rumorLongSleeves = "Long Sleeves",
	rumorCloak = "Cloak",
	rumorNoCloak = "No Cloak",
	rumorGloves = "Gloves",
	rumorNoGloves = "No Gloves",
	rumorNoBelt = "No Belt",
	rumorBook = "Book",
	rumorCoinpurse = "Coinpurse",
	rumorPotion = "Potion",
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


local rumors = {}
rumors.enUS = {
	["I heard somewhere that the spy isn't female."]="rumorMale",
	["I heard the spy is here and he's very good looking."]="rumorMale",
	["A guest said she saw him entering the manor alongside the Grand Magistrix."]="rumorMale",
	["One of the musicians said he would not stop asking questions about the district."]="rumorMale",

	["The spy definitely prefers darker clothing."]="rumorDarkVest",
	["I heard the spy's vest is a dark, rich shade this very night."]="rumorDarkVest",
	["The spy enjoys darker colored vests... like the night."]="rumorDarkVest",
	["Rumor has it the spy is avoiding light colored clothing to try and blend in more."]="rumorDarkVest",

	["I heard the spy's outfit has long sleeves tonight."]="rumorLongSleeves",
	["A friend of mine mentioned the spy has long sleeves on."]="rumorLongSleeves",
	["Someone said the spy is covering up their arms with long sleeves tonight."]="rumorLongSleeves",
	["I just barely caught a glimpse of the spy's long sleeves earlier in the evening."]="rumorLongSleeves",

	["I heard that the spy left their cape in the palace before coming here."]="rumorNoCloak",
	["I heard the spy dislikes capes and refuses to wear one."]="rumorNoCloak",

	["There's a rumor that the spy always wears gloves."]="rumorGloves",
	["I heard the spy carefully hides their hands."]="rumorGloves",
	["Someone said the spy wears gloves to cover obvious scars."]="rumorGloves",
	["I heard the spy always dons gloves."]="rumorGloves",
}
rumors.enGB = rumors

function Locale:Rumor(gossip)
	local locale = GetLocale()
	if rumors[current_locale] and rumors[current_locale][gossip] then
		return self:Get(rumors[current_locale][gossip])
	end
end

current_locale = GetLocale()
