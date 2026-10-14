local utf8 = require("utf8")
local PALETTE = require("PALETTE")

local function noop() end

local DIR_COMPONENTS = {
    { x = 1,  y = 0 },
    { x = 0,  y = 1 },
    { x = -1, y = 0 },
    { x = 0,  y = -1 }
}

local DIR = {
    RIGHT = 1,
    DOWN = 2,
    LEFT = 3,
    UP = 4
}

local Runtime = {
    dp = DIR.RIGHT,
    cc = DIR.LEFT,
    retries = 0
}
Runtime.__index = Runtime

function Runtime:restoreStackItems(...)
    local items = { ... }
    for i = #items, 1, -1 do
        self:push(items[i])
    end
end

function Runtime:push(v)
    table.insert(self.stack, v)
end

function Runtime:pop(a)
    a = a or 1
    if a > #self.stack then
        return false
    end

    local p = {}
    for i = 1, a do
        p[i] = table.remove(self.stack)
    end
    return unpack(p, 1, a)
end

function Runtime:add()
    local a, b = self:pop(2)
    if not a then return end
    self:push(a + b)
end

function Runtime:subtract()
    local a, b = self:pop(2)
    if not a then return end
    self:push(b - a)
end

function Runtime:multiply()
    local a, b = self:pop(2)
    if not a then return end
    self:push(a * b)
end

function Runtime:divide()
    local a, b = self:pop(2)
    if not a then return end
    if a == 0 then
        self:restoreStackItems(a, b)
        return -- as specified by the doc at https://www.dangermouse.net/esoteric/piet.html
    end
    self:push(math.floor(b / a))
end

function Runtime:mod()
    local a, b = self:pop(2)
    if not a then return end
    if a == 0 then
        self:restoreStackItems(a, b)
        return -- as specified by the doc
    end
    self:push(b % a)
end

function Runtime:nnot()
    local n = self:pop()
    if not n then return end
    if n == 0 then
        self:push(1)
    else
        self:push(0)
    end
end

function Runtime:greater()
    local a, b = self:pop(2)
    if not a then return end
    if b > a then
        self:push(1)
    else
        self:push(0)
    end
end

function Runtime:pointer()
    local n = self:pop()
    if not n then return end

    self.dp = (self.dp - 1 + n) % 4 + 1
end

function Runtime:switch()
    local n = self:pop()
    if not n then return end

    if math.abs(n) % 2 == 1 then
        self.cc = (self.cc == DIR.LEFT) and DIR.RIGHT or DIR.LEFT
    end
end

function Runtime:duplicate()
    if #self.stack == 0 then return end
    self:push(self.stack[#self.stack])
end

function Runtime:roll()
    local a, b = self:pop(2)
    if not a then return end
    if b <= 0 or b > #self.stack then
        self:restoreStackItems(a, b)
        return
    end

    if b == 1 or a == 0 then
        return
    end

    a = a % b

    if a > 0 then
        for _ = 1, a do
            local top = self:pop()
            table.insert(self.stack, #self.stack - b + 2, top)
        end
    elseif a < 0 then
        for _ = 1, math.abs(a) do
            local v = table.remove(self.stack, #self.stack - b + 1)
            table.insert(self.stack, v)
        end
    end
end

function Runtime:in_char(input)
    self:push(utf8.codepoint(input))
end

function Runtime:in_number(input)
    self:push(input)
end

function Runtime:out_char(out_f)
    local n = self:pop()
    if not n then return end
    out_f(utf8.char(n))
end

function Runtime:out_number(out_f)
    local n = self:pop()
    if not n then return end
    out_f(n)
end

-- [delta lightness][delta hue]f
local DELTA_COMMAND_MAP = {
    { noop,         Runtime.add,      Runtime.divide, Runtime.greater, Runtime.duplicate, Runtime.in_char },
    { Runtime.push, Runtime.subtract, Runtime.mod,    Runtime.pointer, Runtime.roll,      Runtime.out_number },
    { Runtime.pop,  Runtime.multiply, Runtime.nnot,   Runtime.switch,  Runtime.in_number, Runtime.out_char }
}

function Runtime:getBlockSizeAndBoundBox(x, y)
    local program = self.program_table
    local h = #program
    if h == 0 then return end
    local w = #program[1]

    local target = program[y] and program[y][x]
    if not target then
        return 0, { x = x, y = y, w = 0, h = 0 }
    end

    local min_x, max_x = x, x
    local min_y, max_y = y, y
    local fill = 1

    local queue = { { x = x, y = y } }
    local visited = {}
    local head = 1

    visited[x .. "," .. y] = true

    while head <= #queue do
        local current = queue[head]
        head = head + 1

        if current.x < min_x then
            min_x = current.x
        end
        if current.x > max_x then
            max_x = current.x
        end
        if current.y < min_y then
            min_y = current.y
        end
        if current.y > max_y then
            max_y = current.y
        end

        for i = 1, 4 do
            local nx = current.x + DIR_COMPONENTS[i].x
            local ny = current.y + DIR_COMPONENTS[i].y

            if nx >= 1 and nx <= w and ny >= 1 and ny <= h then
                local key = nx .. "," .. ny

                if not visited[key] and program[ny][nx] == target then
                    visited[key] = true
                    fill = fill + 1

                    table.insert(queue, { x = nx, y = ny })
                end
            end
        end
    end

    return fill, {
        x = min_x,
        y = min_y,
        w = max_x - min_x + 1,
        h = max_y - min_y + 1
    }
end

function Runtime:isCodelAccessible(x, y)
    if not self.program_table[y] then
        return false
    else
        return x >= 1 and x <= #self.program_table[y] and y >= 1 and y <= #self.program_table and
            self.program_table[y][x] ~= PALETTE["black"].index
    end
end

function Runtime:stepProgram()
    if self.retries >= 8 then
        return false
    end

    local program = self.program_table
    local cursor = self.cursor
    local h = #program
    if h == 0 then return end
    local w = #program[1]

    local block_value = program[cursor.y][cursor.x]
    local block_size, block_bounds = self:getBlockSizeAndBoundBox(cursor.x, cursor.y)
    if not block_size or not block_bounds then
        error("error getting block bounds")
    end

    local leftmost, rightmost, exit_codel
    local function updateMostBounds(x, y)
        if not leftmost then
            leftmost = { x = x, y = y }
        end
        rightmost = { x = x, y = y }
    end

    local bottom_y, right_x = block_bounds.y + block_bounds.h - 1, block_bounds.x + block_bounds.w - 1
    if self.dp == DIR.RIGHT then
        local x = right_x
        for y = block_bounds.y, bottom_y do
            local codel = program[y][x]
            if codel == block_value then
                updateMostBounds(x, y)
            end
        end
        exit_codel = (self.cc == DIR.LEFT) and leftmost or rightmost
    end
    if self.dp == DIR.DOWN then
        local y = bottom_y
        for x = block_bounds.x, right_x do
            local codel = program[y][x]
            if codel == block_value then
                updateMostBounds(x, y)
            end
        end
        exit_codel = (self.cc == DIR.LEFT) and rightmost or leftmost
    end
    if self.dp == DIR.LEFT then
        local x = block_bounds.x
        for y = block_bounds.y, bottom_y do
            local codel = program[y][x]
            if codel == block_value then
                updateMostBounds(x, y)
            end
        end
        exit_codel = (self.cc == DIR.LEFT) and rightmost or leftmost
    end
    if self.dp == DIR.UP then
        local y = block_bounds.y
        for x = block_bounds.x, right_x do
            local codel = program[y][x]
            if codel == block_value then
                updateMostBounds(x, y)
            end
        end
        exit_codel = (self.cc == DIR.LEFT) and leftmost or rightmost
    end
    exit_codel.x = exit_codel.x + DIR_COMPONENTS[self.dp].x
    exit_codel.y = exit_codel.y + DIR_COMPONENTS[self.dp].y

    if self:isCodelAccessible(exit_codel.x, exit_codel.y) then
        self.retries = 0
        self.cursor = exit_codel
    else
        if self.retries % 2 == 0 then
            self.cc = (self.cc == DIR.LEFT) and DIR.RIGHT or DIR.LEFT
        else
            self.dp = (self.dp % 4) + 1
        end
        self.retries = self.retries + 1
    end

    return true
end

return function(program_table) -- new Runtime
    return setmetatable({
        program_table = program_table or {},
        stack = {},
        cursor = { x = 1, y = 1 },
    }, Runtime)
end
