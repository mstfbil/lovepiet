local loadProgram = require("loadProgram")
local Runtime = require("Runtime")

local runtime

function love.load()
    local program_image_data = love.image.newImageData("example.png")
    runtime = Runtime(loadProgram(program_image_data))
end
