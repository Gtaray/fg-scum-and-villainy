local _bExpanded = false;

function onInit()
	_bExpanded = false;
	self.update();

	if Session.IsHost then
		return;
	end

	registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);
end

function onMenuSelection(selection, subselection)
	if not Session.IsHost and selection == 6 and subselection == 6 then
		CrewManager.sendPlayerDeleteJobOobMsg(getDatabaseNode());
	end
end

--
--	UI Events
--

function onClickRelease()
	self.toggleExpander();
	return true;
end

-- 
-- Display
--

function toggleExpander()
	_bExpanded = not _bExpanded;
	self.update();
end

function update()
	if _bExpanded then
		expander.setIcon("sidebar_dock_category_expanded");
	else
		expander.setIcon("sidebar_dock_category_collapsed");
	end

	details.setVisible(_bExpanded);
end
