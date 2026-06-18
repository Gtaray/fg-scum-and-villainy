--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local fSetVarNumber;
local fSetVarNumberField;
local fOnClose;

local _tPendingFieldHandlers = {};

function onInit()
	fSetVarNumber = super.setVarNumber;
	super.setVarNumber = setVarNumber;

	fSetVarNumberField = super.setVarNumberField;
	super.setVarNumberField = setVarNumberField;

	fOnClose = super.onClose;
	super.onClose = onClose;

	if super and super.onInit then
		super.onInit();
	end
end

function onClose()
	for _, rPending in pairs(_tPendingFieldHandlers) do
		if (rPending.sPath or "") ~= "" then
			DB.removeHandler(rPending.sPath, "onUpdate", rPending.fHandler);
		end
	end
	_tPendingFieldHandlers = {};

	if fOnClose then
		fOnClose();
	end
end

-- Block client-side writes for stress counter values.
-- This prevents mid-session row initialization from attempting unauthorized
-- default writes before linked stress nodes have fully replicated.
function setVarNumber(sKey, n)
	if not Session.IsHost then
		return;
	end

	fSetVarNumber(sKey, n);
end

function setVarNumberField(sKey, sField)
	if Session.IsHost then
		fSetVarNumberField(sKey, sField);
		return;
	end

	if (sKey or "") == "" then
		return;
	end

	local nodeWin = window.getDatabaseNode();
	if not nodeWin then
		return;
	end

	if (sField or "") == "" then
		sField = sKey;
	end

	local sPath = DB.getPath(nodeWin, sField);

	-- If source data already exists, bind immediately.
	if DB.getValue(sPath) ~= nil then
		fSetVarNumberField(sKey, sField);
		return;
	end

	-- Otherwise defer binding until host replication creates the node/value.
	local rExisting = _tPendingFieldHandlers[sKey];
	if rExisting and (rExisting.sPath or "") ~= "" then
		DB.removeHandler(rExisting.sPath, "onUpdate", rExisting.fHandler);
	end

	local fHandler = function()
		if DB.getValue(sPath) == nil then
			return;
		end

		local rPending = _tPendingFieldHandlers[sKey];
		if rPending and (rPending.sPath or "") ~= "" then
			DB.removeHandler(rPending.sPath, "onUpdate", rPending.fHandler);
			_tPendingFieldHandlers[sKey] = nil;
		end

		fSetVarNumberField(sKey, sField);
	end

	_tPendingFieldHandlers[sKey] = {
		sPath = sPath,
		fHandler = fHandler,
	};
	DB.addHandler(sPath, "onUpdate", fHandler);
end
