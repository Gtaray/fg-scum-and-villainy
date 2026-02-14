local _tPosition = {};
local _tEffect = {};


function onInit()
	RollManager.addPositionUpdateHandler(onPositionChanged);
	RollManager.addEffectUpdateHandler(onEffectChanged);

	onPositionChanged();
	onEffectChanged();
end

function addPosition(sKey, buttonControl)
	_tPosition[sKey] = buttonControl;
end

function addEffect(sKey, buttonControl)
	_tEffect[sKey] = buttonControl;
end


function onPositionChanged()
	selectPosition(RollManager.getPosition());
end

function onEffectChanged()
	selectEffect(RollManager.getEffect());
end


function selectPosition(sPosition)
	for sKey, button in pairs(_tPosition) do
		if sKey == sPosition then
			button.setValue(1);
		else
			button.setValue(0);
		end
	end
end

function selectEffect(sEffect)
	for sKey, button in pairs(_tEffect) do
		if sKey == sEffect then
			button.setValue(1);
		else
			button.setValue(0);
		end
	end
end