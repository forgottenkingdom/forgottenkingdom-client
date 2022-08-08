local GameObject = require(_G.libDir .. "engine.gameobject")
local Button = require(_G.libDir .. "middleclass")("Button")

function Button:initialize(text, x, y)
    GameObject.initialize(self)
    self.text = love.graphics.newText(love.font, text)
    self.position = {
        x = x,
        y = y
    }
end

function Button:draw()
    GameObject.draw(self)

    local w, h = self.text:getDimensions(0)
    love.graphics.rectangle("line", self.position.x, self.position.y, w, h)
end