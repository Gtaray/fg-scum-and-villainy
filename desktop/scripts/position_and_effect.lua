function onInit()
	RollManager.addPositionUpdateHandler(onPositionChanged);
	RollManager.addEffectUpdateHandler(onEffectChanged);

	onPositionChanged();
	onEffectChanged();
end

function onPositionChanged()
	local sPosition = RollManager.getPosition();

	if sPosition == "desperate" then
		selectPosition(position_desperate);
	elseif sPosition == "risky" then
		selectPosition(position_risky);
	else
		selectPosition(position_controlled);
	end
end

function onEffectChanged()
	local sEffect = RollManager.getEffect();

	if sEffect == "limited" then
		selectEffect(effect_limited);
	elseif sEffect == "standard" then
		selectEffect(effect_standard);
	else
		selectEffect(effect_great);
	end
end

function selectPosition(control)
	position_desperate.setValue(0);
	position_risky.setValue(0);
	position_controlled.setValue(0);

	control.setValue(1);
end

function selectEffect(control)
	effect_limited.setValue(0);
	effect_standard.setValue(0);
	effect_great.setValue(0);

	control.setValue(1);
end