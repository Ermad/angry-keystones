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
	keystoneFormat = "[Keystone: %s - Level %d]",
	forcesFormat = " - Enemy Forces: %s",
}

langs.ruRU = {
	config_characterConfig = "Настройки персонажа",
	config_progressTooltip = "Показывать прогресс за каждого врага в подсказках",
	config_progressFormat = "Формат отображения прогресса",
	config_progressFormat_1 = "24.19%",
	config_progressFormat_2 = "90/372",
	config_progressFormat_3 = "24.19% - 90/372",
	keystoneFormat = "[Ключ: %s - Уровень %d]",
	forcesFormat = " - Врагов убито: %s",
}

langs.deDE = {
	config_characterConfig = "Charakter Konfiguration",
	config_progressTooltip = "Zeige Fortschritt pro Gegner im Tooltip",
	config_progressFormat = "Anzeigeformat Fortschrittsbalken",
	config_progressFormat_1 = "24.19%",
	config_progressFormat_2 = "90/372",
	config_progressFormat_3 = "24.19% - 90/372",
	keystoneFormat = "[Schlüsselstein: %s - Level %d]",
	forcesFormat = " - Feindliche Streitkräfte: %s",
}

function Locale:Get(key)
	if langs[current_locale][key] ~= nil then
		return langs[current_locale][key]
	else
		return langs[default_locale][key]
	end
end

function Locale:Has(key)
	local locale = GetLocale()
	return langs[locale] and langs[locale][key] ~= nil
end

function Locale:Exists(key)
	return langs[default_locale][key] ~= nil
end

setmetatable(Locale, {__index = Locale.Get})

current_locale = GetLocale()
if langs[current_locale] == nil then
	current_locale = default_locale
end
