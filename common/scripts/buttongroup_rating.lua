-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- DISPLAY
-- 
-- We have to override this entire function because _tDisplaySlots is not 
-- accessible outside of the parent script

local _tDisplaySlots = {};
function refreshDisplay()
	if not self.isInitialized() then
		return;
	end

	local nSlots = self.getSlotCount();

	if #_tDisplaySlots ~= nSlots then
		local nSpacing = self.getMetadata("spacing");
		local nMaxSlotsPerRow = self.getMetadata("maxslotperrow");

		for _,v in ipairs(_tDisplaySlots) do
			v.destroy();
		end
		_tDisplaySlots = {};

		local nMinHeight = self.getMetadata("minh");
		local nDataHeight = (math.floor((nSlots - 1) / nMaxSlotsPerRow) + 1) * nSpacing;
		local nCenterOffset = (nMinHeight > nDataHeight) and math.floor((nMinHeight - nDataHeight) / 2) or 0;

		for i = 1, nSlots do
			local sIcon = self.getSlotIcon(i);
			local sColor = self.getSlotColor(i);

			local nX = (((i - 1) % nMaxSlotsPerRow) * (nSpacing / 2)) + math.floor(nSpacing / 4);
			local nY = (math.floor((i - 1) / nMaxSlotsPerRow) * nSpacing) + math.floor(nSpacing / 2) + nCenterOffset;

			_tDisplaySlots[i] = addBitmapWidget({
				icon = sIcon,
				color = sColor,
				position = "topleft", x = nX, y = nY,
				w = nSpacing, h = nSpacing,
			});
		end

		setAnchoredWidth(math.min(nSlots, nMaxSlotsPerRow) * (nSpacing / 2));
		setAnchoredHeight(math.max(nMinHeight, nDataHeight));
	else
		for i = 1, nSlots do
			local wgt = _tDisplaySlots[i];
			if wgt then
				wgt.setBitmap(self.getSlotIcon(i));
				wgt.setColor(self.getSlotColor(i));
			end
		end
	end
end

--
-- USER EVENT
--

function calcClickValue(x, y)
	local nSpacing = self.getMetadata("spacing");

	-- Each segment is 1/2 the spacing width.
	local nWidth = nSpacing / 2;
	local nMaxSlotsPerRow = self.getMetadata("maxslotperrow");

	local nClickH = math.floor(x / nWidth) + 1;
	if self.getMetadata("inverted") then
		nClickH = self.getMaxValue() - nClickH + 1;
	end

	if nClickH > self.getMaxValue() then
		nClickH = self.getMaxValue();
	end

	local nClickV;
	if self.getMaxValue() > nMaxSlotsPerRow then
		nClickV	= math.floor(y / nSpacing);
	else
		nClickV = 0;
	end

	local nClick = (nClickV * nMaxSlotsPerRow) + nClickH;
	return nClick;
end

