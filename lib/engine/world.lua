local World = require(_G.libDir .. "middleclass")("World")

function World:initialize(width, height, entities)
    self.width = width or 100
    self.height = height or 100
    self.entities = entities or {}
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

return World