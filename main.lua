_G.baseDir      = (...):match("(.-)[^%.]+$")
_G.libDir       = _G.baseDir .. "lib."

_G.bitser = require(_G.libDir .. "bitser")

local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and love.math.random(0, 0xf) or love.math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

local selfId = uuid()
print(selfId)
_G.Client = {
    Udp = require(_G.libDir .. "udp_client"):new(selfId),
    Tcp = require(_G.libDir .. "tcp_client"):new(selfId)
}

_G.Client.Tcp.handshake = "00000"
_G.Client.Udp.handshake = "00000"

_G.Client.Tcp:connect("192.168.1.65", 8080)
_G.Client.Udp:connect("192.168.1.65", 8081)

local camera = require(_G.libDir .. "camera")()
local world = nil

local World = require(_G.libDir .. "engine.world")

_G.Client.Udp.callbacks.recv = function (data)
    local packet = _G.bitser.loads(data)
    if packet.id == "entity_update" then
        world:updateEntity(packet.entityId, packet.entityData)
    elseif packet.id == "entity_create" then
        world:addEntity(packet.entityData)
    elseif packet.id == "entity_remove" then
        world:removeEntity(packet.entityId)
    end
end

_G.Client.Tcp.callbacks.recv = function (data)
    local packet = _G.bitser.loads(data)
    print(packet.id)
    if packet.id == "world_load" then
        world = World:new(packet.world.width, packet.world.height, packet.world.entities)
    end
end

function love.update(dt)
    _G.Client.Tcp:update(dt)
    _G.Client.Udp:update(dt)

    local z = love.keyboard.isDown("z");
    local w = love.keyboard.isDown("w");
    local q = love.keyboard.isDown("q");
    local a = love.keyboard.isDown("a");
    local d = love.keyboard.isDown("d");
    local s = love.keyboard.isDown("s");
    local lshift = love.keyboard.isDown("lshift");

    if z or w then
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_move",
            cmd = "up"
        }))
    end

    if q or a then
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_move",
            cmd = "left"
        }))
    end

    if d then
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_move",
            cmd = "right"
        }))
    end

    if s then
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_move",
            cmd = "down"
        }))
    end

    local mouseIsDown = love.mouse.isDown(1)
    if mouseIsDown then
        local mx, my = camera:mousePosition()
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_shoot",
            data = { x = mx, y = my },
        }))
    end

    local mx, my = camera:mousePosition()
    _G.Client.Udp:send(_G.bitser.dumps({
        id = "player_orientation",
        data = { x = mx, y = my },
    }))

    _G.Client.Udp:send(_G.bitser.dumps({
        id = "player_shield",
        data = true
    }))
    
    if type(world) == "table" then
        for i, entity in ipairs(world.entities) do
            if entity.id == selfId then
                if entity.components["Position"] then
                    local ePos = entity.components["Position"].position
                    camera:lookAt(ePos.x, ePos.y)
                end
            end
        end
    end
end

function love.draw()
    if type(world) == "table" then
        local selfEntity = world:getEntityById(selfId)
        if selfEntity then
            local sClan = selfEntity.components["Clan"]
            love.graphics.print("Clan Name: " .. sClan.clanName)
            love.graphics.print("Clan Fame: " .. sClan.clanFame, 0, 20)
        end
    end
    camera:attach()
    if type(world) == "table" then
        local selfEntity = world:getEntityById(selfId)
        love.graphics.rectangle("line", 0, 0, world.width, world.height)
        for i, entity in ipairs(world.entities) do
            local ePos = entity.components["Position"]
            local eDim = entity.components["Dimension"]
            local eOri = entity.components["Orientation"]
            local eShield = entity.components["Shield"]
            local eLife = entity.components["Life"]
            local eClan = entity.components["Clan"]
            if ePos and eDim and eOri then
                love.graphics.push()
                love.graphics.translate(ePos.position.x + eDim.width / 2, ePos.position.y + eDim.height / 2)
                love.graphics.rotate(eOri.orientation)
                love.graphics.rectangle("fill", -(eDim.width/2), -(eDim.height/2), eDim.width , eDim.height)
                love.graphics.pop()
            end
            if ePos and eDim and eOri and eShield and eLife then
                if entity.id ~= selfId then
                    if selfEntity then
                        if eClan.clanName ~= selfEntity.components["Clan"].clanName then
                            love.graphics.setColor(1, 0, 0, 1)
                        else
                            love.graphics.setColor(0, 1, 0, 1)
                        end
                    end
                    love.graphics.print(eClan.clanName, ePos.position.x, ePos.position.y - 32)
                    love.graphics.push()
                    love.graphics.translate(ePos.position.x + eDim.width / 2, ePos.position.y + eDim.height / 2)
                    love.graphics.rotate(eOri.orientation)
                    love.graphics.rectangle("line", -(eDim.width/2), -(eDim.height/2), eDim.width , eDim.height)
                    love.graphics.pop()
                    love.graphics.setColor(1,1,1,1)
                end
                love.graphics.push()
                love.graphics.translate(ePos.position.x + eDim.width / 2, ePos.position.y + eDim.height / 2)
                love.graphics.rotate(eOri.orientation)
                love.graphics.rectangle("fill", -(eDim.width/2), -(eDim.height/2), eDim.width , eDim.height)
                love.graphics.pop()
                -- life
                love.graphics.setColor(1,0,0,1)
                love.graphics.rectangle("fill", ePos.position.x, ePos.position.y - eDim.width / 2, 32 * (eLife.life / eLife.maxLife ), 8 )
                love.graphics.setColor(1,1,1,1)
                love.graphics.rectangle("line", ePos.position.x, ePos.position.y - eDim.width / 2, 32, 8 )
                if eShield.activated then
                    love.graphics.setColor(0,0,1, eShield.armor / 100)
                    love.graphics.push()
                    love.graphics.translate(ePos.position.x + 4 + (48 * math.cos(eOri.orientation)), ePos.position.y + 24 + (48 * math.sin(eOri.orientation)))
                    love.graphics.rotate(eOri.orientation)
                    love.graphics.rectangle("fill", -4, -24, 8, 48)
                    love.graphics.pop()
                    love.graphics.setColor(1,1,1,1)
                end
            end
            -- if v.position then
            --     if v.id == clientId then
            --         love.graphics.setColor(0,1,0,1)
            --     else
            --         if v.isPlayer then
            --             if v.pvp then
            --                 love.graphics.setColor(1,0,0,1)
            --             else
            --                 love.graphics.setColor(0,0,1,1)
            --             end
            --         else
            --             love.graphics.setColor(1,1,1,1)
            --         end
            --     end
            --     if v.width and v.height then
            --         love.graphics.push()
            --         love.graphics.translate(v.position.x + v.width / 2, v.position.y + v.height / 2)
            --         love.graphics.rotate(v.orientation)
            --         love.graphics.rectangle("fill", -(v.width/2), -(v.height/2), v.width , v.height)
            --         love.graphics.pop()
            --         if v.activated then
            --             love.graphics.push()
            --             love.graphics.translate(v.position.x + 4 + (48 * math.cos(v.orientation)), v.position.y + 24 + (48 * math.sin(v.orientation)))
            --             love.graphics.rotate(v.orientation)
            --             love.graphics.rectangle("fill", -4, -24, 8, 48)
            --             love.graphics.pop()
            --         end
            --     end
            -- end
            -- if v.life then
            --     love.graphics.setColor(1,0,0,1)
            --     love.graphics.rectangle("fill", v.position.x, v.position.y - 16, 32, 8 )
            --     love.graphics.setColor(1,1,1,1)
            -- end
        end
    end
    camera:detach()
end

function love.keyreleased(key)
    if key == "p" then
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_pvp"
        }))
    end
    if key == "o" then
        _G.Client.Tcp:send(_G.bitser.dumps({
            id = "request_player_entity",
        }))
    end
    if key == "lshift" then
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_shield",
            data = false
        }))
    end
end

function love.keypressed(key)
    if key == "lshift" then
        _G.Client.Udp:send(_G.bitser.dumps({
            id = "player_shield",
            data = true
        }))
    end
end

function love.quit()
    _G.Client.Tcp:disconnect()
    _G.Client.Udp:disconnect()
end