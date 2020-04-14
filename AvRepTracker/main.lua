-- AVRepTracker = LibStub("AceAddon-3.0"):NewAddon("AVRepTracker", "AceConsole-3.0", "AceEvent-3.0")
-- LibStub("AceConfigRegistry-3.0"):NotifyChange("AVRepTracker")

local addonName, T = ...;

SLASH_AVRT1 = "/avrt";

function SlashCmdList.AVRT(msg, editbox)
	local command, words = msg:match("^(%S*)%s*(.-)$");
	-- Any leading non-whitespace is captured into command
	-- the rest (minus leading whitespace) is captured into words.
	if (command == "toggle") or (string.len(command) == 0) then
		T:toggleTracking();
		T:printEnabledState();
	elseif command == "start" then
		T:startRecording();
	elseif command == "stop" then
		T:stopRecording();
	elseif command == "debug" then
		T:toggleDebug();
		T:printDebugState();
	elseif (command == "help") or (command == "?")  then
		T:printHelp();
	elseif command == "list" then -- for debugging
		T:listFactions();
	elseif command == "findfaction" then -- for debugging
		T:findStormpikeFactionIndex();
	else
		-- If not handled above, display some sort of help message
		print("Syntax: /avrt")
	end
end

T.STORMPIKE_GUARD_ID = 730;

T.isTrackingEnabled = false;
T.isRecording = false;
T.stormpikeFactionIndex = -1;
T.startRep = 0;
T.startTimeSec = 0;
T.isDebugEnabled = false;


function T:prepareAddon()
	T:trace("Setting up AV Reputation Tracker");
	T.isTrackingEnabled = g_avrt_TrackingEnabled;
	T.stormpikeFactionIndex = T:findStormpikeFactionIndex();
	T.isDebugEnabled = g_avrt_IsDebugTracingEnabled;
	T:printEnabledState();
end;

function T:startRecording()
	if (T.stormpikeFactionIndex == -1) then
		print("Stormpike faction index not found. Make sure the entry is visible in the reputation window");
		return;
	end
	if (T.isRecording) then
		print("Already recording");
	end
	
	local _, _, _, _, _, earnedValue, _, _, _, _, _, _, _ = GetFactionInfo(T.stormpikeFactionIndex);
	T.startRep = earnedValue;
	T.startTimeSec = GetTime();
	print("Starting session. Current total reputation: " .. T.startRep);
	T.isRecording = true;
end

function T:stopRecording()
	if (T.stormpikeFactionIndex == -1) then
		print("Stormpike faction index not found. Make sure the entry is visible in the reputation window");
		return;
	end
	if (not T.isRecording) then
		T:trace("Already stopped recording");
		return;
	end
	T:printSummary();
	T.isRecording = false;
end

function T:printSummary()
	if not T.isRecording then
		return;
	end
	
	local _, _, _, _, _, earnedValue, _, _, _, _, _, _, _ = GetFactionInfo(T.stormpikeFactionIndex);
	local currentRep = earnedValue;
	local gain = currentRep - T.startRep;
	local durationSeconds = (GetTime() - T.startTimeSec);
	local minutes = string.format("%.0f", durationSeconds / 60);
	local seconds = string.format("%02d", durationSeconds % 60);
	local repPerHour = string.format("%.0f", gain / (durationSeconds / 60 / 60));
	T:trace("duration: " .. string.format("%.1f", durationSeconds));
	print("End session. Total Reputation: " .. currentRep .. "\nYou gained " .. gain .. " reputation in " .. minutes .. ":" .. seconds .. " minutes\n" .. repPerHour .. " reputation/hour" );
end

function avrt_OnEnterWorld(self, event, isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		T:prepareAddon();
	else
		T:trace("zoned between map instances");
		local inInstance, instanceType = IsInInstance();
		T:trace("InInstance: " .. tostring(inInstance) .. ", type: " .. instanceType);

		if inInstance and instanceType == "pvp" then
			local name, _, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo();
			T:trace(name .. ", instance ID: " .. instanceID );
			if instanceID == 30 then
				T:startRecording();
			else 
				T:stopRecording();
			end
		else
			T:stopRecording();
		end
	end
end

local f = CreateFrame("FRAME", "AvRepTrackerFrame");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:SetScript("OnEvent", avrt_OnEnterWorld);


function T:printEnabledState()
	print("AV Reputation Tracker" .. (T.isTrackingEnabled and "|cff22dd33 enabled" or "|cffdd3333 disabled"));
end

function T:printDebugState()
	print("AV Reputation Tracker debugging" .. (T.isDebugEnabled and "|cff22dd33 enabled" or "|cffdd3333 disabled"));
end

function T:toggleTracking()
	g_avrt_TrackingEnabled = not g_avrt_TrackingEnabled;
	T.isTrackingEnabled = g_avrt_TrackingEnabled;
end

function T:toggleDebug()
	g_avrt_IsDebugTracingEnabled = not g_avrt_IsDebugTracingEnabled;
	T.isDebugEnabled = g_avrt_IsDebugTracingEnabled;
end

function T:findStormpikeFactionIndex()
	local numFactions = GetNumFactions();
	for i=1, numFactions do
		local name, _, _, _, _, reputation, _, _, isHeader, _, _hasRep, _, _, factionID = GetFactionInfo(i);
		if factionID == T.STORMPIKE_GUARD_ID then
			T:trace("Stormpike faction index: " .. i);
			return i;
		end
	end
	print("Stormpike faction not found!");
	return -1;
end

function T:listFactions()
	local numFactions = GetNumFactions();
	for i=1, numFactions do
		local name, _, _, _, _, reputation, _, _, isHeader, _, _hasRep, _, _, factionID = GetFactionInfo(i);
		if (not isHeader) then
			print(i .. ": " .. name .. " " .. reputation);
		end
	end
end

function T:trace(msg)
	if (T.isDebugEnabled) then
		print(msg);
	end
end

function T:printHelp()
	print("Alterac Valley commands \n /avrt - toggles AVRT on/off \n /avrt start  /avrt stop - starts and stops AV rep recording \n /avrt list - lists known factions for this character \n /avrt debug - toggles debug messages")
end


