local PlayScreen = require(_G.libDir .. "middleclass")("PlayScreen", _G.xle.Scene)
local ButtonElement = require(_G.engineDir .. "builtin.gameobjects.button")

function PlayScreen:initialize (name, active )
    _G.xle.Scene.initialize(self, name, active)
end

function PlayScreen:init()
    _G.xle.Scene.init(self)
    love.window.setTitle(self.name)

    self.nodes = {
    }

    _G.masterServer:send(_G.bitser.dumps({
        id = "list_character",
        data = {
            email = _G.user.email,
            token = _G.user.token,
        }
    }))
    self.charactersButtons = {}
end

function PlayScreen:update(...)
    if #_G.user.characters > 0 and #self.charactersButtons < #_G.user.characters then
        for i, v in ipairs(_G.user.characters) do
            local btnInstance = ButtonElement:new(v.name, 10, 50 * i)
            btnInstance:addOnClickEvent("load_character", function ()
                _G.masterServer:send(_G.bitser.dumps({
                    id = "play",
                    data = {
                        characterName = v.name,
                        email = _G.user.email,
                        token = _G.user.token,
                    }
                }))
            end)
            self.charactersButtons[v.name] = btnInstance
        end
    end

    for k in pairs(self.charactersButtons) do
        if self.charactersButtons[k].update ~= nil then
            self.charactersButtons[k]:update(...)
        end
    end

    for k in pairs(self.nodes) do
        if self.nodes[k].update ~= nil then
            self.nodes[k]:update(...)
        end
    end
end

function PlayScreen:draw(...)
    if _G.worldServer ~= nil then
        _G.worldServer:draw(...)
    end

    for k in pairs(self.charactersButtons) do
        if self.charactersButtons[k].draw ~= nil then
            self.charactersButtons[k]:draw(...)
        end
    end


    for k in pairs(self.nodes) do
        if self.nodes[k].draw ~= nil then
            self.nodes[k]:draw(...)
        end
    end
end

function PlayScreen:mousepressed(...)
    for k in pairs(self.charactersButtons) do
        if self.charactersButtons[k].mousepressed ~= nil then
            self.charactersButtons[k]:mousepressed(...)
        end
    end

    for k in pairs(self.nodes) do
        if self.nodes[k].mousepressed ~= nil then
            self.nodes[k]:mousepressed(...)
        end
    end
end
function PlayScreen:mousereleased(...)
    for k in pairs(self.charactersButtons) do
        if self.charactersButtons[k].mousereleased ~= nil then
            self.charactersButtons[k]:mousereleased(...)
        end
    end

    for k in pairs(self.nodes) do
        if self.nodes[k].mousereleased ~= nil then
            self.nodes[k]:mousereleased(...)
        end
    end
end

function PlayScreen:keyreleased(key)
    if _G.worldServer ~= nil then
        if key == "p" then
            _G.worldServer.udp:send(_G.bitser.dumps({
                id = "player_pvp"
            }))
        end
        if key == "lshift" then
            _G.worldServer.udp:send(_G.bitser.dumps({
                id = "player_shield",
                data = false
            }))
        end
    end
end

function PlayScreen:keypressed(key)
    if _G.worldServer ~= nil then
        if key == "lshift" then
            _G.worldServer.udp:send(_G.bitser.dumps({
                id = "player_shield",
                data = true
            }))
        end
    end
end
return PlayScreen;