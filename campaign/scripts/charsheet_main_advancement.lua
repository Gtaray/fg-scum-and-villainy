function onInit()
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "playbook.xptrigger"), "onUpdate", updateAdvancementText)

	self.updateAdvancementText();
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "playbook.xptrigger"), "onUpdate", updateAdvancementText)
end

function updateAdvancementText()
	local node = getDatabaseNode();

	local sDesperate = string.format("<list><li><i>%s</i></li></list>", Interface.getString("char_label_advancement_desperate"))
	local sDesc = string.format("<p>%s</p>", Interface.getString("char_label_advancement"))
	local sExpression = string.format("<li><i>%s</i></li>", Interface.getString("char_label_advancement_expression"))
	local sTraumas = string.format("<li><i>%s</i></li>", Interface.getString("char_label_advancement_traumas"))

	local sText = string.format("%s%s<list>", sDesperate, sDesc);

	local xpTrigger = DB.getValue(node, "playbook.xptrigger");
	if xpTrigger then
		sText = string.format("%s<li><i>%s</i></li>", sText, xpTrigger)
	end

	sText = string.format("%s%s%s</list>", sText, sExpression, sTraumas);
	sText = string.gsub(sText, "%[b%]", "<b>")
	sText = string.gsub(sText, "%[/b%]", "</b>")

	desc.setValue(sText);
end