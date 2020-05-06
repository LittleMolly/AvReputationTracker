local addonName, NS = ...;

function restedXpInfo_calculateXpValues(self, event)
    NS.RestedXp = GetXPExhaustion()
    if NS.RestedXp then        
        local XPMax = UnitXPMax("player")
        local RestedCap = XPMax * 1.5
        local xpUntilCap = RestedCap - NS.RestedXp
        local restedXpPerMinute = RestedCap / 30 / 8 / 60
        local minutesUntilCap = xpUntilCap / restedXpPerMinute
        local restedPercentage = 100 * NS.RestedXp / RestedCap
        
        NS.isCapped = NS.RestedXp >= RestedCap
        NS.minutes = string.format("%02d", minutesUntilCap % 60)
        NS.hours = string.format("%.0f", math.floor((minutesUntilCap / 60) % 24))
        NS.days = string.format("%.0f", math.floor(minutesUntilCap / 60 / 24))
        if restedPercentage < 10 then
            NS.restedPercentageFormatted = string.format("%.1f", restedPercentage) 
        else 
            NS.restedPercentageFormatted = string.format("%.0f", restedPercentage)
        end
    end
end

local f = CreateFrame("FRAME", "RestedXpFrame");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_XP_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("UPDATE_EXHAUSTION")
f:SetScript("OnEvent", restedXpInfo_calculateXpValues);

MainMenuExpBar:HookScript("OnEnter", function(self)
    if NS.RestedXp then
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Rested XP")
        GameTooltip:AddDoubleLine("Total rested XP", NS.RestedXp)
        GameTooltip:AddDoubleLine("% of rested XP cap", NS.restedPercentageFormatted .."%")
        if not NS.isCapped then
            GameTooltip:AddDoubleLine("Until rested XP cap", NS.days .."d ".. NS.hours .."h ".. NS.minutes .."m")
        end
    end
end)

MainMenuExpBar:HookScript("OnLeave", function(self)
end)

function NS:printXPStats()
    NS.RestedXp = GetXPExhaustion()
    if NS.RestedXp then
        local XP = UnitXP("player")
        local XPMax = UnitXPMax("player")
        local RestedCap = XPMax * 1.5
        NS.isCapped = NS.RestedXp >= RestedCap
        local xpUntilCap = RestedCap - NS.RestedXp
        local restedXpPerMinute = RestedCap / 30 / 8 / 60
        local minutesUntilCap = xpUntilCap / restedXpPerMinute
        local restedPercentage = 100 * NS.RestedXp / RestedCap
        
        NS.minutes = string.format("%02d", minutesUntilCap % 60)
        NS.hours = string.format("%.0f", math.floor((minutesUntilCap / 60) % 24))
        NS.days = string.format("%.0f", math.floor(minutesUntilCap / 60 / 24))
        if restedPercentage < 10 then
            NS.restedPercentageFormatted = string.format("%.1f", restedPercentage) 
        else 
            NS.restedPercentageFormatted = string.format("%.0f", restedPercentage)
        end
        
        print(NS.restedPercentageFormatted .."% of max rested XP acquired")
        if not NS.isCapped then
            print("Time until rested XP cap: ".. NS.days .." days, ".. NS.hours .." hours, ".. NS.minutes .." minutes")
        end
    end
end