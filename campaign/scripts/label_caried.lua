function onInit()
    local nodeChar = window.getDatabaseNode();
    DB.addHandler(DB.getPath(nodeChar, "inventory.load.*"), "onUpdate", update)
    DB.addHandler(DB.getPath(nodeChar, "inventory.gear.*.load"), "onUpdate", update)
    DB.addHandler(DB.getPath(nodeChar, "inventory.gear.*.equipped"), "onUpdate", update)
    self.update()
end

function onClose()
    local nodeChar = window.getDatabaseNode();
    DB.removeHandler(DB.getPath(nodeChar, "inventory.load.*"), "onUpdate", update)
    DB.removeHandler(DB.getPath(nodeChar, "inventory.gear.*.load"), "onUpdate", update)
    DB.removeHandler(DB.getPath(nodeChar, "inventory.gear.*.equipped"), "onUpdate", update)
end

function update()
    local nodeChar = window.getDatabaseNode();
    local nCarried = CharManager.getCurrentCarriedLoad(nodeChar)
    local nLoad = CharManager.getCurrentMaxLoad(nodeChar)
    local sText = string.format(Interface.getString("char_label_carried"), nCarried, nLoad)

    setValue(sText);
    setColor(CharManager.getLoadLabelColor(nodeChar));
end