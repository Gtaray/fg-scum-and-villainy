X_OFFSET = 40;
Y_OFFSET = 14;
ENTRIES_PER_ROW = 4;
ROW_HEIGHT = 14;
WIDGET_PADDING = 10;
WIDGET_WIDTH = 60;

function onInit()
    DB.addHandler(DB.getPath(window.getDatabaseNode(), "health.trauma.list.*.description"), "onUpdate", onDescriptionChanged);
    DB.addHandler(DB.getPath(window.getDatabaseNode(), "health.trauma.list.*.active"), "onUpdate", onActiveChanged);

    self.updateWidgets();
end

function onClose()
    DB.removeHandler(DB.getPath(window.getDatabaseNode(), "health.trauma.list.*.description"), "onUpdate", onDescriptionChanged);
    DB.removeHandler(DB.getPath(window.getDatabaseNode(), "health.trauma.list.*.active"), "onUpdate", onActiveChanged);
end

--
-- USER INTERACTION
--
function onClickDown(button, x, y)
    return button == 1;
end

function onClickRelease(button, x, y)
    if button ~= 1 then
        return;
    end

    local tTraumas = self.getTraumas();
    for i, tTrauma in ipairs(tTraumas) do
        local widget = findWidget("trauma" .. i);
        local ww, wh = widget.getSize();
        local _, wx, wy  = widget.getPosition();

        if x > wx-(ww/2) and x < wx + (ww/2) then
            if y > wy-(wh/2) and y < wy + (wh/2) then
                if tTrauma.bActive then
                    DB.setValue(tTrauma.node, "active", "number", 0);
                else
                    DB.setValue(tTrauma.node, "active", "number", 1);
                end
                return;
            end
        end
    end
end

--
-- DATA SOURCE
--
function onDescriptionChanged()
    self.updateWidgets();
end

function onActiveChanged()
    self.updateWidgets();
end

function getTraumas()
    local nodes = DB.getChildList(window.getDatabaseNode(), "health.trauma.list");
    local tTraumas = {};

    for _, node in ipairs(nodes) do
        table.insert(tTraumas, {
            node = node,
            bActive = DB.getValue(node, "active", 0) == 1,
            sTrauma = DB.getValue(node, "description", "")
        });
    end

    return tTraumas;
end

--
-- BUILDING UI
--


function updateWidgets()
    local x = X_OFFSET;
    local y = Y_OFFSET;

    local tTraumas = self.getTraumas();
    local sFullColor, sDisabledColor = UtilityManager.getFullAndDisabledFontColors("tabfont", "80");
    
    for i, tTrauma in ipairs(tTraumas) do
        local widget = findWidget("trauma" .. i);
        if not widget then
           widget = addTextWidget({
                name = "trauma" .. i,
                font = "tabfont", text = tTrauma.sTrauma,
                w = WIDGET_WIDTH, minw = WIDGET_WIDTH,
                position = "topleft", x = x, y = y,
            }); 
        end

        widget.setText(tTrauma.sTrauma);

        if tTrauma.bActive then
            widget.setColor(sFullColor);
        else
            widget.setColor(sDisabledColor);
        end

        x = x + WIDGET_WIDTH + WIDGET_PADDING;

        -- If this is the last entry in a row, adjust the y downwards
        -- If it's not the last entry, then add a SPACER widget
        if i % ENTRIES_PER_ROW == 0 then
            y = y + ROW_HEIGHT;
            x = X_OFFSET;
        end
    end
end