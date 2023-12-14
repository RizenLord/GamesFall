--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety)
    
    --32x32
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    self.shiny = math.random() < SHINYCHANCE and true or false
    self.shinyConfig = {timer = nil, factor = 1}
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34, 32, 52, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.shiny then
        love.graphics.setBlendMode('add')

        love.graphics.setColor(255, 255, 255, self.shinyConfig.factor)
        love.graphics.rectangle('fill', self.x + x,
            self.y + y, 32, 32, 4)

        if not self.shinyConfig.timer then
             self.shinyConfig.timer = Timer.tween(1.5, {
                [self.shinyConfig] = { factor = 0 }
            }):finish(function()
                Timer.tween(.75, {
                    [self.shinyConfig] = { factor = 1 }
                }):finish(function() 
                    self.shinyConfig.timer = nil
                end)
            end)
        end
        love.graphics.setBlendMode('alpha')
    end
end