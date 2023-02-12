-- local dump = require "luadump"
local pipe = require "autosig2/pipe"
local func = require "autosig2/func"

local state = {
    distance = 500,
    use = false,
    replace = false,
    remove = false,
    backward = false
}

local translations = {
    SIGNAL_DISTANCE = _("SIGNAL_DISTANCE"),
    AUTOSIG = _("AUTOSIG"),
    ON = _("ON"),
    OFF = _("OFF"),
    METER = _("METER"),
    NO = _("No"),
    YES = _("Yes"),
    REPLACE = _("REPLACE"),
    REMOVE = _("REMOVE"),
    FORWARD = _("FORWARD"),
    BACKWARD = _("BACKWARD")
}

local setSpacingText = function(spacing)
    return string.format("%d%s", spacing, translations.METER)
end

local createWindow = function()
    if not api.gui.util.getById("autosig2.use") then
        local menu = api.gui.util.getById("menu.construction.rail.settings")
        local menuLayout = menu:getLayout()
        
        local useComp = api.gui.comp.Component.new("ParamsListComp::ButtonParam")
        
        local useLayout = api.gui.layout.BoxLayout.new("VERTICAL")
        useComp:setLayout(useLayout)
        useComp:setId("autosig2.use")
        
        local use = api.gui.comp.TextView.new(translations.AUTOSIG)
        
        local useButtonComp = api.gui.comp.ToggleButtonGroup.new(0, 0, false)
        local useNo = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new(translations.NO))
        local useYes = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new(translations.YES))
        local useReplace = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new(translations.REPLACE))
        local useRemove = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new(translations.REMOVE))
        useButtonComp:setName("ToggleButtonGroup")
        useButtonComp:add(useNo)
        useButtonComp:add(useYes)
        useButtonComp:add(useReplace)
        useButtonComp:add(useRemove)
        
        local useDirectionComp = api.gui.comp.ToggleButtonGroup.new(0, 0, false)
        local useForward = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new(translations.FORWARD))
        local useBackward = api.gui.comp.ToggleButton.new(api.gui.comp.TextView.new(translations.BACKWARD))
        useDirectionComp:setName("ToggleButtonGroup")
        useDirectionComp:add(useForward)
        useDirectionComp:add(useBackward)
        
        useLayout:addItem(use)
        useLayout:addItem(useButtonComp)
        useLayout:addItem(useDirectionComp)
        
        local spacingComp = api.gui.comp.Component.new("ParamsListComp::SliderParam")
        local spacingLayout = api.gui.layout.BoxLayout.new("VERTICAL")
        spacingLayout:setName("ParamsListComp::SliderParam::Layout")
        
        spacingComp:setLayout(spacingLayout)
        spacingComp:setId("autosig2.spacing")
        
        local spacingText = api.gui.comp.TextView.new(translations.SIGNAL_DISTANCE)
        local spacingValue = api.gui.comp.TextView.new(setSpacingText(state.distance))
        local spacingSlider = api.gui.comp.Slider.new(true)
        local spacingSliderLayout = api.gui.layout.BoxLayout.new("HORIZONTAL")
        
        spacingValue:setName("ParamsListComp::SliderParam::SliderLabel")
        spacingValue:setId("autosig2.text")
        spacingSlider:setId("autosig2.slider")
        
        spacingSlider:setStep(10)
        spacingSlider:setMinimum(1)
        spacingSlider:setMaximum(200)
        spacingSlider:setValue(state.distance * 0.1, false)
        
        spacingSliderLayout:addItem(spacingSlider)
        spacingSliderLayout:addItem(spacingValue)
        spacingLayout:addItem(spacingText)
        spacingLayout:addItem(spacingSliderLayout)
        
        menuLayout:addItem(useComp)
        menuLayout:addItem(spacingComp)
        
        spacingSlider:onValueChanged(function(value)
            local cmd = api.cmd.make.sendScriptEvent("autosig2.lua", "__autosig2__", "distance", {distance = value * 10})
            spacingSlider:invokeLater(function()
                spacingValue:setText(setSpacingText(value * 10))
                api.cmd.sendCommand(cmd, function() end)
            end)
        end)
        
        useNo:onToggle(function()
            local cmd1 = api.cmd.make.sendScriptEvent("autosig2.lua", "__autosig2__", "use", {use = false})
            local cmd2 = api.cmd.make.sendScriptEvent("autosig2.lua", "__edgeTool__", "off", {sender = "autosig2"})
            useRemove:invokeLater(function()
                api.cmd.sendCommand(cmd1, function() end)
                api.cmd.sendCommand(cmd2, function() end)
                spacingComp:setVisible(false, false)
                useDirectionComp:setVisible(false, false)
            end)
        end)
        
        useYes:onToggle(function()
            local cmd1 = api.cmd.make.sendScriptEvent("autosig2.lua", "__autosig2__", "use", {use = true})
            local cmd2 = api.cmd.make.sendScriptEvent("autosig2.lua", "__edgeTool__", "off", {sender = "autosig2"})
            useRemove:invokeLater(function()
                api.cmd.sendCommand(cmd1, function() end)
                api.cmd.sendCommand(cmd2, function() end)
                spacingComp:setVisible(true, false)
                useDirectionComp:setVisible(false, false)
            end)
        end)
        
        useReplace:onToggle(function()
            local cmd1 = api.cmd.make.sendScriptEvent("autosig2.lua", "__autosig2__", "replace", {use = true})
            local cmd2 = api.cmd.make.sendScriptEvent("autosig2.lua", "__edgeTool__", "off", {sender = "autosig2"})
            useRemove:invokeLater(function()
                api.cmd.sendCommand(cmd1, function() end)
                api.cmd.sendCommand(cmd2, function() end)
                spacingComp:setVisible(false, false)
                useDirectionComp:setVisible(true, false)
                if state.backward then
                    useBackward:setSelected(true, true)
                else
                    useForward:setSelected(true, true)
                end
            end)
        end)
        
        useRemove:onToggle(function()
            local cmd1 = api.cmd.make.sendScriptEvent("autosig2.lua", "__autosig2__", "remove", {use = true})
            local cmd2 = api.cmd.make.sendScriptEvent("autosig2.lua", "__edgeTool__", "off", {sender = "autosig2"})
            useRemove:invokeLater(function()
                api.cmd.sendCommand(cmd1, function() end)
                api.cmd.sendCommand(cmd2, function() end)
                spacingComp:setVisible(false, false)
                useDirectionComp:setVisible(true, false)
                if state.backward then
                    useBackward:setSelected(true, true)
                else
                    useForward:setSelected(true, true)
                end
            end)
        end)
        
        useForward:onToggle(function()
            local cmd1 = api.cmd.make.sendScriptEvent("autosig2.lua", "__autosig2__", "backward", {backward = false})
            local cmd2 = api.cmd.make.sendScriptEvent("autosig2.lua", "__edgeTool__", "off", {sender = "autosig2"})
            useRemove:invokeLater(function()
                api.cmd.sendCommand(cmd1, function() end)
                api.cmd.sendCommand(cmd2, function() end)
            end)
        end)
        
        useBackward:onToggle(function()
            local cmd1 = api.cmd.make.sendScriptEvent("autosig2.lua", "__autosig2__", "backward", {backward = true})
            local cmd2 = api.cmd.make.sendScriptEvent("autosig2.lua", "__edgeTool__", "off", {sender = "autosig2"})
            useRemove:invokeLater(function()
                api.cmd.sendCommand(cmd1, function() end)
                api.cmd.sendCommand(cmd2, function() end)
            end)
        end)
        
        if state.use then
            if state.replace then
                useReplace:setSelected(true, true)
            elseif state.remove then
                useRemove:setSelected(true, true)
            else
                useYes:setSelected(true, true)
            end
        else
            useNo:setSelected(true, true)
        end
    end
end

local findAllSignalPos = function(edgeId)
    local isNewBuild = tonumber(getBuildVersion()) > 35020
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
        if isNewBuild then
            sigF = sigF.entity
            sigR = sigR.entity
        end
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
            
            if frozenNodes[comp.node0] or frozenNodes[comp.node1] then
                isSearchFinished = true
            else
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

local function remove(param)
    local edgeObjects = param.edgeObjects
    local nodes = param.nodes
    local map = api.engine.system.streetSystem.getNode2TrackEdgeMap()
    local frozenNodes = api.engine.system.streetConnectorSystem.getNode2StreetConnectorMap()
    local edge = false
    local newObject = false
    
    local searchBackward = (not state.backward and param.left) or (state.backward and not param.left)

    for _, e in ipairs(map[nodes[1]]) do
        for _, d in ipairs(map[nodes[2]]) do
            if d == e then
                if not edge then
                    edge = {
                        entity = e,
                        isBackward = (not state.backward and param.left) or (state.backward and not param.left),
                        comp = api.engine.getComponent(e, api.type.ComponentType.BASE_EDGE)
                    }
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
    
    local isSearchFinished = false
    local proposal = api.type.SimpleProposal.new()
    local id = 0
    local lp = 0
    while not isSearchFinished and lp < 10 do
        lp = lp + 1
        id = id + 1
        do
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
            
            local allSignals, edgeLength = findAllSignalPos(edge.entity)
            local refPos = false
            if allSignals[newObject] then
                refPos = allSignals[newObject].pos
            end
            
            newSigList = func.fold(
                newSigList,
                {},
                function(ls, idt)
                    local id, t = table.unpack(idt)
                    if (api.engine.getComponent(id, api.type.ComponentType.SIGNAL_LIST)) then
                        local keep = true
                        if refPos and not state.backward then
                            keep = (allSignals[id].isLeft and refPos < allSignals[id].pos) or (not allSignals[id].isLeft and refPos > allSignals[id].pos)
                        elseif refPos and state.backward then
                            keep = (allSignals[id].isLeft and refPos > allSignals[id].pos) or (not allSignals[id].isLeft and refPos < allSignals[id].pos)
                        else
                            keep = (allSignals[id].isLeft ~= param.left and searchBackward == edge.isBackward) or (allSignals[id].isLeft == param.left and searchBackward ~= edge.isBackward)
                        end
                        
                        if not keep then
                            proposal.streetProposal.edgeObjectsToRemove[#proposal.streetProposal.edgeObjectsToRemove + 1] = id
                            if (state.replace and id ~= newObject) then
                                local rPos = allSignals[id].pos / edgeLength
                                
                                local sig = api.type.SimpleStreetProposal.EdgeObject.new()
                                local left = searchBackward == edge.isBackward and param.left or not param.left
                                sig.edgeEntity = track.entity
                                sig.param = rPos
                                sig.oneWay = param.oneWay
                                sig.left = left
                                sig.model = param.model
                                sig.playerEntity = api.engine.util.getPlayer()
                                
                                proposal.streetProposal.edgeObjectsToAdd[#proposal.streetProposal.edgeObjectsToAdd + 1] = sig
                                table.insert(ls, {-#proposal.streetProposal.edgeObjectsToAdd, 2})
                            end
                        end
                        if keep then
                            table.insert(ls, idt)
                        end
                    else
                        table.insert(ls, idt)
                    end
                    return ls
                end
            )
            track.comp.objects = newSigList
            
            proposal.streetProposal.edgesToAdd[id] = track
            proposal.streetProposal.edgesToRemove[id] = edge.entity
        
        end
        
        local node = edge.isBackward and edge.comp.node0 or edge.comp.node1
        local nextEdges = {}
        for _, e in ipairs(map[node]) do
            if e ~= edge.entity then
                table.insert(nextEdges, e)
            end
        end
        if #nextEdges == 1 then
            local nextEdge = nextEdges[1]
            local comp = api.engine.getComponent(nextEdge, api.type.ComponentType.BASE_EDGE)
            local isBackward = comp.node1 == node
            
            edge = {
                entity = nextEdge,
                comp = comp,
                isBackward = isBackward
            }
            
            if frozenNodes[comp.node0] or frozenNodes[comp.node1] then
                isSearchFinished = true
            end
        else
            isSearchFinished = true
        end
    end
    
    local cmd = api.cmd.make.buildProposal(proposal, nil, true)
    api.cmd.sendCommand(cmd, function(_) end)

end


local script = {
    handleEvent = function(src, id, name, param)
        if (id == "__edgeTool__" and param.sender ~= "autosig2") then
            if (name == "off") then
                if (param.sender ~= "ptracks") then
                    state.use = false
                    state.replace = false
                    state.remove = false
                end
            end
        elseif (id == "__autosig2__") then
            if (name == "distance") then
                state.distance = param.distance
                if state.distance < 10 then state.distance = 10 end
            elseif (name == "use") then
                state.use = param.use
                state.replace = false
                state.remove = false
                state.backward = false
            elseif (name == "replace") then
                state.use = true
                state.replace = true
                state.remove = false
            elseif (name == "remove") then
                state.use = true
                state.replace = false
                state.remove = true
            elseif (name == "backward") then
                state.backward = param.backward
            elseif (name == "build") then
                if state.remove or state.replace then
                    remove(param)
                else
                    build(param)
                end
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
            state.remove = data.remove
            state.replace = data.replace
            state.backward = data.backward
        end
    end,
    guiHandleEvent = function(id, name, param)
        if id == "streetTerminalBuilder" then
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
                    if name == "builder.apply" and state.use then
                        game.interface.sendScriptEvent("__autosig2__", "build",
                            {
                                nodes = {newSegement.comp.node0, newSegement.comp.node1},
                                edgeObjects = func.map(proposal.removedSegments[1].comp.objects, pipe.select(1)),
                                model = api.res.modelRep.getName(object.modelInstance.modelId),
                                left = object.left,
                                oneWay = object.oneWay
                            }
                    )
                    elseif name == "builder.proposalCreate" then
                        createWindow()
                    end
                end
            end
        end
    end
}

function data()
    return script
end
