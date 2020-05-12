local addonName, NS = ...;

NS.wrong = {" verließ", " verliß", " verlis", " verliess"}
NS.right = "*Verlies"
NS.messageBlocking = false;
NS.BlockingTimeout = 5; -- seconds

SLASH_GN1 = "/gn"

function SlashCmdList.GN(msg, editbox)
	local command, words = msg:match("^(%S*)%s*(.-)$")
	-- Any leading non-whitespace is captured into command
	-- the rest (minus leading whitespace) is captured into words.
	if (command == "toggle") or (string.len(command) == 0) then
		NS:toggleGrammarNazoState();
		NS:printGrammarNazoState();
	elseif command == "test" then
		NS:testPunish()
	else
		-- If not handled above, display some sort of help message
		print("Syntax: /gn to toggle activation")
	end
end


function NS:initialize()
	if GrammarNazo_isEnabled == nil then
		GrammarNazo_isEnabled = false;
	end
	NS:printGrammarNazoState();
end;


function NS:findNoobs(msg, author, channelName)
	if GrammarNazo_isEnabled == true and not NS.messageBlocking then
		if channelName == "LookingForGroup" then
			NS:punishIfStupid(msg, author)
		end
	end
	return false
end

function NS:punishIfStupid(msg, author)
	for k, v in pairs(NS.wrong) do
		if string.find(string.lower(msg), v) then
			NS:punish(author)
		end				
	end
end

function NS:punish(author)
	chatTab, name = GetChannelName("LookingForGroup")
	if chatTab then
		SendChatMessage(NS.right , "CHANNEL", nil, chatTab);
		print("Punished ".. author)
		NS:startMessageBlockingTimer()		
	end
end

function NS:testPunish()
	chatTab, name = GetChannelName("LookingForGroup")
	if chatTab then
		print("test ".. NS.right)
	end
end

function NS:printGrammarNazoState()
	print("Grammar Nazo" .. (GrammarNazo_isEnabled and "|cff22dd33 enabled" or "|cffdd3333 disabled"))
end

function NS:toggleGrammarNazoState()
	GrammarNazo_isEnabled = not GrammarNazo_isEnabled
end




local frame = CreateFrame("FRAME", "GrammarNazoAddonFrame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
local function eventHandler(self, event, message, author, arg3,arg4,arg5,arg6,arg7,arg8, channelName, ...)
	if event == "PLAYER_LOGIN" then
		NS:initialize()
	elseif event == "CHAT_MSG_CHANNEL" then
		NS:findNoobs(message, author, channelName)
	end
end
frame:SetScript("OnEvent", eventHandler)

function frame:onUpdate(sinceLastUpdate)
	self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
	if ( self.sinceLastUpdate >= NS.BlockingTimeout ) then -- in seconds
		frame:SetScript("OnUpdate", nil)
		NS.messageBlocking = false
		-- print("stop blocking")
		self.sinceLastUpdate = 0
	end
end

function NS:startMessageBlockingTimer()
	NS.messageBlocking = true;
	-- print("start blocking")
	frame:SetScript("OnUpdate", frame.onUpdate)
end