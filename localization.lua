-- AuraMan Localization File
AuraManLocale = {}

-- English (default)
AuraManLocale["enUS"] = {
    ["ADDON_NAME"] = "AuraMan",
    ["READY"] = "READY!",
    ["COOLDOWN_READY"] = "%s is ready!",
    ["SLASH_HELP"] = "AuraMan Commands:",
    ["SLASH_TOGGLE"] = "/auraman toggle - Toggle cooldown notifications",
    ["SLASH_RESET"] = "/auraman reset - Reset position of notification frame",
    ["SLASH_LIST"] = "/auraman list - Show tracked abilities for your class",
    ["NOTIFICATIONS_ENABLED"] = "Cooldown notifications enabled",
    ["NOTIFICATIONS_DISABLED"] = "Cooldown notifications disabled",
    ["POSITION_RESET"] = "Notification frame position reset",
    ["NO_ABILITIES_FOUND"] = "No tracked abilities found for your class",
    ["TRACKED_ABILITIES"] = "Tracked abilities:",
    ["ABILITY_NOT_LEARNED"] = "Ability not learned: %s",
}

-- Set current locale
local locale = GetLocale()
if not AuraManLocale[locale] then
    locale = "enUS"
end

-- Function to get localized text
function AuraManGetText(key)
    return AuraManLocale[locale][key] or key
end
