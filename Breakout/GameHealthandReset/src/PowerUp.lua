--[[
    GD50
    Breakout Remake

    -- Ball Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a ball which will bounce back and forth between the sides
    of the world space, the player's paddle, and the bricks laid out above
    the paddle. The ball can have a skin, which is chosen at random, just
    for visual variety.
]]

PowerUp = Class{}

function PowerUp:init()
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16

    self.x = math.random(50, VIRTUAL_WIDTH - 50)
    self.y = 50

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = 0

    -- this will effectively be the color of our ball, and we will index
    -- our table of Quads relating to the global block texture using this
end

--[[
    Expects an argument with a bounding box, be that a paddle or a brick,
    and returns true if the bounding boxes of this and the argument overlap.
]]

--[[
    Places the ball in the middle of the screen, with no movement.
]]
function PowerUp:reset()
    self.x = math.random(50, VIRTUAL_WIDTH - 50)
    self.y = 50
    self.dy = 0
end

function PowerUp:update(dt)
    self.y = self.y + self.dy * dt

    -- allow ball to bounce off walls
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - 8 then
        self.x = VIRTUAL_WIDTH - 8
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        gSounds['wall-hit']:play()
    end
end

function PowerUp:render()
    -- gTexture is our global texture for all blocks
    -- gBallFrames is a table of quads mapping to each individual ball skin in the texture
    love.graphics.draw(gTextures['main'], gFrames['powerUps'][math.random(1,10)],
        self.x, self.y)
end