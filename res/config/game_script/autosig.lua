local dump = require "luadump"
local pipe = require "autosig/pipe"
local func = require "autosig/func"
local coor = require "autosig/coor"

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
    
    local sideLabel = gui.textView_create("autosig.side.text", _("SIGNAL_SIDE"), 200)
    local sideValue = gui.textView_create("autosig.side.value", sideList[state.side])
    local sideButton = gui.button_create("autosig.side.btn", sideValue)
    local sideLayout = gui.boxLayout_create("autosig.side.layout", "HORIZONTAL")
    local sideComp = gui.component_create("autosig.side", "")
    sideComp:setLayout(sideLayout)
    sideLayout:addItem(sideLabel)
    sideLayout:addItem(sideButton)
    state.windows.side = sideValue
    
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
    
    distAddButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = 10}) end)
    sideButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "side", {}) end)
    distAddPlusButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = 50}) end)
    distSubButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = -10}) end)
    distSubPlusButton:onClick(function()game.interface.sendScriptEvent("__autosig__", "distance", {step = -50}) end)
    
    vLayout:addItem(distLabel)
    vLayout:addItem(distComp)
    vLayout:addItem(sideComp)
    
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
            game.interface.sendScriptEvent("__edgeTool__", "off", {sender = "autosig"})
        end)
        state.button:onClick(function()state.showWindow = not state.showWindow end)
    end
end

local function build(param)
    local edgeObjects = param.edgeObjects
    local nodes = param.nodes
    local map = api.engine.system.streetSystem.getNode2TrackEdgeMap()
    local edge = false
    local newObject = false
    
    for _, e in ipairs(map[nodes[1]]) do
        for _, d in ipairs(map[nodes[2]]) do
            if d == e then
                if not edge then
                    edge = {entity = e, comp = api.engine.getComponent(e, api.type.ComponentType.BASE_EDGE)}
                else return end
            end
        end
    end
    if not edge then return end
    
    for _, o in ipairs(edge.comp.objects) do
        if not func.contains(edgeObjects, o[1]) then
            if not newObject then
                newObject = o[1]
            else return end
        end
    end
    if not newObject then return end
    
    local tpn = api.engine.getComponent(edge.entity, api.type.ComponentType.TRANSPORT_NETWORK)
    local sections = func.fold(tpn.edges, pipe.new * {},
        function(posList, sec)
            local s = posList[#posList] and posList[#posList][2] or 0
            local length = sec.geometry.length
            return posList / {s, s + length, length}
        end)
    
    local signals = {}
    for i, sec in ipairs(sections) do
        local s, e, l = table.unpack(sec)
        local sigF = api.engine.system.signalSystem.getSignal(api.type.EdgeId.new(edge.entity, i - 1), false)
        local sigR = api.engine.system.signalSystem.getSignal(api.type.EdgeId.new(edge.entity, i - 1), true)
        if sigF > 0 then
            signals[sigF] = {pos = e, isBackward = false}
        end
        if sigR > 0 then
            signals[sigR] = {pos = s, isBackward = true}
        end
    end
    local totalLength = sections[#sections][2]
    
    local newSigInfo = signals[newObject]
    if not newSigInfo then return end
    
    local edgeList = {func.with(edge, {isBackward = not newSigInfo.isBackward, length = totalLength, startPos = 0, endPos = totalLength})}
    
    local isSearchFinished = false
    repeat
        local lastEdge = edgeList[#edgeList]
        local node = lastEdge.isBackward and lastEdge.comp.node0 or lastEdge.comp.node1
        local nextEdges = {}
        for _, e in ipairs(map[node]) do
            if e ~= lastEdge.entity then
                table.insert(nextEdges, e)
            end
        end
        if #nextEdges == 1 then
            local nextEdge = nextEdges[1]
            local comp = api.engine.getComponent(nextEdge, api.type.ComponentType.BASE_EDGE)
            local length = coor.new(comp.tangent0):length()
            table.insert(edgeList, {
                entity = nextEdge,
                comp = comp,
                isBackward = comp.node1 == node,
                startPos = edgeList[#edgeList].endPos,
                endPos = edgeList[#edgeList].endPos + length,
                length = length
            })
        else
            isSearchFinished = true
        end
    until isSearchFinished
    
    
    local allPos = {}
    for i = newSigInfo.pos + state.distance, totalLength, state.distance do
        table.insert(allPos, i)
    end
    
    for _, edge in ipairs(edgeList) do
        edge.allPos = func.filter(allPos, function(pos) return pos > edge.startPos and pos < edge.endPos end)
    end
    
    local proposal = api.type.SimpleProposal.new()

    for id, edge in ipairs(func.filter(edgeList, function(e) return #e.allPos > 0 end)) do
        local track = api.type.SegmentAndEntity.new()
        local comp = api.engine.getComponent(edge.entity, api.type.ComponentType.BASE_EDGE)
        local trackEdge = api.engine.getComponent(edge.entity, api.type.ComponentType.BASE_EDGE_TRACK)
        
        track.entity = -id
        track.playerOwned = {player = api.engine.util.getPlayer()}
        
        track.comp.node0 = comp.node0
        track.comp.node1 = comp.node1
        for i = 1, 3 do
            track.comp.tangent0[i] = comp.tangent0[i]
            track.comp.tangent1[i] = comp.tangent1[i]
        end
        track.comp.type = comp.type
        track.comp.typeIndex = comp.typeIndex
        
        
        track.type = 1
        track.trackEdge.trackType = trackEdge.trackType
        track.trackEdge.catenary = trackEdge.catenary
        local newSigList = {}
        
        for n, pos in ipairs(edge.allPos) do
            local rPos = (pos - edge.startPos) / edge.length
            if edge.isBackward then rPos = 1 - rPos end
            local sig = api.type.SimpleStreetProposal.EdgeObject.new()
            sig.edgeEntity = -id
            sig.param = rPos
            sig.oneWay = param.oneWay
            sig.left = param.left
            sig.model = param.model
            sig.playerEntity = api.engine.util.getPlayer()
            
            
            proposal.streetProposal.edgeObjectsToAdd[#proposal.streetProposal.edgeObjectsToAdd + 1] = sig
            table.insert(newSigList, {-#proposal.streetProposal.edgeObjectsToAdd, 2})
        end
        
        track.comp.objects = newSigList
        
        proposal.streetProposal.edgesToAdd[e] = track
        proposal.streetProposal.edgesToRemove[e] = edge.entity
    end

    dump()(proposal)
    api.cmd.sendCommand(api.cmd.make.buildProposal(proposal, nil, false), function(x)dump()(x) end)

end

local script = {
    handleEvent = function(src, id, name, param)
        if (id == "__edgeTool__" and param.sender ~= "autosig") then
            if (name == "off") then
                state.use = false
            end
        elseif (id == "__autosig__") then
            if (name == "distance") then
                state.distance = state.distance + param.step
                if state.distance < 10 then state.distance = 10 end
            elseif (name == "side") then
                state.side = state.side < #sideList and state.side + 1 or 1
            elseif (name == "use") then
                state.use = not state.use
            elseif (name == "build") then
                build(param)
            end
        end
    end,
    save = function()
        return state
    end,
    load = function(data)
        if data then
            state.distance = data.distance
            state.use = data.use
            state.side = data.side
        end
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
                proposal and proposal.addedSegments and #proposal.addedSegments == 1 and
                proposal.removedSegments and #proposal.removedSegments == #proposal.addedSegments and
                proposal.addedNodes and #proposal.addedNodes == 0 and
                proposal.removedNodes and #proposal.removedNodes == 0 and
                proposal.edgeObjectsToAdd and #proposal.edgeObjectsToAdd == 1
            then
                local newSegement = proposal.addedSegments[1]
                local nodes = {newSegement.comp.node0, newSegement.comp.node1}
                local edgeObjects = func.map(proposal.removedSegments[1].comp.objects, pipe.select(1))
                local object = proposal.edgeObjectsToAdd[1]
                local model = api.res.modelRep.getName(object.modelInstance.modelId)
                local left = object.left
                local oneWay = object.oneWay
                dump()(proposal)
                game.interface.sendScriptEvent("__autosig__", "build", {nodes = nodes, edgeObjects = edgeObjects, model = model, left = left, oneWay = oneWay})
            end
        end
    end
}

function data()
    return script
end
