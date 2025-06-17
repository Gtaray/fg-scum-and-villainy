local _sMaxSource;

-- maxsource needs to be a DB field that exists at the same hierarchical level as 
-- the source for this field

function onInit()
	if super and super.onInit then
		super.onInit();
	end

	if self.update then
		self.update();
	end

	if maxsource and maxsource[1] then
		self.setMaxLink(maxsource[1]);
	end
end

function onClose()
	if _sMaxSource then
		DB.removeHandler(_sMaxSource, "onUpdate", onMaxUpdated);
	end
end

function onMaxUpdated()
	if _sMaxSource then
		local nMax = DB.getValue(window.getDatabaseNode(), _sMaxSource, 0);
		local nCur = getValue();
		setMaxValue(nMax);
		setValue(math.min(nCur, nMax));
		
		if self.update then
			self.update();
		end
	end
end

function setMaxLink(sLink)
	local node = window.getDatabaseNode();
	if _sMaxSource then
		DB.removeHandler(DB.getPath(node, _sMaxSource), "onUpdate", onMaxUpdated);
		_sMaxSource = nil;
	end
		
	if sLink then
		_sMaxSource = sLink;

		DB.addHandler(DB.getPath(node, _sMaxSource), "onUpdate", onMaxUpdated);
		onMaxUpdated();
	end
end