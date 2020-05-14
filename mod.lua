function data()
    return {
        info = {
            minorVersion = 6,
            severityAdd = "NONE",
            severityRemove = "NONE",
            name = _("MOD_NAME"),
            description = _("MOD_DESC"),
            authors = {
                {
                    name = "Enzojz",
                    role = "CREATOR",
                    text = "Idea, Scripting, Modeling, Texturing",
                    steamProfile = "enzojz",
                    tfnetId = 27218,
                }
            },
            tags = {"Track", "Script Mod", "Signal", "Track Asset"},
        },
        runFn = function()
            local sigList = {}
            addModifier("loadModel",
                function(fileName, data)
                    if data.metadata and data.metadata.signal and 
                    (data.metadata.signal.type == "ONE_WAY_PATH_SIGNAL" or data.metadata.signal.type == "PATH_SIGNAL")
                    and data.metadata.availability then
                        local yearFrom = data.metadata.availability.yearFrom or 0
                        local yearTo = data.metadata.availability.yearTo or 0
                        if yearFrom >= 1850 or yearTo >= 1850 then
                            local fname = string.match(fileName, "res/models/model/(.+).mdl")
                            if fname then
                                pcall(function()
                                    table.insert(sigList, fname)
                                    local file = io.open("autosig.rec", "w")
                                    file:write(table.concat(sigList, "\n"))
                                    file:close()
                                end)
                            end
                        end
                    end
                    return data
                end)
        end
    }
end
