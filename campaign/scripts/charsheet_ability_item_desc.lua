function onInit()
	local node = window.getDatabaseNode();
	DB.addHandler(DB.getPath(node, "name"), "onUpdate", update);
	DB.addHandler(DB.getPath(node, "description"), "onUpdate", update);

	self.update();
end

function onClose()
	local node = window.getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "name"), "onUpdate", update);
	DB.removeHandler(DB.getPath(node, "description"), "onUpdate", update);
end

function update()
	local node = window.getDatabaseNode();
	local sName = DB.getValue(node, "name", "");
	local sDesc = DB.getValue(node, "description", "");

	-- Trim the <p> and </p> from the string
	sDesc = string.gsub(sDesc, "<p />", "") -- Remove empty paragraphs
	sDesc = string.sub(sDesc, 4, -5);
	local sText = string.format("<p><b>%s</b>: %s</p>", sName, sDesc);

	setValue(sText);
end