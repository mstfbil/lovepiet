local loadProgram = require("loadProgram")
local Runtime = require("Runtime")

local runtime
local program_image, program_table

function love.load()
    runtime = Runtime()

    local program_image_data = love.image.newImageData("example.png")
    program_image = love.graphics.newImage(program_image_data)
    program_table = loadProgram(program_image_data)
end
