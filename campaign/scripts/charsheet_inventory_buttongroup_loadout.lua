function onClickRelease(button, x, y)
    if isReadOnly() then
        return;
    end

    local itemnode = window.getDatabaseNode();
    local bSelectOneByOne = DB.getValue(itemnode, "load_type", "") == "multi";

    if bSelectOneByOne then
        return super.onClickRelease(button, x, y);
    end

    local m = self.getMaxValue();
    local c = self.getCurrentValue();
    if c ~= 0 then
        self.setCurrentValue(0);
    else
        self.setCurrentValue(m);
    end
    
    return true;
end

function onWheel(n)
    if isReadOnly() then
        return;
    end
    if not Input.isControlPressed() then
        return false;
    end

    local itemnode = window.getDatabaseNode();
    local bSelectOneByOne = DB.getValue(itemnode, "load_type", "") == "multi";

    if bSelectOneByOne then
        return super.onWheel(n);
    end

    if n > 0 then
        self.setCurrentValue(self.getMaxValue());
    elseif n < 0 then
        self.setCurrentValue(0);
    end
    return true;
end

function getMaxValue()
    local m = super.getMaxValue();
    if m == 0 then
        m = 1;
    end
    return m;
end