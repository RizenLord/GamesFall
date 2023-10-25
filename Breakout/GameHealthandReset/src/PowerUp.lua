
PowerUp = Class{}

function PowerUp:init(x, y, skin)
    -- simple positional and dimensional variables
    self.width = 16
    self.height = 16

    self.x = x
    self.y = y

    -- these variables are for keeping track of our velocity on both the
    -- X and Y axis, since the ball can move in two dimensions
    self.dy = 0
    self.dx = 0

    self.skin = skin
end

function PowerUp:update(dt)
    self.dy = 60 

    self.y = self.y + self.dy * dt
end


function PowerUp:collision(paddle)

    if self.x > paddle.x + paddle.width or self.x + self.width < paddle.x then
        return false
    end

    if self.y > paddle.y + paddle.height or self.y + self.height < paddle.y then
        return false
    end

    return true
end


function PowerUp:render()
    -- gTexture is our global texture for all blocks
    love.graphics.draw(gTextures['main'], gFrames['powerUps'][self.skin], self.x, self.y)
end
