local loadProgram = require("loadProgram")

local program_image_data, program_image

function love.load()
    program_image_data = love.image.newImageData("example.png")
    program_image = love.graphics.newImage(program_image_data)

    loadProgram(program_image_data)
end
