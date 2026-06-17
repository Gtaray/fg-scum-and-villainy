function onInit()
	--setVisible(not Session.IsHost);
end

-- Has to be overridden by inhereted templates
function getCallback()
	return nil;
end

function onClickDown(button, x, y)
	if not Session.IsHost then
		return button == 1;
	end
end

function onClickRelease()
	local fCallback = self.getCallback();
	if not fCallback then
		return;
	end

	local sPath = nil;
	if path and path[1] then
		sPath = path[1];
	end
	if not sPath then
		return;
	end

	sPath = DB.getPath(window.getDatabaseNode(), sPath)

	local sType = DB.getType(sPath);
	if not sType then
		return;
	end

	local sTitleRes = nil;
	if titleres and titleres[1] then
		sTitleRes = titleres[1];
	end
	if not sTitleRes then
		return;
	end

	local tData = {
		sTitleRes = sTitleRes,
		sDbPath = sPath,
		sText = DB.getValue(sPath),
		sType = sType,
		fnCallback = fCallback
	}

	if sType == "formattedtext" then
		DialogManager.openDialog("dialog_formattedtext", tData);
	elseif sType == "string" then
		DialogManager.openDialog("dialog_text", tData);
	end
end