local World = require(_G.libDir .. "middleclass")("World")

function World:initialize(width, height, entities)
    self.width = width or 100
    self.height = height or 100
    self.entities = entities or {}
    self.camera = require(_G.libDir .. "camera")()
end

function World:getEntityById( entityId )
    local entity = nil
    for i, e in ipairs(self.entities) do
        if e.id == entityId then
            entity = e
        end
    end
    return entity
end

function World:addEntity(entityData)
    table.insert(self.entities, #self.entities + 1, entityData)
end

function World:updateEntity(entityId, entityData)
    for i, v in ipairs(self.entities) do
        if v.id == entityId then
            v.components = entityData.components
        end
    end
end

function World:removeEntity(entityId, entityData)
    for i, v in ipairs(self.entities) do
        if v.id == entityId then
            table.remove(self.entities, i)
        end
    end
end

function World:update()
    for i, entity in ipairs(self.entities) do
        if entity.id == _G.user.email then
            if entity.components["Position"] then
                local ePos = entity.components["Position"].position
                self.camera:lookAt(ePos.x, ePos.y)
            end
        end
    end
end

function World:draw()
    self.camera:attach()
        local selfEntity = self:getEntityById(_G.user.email)
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
        for i, entity in ipairs(self.entities) do
            local ePos = entity.components["Position"]
            local eDim = entity.components["Dimension"]
            local eOri = entity.components["Orientation"]
            local eShield = entity.components["Shield"]
            local eLife = entity.components["Life"]
            local eClan = entity.components["Clan"]
            local eName = entity.components["Name"]
            if ePos and eDim and eOri then
                love.graphics.push()
                love.graphics.translate(ePos.position.x + eDim.width / 2, ePos.position.y + eDim.height / 2)
                love.graphics.rotate(eOri.orientation)
                love.graphics.rectangle("fill", -(eDim.width/2), -(eDim.height/2), eDim.width , eDim.height)
                love.graphics.pop()
            end
            if ePos and eDim and eOri and eLife then
                love.graphics.setColor(1,0,0,1)
                love.graphics.rectangle("fill", ePos.position.x, ePos.position.y - eDim.width / 2, 32 * (eLife.life / eLife.maxLife ), 8 )
                love.graphics.setColor(1,1,1,1)
                love.graphics.rectangle("line", ePos.position.x, ePos.position.y - eDim.width / 2, 32, 8 )
                love.graphics.push()
                love.graphics.translate(ePos.position.x + eDim.width / 2, ePos.position.y + eDim.height / 2)
                love.graphics.rotate(eOri.orientation)
                love.graphics.rectangle("fill", -(eDim.width/2), -(eDim.height/2), eDim.width , eDim.height)
                love.graphics.pop()
            end
            if ePos and eDim and eOri and eShield and eLife and eClan then
                if entity.id ~= _G.user.selectedCharacter then
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
        end
    self.camera:detach()
end

return World