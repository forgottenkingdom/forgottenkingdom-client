_G.baseDir      = (...):match("(.-)[^%.]+$")
_G.libDir       = _G.baseDir .. "lib."
_G.srcDir       = _G.baseDir .. "src."
_G.engineDir    = _G.libDir .. "engine."

-- Utils
_G.bitser = require(_G.libDir .. "bitser")


-- Server configuration
_G.user = {
    email = "baw.developpement@gmail.com",
    token = nil,
    characters = {}
}

_G.masterServer = nil

_G.worldServer = nil

-- XLE configuration
local scenes    = require(_G.srcDir .. "scenes.scenes")

_G.xle          = require(_G.engineDir .. "xle")

_G.xleInstance  = _G.xle.Init:new("forgottenkingdom", scenes)

_G.xleInstance:addCallback("updateServer", "update", function (dt)
    if _G.masterServer ~= nil then
        _G.masterServer:update(dt)
    end

    if _G.worldServer ~= nil then
        _G.worldServer:update(dt)
    end
end)

_G.xleInstance:addCallback("exitServer", "quit", function ()
    print("quit")
    if _G.masterServer ~= nil then
        _G.masterServer:disconnect()
    end

    if _G.worldServer ~= nil then
        _G.worldServer:disconnect()
    end
end)