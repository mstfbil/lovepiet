local PALETTE = {
    { 1,     0.753, 0.753 }, -- light red
    { 1,     1,     0.753 }, -- light yellow
    { 0.753, 1,     0.753 }, -- light green
    { 0.753, 1,     1 },     -- light cyan
    { 0.753, 0.753, 1 },     -- light blue
    { 1,     0.753, 1 },     -- light magenta
    { 1,     0,     0 },     -- red
    { 1,     1,     0 },     -- yellow
    { 0,     1,     0 },     -- green
    { 0,     1,     1 },     -- cyan
    { 0,     0,     1 },     -- blue
    { 1,     0,     1 },     -- magenta
    { 0.753, 0,     0 },     -- dark red
    { 0.753, 0.753, 0 },     -- dark yellow
    { 0,     0.753, 0 },     -- dark green
    { 0,     0.753, 0.753 }, -- dark cyan
    { 0,     0,     0.753 }, -- dark blue
    { 0.753, 0,     0.753 }, -- dark magenta

    { 1,     1,     1 },     -- white
    { 0,     0,     0 }      -- black
}

local function gcdTable(t)
    local result = t[1]
    for i = 2, #t do
        local a, b = result, t[i]
        while b ~= 0 do
            a, b = b, a % b
        end
        result = math.abs(a)
        if result == 1 then
            break
        end
    end
    return result
end

local function normalizeImageColors(_, _, r, g, b)
    local nearest_color = PALETTE[1]
    local min_dist_sq   = math.huge

    for i = 1, #PALETTE do
        local color = PALETTE[i]
        local dr = r - color[1]
        local dg = g - color[2]
        local db = b - color[3]

        local dist_sq = dr ^ 2 + dg ^ 2 + db ^ 2
        if dist_sq < min_dist_sq then
            min_dist_sq = dist_sq
            nearest_color = color
        end
    end

    return nearest_color[1], nearest_color[2], nearest_color[3]
end

---@param image_data love.ImageData
local function autodetectCodelSize(image_data)
    local w, h = image_data:getDimensions()

    local run_lengths = {}

    for y = 0, h - 1 do
        local current_color = image_data:getPixel(0, y)
        local current_run = 0
        for x = 0, w - 1 do
            if image_data:getPixel(x, y) == current_color then
                current_run = current_run + 1
            else
                table.insert(run_lengths, current_run)
                current_color = image_data:getPixel(x, y)
                current_run = 1
            end
        end
        table.insert(run_lengths, current_run)
    end

    for x = 0, w - 1 do
        local current_color = image_data:getPixel(x, 0)
        local current_run = 0
        for y = 0, h - 1 do
            if image_data:getPixel(x, y) == current_color then
                current_run = current_run + 1
            else
                table.insert(run_lengths, current_run)
                current_color = image_data:getPixel(x, y)
                current_run = 1
            end
        end
        table.insert(run_lengths, current_run)
    end

    if #run_lengths == 0 then
        return 1
    end

    local codel_size = gcdTable(run_lengths)
    if codel_size == w or codel_size == h then
        return 1
    end

    return codel_size
end

---@param image_data love.ImageData
local function loadProgramImageToTable(image_data, codel_size)
    local w, h = image_data:getDimensions()
    local pw, ph = w / codel_size, h / codel_size
    local half_offset = math.floor(codel_size / 2)

    local program_table = {}

    for y = 1, ph do
        program_table[y] = {}
        for x = 1, pw do
            for i = 1, #PALETTE do
                local sx = (x - 1) * codel_size + half_offset
                local sy = (y - 1) * codel_size + half_offset
                local sr, sg, sb = image_data:getPixel(sx, sy)
                local color = PALETTE[i]
                if math.abs(sr - color[1]) < 0.01 and
                    math.abs(sg - color[2]) < 0.01 and
                    math.abs(sb - color[3]) < 0.01 then
                    program_table[y][x] = i
                    break
                end
            end
        end
    end

    return program_table
end

---@param image_data love.ImageData
return function(image_data)
    image_data:mapPixel(normalizeImageColors)
    local codel_size = autodetectCodelSize(image_data)
    local program_table = loadProgramImageToTable(image_data, codel_size)
    return program_table
end
