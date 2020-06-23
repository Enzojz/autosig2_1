-- local dump = require "luadump"
local pipe = require "autosig2/pipe"
local func = require "autosig2/func"

local state = {
    window = false,
    distance = 500,
    use = false,
    fn = {}
}

local setWidth = function(ctrl, width)
    local tRect = ctrl:getContentRect()
    local tSize = api.gui.util.Size.new()
    tSize.h = tRect.h
    tSize.w = width
    ctrl:setGravity(-1, -1)
    ctrl:setMinimumSize(tSize)
end

local setSpacingText = function(spacing)
    return string.format("%d%s", spacing, _("METER"))
end

local createWindow = function()
    if not state.window then
        local spacingValue = api.gui.comp.TextView.new(setSpacingText(state.distance))
        local spacingSlider = api.gui.comp.Slider.new(true)
        
        spacingSlider:setStep(10)
        spacingSlider:setMinimum(1)
        spacingSlider:setMaximum(200)
        spacingSlider:setValue(state.distance * 0.1, false)
        
        setWidth(spacingSlider, 200)
        
        local comp = api.gui.comp.Component.new("")
        local layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
        layout:setId("autosig2.layout")
        comp:setLayout(layout)
        
        state.window = api.gui.comp.Window.new(_("SIGNAL_DISTANCE"), comp)
        state.window:setId("autosig2.window")
        
        layout:addItem(spacingSlider)
        layout:addItem(spacingValue)
        
        spacingSlider:onValueChanged(function(value)
            table.insert(state.fn, function()
                spacingValue:setText(setSpacingText(value * 10))
                game.interface.sendScriptEvent("__autosig2__", "distance", {distance = value * 10})
            end)
        end)
        
        state.window:onClose(function()state.window:setVisible(false, false) end)
        
        local mainView = api.gui.util.getById("mainView"):getContentRect().h
        local mainMenuHeight = api.gui.util.getById("mainMenuTopBar"):getContentRect().h + api.gui.util.getById("mainMenuBottomBar"):getContentRect().h
        local x = api.gui.util.getById("autosig2.button"):getContentRect().x
        local y = mainView - mainMenuHeight - state.window:calcMinimumSize().h
        
        game.gui.window_setPosition("autosig2.window", x, y)
    end
end

local createComponents = function()
    if (not state.useLabel) then
        local label = gui.textView_create("autosig2.lable", _("AUTOSIG"))
        local button = gui.button_create("autosig2.button", label)
        
        state.useLabel = gui.textView_create("autosig2.use.text", state.use and _("ON") or _("OFF"))
        local use = gui.button_create("autosig2.use", state.useLabel)
        
        game.gui.boxLayout_addItem("gameInfo.layout", gui.component_create("gameInfo.autosig2.sep", "VerticalLine").id)
        game.gui.boxLayout_addItem("gameInfo.layout", "autosig2.button")
        game.gui.boxLayout_addItem("gameInfo.layout", "autosig2.use")
        
        use:onClick(function()
            game.interface.sendScriptEvent("__autosig2__", "use", {})
            game.interface.sendScriptEvent("__edgeTool__", "off", {sender = "autosig2"})
        end)
        
        button:onClick(function()
            if state.window and state.use then
                state.window:setVisible(not state.window:isVisible(), false)
            elseif not state.window and state.use then
                table.insert(state.fn, createWindow)
            end
        end)
    end
end

local findAllSignalPos = function(edgeId)
    local tpn = api.engine.getComponent(edgeId, api.type.ComponentType.TRANSPORT_NETWORK)
    local sections = func.fold(tpn.edges, pipe.new * {},
        function(posList, sec)
            local s = posList[#posList] and posList[#posList][2] or 0
            local length = sec.geometry.length
            return posList / {s, s + length, length}
        end)
    
    local edgeLength = sections[#sections][2]
    local signals = {}
    for i, sec in ipairs(sections) do
        local s, e, l = table.unpack(sec)
        local sigF = api.engine.system.signalSystem.getSignal(api.type.EdgeId.new(edgeId, i - 1), false)
        local sigR = api.engine.system.signalSystem.getSignal(api.type.EdgeId.new(edgeId, i - 1), true)
        if sigF > 0 then
            signals[sigF] = {pos = e, isLeft = true}
        end
        if sigR > 0 then
            signals[sigR] = {pos = s, isLeft = false}
        end
    end
    
    return signals, edgeLength
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
    
    local signals, edgeLength = findAllSignalPos(edge.entity)
    
    local newSigInfo = signals[newObject]
    if not newSigInfo then return end
    
    local edgeList = {
        func.with(edge, {
            isBackward = newSigInfo.isLeft,
            length = edgeLength,
            startPos = 0,
            endPos = edgeLength
        })
    }
    
    local isSearchFinished = false
    do
        local terminateSig =
            pipe.new
            * func.values(signals)
            * pipe.filter(function(sig) return newSigInfo.isLeft == sig.isLeft and (edgeList[1].isBackward and (sig.pos < newSigInfo.pos) or (sig.pos > newSigInfo.pos)) end)
            * pipe.sort(edgeList[1].isBackward and function(l, r) return l.pos > r.pos end or function(l, r) return l.pos < r.pos end)
        
        if #terminateSig > 0 then
            isSearchFinished = true
            edgeList[1].endPos = edgeList[1].isBackward and edgeList[1].length - terminateSig[1].pos or terminateSig[1].pos
        end
    end
    
    local frozenNodes = api.engine.system.streetConnectorSystem.getNode2StreetConnectorMap()
    while not isSearchFinished do
        local lastEdge = edgeList[#edgeList]
        local node = lastEdge.isBackward and lastEdge.comp.node0 or lastEdge.comp.node1
        
        if frozenNodes[node] then
            isSearchFinished = true
        else
            
            local nextEdges = {}
            for _, e in ipairs(map[node]) do
                if e ~= lastEdge.entity then
                    table.insert(nextEdges, e)
                end
            end
            if #nextEdges == 1 then
                local nextEdge = nextEdges[1]
                local comp = api.engine.getComponent(nextEdge, api.type.ComponentType.BASE_EDGE)
                local allSignals, length = findAllSignalPos(nextEdge)
                local isBackward = comp.node1 == node
                
                for _, signal in ipairs(func.sort(func.values(allSignals), isBackward and function(l, r) return l.pos > r.pos end or function(l, r) return l.pos < r.pos end)) do
                    if (signal.isLeft == param.left and isBackward == edgeList[1].isBackward) or
                        (signal.isLeft ~= param.left and isBackward ~= edgeList[1].isBackward)
                    then
                        isSearchFinished = true
                        table.insert(edgeList, {
                            entity = nextEdge,
                            comp = comp,
                            isBackward = isBackward,
                            startPos = edgeList[#edgeList].endPos,
                            endPos = edgeList[#edgeList].endPos + (isBackward and length - signal.pos or signal.pos),
                            length = length
                        })
                        break
                    end
                end
                
                if not isSearchFinished then
                    table.insert(edgeList, {
                        entity = nextEdge,
                        comp = comp,
                        isBackward = isBackward,
                        startPos = edgeList[#edgeList].endPos,
                        endPos = edgeList[#edgeList].endPos + length,
                        length = length
                    })
                end
            else
                isSearchFinished = true
            end
        end
    end
    
    local allPos = {}
    for i = (newSigInfo.isLeft and (edgeList[1].length - newSigInfo.pos) or newSigInfo.pos) + state.distance, edgeList[#edgeList].endPos, state.distance do
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
        local newSigList = comp.objects
        
        for n, pos in ipairs(edge.allPos) do
            local rPos = (pos - edge.startPos) / edge.length
            if edge.isBackward then rPos = 1 - rPos end
            local sig = api.type.SimpleStreetProposal.EdgeObject.new()
            local left = param.left
            if edgeList[1].isBackward ~= edge.isBackward then left = not left end
            sig.edgeEntity = -id
            sig.param = rPos
            sig.oneWay = param.oneWay
            sig.left = left
            sig.model = param.model
            sig.playerEntity = api.engine.util.getPlayer()
            
            proposal.streetProposal.edgeObjectsToAdd[#proposal.streetProposal.edgeObjectsToAdd + 1] = sig
            table.insert(newSigList, {-#proposal.streetProposal.edgeObjectsToAdd, 2})
        end
        
        track.comp.objects = newSigList
        
        proposal.streetProposal.edgesToAdd[id] = track
        proposal.streetProposal.edgesToRemove[id] = edge.entity
    end
    
    local cmd = api.cmd.make.buildProposal(proposal, nil, false)
    api.cmd.sendCommand(cmd, function(_) end)

end

local script = {
    handleEvent = function(src, id, name, param)
        if (id == "__edgeTool__" and param.sender ~= "autosig2") then
            if (name == "off") then
                state.use = false
            end
        elseif (id == "__autosig2__") then
            if (name == "distance") then
                state.distance = param.distance
                if state.distance < 10 then state.distance = 10 end
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
        end
    end,
    guiUpdate = function()
        createComponents()
        if not state.use and state.window and state.window:isVisible() then
            state.window:close()
        end
        
        for _, fn in ipairs(state.fn) do fn() end
        state.fn = {}
        
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
                local object = proposal.edgeObjectsToAdd[1]
                if (newSegement.type == 1 and object.category == 2) then
                    game.interface.sendScriptEvent("__autosig2__", "build",
                        {
                            nodes = {newSegement.comp.node0, newSegement.comp.node1},
                            edgeObjects = func.map(proposal.removedSegments[1].comp.objects, pipe.select(1)),
                            model = api.res.modelRep.getName(object.modelInstance.modelId),
                            left = object.left,
                            oneWay = object.oneWay
                        }
                )
                end
            end
        end
    end
}

function data()
    return script
end
