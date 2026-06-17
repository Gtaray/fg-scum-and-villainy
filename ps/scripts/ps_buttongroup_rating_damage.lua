-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- DISPLAY
-- 

function getSlotIcon(n)
	local bBottom = n <= self.getCurrentValue();
	local bTop = n <= self.getRatingValue();
	
	if bTop and bBottom then
		return self.getMetadata("icon_both");
	elseif bTop then
		return self.getMetadata("icon_top");
	elseif bBottom then
		return self.getMetadata("icon_bottom");
	end

	return self.getMetadata("icon_off");
end

--
-- DATA
--

function adjustCounter(nAdj)
	local nMax = self.getRatingValue();
	local nVal = self.getCurrentValue() + nAdj;
	self.setCurrentValue(math.max(math.min(nVal, nMax), 0));
end

function getRatingValue()
	return self.getVarNumber("rating");
end