function onButtonPress()
	local clockNode = window.getDatabaseNode();
	ClockManager.sendClockToChat(clockNode);
end