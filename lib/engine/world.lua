local World = require(_G.libDir .. "middleclass")("World")

function World:initialize(width, height, entities)
    self.width = width or 100
    self.height = height or 100
    self.entities = entities or {}
    self.camera = require(_G.libDir .. "camera")()
    
    self.tools = {
        gridSize = {
            width = 16,
            height = 16
        }
    }

    self.debugActivated = false
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
        if self.debugActivated then
            self:drawDebug()
        end
    self.camera:detach()
end

function World:drawDebug()
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    -- draw grid
    mx, my = self.camera:mousePosition()
    for x=0, self.width / self.tools.gridSize.width do
        for y=0, self.height / self.tools.gridSize.height do
            love.graphics.rectangle("line", x * self.tools.gridSize.width, y * self.tools.gridSize.height, self.tools.gridSize.width, self.tools.gridSize.height )
            if mx > x * self.tools.gridSize.width and mx < (x * self.tools.gridSize.width) + self.tools.gridSize.width and my > y * self.tools.gridSize.height and my < (y * self.tools.gridSize.height) + self.tools.gridSize.height then
                love.graphics.rectangle("fill", x * self.tools.gridSize.width, y * self.tools.gridSize.height, self.tools.gridSize.width, self.tools.gridSize.height )
            end
        end
    end 
end

function World:keyreleased(key)
    if key == m then
        self.debugActivated = not self.debugActivated
    end
end

function World:mousereleased()
    mx, my = self.camera:mousePosition()
    for x=0, self.width / self.tools.gridSize.width do
        for y=0, self.height / self.tools.gridSize.height do
            if mx > x * self.tools.gridSize.width and mx < (x * self.tools.gridSize.width) + self.tools.gridSize.width and my > y * self.tools.gridSize.height and my < (y * self.tools.gridSize.height) + self.tools.gridSize.height then
                self:addEntity({
                    id = "test",
                    components = {
                        Position = {
                            position = {
                                x = x * self.tools.gridSize.width,
                                y = y * self.tools.gridSize.height
                            }
                        },
                        Dimension= {
                            width = 16,
                            height = 16
                        },
                        Orientation = {
                            orientation = 0
                        }
                    }
                })
            end
        end
    end
end

return World