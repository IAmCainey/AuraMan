-- AuraMan - Multi-Class Cooldown Tracker v1.7
-- Classic WoW Addon for Turtle WoW (1.12.1)
-- Enhanced scaling with smart bounds checking, clickable HUD icons, and comprehensive configuration UI

local AuraMan = {}
AuraMan.frame = nil
AuraMan.hudFrame = nil
AuraMan.cooldownFrames = {}
AuraMan.trackedSpells = {}
AuraMan.lastUpdate = 0
AuraMan.updateInterval = 0.1
AuraMan.enabled = true

-- Database for saved variables
if not AuraManDB then
    AuraManDB = {
        enabled = true,
        hudX = 0,
        hudY = 0,
        hudScale = 1.0,
        iconSize = 40,
        iconsPerRow = 5,
        showText = true,
        hudOpacity = 0.3,
    }
else
    -- Ensure all required fields exist with safe defaults
    if type(AuraManDB.hudScale) ~= "number" or AuraManDB.hudScale <= 0 or AuraManDB.hudScale > 3 then
        AuraManDB.hudScale = 1.0
    end
    if type(AuraManDB.hudX) ~= "number" then
        AuraManDB.hudX = 0
    end
    if type(AuraManDB.hudY) ~= "number" then
        AuraManDB.hudY = 0
    end
    if type(AuraManDB.iconSize) ~= "number" or AuraManDB.iconSize < 20 or AuraManDB.iconSize > 100 then
        AuraManDB.iconSize = 40
    end
    if type(AuraManDB.iconsPerRow) ~= "number" or AuraManDB.iconsPerRow < 1 or AuraManDB.iconsPerRow > 10 then
        AuraManDB.iconsPerRow = 5
    end
    if AuraManDB.enabled == nil then
        AuraManDB.enabled = true
    end
    if AuraManDB.showText == nil then
        AuraManDB.showText = true
    end
    if type(AuraManDB.hudOpacity) ~= "number" or AuraManDB.hudOpacity < 0 or AuraManDB.hudOpacity > 1 then
        AuraManDB.hudOpacity = 0.3
    end
end

-- Class abilities to track (Classic WoW spell IDs and names)
local CLASS_ABILITIES = {
    ["ROGUE"] = {
        ["Stealth"] = {
            id = 1784,
            cooldown = 10,
            icon = "Interface\\Icons\\Ability_Stealth",
            priority = 1
        },
        ["Vanish"] = {
            id = 1856,
            cooldown = 300,
            icon = "Interface\\Icons\\Ability_Vanish",
            priority = 5
        },
        ["Kidney Shot"] = {
            id = 408,
            cooldown = 20,
            icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",
            priority = 4
        },
        ["Cold Blood"] = {
            id = 14177,
            cooldown = 60,
            icon = "Interface\\Icons\\Spell_Ice_Lament",
            priority = 3
        },
        ["Preparation"] = {
            id = 14185,
            cooldown = 600,
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            priority = 5
        },
        ["Evasion"] = {
            id = 5277,
            cooldown = 300,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",
            priority = 3
        },
        ["Sprint"] = {
            id = 2983,
            cooldown = 300,
            icon = "Interface\\Icons\\Ability_Rogue_Sprint",
            priority = 2
        },
        ["Blind"] = {
            id = 2094,
            cooldown = 300,
            icon = "Interface\\Icons\\Spell_Shadow_MindSteal",
            priority = 3
        },
        ["Thistle Tea"] = {
            id = 7676,
            cooldown = 300,
            icon = "Interface\\Icons\\INV_Drink_Milk_05",
            priority = 2
        },
        ["Kick"] = {
            id = 1766,
            cooldown = 10,
            icon = "Interface\\Icons\\Ability_Kick",
            priority = 4
        },
        ["Gouge"] = {
            id = 1776,
            cooldown = 10,
            icon = "Interface\\Icons\\Ability_Gouge",
            priority = 3
        },
        ["Distraction"] = {
            id = 1725,
            cooldown = 30,
            icon = "Interface\\Icons\\Ability_Rogue_Distraction",
            priority = 2
        },
    },
    
    ["WARRIOR"] = {
        ["Shield Wall"] = {
            id = 871,
            cooldown = 1800, -- 30 minutes
            icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
            priority = 5
        },
        ["Last Stand"] = {
            id = 12975,
            cooldown = 480, -- 8 minutes
            icon = "Interface\\Icons\\Spell_Holy_AshesToAshes",
            priority = 4
        },
        ["Bloodthirst"] = {
            id = 23881,
            cooldown = 6,
            icon = "Interface\\Icons\\Spell_Nature_BloodLust",
            priority = 2
        },
        ["Whirlwind"] = {
            id = 1680,
            cooldown = 10,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            priority = 3
        },
        ["Intimidating Shout"] = {
            id = 5246,
            cooldown = 180,
            icon = "Interface\\Icons\\Ability_GolemThunderClap",
            priority = 3
        },
        ["Recklessness"] = {
            id = 1719,
            cooldown = 1800,
            icon = "Interface\\Icons\\Ability_CriticalStrike",
            priority = 5
        },
        ["Retaliation"] = {
            id = 20230,
            cooldown = 1800,
            icon = "Interface\\Icons\\Ability_Warrior_Challange",
            priority = 4
        },
        ["Challenging Shout"] = {
            id = 1161,
            cooldown = 600, -- 10 minutes
            icon = "Interface\\Icons\\Ability_BullRush",
            priority = 3
        },
        ["Shield Slam"] = {
            id = 23922,
            cooldown = 6,
            icon = "Interface\\Icons\\INV_Shield_05",
            priority = 3
        },
        ["Thunder Clap"] = {
            id = 6343,
            cooldown = 4,
            icon = "Interface\\Icons\\Spell_Nature_ThunderClap",
            priority = 2
        },
        ["Berserker Rage"] = {
            id = 18499,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Nature_AncestralGuardian",
            priority = 3
        },
        ["Pummel"] = {
            id = 6552,
            cooldown = 30,
            icon = "Interface\\Icons\\INV_Gauntlets_04",
            priority = 4
        },
        ["Overpower"] = {
            id = 7384,
            cooldown = 5,
            icon = "Interface\\Icons\\Ability_MeleeDamage",
            priority = 2
        },
    },
    
    ["MAGE"] = {
        ["Counterspell"] = {
            id = 2139,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Frost_IceShock",
            priority = 4
        },
        ["Blink"] = {
            id = 1953,
            cooldown = 15,
            icon = "Interface\\Icons\\Spell_Arcane_Blink",
            priority = 3
        },
        ["Ice Block"] = {
            id = 45438,
            cooldown = 300,
            icon = "Interface\\Icons\\Spell_Frost_Frost",
            priority = 5
        },
        ["Presence of Mind"] = {
            id = 12043,
            cooldown = 180,
            icon = "Interface\\Icons\\Spell_Nature_EnchantArmor",
            priority = 4
        },
        ["Evocation"] = {
            id = 12051,
            cooldown = 480,
            icon = "Interface\\Icons\\Spell_Nature_Purge",
            priority = 3
        },
        ["Combustion"] = {
            id = 11129,
            cooldown = 180,
            icon = "Interface\\Icons\\Spell_Fire_SealOfFire",
            priority = 4
        },
        ["Cold Snap"] = {
            id = 11958,
            cooldown = 480,
            icon = "Interface\\Icons\\Spell_Frost_WizardMark",
            priority = 3
        },
        ["Frost Nova"] = {
            id = 122,
            cooldown = 25,
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            priority = 3
        },
        ["Polymorph"] = {
            id = 118,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Nature_Polymorph",
            priority = 4
        },
    },
    
    ["PRIEST"] = {
        ["Psychic Scream"] = {
            id = 8122,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Shadow_PsychicScream",
            priority = 3
        },
        ["Fade"] = {
            id = 586,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Magic_LesserInvisibilty",
            priority = 2
        },
        ["Inner Fire"] = {
            id = 588,
            cooldown = 0,
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            priority = 1
        },
        ["Power Word: Shield"] = {
            id = 17,
            cooldown = 0,
            icon = "Interface\\Icons\\Spell_Holy_PowerWordShield",
            priority = 2
        },
        ["Fear Ward"] = {
            id = 6346,
            cooldown = 180,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism",
            priority = 4
        },
        ["Desperate Prayer"] = {
            id = 19236,
            cooldown = 600,
            icon = "Interface\\Icons\\Spell_Holy_Restoration",
            priority = 3
        },
        ["Silence"] = {
            id = 15487,
            cooldown = 45,
            icon = "Interface\\Icons\\Spell_Shadow_ImpPhaseShift",
            priority = 4
        },
        ["Mind Control"] = {
            id = 605,
            cooldown = 8,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
            priority = 5
        },
    },
    
    ["PALADIN"] = {
        ["Lay on Hands"] = {
            id = 633,
            cooldown = 3600, -- 60 minutes
            icon = "Interface\\Icons\\Spell_Holy_LayOnHands",
            priority = 5
        },
        ["Divine Protection"] = {
            id = 498,
            cooldown = 300,
            icon = "Interface\\Icons\\Spell_Holy_Restoration",
            priority = 4
        },
        ["Consecration"] = {
            id = 26573,
            cooldown = 8,
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            priority = 3
        },
        ["Hammer of Justice"] = {
            id = 853,
            cooldown = 60,
            icon = "Interface\\Icons\\Spell_Holy_SealOfMight",
            priority = 3
        },
        ["Divine Favor"] = {
            id = 20216,
            cooldown = 120,
            icon = "Interface\\Icons\\Spell_Holy_Heal",
            priority = 4
        },
        ["Forbearance"] = {
            id = 25771,
            cooldown = 60,
            icon = "Interface\\Icons\\Spell_Holy_RemoveCurse",
            priority = 2
        },
        ["Blessing of Protection"] = {
            id = 1022,
            cooldown = 300,
            icon = "Interface\\Icons\\Spell_Holy_SealOfProtection",
            priority = 4
        },
        ["Turn Undead"] = {
            id = 2878,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Holy_TurnUndead",
            priority = 3
        },
        ["Divine Shield"] = {
            id = 642,
            cooldown = 300,
            icon = "Interface\\Icons\\Spell_Holy_DivineProtection",
            priority = 5
        },
    },
    
    ["HUNTER"] = {
        ["Rapid Fire"] = {
            id = 3045,
            cooldown = 300,
            icon = "Interface\\Icons\\Ability_Hunter_RunningShot",
            priority = 4
        },
        ["Deterrence"] = {
            id = 19263,
            cooldown = 300,
            icon = "Interface\\Icons\\Ability_Whirlwind",
            priority = 3
        },
        ["Freezing Trap"] = {
            id = 1499,
            cooldown = 15,
            icon = "Interface\\Icons\\Spell_Frost_ChainsOfIce",
            priority = 3
        },
        ["Concussive Shot"] = {
            id = 5116,
            cooldown = 12,
            icon = "Interface\\Icons\\Spell_Frost_Stun",
            priority = 2
        },
        ["Bestial Wrath"] = {
            id = 19574,
            cooldown = 120,
            icon = "Interface\\Icons\\Ability_Druid_FerociousBite",
            priority = 4
        },
        ["Intimidation"] = {
            id = 19577,
            cooldown = 60,
            icon = "Interface\\Icons\\Ability_Devour",
            priority = 3
        },
        ["Aimed Shot"] = {
            id = 19434,
            cooldown = 6,
            icon = "Interface\\Icons\\INV_Spear_07",
            priority = 3
        },
        ["Multi-Shot"] = {
            id = 2643,
            cooldown = 10,
            icon = "Interface\\Icons\\Ability_UpgradeMoonGlaive",
            priority = 2
        },
        ["Wing Clip"] = {
            id = 2974,
            cooldown = 0,
            icon = "Interface\\Icons\\Ability_Rogue_Trip",
            priority = 2
        },
        ["Disengage"] = {
            id = 781,
            cooldown = 5,
            icon = "Interface\\Icons\\Ability_Rogue_Feint",
            priority = 2
        },
    },
    
    ["WARLOCK"] = {
        ["Death Coil"] = {
            id = 6789,
            cooldown = 120,
            icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
            priority = 4
        },
        ["Howl of Terror"] = {
            id = 5484,
            cooldown = 40,
            icon = "Interface\\Icons\\Spell_Shadow_DeathScream",
            priority = 3
        },
        ["Shadow Ward"] = {
            id = 6229,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Shadow_AntiShadow",
            priority = 2
        },
        ["Amplify Curse"] = {
            id = 18288,
            cooldown = 180,
            icon = "Interface\\Icons\\Spell_Shadow_Contagion",
            priority = 3
        },
        ["Soul Burn"] = {
            id = 17877,
            cooldown = 60,
            icon = "Interface\\Icons\\Spell_Fire_SoulBurn",
            priority = 3
        },
        ["Conflagrate"] = {
            id = 17962,
            cooldown = 10,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            priority = 2
        },
        ["Fear"] = {
            id = 5782,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Shadow_Possession",
            priority = 4
        },
        ["Banish"] = {
            id = 710,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Shadow_Cripple",
            priority = 3
        },
        ["Shadowburn"] = {
            id = 17877,
            cooldown = 15,
            icon = "Interface\\Icons\\Spell_Shadow_ScourgeBuild",
            priority = 3
        },
    },
    
    ["DRUID"] = {
        ["Bash"] = {
            id = 5211,
            cooldown = 60,
            icon = "Interface\\Icons\\Ability_Druid_Bash",
            priority = 3
        },
        ["Frenzied Regeneration"] = {
            id = 22842,
            cooldown = 180,
            icon = "Interface\\Icons\\Ability_BullRush",
            priority = 4
        },
        ["Barkskin"] = {
            id = 22812,
            cooldown = 30,
            icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem",
            priority = 3
        },
        ["Nature's Swiftness"] = {
            id = 17116,
            cooldown = 180,
            icon = "Interface\\Icons\\Spell_Nature_RavenForm",
            priority = 4
        },
        ["Innervate"] = {
            id = 29166,
            cooldown = 360,
            icon = "Interface\\Icons\\Spell_Nature_Lightning",
            priority = 5
        },
        ["Swiftmend"] = {
            id = 18562,
            cooldown = 15,
            icon = "Interface\\Icons\\INV_Relics_IdolOfRejuvenation",
            priority = 3
        },
        ["Entangling Roots"] = {
            id = 339,
            cooldown = 10,
            icon = "Interface\\Icons\\Spell_Nature_StrangleVines",
            priority = 3
        },
        ["Hibernate"] = {
            id = 2637,
            cooldown = 15,
            icon = "Interface\\Icons\\Spell_Nature_Sleep",
            priority = 3
        },
        ["Faerie Fire"] = {
            id = 770,
            cooldown = 6,
            icon = "Interface\\Icons\\Spell_Nature_FaerieFire",
            priority = 2
        },
        ["Bear Form"] = {
            id = 5487,
            cooldown = 1,
            icon = "Interface\\Icons\\Ability_Racial_BearForm",
            priority = 1
        },
        ["Cat Form"] = {
            id = 768,
            cooldown = 1,
            icon = "Interface\\Icons\\Ability_Druid_CatForm",
            priority = 1
        },
    },
    
    ["SHAMAN"] = {
        ["Earth Elemental Totem"] = {
            id = 2062,
            cooldown = 1200, -- 20 minutes
            icon = "Interface\\Icons\\Spell_Nature_EarthElemental_Totem",
            priority = 5
        },
        ["Fire Elemental Totem"] = {
            id = 2894,
            cooldown = 1200, -- 20 minutes
            icon = "Interface\\Icons\\Spell_Fire_Elemental_Totem",
            priority = 5
        },
        ["Grounding Totem"] = {
            id = 8177,
            cooldown = 15,
            icon = "Interface\\Icons\\Spell_Nature_GroundingTotem",
            priority = 3
        },
        ["Nature's Swiftness"] = {
            id = 16188,
            cooldown = 180,
            icon = "Interface\\Icons\\Spell_Nature_RavenForm",
            priority = 4
        },
        ["Elemental Mastery"] = {
            id = 16166,
            cooldown = 180,
            icon = "Interface\\Icons\\Spell_Nature_WispHeal",
            priority = 4
        },
        ["Stormstrike"] = {
            id = 17364,
            cooldown = 20,
            icon = "Interface\\Icons\\Ability_Shaman_StormStrike",
            priority = 3
        },
        ["Purge"] = {
            id = 370,
            cooldown = 8,
            icon = "Interface\\Icons\\Spell_Nature_Purge",
            priority = 3
        },
        ["Ghost Wolf"] = {
            id = 2645,
            cooldown = 1,
            icon = "Interface\\Icons\\Spell_Nature_SpiritWolf",
            priority = 1
        },
        ["Wind Shear"] = {
            id = 57994,
            cooldown = 6,
            icon = "Interface\\Icons\\Spell_Nature_Cyclone",
            priority = 4
        },
        ["Tremor Totem"] = {
            id = 8143,
            cooldown = 1,
            icon = "Interface\\Icons\\Spell_Nature_TremorTotem",
            priority = 2
        },
    },
}

-- Helper function to safely get localized text
function AuraMan:GetLocalizedText(key)
    if AuraManGetText then
        return AuraManGetText(key)
    else
        -- Fallback messages if localization not loaded yet
        local fallbacks = {
            ["NOTIFICATIONS_ENABLED"] = "Cooldown notifications enabled",
            ["NOTIFICATIONS_DISABLED"] = "Cooldown notifications disabled",
            ["POSITION_RESET"] = "HUD position reset",
            ["SLASH_HELP"] = "AuraMan Commands:",
            ["SLASH_TOGGLE"] = "/auraman toggle - Toggle cooldown notifications",
            ["SLASH_RESET"] = "/auraman reset - Reset HUD position",
            ["SLASH_LIST"] = "/auraman list - Show tracked abilities",
            ["NO_ABILITIES_FOUND"] = "No tracked abilities found for your class",
            ["TRACKED_ABILITIES"] = "Tracked abilities:",
            ["ABILITY_NOT_LEARNED"] = "Ability not learned: %s",
        }
        return fallbacks[key] or key
    end
end

-- Create the main addon frame
function AuraMan:CreateFrame()
    self.frame = CreateFrame("Frame", "AuraManFrame", UIParent)
    self.frame:SetScript("OnEvent", function() self:OnEvent() end)
    self.frame:SetScript("OnUpdate", function() self:OnUpdate() end)
    
    -- Register events
    self.frame:RegisterEvent("ADDON_LOADED")
    self.frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self.frame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    self.frame:RegisterEvent("PLAYER_LOGIN")
    self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

-- Create notification frame
function AuraMan:CreateHUDFrame()
    self.hudFrame = CreateFrame("Frame", "AuraManHUDFrame", UIParent)
    
    -- Safe initial sizing
    self.hudFrame:SetWidth(300)
    self.hudFrame:SetHeight(200)
    
    -- Safe scale setting first
    local scale = AuraManDB.hudScale
    if type(scale) == "number" and scale > 0 and scale <= 3 then
        self.hudFrame:SetScale(scale)
    else
        self.hudFrame:SetScale(1.0)
        AuraManDB.hudScale = 1.0
        scale = 1.0
    end
    
    -- Safe positioning with bounds checking
    local hudX = type(AuraManDB.hudX) == "number" and AuraManDB.hudX or 0
    local hudY = type(AuraManDB.hudY) == "number" and AuraManDB.hudY or 0
    
    -- Calculate screen bounds considering the current scale
    local screenWidth = UIParent:GetWidth()
    local screenHeight = UIParent:GetHeight()
    local frameWidth = self.hudFrame:GetWidth() * scale
    local frameHeight = self.hudFrame:GetHeight() * scale
    local minX = -screenWidth/2 + frameWidth/2
    local maxX = screenWidth/2 - frameWidth/2
    local minY = -screenHeight/2 + frameHeight/2
    local maxY = screenHeight/2 - frameHeight/2
    
    -- Clamp position to screen bounds
    local clampedX = math.max(minX, math.min(maxX, hudX))
    local clampedY = math.max(minY, math.min(maxY, hudY))
    
    -- If the frame would go off-screen, center it
    if clampedX ~= hudX or clampedY ~= hudY then
        clampedX = 0
        clampedY = 0
        AuraManDB.hudX = 0
        AuraManDB.hudY = 0
    end
    
    self.hudFrame:SetPoint("CENTER", UIParent, "CENTER", clampedX, clampedY)
    
    -- Make it movable
    self.hudFrame:SetMovable(true)
    self.hudFrame:EnableMouse(true)
    self.hudFrame:SetScript("OnMouseDown", function()
        if IsShiftKeyDown() then
            this:StartMoving()
        end
    end)
    self.hudFrame:SetScript("OnMouseUp", function()
        if arg1 == "RightButton" then
            -- Right-click opens config menu
            if AuraMan.configFrame then
                if AuraMan.configFrame:IsShown() then
                    AuraMan.configFrame:Hide()
                else
                    AuraMan:UpdateConfigFrame()
                    AuraMan.configFrame:Show()
                end
            end
        else
            -- Left-click drag handling
            this:StopMovingOrSizing()
            local x, y = this:GetCenter()
            local screenWidth = UIParent:GetWidth()
            local screenHeight = UIParent:GetHeight()
            local offsetX = x - screenWidth/2
            local offsetY = y - screenHeight/2
            
            -- Calculate screen bounds considering the current scale
            local scale = this:GetScale()
            local frameWidth = this:GetWidth() * scale
            local frameHeight = this:GetHeight() * scale
            local minX = -screenWidth/2 + frameWidth/2
            local maxX = screenWidth/2 - frameWidth/2
            local minY = -screenHeight/2 + frameHeight/2
            local maxY = screenHeight/2 - frameHeight/2
            
            -- Clamp position to screen bounds
            local clampedX = math.max(minX, math.min(maxX, offsetX))
            local clampedY = math.max(minY, math.min(maxY, offsetY))
            
            -- If position was adjusted, apply it
            if clampedX ~= offsetX or clampedY ~= offsetY then
                this:ClearAllPoints()
                this:SetPoint("CENTER", UIParent, "CENTER", clampedX, clampedY)
            end
            
            -- Save the clamped position
            AuraManDB.hudX = clampedX
            AuraManDB.hudY = clampedY
        end
    end)
    
    -- Background (semi-transparent)
    self.hudFrame.bg = self.hudFrame:CreateTexture(nil, "BACKGROUND")
    self.hudFrame.bg:SetAllPoints()
    self.hudFrame.bg:SetTexture(0, 0, 0, AuraManDB.hudOpacity)
    
    -- Title text
    self.hudFrame.title = self.hudFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.hudFrame.title:SetPoint("TOP", self.hudFrame, "TOP", 0, -5)
    self.hudFrame.title:SetText("AuraMan - Cooldown Tracker")
    self.hudFrame.title:SetTextColor(1, 1, 0)
    
    -- Initialize cooldown frames table
    self.cooldownFrames = {}
    
    -- Create cooldown icon frames
    self:CreateCooldownIcons()
end

-- Create configuration UI
function AuraMan:CreateConfigFrame()
    if self.configFrame then
        return
    end
    
    -- Main config frame
    self.configFrame = CreateFrame("Frame", "AuraManConfigFrame", UIParent)
    self.configFrame:SetWidth(400)
    self.configFrame:SetHeight(500)
    self.configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.configFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self.configFrame:SetBackdropColor(0, 0, 0, 0.8)
    self.configFrame:SetMovable(true)
    self.configFrame:EnableMouse(true)
    self.configFrame:SetScript("OnMouseDown", function() this:StartMoving() end)
    self.configFrame:SetScript("OnMouseUp", function() this:StopMovingOrSizing() end)
    self.configFrame:Hide()
    
    -- Title
    local title = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", self.configFrame, "TOP", 0, -15)
    title:SetText("AuraMan Configuration")
    title:SetTextColor(1, 1, 0)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    closeButton:SetWidth(80)
    closeButton:SetHeight(22)
    closeButton:SetPoint("TOPRIGHT", self.configFrame, "TOPRIGHT", -15, -15)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function() AuraMan.configFrame:Hide() end)
    
    -- Enable/Disable checkbox
    local enabledCheckbox = CreateFrame("CheckButton", nil, self.configFrame, "UICheckButtonTemplate")
    enabledCheckbox:SetPoint("TOPLEFT", self.configFrame, "TOPLEFT", 20, -50)
    enabledCheckbox.text = enabledCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enabledCheckbox.text:SetPoint("LEFT", enabledCheckbox, "RIGHT", 5, 0)
    enabledCheckbox.text:SetText("Enable AuraMan")
    enabledCheckbox:SetScript("OnClick", function()
        AuraManDB.enabled = not AuraManDB.enabled
        AuraMan.enabled = AuraManDB.enabled
        this:SetChecked(AuraManDB.enabled)
        if AuraManDB.enabled then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Enabled")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Disabled")
        end
    end)
    
    -- Scale slider
    local scaleSlider = CreateFrame("Slider", nil, self.configFrame, "OptionsSliderTemplate")
    scaleSlider:SetPoint("TOPLEFT", self.configFrame, "TOPLEFT", 20, -90)
    scaleSlider:SetWidth(200)
    scaleSlider:SetHeight(20)
    scaleSlider:SetMinMaxValues(0.5, 2.0)
    scaleSlider:SetValue(AuraManDB.hudScale)
    scaleSlider:SetValueStep(0.1)
    scaleSlider.textLow = scaleSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scaleSlider.textLow:SetPoint("BOTTOMLEFT", scaleSlider, "BOTTOMLEFT", 0, -10)
    scaleSlider.textLow:SetText("0.5x")
    scaleSlider.textHigh = scaleSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scaleSlider.textHigh:SetPoint("BOTTOMRIGHT", scaleSlider, "BOTTOMRIGHT", 0, -10)
    scaleSlider.textHigh:SetText("2.0x")
    scaleSlider.title = scaleSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scaleSlider.title:SetPoint("TOPLEFT", scaleSlider, "TOPLEFT", 0, 15)
    scaleSlider.title:SetText("HUD Scale: " .. AuraManDB.hudScale .. "x")
    scaleSlider:SetScript("OnValueChanged", function()
        local value = this:GetValue()
        value = math.floor(value * 10) / 10 -- Round to 1 decimal place
        AuraManDB.hudScale = value
        this.title:SetText("HUD Scale: " .. value .. "x")
        AuraMan:ApplyScale()
    end)
    
    -- Opacity slider
    local opacitySlider = CreateFrame("Slider", nil, self.configFrame, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", self.configFrame, "TOPLEFT", 20, -150)
    opacitySlider:SetWidth(200)
    opacitySlider:SetHeight(20)
    opacitySlider:SetMinMaxValues(0, 1)
    opacitySlider:SetValue(AuraManDB.hudOpacity)
    opacitySlider:SetValueStep(0.1)
    opacitySlider.textLow = opacitySlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    opacitySlider.textLow:SetPoint("BOTTOMLEFT", opacitySlider, "BOTTOMLEFT", 0, -10)
    opacitySlider.textLow:SetText("0%")
    opacitySlider.textHigh = opacitySlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    opacitySlider.textHigh:SetPoint("BOTTOMRIGHT", opacitySlider, "BOTTOMRIGHT", 0, -10)
    opacitySlider.textHigh:SetText("100%")
    opacitySlider.title = opacitySlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    opacitySlider.title:SetPoint("TOPLEFT", opacitySlider, "TOPLEFT", 0, 15)
    opacitySlider.title:SetText("Background Opacity: " .. math.floor(AuraManDB.hudOpacity * 100) .. "%")
    opacitySlider:SetScript("OnValueChanged", function()
        local value = this:GetValue()
        value = math.floor(value * 10) / 10 -- Round to 1 decimal place
        AuraManDB.hudOpacity = value
        this.title:SetText("Background Opacity: " .. math.floor(value * 100) .. "%")
        if AuraMan.hudFrame and AuraMan.hudFrame.bg then
            AuraMan.hudFrame.bg:SetTexture(0, 0, 0, value)
        end
    end)
    
    -- Icon size slider
    local iconSizeSlider = CreateFrame("Slider", nil, self.configFrame, "OptionsSliderTemplate")
    iconSizeSlider:SetPoint("TOPLEFT", self.configFrame, "TOPLEFT", 20, -210)
    iconSizeSlider:SetWidth(200)
    iconSizeSlider:SetHeight(20)
    iconSizeSlider:SetMinMaxValues(20, 80)
    iconSizeSlider:SetValue(AuraManDB.iconSize)
    iconSizeSlider:SetValueStep(5)
    iconSizeSlider.textLow = iconSizeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    iconSizeSlider.textLow:SetPoint("BOTTOMLEFT", iconSizeSlider, "BOTTOMLEFT", 0, -10)
    iconSizeSlider.textLow:SetText("20px")
    iconSizeSlider.textHigh = iconSizeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    iconSizeSlider.textHigh:SetPoint("BOTTOMRIGHT", iconSizeSlider, "BOTTOMRIGHT", 0, -10)
    iconSizeSlider.textHigh:SetText("80px")
    iconSizeSlider.title = iconSizeSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    iconSizeSlider.title:SetPoint("TOPLEFT", iconSizeSlider, "TOPLEFT", 0, 15)
    iconSizeSlider.title:SetText("Icon Size: " .. AuraManDB.iconSize .. "px")
    iconSizeSlider:SetScript("OnValueChanged", function()
        local value = this:GetValue()
        value = math.floor(value / 5) * 5 -- Round to nearest 5
        AuraManDB.iconSize = value
        this.title:SetText("Icon Size: " .. value .. "px")
        AuraMan:CreateCooldownIcons()
    end)
    
    -- Icons per row slider
    local iconsPerRowSlider = CreateFrame("Slider", nil, self.configFrame, "OptionsSliderTemplate")
    iconsPerRowSlider:SetPoint("TOPLEFT", self.configFrame, "TOPLEFT", 20, -270)
    iconsPerRowSlider:SetWidth(200)
    iconsPerRowSlider:SetHeight(20)
    iconsPerRowSlider:SetMinMaxValues(1, 10)
    iconsPerRowSlider:SetValue(AuraManDB.iconsPerRow)
    iconsPerRowSlider:SetValueStep(1)
    iconsPerRowSlider.textLow = iconsPerRowSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    iconsPerRowSlider.textLow:SetPoint("BOTTOMLEFT", iconsPerRowSlider, "BOTTOMLEFT", 0, -10)
    iconsPerRowSlider.textLow:SetText("1")
    iconsPerRowSlider.textHigh = iconsPerRowSlider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    iconsPerRowSlider.textHigh:SetPoint("BOTTOMRIGHT", iconsPerRowSlider, "BOTTOMRIGHT", 0, -10)
    iconsPerRowSlider.textHigh:SetText("10")
    iconsPerRowSlider.title = iconsPerRowSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    iconsPerRowSlider.title:SetPoint("TOPLEFT", iconsPerRowSlider, "TOPLEFT", 0, 15)
    iconsPerRowSlider.title:SetText("Icons Per Row: " .. AuraManDB.iconsPerRow)
    iconsPerRowSlider:SetScript("OnValueChanged", function()
        local value = math.floor(this:GetValue())
        AuraManDB.iconsPerRow = value
        this.title:SetText("Icons Per Row: " .. value)
        AuraMan:CreateCooldownIcons()
    end)
    
    -- Action buttons
    local resetButton = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    resetButton:SetWidth(100)
    resetButton:SetHeight(22)
    resetButton:SetPoint("BOTTOMLEFT", self.configFrame, "BOTTOMLEFT", 20, 20)
    resetButton:SetText("Reset Position")
    resetButton:SetScript("OnClick", function()
        AuraManDB.hudX = 0
        AuraManDB.hudY = 0
        if AuraMan.hudFrame then
            AuraMan.hudFrame:ClearAllPoints()
            AuraMan.hudFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Position reset to center")
    end)
    
    local hideButton = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    hideButton:SetWidth(100)
    hideButton:SetHeight(22)
    hideButton:SetPoint("BOTTOM", self.configFrame, "BOTTOM", 0, 20)
    hideButton:SetText("Toggle HUD")
    hideButton:SetScript("OnClick", function()
        if AuraMan.hudFrame and AuraMan.hudFrame:IsShown() then
            AuraMan.hudFrame:Hide()
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r HUD hidden")
        elseif AuraMan.hudFrame then
            AuraMan.hudFrame:Show()
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r HUD shown")
        end
    end)
    
    local listButton = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    listButton:SetWidth(100)
    listButton:SetHeight(22)
    listButton:SetPoint("BOTTOMRIGHT", self.configFrame, "BOTTOMRIGHT", -20, 20)
    listButton:SetText("List Abilities")
    listButton:SetScript("OnClick", function()
        AuraMan:ListTrackedAbilities()
    end)
    
    -- Instructions
    local instructions = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    instructions:SetPoint("TOPLEFT", self.configFrame, "TOPLEFT", 20, -330)
    instructions:SetWidth(360)
    instructions:SetJustifyH("LEFT")
    instructions:SetText("• Hold Shift and drag the HUD to move it\n• Changes are applied immediately and saved automatically\n• Use the sliders to fine-tune your HUD appearance\n• The HUD will automatically stay within screen bounds")
    instructions:SetTextColor(0.8, 0.8, 0.8)
    
    -- Store references for updates
    self.configFrame.enabledCheckbox = enabledCheckbox
    self.configFrame.scaleSlider = scaleSlider
    self.configFrame.opacitySlider = opacitySlider
    self.configFrame.iconSizeSlider = iconSizeSlider
    self.configFrame.iconsPerRowSlider = iconsPerRowSlider
end

-- Apply scale with bounds checking
function AuraMan:ApplyScale()
    if not self.hudFrame then return end
    
    local x, y = self.hudFrame:GetCenter()
    local screenWidth = UIParent:GetWidth()
    local screenHeight = UIParent:GetHeight()
    local unscaledX = x - screenWidth/2
    local unscaledY = y - screenHeight/2
    
    -- Apply the new scale
    local newScale = AuraManDB.hudScale
    if type(newScale) == "number" and newScale > 0 and newScale <= 3 then
        self.hudFrame:SetScale(newScale)
    else
        self.hudFrame:SetScale(1.0)
        AuraManDB.hudScale = 1.0
        newScale = 1.0
    end
    
    -- Calculate screen bounds considering the new scale
    local frameWidth = self.hudFrame:GetWidth() * newScale
    local frameHeight = self.hudFrame:GetHeight() * newScale
    local minX = -screenWidth/2 + frameWidth/2
    local maxX = screenWidth/2 - frameWidth/2
    local minY = -screenHeight/2 + frameHeight/2
    local maxY = screenHeight/2 - frameHeight/2
    
    -- Clamp position to screen bounds
    local clampedX = math.max(minX, math.min(maxX, unscaledX))
    local clampedY = math.max(minY, math.min(maxY, unscaledY))
    
    -- If the frame would go off-screen, center it
    if clampedX ~= unscaledX or clampedY ~= unscaledY then
        clampedX = 0
        clampedY = 0
    end
    
    -- Apply position
    self.hudFrame:ClearAllPoints()
    self.hudFrame:SetPoint("CENTER", UIParent, "CENTER", clampedX, clampedY)
    
    -- Update saved position
    AuraManDB.hudX = clampedX
    AuraManDB.hudY = clampedY
end

-- Update config frame values
function AuraMan:UpdateConfigFrame()
    if not self.configFrame then return end
    
    if self.configFrame.enabledCheckbox then
        self.configFrame.enabledCheckbox:SetChecked(AuraManDB.enabled)
    end
    if self.configFrame.scaleSlider then
        self.configFrame.scaleSlider:SetValue(AuraManDB.hudScale)
        self.configFrame.scaleSlider.title:SetText("HUD Scale: " .. AuraManDB.hudScale .. "x")
    end
    if self.configFrame.opacitySlider then
        self.configFrame.opacitySlider:SetValue(AuraManDB.hudOpacity)
        self.configFrame.opacitySlider.title:SetText("Background Opacity: " .. math.floor(AuraManDB.hudOpacity * 100) .. "%")
    end
    if self.configFrame.iconSizeSlider then
        self.configFrame.iconSizeSlider:SetValue(AuraManDB.iconSize)
        self.configFrame.iconSizeSlider.title:SetText("Icon Size: " .. AuraManDB.iconSize .. "px")
    end
    if self.configFrame.iconsPerRowSlider then
        self.configFrame.iconsPerRowSlider:SetValue(AuraManDB.iconsPerRow)
        self.configFrame.iconsPerRowSlider.title:SetText("Icons Per Row: " .. AuraManDB.iconsPerRow)
    end
end

-- Create cooldown icon frames
function AuraMan:CreateCooldownIcons()
    -- Clear existing frames
    for _, frame in pairs(self.cooldownFrames) do
        frame:Hide()
        frame:SetParent(nil)
    end
    self.cooldownFrames = {}
    
    -- Get player's class
    local _, class = UnitClass("player")
    if not class or not CLASS_ABILITIES[class] then
        return
    end
    
    local iconSize = AuraManDB.iconSize
    local iconsPerRow = AuraManDB.iconsPerRow
    local spacing = 5
    local startX = 10
    local startY = -30
    
    -- Safety checks for sizing values
    if type(iconSize) ~= "number" or iconSize < 20 or iconSize > 100 then
        iconSize = 40
        AuraManDB.iconSize = 40
    end
    if type(iconsPerRow) ~= "number" or iconsPerRow < 1 or iconsPerRow > 10 then
        iconsPerRow = 5
        AuraManDB.iconsPerRow = 5
    end
    
    local row = 0
    local col = 0
    
    -- Create frames only for learned abilities
    for spellName, spellData in pairs(self.trackedSpells) do
        -- Sanitize frame name by removing spaces and special characters
        local frameName = "AuraManCooldown_" .. string.gsub(spellName, "[%s%p]", "")
        local frame = CreateFrame("Frame", frameName, self.hudFrame)
        
        -- Safe frame sizing
        if type(iconSize) == "number" and iconSize > 0 then
            frame:SetWidth(iconSize)
            frame:SetHeight(iconSize + 15) -- Extra space for text
        else
            frame:SetWidth(40)
            frame:SetHeight(55)
        end
        
        -- Position the frame
        local x = startX + (col * (iconSize + spacing))
        local y = startY - (row * (iconSize + spacing + 15))
        frame:SetPoint("TOPLEFT", self.hudFrame, "TOPLEFT", x, y)
        
        -- Icon
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        if type(iconSize) == "number" and iconSize > 0 then
            frame.icon:SetWidth(iconSize)
            frame.icon:SetHeight(iconSize)
        else
            frame.icon:SetWidth(40)
            frame.icon:SetHeight(40)
        end
        frame.icon:SetPoint("TOP", frame, "TOP", 0, 0)
        frame.icon:SetTexture(spellData.icon)
        
        -- Cooldown text
        frame.cooldownText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.cooldownText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
        frame.cooldownText:SetTextColor(1, 1, 1)
        frame.cooldownText:SetText("")
        
        -- Spell name (smaller text)
        frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.nameText:SetPoint("CENTER", frame.icon, "CENTER", 0, 0)
        frame.nameText:SetTextColor(1, 1, 1)
        frame.nameText:SetText("")
        -- Safe font setting
        if frame.nameText.SetFont then
            frame.nameText:SetFont("Fonts\\FRIZQT__.TTF", 8)
        end
        
        -- Gray overlay for when on cooldown
        frame.grayOverlay = frame:CreateTexture(nil, "OVERLAY")
        frame.grayOverlay:SetAllPoints(frame.icon)
        frame.grayOverlay:SetTexture(0, 0, 0, 0.6)
        frame.grayOverlay:Hide()
        
        -- Make the frame clickable
        frame:EnableMouse(true)
        frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        frame:SetScript("OnClick", function()
            AuraMan:OnIconClick(this.spellName, this.spellData)
        end)
        frame:SetScript("OnEnter", function()
            AuraMan:OnIconEnter(this.spellName, this.spellData)
        end)
        frame:SetScript("OnLeave", function()
            AuraMan:OnIconLeave()
        end)
        
        -- Store spell data
        frame.spellName = spellName
        frame.spellData = spellData
        
        self.cooldownFrames[spellName] = frame
        
        -- Move to next position
        col = col + 1
        if col >= iconsPerRow then
            col = 0
            row = row + 1
        end
    end
    
    -- Resize HUD frame based on content
    local totalRows = math.ceil(self:CountTable(self.cooldownFrames) / iconsPerRow)
    local newHeight = 50 + (totalRows * (iconSize + spacing + 15))
    local newWidth = 20 + (iconsPerRow * (iconSize + spacing))
    
    -- Safe HUD frame sizing
    if type(newWidth) == "number" and newWidth > 0 and newWidth < 2000 then
        self.hudFrame:SetWidth(newWidth)
    else
        self.hudFrame:SetWidth(300)
    end
    if type(newHeight) == "number" and newHeight > 0 and newHeight < 2000 then
        self.hudFrame:SetHeight(newHeight)
    else
        self.hudFrame:SetHeight(200)
    end
end

-- Event handler
function AuraMan:OnEvent()
    if event == "ADDON_LOADED" and arg1 == "AuraMan" then
        self:Initialize()
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        self:UpdateTrackedSpells()
    elseif event == "SPELL_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_COOLDOWN" then
        self:CheckCooldowns()
    end
end

-- Initialize the addon
function AuraMan:Initialize()
    self:CreateHUDFrame()
    self:CreateConfigFrame()
    self:RegisterSlashCommands()
    self.enabled = AuraManDB.enabled
end

-- Update tracked spells based on player's spellbook
function AuraMan:UpdateTrackedSpells()
    self.trackedSpells = {}
    
    -- Get player's class
    local _, class = UnitClass("player")
    if not class or not CLASS_ABILITIES[class] then
        return
    end
    
    -- Scan spellbook for tracked abilities
    for spellName, spellData in pairs(CLASS_ABILITIES[class]) do
        for i = 1, GetNumSpellTabs() do
            local _, _, offset, numSpells = GetSpellTabInfo(i)
            for j = offset + 1, offset + numSpells do
                local name = GetSpellName(j, BOOKTYPE_SPELL)
                if name == spellName then
                    self.trackedSpells[spellName] = {
                        name = spellName,
                        id = spellData.id,
                        cooldown = spellData.cooldown,
                        icon = spellData.icon,
                        priority = spellData.priority,
                        spellIndex = j
                    }
                    break
                end
            end
        end
    end
    
    -- Update HUD icons
    self:CreateCooldownIcons()
    self:UpdateHUDIcons()
end

-- Check cooldowns and update HUD
function AuraMan:CheckCooldowns()
    if not self.enabled then return end
    
    self:UpdateHUDIcons()
end

-- Update HUD icons with current cooldown status
function AuraMan:UpdateHUDIcons()
    if not self.cooldownFrames then return end
    
    for spellName, frame in pairs(self.cooldownFrames) do
        local spellData = self.trackedSpells[spellName]
        
        if spellData then
            -- Spell is learned (all frames are for learned spells now)
            local start, duration = GetSpellCooldown(spellData.spellIndex, BOOKTYPE_SPELL)
            
            if start and duration and duration > 0 then
                -- Spell is on cooldown
                local remaining = (start + duration) - GetTime()
                if remaining > 0 then
                    frame.grayOverlay:Show()
                    frame.cooldownText:SetText(self:FormatTime(remaining))
                    frame.cooldownText:SetTextColor(1, 0.5, 0.5) -- Red-ish
                    frame.nameText:SetText("")
                else
                    -- Spell is ready
                    frame.grayOverlay:Hide()
                    frame.cooldownText:SetText("READY")
                    frame.cooldownText:SetTextColor(0, 1, 0) -- Green
                    frame.nameText:SetText("")
                end
            else
                -- Spell is ready (no cooldown)
                frame.grayOverlay:Hide()
                frame.cooldownText:SetText("READY")
                frame.cooldownText:SetTextColor(0, 1, 0) -- Green
                frame.nameText:SetText("")
            end
        end
    end
end

-- Format time for display
function AuraMan:FormatTime(seconds)
    if seconds >= 3600 then
        return string.format("%.1fh", seconds / 3600)
    elseif seconds >= 60 then
        return string.format("%.1fm", seconds / 60)
    else
        return string.format("%.0fs", seconds)
    end
end

-- Update function
function AuraMan:OnUpdate()
    local now = GetTime()
    if now - self.lastUpdate >= self.updateInterval then
        self:CheckCooldowns()
        self.lastUpdate = now
    end
end

-- Slash commands
function AuraMan:RegisterSlashCommands()
    SLASH_AURAMAN1 = "/auraman"
    SLASH_AURAMAN2 = "/am"
    
    SlashCmdList["AURAMAN"] = function(msg)
        local command = strlower(msg)
        
        if command == "toggle" then
            AuraManDB.enabled = not AuraManDB.enabled
            AuraMan.enabled = AuraManDB.enabled
            if AuraManDB.enabled then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. AuraMan:GetLocalizedText("NOTIFICATIONS_ENABLED"))
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. AuraMan:GetLocalizedText("NOTIFICATIONS_DISABLED"))
            end
        elseif command == "reset" then
            AuraManDB.hudX = 0
            AuraManDB.hudY = 0
            if AuraMan.hudFrame then
                AuraMan.hudFrame:ClearAllPoints()
                AuraMan.hudFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. AuraMan:GetLocalizedText("POSITION_RESET"))
        elseif command == "list" then
            AuraMan:ListTrackedAbilities()
        elseif command == "scale" then
            -- Toggle between scale sizes
            if AuraManDB.hudScale == 1.0 then
                AuraManDB.hudScale = 0.8
            elseif AuraManDB.hudScale == 0.8 then
                AuraManDB.hudScale = 0.5
            elseif AuraManDB.hudScale == 0.5 then
                AuraManDB.hudScale = 1.2
            else
                AuraManDB.hudScale = 1.0
            end
            if AuraMan.hudFrame then
                -- Store current screen position before scaling
                local x, y = AuraMan.hudFrame:GetCenter()
                local screenWidth = UIParent:GetWidth()
                local screenHeight = UIParent:GetHeight()
                
                -- Get current scale and calculate unscaled position
                local currentScale = AuraMan.hudFrame:GetScale()
                local unscaledX = x - screenWidth/2
                local unscaledY = y - screenHeight/2
                
                -- Apply the new scale
                local newScale = AuraManDB.hudScale
                if type(newScale) == "number" and newScale > 0 and newScale <= 3 then
                    AuraMan.hudFrame:SetScale(newScale)
                else
                    AuraMan.hudFrame:SetScale(1.0)
                    AuraManDB.hudScale = 1.0
                    newScale = 1.0
                end
                
                -- Calculate screen bounds considering the new scale
                local frameWidth = AuraMan.hudFrame:GetWidth() * newScale
                local frameHeight = AuraMan.hudFrame:GetHeight() * newScale
                local minX = -screenWidth/2 + frameWidth/2
                local maxX = screenWidth/2 - frameWidth/2
                local minY = -screenHeight/2 + frameHeight/2
                local maxY = screenHeight/2 - frameHeight/2
                
                -- Clamp position to screen bounds
                local clampedX = math.max(minX, math.min(maxX, unscaledX))
                local clampedY = math.max(minY, math.min(maxY, unscaledY))
                
                -- If the frame would go off-screen, center it
                if clampedX ~= unscaledX or clampedY ~= unscaledY then
                    clampedX = 0
                    clampedY = 0
                end
                
                -- Restore position after scaling
                AuraMan.hudFrame:ClearAllPoints()
                AuraMan.hudFrame:SetPoint("CENTER", UIParent, "CENTER", clampedX, clampedY)
                
                -- Update saved position
                AuraManDB.hudX = clampedX
                AuraManDB.hudY = clampedY
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Scale set to " .. AuraManDB.hudScale)
        elseif command == "opacity" then
            -- Toggle between opacity levels
            if AuraManDB.hudOpacity == 0.3 then
                AuraManDB.hudOpacity = 0.5
            elseif AuraManDB.hudOpacity == 0.5 then
                AuraManDB.hudOpacity = 0.7
            elseif AuraManDB.hudOpacity == 0.7 then
                AuraManDB.hudOpacity = 0.0
            else
                AuraManDB.hudOpacity = 0.3
            end
            if AuraMan.hudFrame and AuraMan.hudFrame.bg then
                AuraMan.hudFrame.bg:SetTexture(0, 0, 0, AuraManDB.hudOpacity)
            end
            local opacityPercent = math.floor(AuraManDB.hudOpacity * 100)
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Background opacity set to " .. opacityPercent .. "%")
        elseif command == "hide" then
            if AuraMan.hudFrame and AuraMan.hudFrame:IsShown() then
                AuraMan.hudFrame:Hide()
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r HUD hidden")
            elseif AuraMan.hudFrame then
                AuraMan.hudFrame:Show()
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r HUD shown")
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r HUD not initialized yet")
            end
        elseif command == "config" or command == "options" then
            if AuraMan.configFrame then
                if AuraMan.configFrame:IsShown() then
                    AuraMan.configFrame:Hide()
                else
                    AuraMan:UpdateConfigFrame()
                    AuraMan.configFrame:Show()
                end
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Config frame not initialized yet")
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. AuraMan:GetLocalizedText("SLASH_HELP") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. AuraMan:GetLocalizedText("SLASH_TOGGLE") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. AuraMan:GetLocalizedText("SLASH_RESET") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. AuraMan:GetLocalizedText("SLASH_LIST") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/auraman config|r - Open configuration panel")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/auraman scale|r - Change HUD scale")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/auraman opacity|r - Change background opacity")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/auraman hide|r - Toggle HUD visibility")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Shift+drag|r - Move HUD")
        end
    end
end

-- List tracked abilities for debugging
function AuraMan:ListTrackedAbilities()
    local _, class = UnitClass("player")
    if not class or not CLASS_ABILITIES[class] then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. self:GetLocalizedText("NO_ABILITIES_FOUND"))
        return
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. self:GetLocalizedText("TRACKED_ABILITIES"))
    
    for spellName, spellData in pairs(AuraMan.trackedSpells) do
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00✓|r " .. spellName .. " (Priority: " .. spellData.priority .. ")")
    end
    
    -- Show total count of learned abilities
    local learnedCount = AuraMan:CountTable(AuraMan.trackedSpells)
    local totalCount = AuraMan:CountTable(CLASS_ABILITIES[class])
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. learnedCount .. " of " .. totalCount .. " class abilities learned")
end

-- Helper function to count table elements
function AuraMan:CountTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Handle HUD icon clicks
function AuraMan:OnIconClick(spellName, spellData)
    if not spellName or not spellData then
        return
    end
    
    -- Check if we have a valid spell index
    if spellData.spellIndex then
        -- Left click: Cast the spell
        if arg1 == "LeftButton" then
            -- Shift+Left click: Open spellbook to the spell
            if IsShiftKeyDown() then
                ToggleSpellBook(BOOKTYPE_SPELL)
                -- Try to select the spell tab and highlight the spell
                SpellBookFrame:Show()
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Opened spellbook for " .. spellName)
            else
                -- Regular left click: Cast the spell
                local spellName, spellRank = GetSpellName(spellData.spellIndex, BOOKTYPE_SPELL)
                if spellName then
                    CastSpell(spellData.spellIndex, BOOKTYPE_SPELL)
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Casting " .. spellName)
                end
            end
        -- Right click: Show spell info (or pass through to HUD handler)
        elseif arg1 == "RightButton" then
            -- For now, just show spell info
            local cooldownText = spellData.cooldown and (spellData.cooldown .. " seconds") or "Unknown"
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. spellName .. " (Cooldown: " .. cooldownText .. ")")
        end
    else
        -- Fallback: try to cast by name
        if arg1 == "LeftButton" then
            if IsShiftKeyDown() then
                ToggleSpellBook(BOOKTYPE_SPELL)
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Opened spellbook for " .. spellName)
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Attempting to cast " .. spellName .. " (no spell index)")
                -- This is a fallback - may not work in all cases
                CastSpellByName(spellName)
            end
        elseif arg1 == "RightButton" then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. spellName .. " (spell not found in spellbook)")
        end
    end
end

-- Handle HUD icon mouse enter (for future tooltip functionality)
function AuraMan:OnIconEnter(spellName, spellData)
    -- Future: Show tooltip with spell information
    -- For now, this is a placeholder
end

-- Handle HUD icon mouse leave
function AuraMan:OnIconLeave()
    -- Future: Hide tooltip
    -- For now, this is a placeholder
end

-- Initialize the addon
AuraMan:CreateFrame()
