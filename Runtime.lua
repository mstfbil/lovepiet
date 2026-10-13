local utf8 = require("utf8")

local function noop() end

local DIRS = {
    RIGHT = 1,
    DOWN = 2,
    LEFT = 3,
    UP = 4
}

local Runtime = {
    dp = DIRS.RIGHT,
    cc = DIRS.LEFT,
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
        self.cc = (self.cc == DIRS.LEFT) and DIRS.RIGHT or DIRS.LEFT
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

---@param program_table number[][]
function Runtime:interpretProgram(program_table)
    -- wip
end

return function() -- new Runtime
    return setmetatable({
        stack = {},
        pointer = { 0, 0 },
    }, Runtime)
end
