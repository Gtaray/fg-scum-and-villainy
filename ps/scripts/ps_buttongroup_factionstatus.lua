-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function getSlotCount()
	return self.getMaximumValue() - self.getMinimumValue() + 1;
end

function getSlotIcon(n)
	-- Offset slot number (n) from being 1 to min+max+1 to instead go from min to max
	-- The magic number 1 is because the slot number is indexed from 1, not 0, so we need to undo
	-- that in order to instead make the center 0
	n = n - math.abs(self.getMinimumValue()) - 1;
	local nCur = self.getCurrentValue();

	if nCur < 0 and n <= 0 and n >= nCur then
		return self.getMetadata("icon_negative");
	end

	if nCur >= 0 and n >= 0 and n <= nCur then
		return self.getMetadata("icon_positive");
	end

	return self.getMetadata("icon_base");
end

--
-- DATA
--

function adjustCounter(nAdj)
	local max = self.getMaximumValue();
	local min = self.getMinimumValue();
	local cur = self.getCurrentValue() + nAdj;
	
	cur = math.min(math.max(cur, min), max);
	self.setCurrentValue(cur);
end

function getMinimumValue()
	return self.getVarNumberLocal("minimum");
end

function getMaximumValue()
	return self.getVarNumberLocal("maximum");
end

--
-- USER EVENT
--

function calcClickValue(x, y)
	local nSpacing = self.getMetadata("spacing");
	local nWidth = nSpacing / 2;
	local nMaxSlotsPerRow = self.getMetadata("maxslotperrow");

	local nClickH = math.floor(x / nWidth) + 1;

	local nClickV;
	if self.getMaxValue() > nMaxSlotsPerRow then
		nClickV	= math.floor(y / nSpacing);
	else
		nClickV = 0;
	end
	local nClick = (nClickV * nMaxSlotsPerRow) + nClickH;

	-- Adjust the click location to instead be at "0", instead of whatever the center is
	nClick = nClick - math.abs(self.getMinimumValue()) - 1;
	return nClick;
end