local GameServersScreen = require(_G.libDir .. "middleclass")("GameServersScreen", _G.xle.Scene)
local ButtonElement = require(_G.engineDir .. "builtin.gameobjects.button")
local http = require("socket.http")
local json = require(_G.libDir .. "json")

function GameServersScreen:initialize (name, active )
    _G.xle.Scene.initialize(self, name, active)
end

function GameServersScreen:init()
    _G.xle.Scene.init(self)
    love.window.setTitle(self.name)

    self.nodes = {
        refresh = ButtonElement:new("Refresh", 10, 150),
    }

    self.serverList = {}

    self.nodes.refresh:addOnClickEvent("getserverlist", function ()
        local b, c = http.request("http://localhost:3000/servers")
        print(type(b), c)
        self.serverList = json.decode(b)    
        _G.xle.Scene.goToScene("scene-servers");
    end)
end

function GameServersScreen:update(...)
    for k in pairs(self.nodes) do
        if self.nodes[k].update ~= nil then
            self.nodes[k]:update(...)
        end
    end
end

function GameServersScreen:draw(...)
    for k in pairs(self.nodes) do
        if self.nodes[k].draw ~= nil then
            self.nodes[k]:draw(...)
        end
    end

    for i, v in ipairs(self.serverList) do
        print(v)
    end
end

function GameServersScreen:mousepressed(...)
    for k in pairs(self.nodes) do
        if self.nodes[k].mousepressed ~= nil then
            self.nodes[k]:mousepressed(...)
        end
    end
end
function GameServersScreen:mousereleased(...)
    for k in pairs(self.nodes) do
        if self.nodes[k].mousereleased ~= nil then
            self.nodes[k]:mousereleased(...)
        end
    end
end

return GameServersScreen;