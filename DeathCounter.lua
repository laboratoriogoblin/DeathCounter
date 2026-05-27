--[[
LaboratorioGoblin Addon

Copyright (C) 2026 LaboratorioGoblin

This Source Code Form is subject to the terms of the
Mozilla Public License, v. 2.0.
If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/
]]


local addonName = ...
local DEATHCOUNTER_VERSION = "1.3"

local DeathCounter = CreateFrame("Frame", "DeathCounterFrame")

-- =====================================================
-- DATABASE
-- =====================================================

DeathCounterDB = DeathCounterDB or {}

local defaults = {
    total = 0,
    pvp = 0,
    pve = 0,
    session = 0,
    scale = 1,
    locked = false,
    pos = {
        point = "CENTER",
        relativePoint = "CENTER",
        x = 0,
        y = 0
    }
}

local db
local playerGUID
local lastKillerType = "PVE"

local function CopyDefaults(src, dst)
    if type(src) ~= "table" then
        return {}
    end

    if type(dst) ~= "table" then
        dst = {}
    end

    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end

    return dst
end

local function GetDB()
    DeathCounterDB = CopyDefaults(defaults, DeathCounterDB)
    return DeathCounterDB
end

-- =====================================================
-- UI
-- =====================================================

local frame = CreateFrame("Frame", "DeathCounterDisplay", UIParent)
frame:SetSize(80, 80)
frame:SetFrameStrata("MEDIUM")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

frame:SetScript("OnDragStart", function(self)
    if not db.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()

    db.pos.point = point
    db.pos.relativePoint = relativePoint
    db.pos.x = xOfs
    db.pos.y = yOfs
end)

local skull = frame:CreateTexture(nil, "ARTWORK")
skull:SetSize(32, 32)
skull:SetPoint("TOP", 0, 0)
skull:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("TOP", skull, "BOTTOM", 0, -4)
text:SetText("0")

local function UpdateDisplay()
    text:SetText(db.total or 0)
end

local function PrintCmd(cmd, desc)
    print("|cffffff00" .. cmd .. "|r - " .. desc)
end

-- =====================================================
-- TOOLTIP
-- =====================================================

frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    GameTooltip:AddLine("Death Counter")
    GameTooltip:AddLine(" ")

    GameTooltip:AddDoubleLine("Total:", db.total)
    GameTooltip:AddDoubleLine("PvE:", db.pve)
    GameTooltip:AddDoubleLine("PvP:", db.pvp)
    GameTooltip:AddDoubleLine("Session:", db.session)

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("/dc for commands")

    GameTooltip:Show()
end)

frame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- =====================================================
-- PVP / PVE DETECTION
-- =====================================================

local function IsPlayerKiller(sourceFlags)
    if not sourceFlags then
        return false
    end

    if bit.band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
        return true
    end

    if bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
        return true
    end

    return false
end

-- =====================================================
-- BLIZZARD SYNC
-- =====================================================

local STAT_TOTAL_DEATHS = 60

local function SafeStatistic(statID)
    local success, result = pcall(GetStatistic, statID)

    if success and result and result ~= "--" then
        return tonumber(result)
    end

    return nil
end

local function SyncStatistics()
    local totalDeaths = SafeStatistic(STAT_TOTAL_DEATHS)

    if not totalDeaths then
        print("|cffff0000DeathCounter: Could not read statistics.")
        print("|cffffff00Open Achievements > Statistics first.")
        return
    end

    db.total = totalDeaths

    UpdateDisplay()

    print("|cff00ff00DeathCounter synchronized.|r")
    print("|cffffff00Total:|r " .. db.total)
end

-- =====================================================
-- EVENTS
-- =====================================================

DeathCounter:RegisterEvent("PLAYER_LOGIN")
DeathCounter:RegisterEvent("PLAYER_DEAD")
DeathCounter:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

DeathCounter:SetScript("OnEvent", function(self, event, ...)

    if event == "PLAYER_LOGIN" then

        db = GetDB()
        playerGUID = UnitGUID("player")

        frame:ClearAllPoints()
        frame:SetPoint(
            db.pos.point,
            UIParent,
            db.pos.relativePoint,
            db.pos.x,
            db.pos.y
        )

        frame:SetScale(db.scale)
        frame:EnableMouse(not db.locked)

        UpdateDisplay()

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then

        local timestamp,
            subEvent,
            hideCaster,
            sourceGUID,
            sourceName,
            sourceFlags,
            sourceRaidFlags,
            destGUID = select(1, ...)

        if destGUID ~= playerGUID then
            return
        end

        if subEvent == "UNIT_DIED"
        or subEvent == "PARTY_KILL"
        or subEvent == "SPELL_INSTAKILL" then

            if IsPlayerKiller(sourceFlags) then
                lastKillerType = "PVP"
            else
                lastKillerType = "PVE"
            end

        elseif subEvent == "ENVIRONMENTAL_DAMAGE" then

            lastKillerType = "PVE"

        elseif subEvent == "SWING_DAMAGE"
        or subEvent == "SPELL_DAMAGE"
        or subEvent == "RANGE_DAMAGE"
        or subEvent == "SPELL_PERIODIC_DAMAGE" then

            if IsPlayerKiller(sourceFlags) then
                lastKillerType = "PVP"
            else
                lastKillerType = "PVE"
            end
        end

    elseif event == "PLAYER_DEAD" then

        db.total = db.total + 1
        db.session = db.session + 1

        if lastKillerType == "PVP" then
            db.pvp = db.pvp + 1
        else
            db.pve = db.pve + 1
        end

        UpdateDisplay()
    end
end)

-- =====================================================
-- COMMANDS
-- =====================================================

SLASH_DEATHCOUNTER1 = "/dc"

SlashCmdList["DEATHCOUNTER"] = function(msg)

    msg = string.lower(msg or "")

    if msg == "" then

        print("|cff00ff00DeathCounter v" .. DEATHCOUNTER_VERSION .. "|r")

        PrintCmd("/dc lock", "Lock frame")
        PrintCmd("/dc unlock", "Unlock frame")
        PrintCmd("/dc reset", "Reset all statistics")
        PrintCmd("/dc scale X", "Scale UI")
        PrintCmd("/dc sync", "Sync total deaths from Blizzard stats")
        PrintCmd("/dc ini pvp X", "Initialize PvP counter")
        PrintCmd("/dc ini pve X", "Initialize PvE counter")

        print("|cffaaaaaaPvP + PvE cannot exceed Total deaths.|r")

        return
    end

    if msg == "lock" then

        db.locked = true
        frame:EnableMouse(false)
        print("|cff00ff00DeathCounter locked.|r")

    elseif msg == "unlock" then

        db.locked = false
        frame:EnableMouse(true)
        print("|cff00ff00DeathCounter unlocked.|r")

    elseif msg == "reset" then

        db.total = 0
        db.pvp = 0
        db.pve = 0
        db.session = 0

        UpdateDisplay()

        print("|cff00ff00DeathCounter reset.|r")

    elseif msg == "sync" then

        SyncStatistics()

    elseif string.find(msg, "^ini pvp") then

        local value = tonumber(string.match(msg, "ini%s+pvp%s+(%d+)"))

        if value then

            if (value + db.pve) > db.total then
                print("|cffff0000PvE + PvP cannot exceed total deaths.|r")
                return
            end

            db.pvp = value
            UpdateDisplay()

            print("|cff00ff00PvP initialized to " .. value .. "|r")
        else
            print("|cffff0000Usage: /dc ini pvp 0|r")
        end

    elseif string.find(msg, "^ini pve") then

        local value = tonumber(string.match(msg, "ini%s+pve%s+(%d+)"))

        if value then

            if (value + db.pvp) > db.total then
                print("|cffff0000PvE + PvP cannot exceed total deaths.|r")
                return
            end

            db.pve = value
            UpdateDisplay()

            print("|cff00ff00PvE initialized to " .. value .. "|r")
        else
            print("|cffff0000Usage: /dc ini pve 7|r")
        end

    elseif string.find(msg, "scale") then

        local scale = tonumber(string.match(msg, "scale%s+(%d+%.?%d*)"))

        if scale and scale > 0 then
            db.scale = scale
            frame:SetScale(scale)

            print("|cff00ff00Scale set to " .. scale .. "|r")
        else
            print("|cffff0000Usage: /dc scale 1.2|r")
        end

    else
        print("|cffff0000Unknown command. Use /dc|r")
    end
end

