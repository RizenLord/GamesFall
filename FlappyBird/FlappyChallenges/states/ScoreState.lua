--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

local BRONZE_IMG = love.graphics.newImage('bronze.png')
local SILVER_IMG = love.graphics.newImage('silver.png')
local GOLD_IMG = love.graphics.newImage('gold.png')

local SAD_IMG = love.graphics.newImage('sad.png')

ScoreState = Class{__includes = BaseState}

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    if self.score == 0 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('Oof! You Lost!', 0, 48, VIRTUAL_WIDTH, 'center')

        love.graphics.draw(SAD_IMG, VIRTUAL_WIDTH/2 - SAD_IMG:getWidth()/2, 120)
        
    elseif self.score == 1 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('You Earned a Bronze Trophy!', 0, 48, VIRTUAL_WIDTH, 'center')

        love.graphics.draw(BRONZE_IMG, VIRTUAL_WIDTH/2 - BRONZE_IMG:getWidth()/2, 120)

    elseif self.score == 2 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('You Earned a Silver Trophy!', 0, 48, VIRTUAL_WIDTH, 'center')

        love.graphics.draw(SILVER_IMG, VIRTUAL_WIDTH/2 - SILVER_IMG:getWidth()/2, 120)
    elseif self.score >= 3 then
        love.graphics.setFont(flappyFont)
        love.graphics.printf('You Earned a Gold Trophy!', 0, 48, VIRTUAL_WIDTH, 'center')

        love.graphics.draw(GOLD_IMG, VIRTUAL_WIDTH/2 - GOLD_IMG:getWidth()/2, 120)
    end
    
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 84, VIRTUAL_WIDTH, 'center')

    love.graphics.printf('Press Enter to Play Again!', 0, 240, VIRTUAL_WIDTH, 'center')
end