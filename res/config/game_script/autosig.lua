-- local dump = require "luadump"
local pipe = require "autosig/pipe"
local func = require "autosig/func"

local defBridgeList = {"cement", "iron", "stone"}
local sideList = {_("LEFT"), _("RIGHT"), _("BOTH")}
local defSignalList = {
    "railroad/signal_path_c",
    "railroad/signal_path_c_one_way",
    "railroad/signal_path_a",
    "railroad/signal_path_a_one_way"
}

local state = {
    windows = {
        window = false,
        bridge = false,
        signal = false,
        distance = false,
        side = false
    },
    button = false,
    use = false,
    useLabel = false,
    bridge = 1,
    signal = 1,
    side = 2,
    distance = 500,
    showWindow = false,
    signalList = defSignalList,
    bridgeList = defBridgeList
}

local showWindow = function()
    local vLayout = gui.boxLayout_create("autosig.window.vLayout", "VERTICAL")
    state.windows.window = gui.window_create("autosig.window", _("TITLE"), vLayout)
    
    local bridgeLabel = gui.textView_create("autosig.bridge.text", _("BRIDGE_TYPE"), 200)
    local bridgeImage = gui.imageView_create("autosig.bridge.image", "ui/bridges/" .. state.bridgeList[state.bridge] .. ".tga")
    local bridgeButton = gui.button_create("autosig.bridge.btn", bridgeImage)
    local bridgeLayout = gui.boxLayout_create("autosig.bridge.layout", "HORIZONTAL")
    local bridgeComp = gui.component_create("autosig.bridge", "a")
    bridgeComp:setLayout(bridgeLayout)
    bridgeLayout:addItem(bridgeLabel)
    bridgeLayout:addItem(bridgeButton)
    state.windows.bridge = bridgeImage
    
    local sideLabel = gui.textView_create("autosig.side.text", _("SIGNAL_SIDE"), 200)
    local sideValue = gui.textView_create("autosig.side.value", sideList[state.side])
    local sideButton = gui.button_create("autosig.side.btn", sideValue)
    local sideLayout = gui.boxLayout_create("autosig.side.layout", "HORIZONTAL")
    local sideComp = gui.component_create("autosig.side", "")
    sideComp:setLayout(sideLayout)
    sideLayout:addItem(sideLabel)
    sideLayout:addItem(sideButton)
    state.windows.side = sideValue
    
    local sigLabel = gui.textView_create("autosig.signal.text", _("SIGNAL_TYPE"), 200)
    local sigImage = gui.imageView_create("autosig.signal.image", "ui/models/" .. state.signalList[state.signal] .. ".tga")
    local sigButton = gui.button_create("autosig.signal.btn", sigImage)
    local sigLayout = gui.boxLayout_create("autosig.signal.layout", "HORIZONTAL")
    local sigComp = gui.component_create("autosig.signal", "")
    sigComp:setLayout(sigLayout)
    sigLayout:addItem(sigLabel)
    sigLayout:addItem(sigButton)
    state.windows.signal = sigImage
    
    local distLabel = gui.textView_create("autosig.distance.lable.", _("SIGNAL_DISTANCE"))
    local distValue = gui.textView_create("autosig.distance.value", tostring(state.distance))
    local distAdd = gui.textView_create("autosig.distance.add.text", "+")
    local distSub = gui.textView_create("autosig.distance.sub.text", "-")
    local distAddPlus = gui.textView_create("autosig.distance.addp.text", "++")
    local distSubPlus = gui.textView_create("autosig.distance.subp.text", "--")
    local distAddButton = gui.button_create("autosig.distance.add", distAdd)
    local distSubButton = gui.button_create("autosig.distance.sub", distSub)
    local distAddPlusButton = gui.button_create("autosig.distance.addp", distAddPlus)
    local distSubPlusButton = gui.button_create("autosig.distance.subp", distSubPlus)
    local distLayout = gui.boxLayout_create("autosig.distance.layout", "HORIZONTAL")
    local distComp = gui.component_create("autosig.distance", "")
    distComp:setLayout(distLayout)
    distLayout:addItem(distSubPlusButton)
    distLayout:addItem(distSubButton)
    distLayout:addItem(distValue)
    distLayout:addItem(distAddButton)
    distLayout:addItem(distAddPlusButton)
    state.windows.distance = distValue
    
    bridgeButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "bridge", {}) end)
    sigButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "signal", {}) end)
    distAddButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = 10}) end)
    sideButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "side", {}) end)
    distAddPlusButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = 50}) end)
    distSubButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = -10}) end)
    distSubPlusButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = -50}) end)
    
    vLayout:addItem(distLabel)
    vLayout:addItem(distComp)
    vLayout:addItem(sideComp)
    vLayout:addItem(bridgeComp)
    vLayout:addItem(sigComp)
    
    local mainView = game.gui.getContentRect("mainView")
    local mainMenuHeight = game.gui.getContentRect("mainMenuTopBar")[4] + game.gui.getContentRect("mainMenuBottomBar")[4]
    local buttonX = game.gui.getContentRect("autosig.button")[1]
    local size = game.gui.calcMinimumSize(state.windows.window.id)
    local y = mainView[4] - size[2] - mainMenuHeight
    
    state.windows.window:onClose(function()
        state.windows = {
            window = false,
            bridge = false,
            signal = false,
            distance = false,
            side = false
        }
        state.showWindow = false
    end)
    game.gui.window_setPosition(state.windows.window.id, buttonX, y)
end

local createComponents = function()
    if (not state.button) then
        local label = gui.textView_create("autosig.lable", _("AUTOSIG"))
        state.button = gui.button_create("autosig.button", label)
        
        state.useLabel = gui.textView_create("autosig.use.text", state.use and _("ON") or _("OFF"))
        state.use = gui.button_create("autosig.use", state.useLabel)
        
        game.gui.boxLayout_addItem("gameInfo.layout", gui.component_create("gameInfo.autosig.sep", "VerticalLine").id)
        game.gui.boxLayout_addItem("gameInfo.layout", "autosig.button")
        game.gui.boxLayout_addItem("gameInfo.layout", "autosig.use")
        
        state.use:onClick(function()
            if state.use then state.showWindow = false end
            game.interface.sendScriptEvent("__autosig__", "use", {})
            game.interface.sendScriptEvent("__edgeTool__", "off", { sender = "autosig" })
        end)
        state.button:onClick(function()state.showWindow = not state.showWindow end)
    end
end

local script = {
    handleEvent = function(src, id, name, param)
        if (id == "__edgeTool__" and param.sender ~= "autosig") then
            if (name == "off") then
                state.use = false
            elseif (name == "init") then
                state = func.with(state, param)
            end
        elseif (id == "__autosig__") then
            if (name == "bridge") then
                state.bridge = state.bridge < #state.bridgeList and state.bridge + 1 or 1
            elseif (name == "distance") then
                state.distance = state.distance + param.step
                if state.distance < 10 then state.distance = 10 end
            elseif (name == "signal") then
                state.signal = state.signal < #state.signalList and state.signal + 1 or 1
            elseif (name == "side") then
                state.side = state.side < #sideList and state.side + 1 or 1
            elseif (name == "use") then
                state.use = not state.use
            elseif (name == "build") then
                local remove, edges = table.unpack(param)
                for _, id in ipairs(remove) do
                    game.interface.bulldoze(id)
                end
                local id = game.interface.buildConstruction(
                    "autosig.con",
                    {
                        edges = edges,
                        bridge = state.bridgeList[state.bridge],
                        signal = state.signalList[state.signal],
                        distance = state.distance,
                        side = state.side
                    },
                    {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
                )
                game.interface.setPlayer(id, game.interface.getPlayer())
                game.interface.upgradeConstruction(
                    id,
                    "autosig.con",
                    {
                        edges = edges,
                        bridge = state.bridgeList[state.bridge],
                        signal = state.signalList[state.signal],
                        distance = state.distance,
                        side = state.side,
                        isFinal = true
                    }
                )
                game.interface.bulldoze(id)
            end
        end
    end,
    save = function() 
        if (not state.signalList) then state.signalList = defSignalList end
        if (not state.bridgeList) then state.bridgeList = defBridgeList end
        if #state.signalList == 0 then state.signalList = defSignalList end
        if #state.bridgeList == 0 then state.bridgeList = defBridgeList end
        return state 
    end,
    load = function(data)
        if data then
            if (not data.signalList) then data.signalList = defSignalList end
            if (not data.bridgeList) then data.bridgeList = defBridgeList end
            if #data.signalList == 0 then data.signalList = defSignalList end
            if #data.bridgeList == 0 then data.bridgeList = defBridgeList end

            state.bridge = data.bridge <= #data.bridgeList and data.bridge or 1
            state.signal = data.signal <= #data.signalList and data.signal or 1
            state.distance = data.distance
            state.use = data.use
            state.side = data.side
            state.signalList = data.signalList
            state.bridgeList = data.bridgeList
        end
    end,
    guiInit = function()
        local signalList = defSignalList
        pcall(function()
            local sList = {}
            local file = io.open("autosig.rec", "r")
            for line in file:lines() do
                table.insert(sList, line)
            end
            file:close()
            if #sList > 0 then signalList = sList end
        end)

        game.interface.sendScriptEvent("__edgeTool__", "init", { signalList = signalList })
    end,
    guiUpdate = function()
        createComponents()
        if (state.showWindow and not state.windows.window) then
            showWindow()
        elseif (not state.showWindow and state.windows.window) then
            state.windows.window:close()
        end
        if state.windows.window then
            state.windows.distance:setText(tostring(state.distance))
            state.windows.side:setText(sideList[state.side])
            state.windows.bridge:setImage("ui/bridges/" .. state.bridgeList[state.bridge] .. ".tga")
            state.windows.signal:setImage("ui/models/" .. state.signalList[state.signal] .. ".tga")
        end
        state.useLabel:setText(state.use and _("ON") or _("OFF"))
    end,
    guiHandleEvent = function(id, name, param)
        if state.use and name == "builder.apply" then
            local proposal = param and param.proposal and param.proposal.proposal
            local toRemove = param.proposal.toRemove
            local toAdd = param.proposal.toAdd
            if 
                (not toAdd or #toAdd == 0) and
                (not toRemove or #toRemove == 0) and
                proposal and proposal.addedSegments and #proposal.addedSegments > 1 and proposal.addedNodes
                and (not proposal.removedSegments or #proposal.removedSegments == 0)
                and (not proposal.edgeObjectsToAdd or #proposal.edgeObjectsToAdd == 0)
            then
                local nodes = {}
                local ids = {}
                local edges = {}
                for i = 1, #proposal.addedNodes do
                    local node = proposal.addedNodes[i]
                    local id = node.entity
                    nodes[id] = {
                        node.comp.position[1],
                        node.comp.position[2],
                        node.comp.position[3]
                    }
                end
                local renewedSegements = {}
                for _, v in pairs(proposal.old2newSegments) do
                    for _, seg in ipairs(v) do
                        table.insert(renewedSegements, seg)
                    end
                end
                for i = 1, #proposal.addedSegments do
                    local seg = proposal.addedSegments[i]
                    if not (pipe.contains(seg.entity)(renewedSegements)) then
                        if (seg.type == 1) then
                            table.insert(ids, seg.entity)
                            local node0 = nodes[seg.comp.node0]
                            local node1 = nodes[seg.comp.node1]
                            local snap0 = not node0
                            local snap1 = not node1
                            
                            local edge = {
                                {
                                    node0 or (game.interface.getEntity(seg.comp.node0).position),
                                    {
                                        seg.comp.tangent0[1],
                                        seg.comp.tangent0[2],
                                        seg.comp.tangent0[3]
                                    }
                                },
                                {
                                    node1 or (game.interface.getEntity(seg.comp.node1).position),
                                    {
                                        seg.comp.tangent1[1],
                                        seg.comp.tangent1[2],
                                        seg.comp.tangent1[3]
                                    }
                                }
                            }
                            local edgeType = seg.comp.type + 1
                            local catenary = seg.params.catenary
                            local trackType = seg.params.trackType == 0 and 1 or 2
                            
                            table.insert(edges, {
                                edge = edge,
                                edgeType = edgeType,
                                catenary = catenary,
                                snap0 = snap0,
                                snap1 = snap1,
                                trackType = trackType
                            })
                        end
                    end
                end
                if (#ids > 0) then
                    game.interface.sendScriptEvent("__autosig__", "build", {ids, edges})
                end
            end
        end
    end
}

function data()
    return script
end
