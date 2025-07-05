-- AuraMan - Multi-Class Cooldown Tracker
-- Classic WoW Addon for Turtle WoW (1.12.1)

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
    }
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
    },
}

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
    self.hudFrame:SetWidth(300)
    self.hudFrame:SetHeight(200)
    self.hudFrame:SetPoint("CENTER", UIParent, "CENTER", AuraManDB.hudX, AuraManDB.hudY)
    self.hudFrame:SetScale(AuraManDB.hudScale)
    
    -- Make it movable
    self.hudFrame:SetMovable(true)
    self.hudFrame:EnableMouse(true)
    self.hudFrame:SetScript("OnMouseDown", function()
        if IsShiftKeyDown() then
            this:StartMoving()
        end
    end)
    self.hudFrame:SetScript("OnMouseUp", function()
        this:StopMovingOrSizing()
        local x, y = this:GetCenter()
        local screenWidth = UIParent:GetWidth()
        local screenHeight = UIParent:GetHeight()
        AuraManDB.hudX = x - screenWidth/2
        AuraManDB.hudY = y - screenHeight/2
    end)
    
    -- Background (semi-transparent)
    local bg = self.hudFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0, 0, 0, 0.3)
    
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
    
    local row = 0
    local col = 0
    
    -- Create frames for each ability
    for spellName, spellData in pairs(CLASS_ABILITIES[class]) do
        local frame = CreateFrame("Frame", "AuraManCooldown_" .. spellName, self.hudFrame)
        frame:SetWidth(iconSize)
        frame:SetHeight(iconSize + 15) -- Extra space for text
        
        -- Position the frame
        local x = startX + (col * (iconSize + spacing))
        local y = startY - (row * (iconSize + spacing + 15))
        frame:SetPoint("TOPLEFT", self.hudFrame, "TOPLEFT", x, y)
        
        -- Icon
        frame.icon = frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetWidth(iconSize)
        frame.icon:SetHeight(iconSize)
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
        frame.nameText:SetFont("Fonts\\FRIZQT__.TTF", 8)
        
        -- Gray overlay for when on cooldown
        frame.grayOverlay = frame:CreateTexture(nil, "OVERLAY")
        frame.grayOverlay:SetAllPoints(frame.icon)
        frame.grayOverlay:SetTexture(0, 0, 0, 0.6)
        frame.grayOverlay:Hide()
        
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
    self.hudFrame:SetWidth(newWidth)
    self.hudFrame:SetHeight(newHeight)
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
            -- Spell is learned
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
        else
            -- Spell is not learned
            frame.grayOverlay:Show()
            frame.cooldownText:SetText("NOT LEARNED")
            frame.cooldownText:SetTextColor(0.5, 0.5, 0.5) -- Gray
            frame.nameText:SetText(string.sub(spellName, 1, 8)) -- Show abbreviated name
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
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. GetLocalizedText("NOTIFICATIONS_ENABLED"))
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. GetLocalizedText("NOTIFICATIONS_DISABLED"))
            end
        elseif command == "reset" then
            AuraManDB.hudX = 0
            AuraManDB.hudY = 0
            if AuraMan.hudFrame then
                AuraMan.hudFrame:ClearAllPoints()
                AuraMan.hudFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. GetLocalizedText("POSITION_RESET"))
        elseif command == "list" then
            AuraMan:ListTrackedAbilities()
        elseif command == "scale" then
            -- Toggle between scale sizes
            if AuraManDB.hudScale == 1.0 then
                AuraManDB.hudScale = 0.8
            elseif AuraManDB.hudScale == 0.8 then
                AuraManDB.hudScale = 1.2
            else
                AuraManDB.hudScale = 1.0
            end
            if AuraMan.hudFrame then
                AuraMan.hudFrame:SetScale(AuraManDB.hudScale)
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r Scale set to " .. AuraManDB.hudScale)
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
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. GetLocalizedText("SLASH_HELP") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. GetLocalizedText("SLASH_TOGGLE") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. GetLocalizedText("SLASH_RESET") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. GetLocalizedText("SLASH_LIST") .. "|r")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/auraman scale|r - Change HUD scale")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/auraman hide|r - Toggle HUD visibility")
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Shift+drag|r - Move HUD")
        end
    end
end

-- List tracked abilities for debugging
function AuraMan:ListTrackedAbilities()
    local _, class = UnitClass("player")
    if not class or not CLASS_ABILITIES[class] then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. GetLocalizedText("NO_ABILITIES_FOUND"))
        return
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00AuraMan:|r " .. GetLocalizedText("TRACKED_ABILITIES"))
    
    for spellName, spellData in pairs(AuraMan.trackedSpells) do
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00✓|r " .. spellName .. " (Priority: " .. spellData.priority .. ")")
    end
    
    -- Show abilities that are available for the class but not learned
    for spellName, spellData in pairs(CLASS_ABILITIES[class]) do
        if not AuraMan.trackedSpells[spellName] then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000✗|r " .. string.format(GetLocalizedText("ABILITY_NOT_LEARNED"), spellName))
        end
    end
end

-- Helper function to count table elements
function AuraMan:CountTable(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Helper function to safely get localized text
local function GetLocalizedText(key)
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

-- Initialize the addon
AuraMan:CreateFrame()
