--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}


--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    self.balls = {params.ball}

    self.recoverPoints = params.recoverPoints or 5000
    print(self.recoverPoints)

    self.powerups = {}
    self.powerupSpawn = false

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)

    self.key = false
end

function PlayState:update(dt)

    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end

    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return

    elseif love.keyboard.wasPressed('r') then
        gStateMachine:change('serve', {
            paddle = self.paddle,
            bricks = LevelMaker.createMap(32),
            health = 5,
            score = 0,
            highScores = self.highScores,
            level = 32,
            recoverPoints = 5000
        })
    end

    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        ball:update(dt)

        if #self.balls ~= 1 then
            if ball.y >= VIRTUAL_HEIGHT then
                table.remove(self.balls, k)
            end
        end
    end

    for k, powerup in pairs(self.powerups) do

        if powerup:collision(self.paddle) == true then
            if powerup.skin == 9 then -- Balls PowerUp
                table.remove(self.powerups, k)
                for i = 0, 1 do
                    local ball = Ball(math.random(7))
                    ball.x = self.balls[1].x + self.balls[1].width / 2 - ball.width / 2
                    ball.y = self.balls[1].y - ball.height
                    ball.dx = math.random(-200, 200)
                    ball.dy = math.random(-50, -60)
                    table.insert(self.balls, ball)
                end

            elseif powerup.skin == 10 then -- Key PowerUp
                table.remove(self.powerups, k)
                self.key = true

            elseif powerup.skin == 8 then -- Slow PowerUp
                table.remove(self.powerups, k)
                for p, ball in pairs(self.balls) do
                    if self.balls[p].dy >= -25 then
                        break
                    elseif self.balls[p].dy >= -30 then
                        break
                    else
                        self.balls[p].dx = self.balls[p].dx * .5
                        self.balls[p].dy = self.balls[p].dy * .5
                    end
                end
            end
        end
    end

    for k, ball in pairs(self.balls) do

        if ball:collides(self.paddle) then
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        for b, ball in pairs(self.balls) do


            if brick.inPlay and ball:collides(brick) then

                if self.key and brick.locked then
                    self.score = self.score + 5000
                    local num = math.random(3)
                        if num == 1 then
                            print("Spawned PowerUp")
                            table.insert(self.powerups, PowerUp(ball.x, ball.y, 10)) -- Key
                        elseif num == 2 then
                            print("Spawned PowerUp")
                            table.insert(self.powerups, PowerUp(ball.x, ball.y, 9)) -- Extra Ball
                        elseif num == 3 then
                            print("Spawned PowerUp")
                            table.insert(self.powerups, PowerUp(ball.x, ball.y, 8)) -- Slow Balls
                        end
                elseif brick.locked then
                    --do nothing
                else
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    if math.random(100) < 25 then
                        local num = math.random(3)
                        if num == 1 then
                            print("Spawned PowerUp")
                            table.insert(self.powerups, PowerUp(ball.x, ball.y, 10)) -- Key
                        elseif num == 2 then
                            print("Spawned PowerUp")
                            table.insert(self.powerups, PowerUp(ball.x, ball.y, 9)) -- Extra Ball
                        elseif num == 3 then
                            print("Spawned PowerUp")
                            table.insert(self.powerups, PowerUp(ball.x, ball.y, 8)) -- Slow Balls
                        end
                    end
                end

                -- trigger the brick's hit function, which removes it from play
                brick:hit(self.key)

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    self.health = math.min(5, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)
                    print(self.recoverPoints)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    if self.health == 5 then
        self.paddle.size = 4
    elseif self.health == 4 then
        self.paddle.size = 3
    elseif self.health == 3 then
        self.paddle.size = 2
    else
        self.paddle.size = 1
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    if #self.balls == 1 then
        if self.balls[1].y >= VIRTUAL_HEIGHT then
            self.health = self.health - 1
            gSounds['hurt']:play()

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level,
                    recoverPoints = self.recoverPoints
                })
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    self.paddle:render()

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end