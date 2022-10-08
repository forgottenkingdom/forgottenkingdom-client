local WorldServer = require(_G.libDir .. "middleclass")("WorldServer")
local World = require(_G.engineDir .. "world")

function WorldServer:initialize(characterName)
    self.currentCharacter = characterName
    self.tcp = require(_G.libDir .. "tcp_client"):new()
    self.udp = require(_G.libDir .. "udp_client"):new()
    self.world = nil

    self.tcp.callbacks.recv = function (data)
        local packet = _G.bitser.loads(data)
        print(packet.id)
        if packet.id == "world_load" then
            self.world = World:new(packet.world.width, packet.world.height, packet.world.entities)
        elseif packet.id == "join_world" then
            if packet.status == 200 then
                print("world found")
                self:disconnect()
                self:connect(packet.server.ip, packet.server.port, self.currentCharacter)
                print(packet.server.ip)
                print(packet.server.port)
            elseif packet.status == 404 then
                print("world not found")
            end
        end
    end

    self.udp.callbacks.recv = function (data)
        local packet = _G.bitser.loads(data)
        if packet.id == "world_update" then
            if self.world ~= nil then
                self.world.entities = packet.worldData.entities
            end
        elseif packet.id == "entity_update" then
            if self.world ~= nil then
                self.world:updateEntity(packet.entityId, packet.entityData)
            end
        elseif packet.id == "entity_create" then
            if self.world ~= nil then
                self.world:addEntity(packet.entityData)
            end
        elseif packet.id == "entity_remove" then
            if self.world ~= nil then
                self.world:removeEntity(packet.entityId)
            end
        end
    end
end

function WorldServer:connect(ip, port)
    self.tcp:connect(ip, port)
    self.udp:connect(ip, port)
end

function WorldServer:disconnect()
    self.tcp:disconnect()
    self.udp:disconnect()
end

function WorldServer:update(dt)
    self.tcp:update(dt)
    self.udp:update(dt)

    if self.world ~= nil then
        self.world:update(dt)
    end

    local z = love.keyboard.isDown("z");
    local w = love.keyboard.isDown("w");
    local q = love.keyboard.isDown("q");
    local a = love.keyboard.isDown("a");
    local d = love.keyboard.isDown("d");
    local s = love.keyboard.isDown("s");
    local lshift = love.keyboard.isDown("lshift");

    if self.world ~= nil then

        if z or w then
            self.udp:send(_G.bitser.dumps({
                id = "player_move",
                cmd = "up"
            }))
        end

        if q or a then
            self.udp:send(_G.bitser.dumps({
                id = "player_move",
                cmd = "left"
            }))
        end

        if d then
            self.udp:send(_G.bitser.dumps({
                id = "player_move",
                cmd = "right"
            }))
        end

        if s then
            self.udp:send(_G.bitser.dumps({
                id = "player_move",
                cmd = "down"
            }))
        end

        local mouseIsDown = love.mouse.isDown(1)
        if mouseIsDown then
            local mx, my = self.world.camera:mousePosition()
            self.udp:send(_G.bitser.dumps({
                id = "player_shoot",
                data = { x = mx, y = my },
            }))
        end

        local mx, my = self.world.camera:mousePosition()
        self.udp:send(_G.bitser.dumps({
            id = "player_orientation",
            data = { x = mx, y = my },
        }))
    end
end

function WorldServer:draw(...)
    if self.world ~= nil then
        self.world:draw(...)
    end
end

return WorldServer