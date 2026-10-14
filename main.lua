local PALETTE = require("PALETTE")
local loadProgram = require("loadProgram")
local Runtime = require("Runtime")

local CODEL_SIZE = 50

local runtime

function love.load()
    local program_image_data = love.image.newImageData("example.png")
    runtime = Runtime(loadProgram(program_image_data))

    love.window.setMode(CODEL_SIZE * #runtime.program_table, CODEL_SIZE * #runtime.program_table)
end

function love.draw()
    for y = 1, #runtime.program_table do
        local row = runtime.program_table[y]
        for x = 1, #row do
            local codel = row[x]
            love.graphics.setColor(PALETTE[codel].color)
            love.graphics.rectangle("fill", (x - 1) * CODEL_SIZE, (y - 1) * CODEL_SIZE, CODEL_SIZE, CODEL_SIZE)
        end
    end

    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", (runtime.cursor.x - 1) * CODEL_SIZE + CODEL_SIZE / 2,
        (runtime.cursor.y - 1) * CODEL_SIZE + CODEL_SIZE / 2, CODEL_SIZE * 0.2)
end

function love.keypressed(key)
    if key == "space" then
        runtime:stepProgram()
    end
end
