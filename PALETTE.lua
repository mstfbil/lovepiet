local PALETTE = {
    [1]  = { color = { 1, 0.753, 0.753 }, name = "light red" },
    [2]  = { color = { 1, 1, 0.753 }, name = "light yellow" },
    [3]  = { color = { 0.753, 1, 0.753 }, name = "light green" },
    [4]  = { color = { 0.753, 1, 1 }, name = "light cyan" },
    [5]  = { color = { 0.753, 0.753, 1 }, name = "light blue" },
    [6]  = { color = { 1, 0.753, 1 }, name = "light magenta" },
    [7]  = { color = { 1, 0, 0 }, name = "red" },
    [8]  = { color = { 1, 1, 0 }, name = "yellow" },
    [9]  = { color = { 0, 1, 0 }, name = "green" },
    [10] = { color = { 0, 1, 1 }, name = "cyan" },
    [11] = { color = { 0, 0, 1 }, name = "blue" },
    [12] = { color = { 1, 0, 1 }, name = "magenta" },
    [13] = { color = { 0.753, 0, 0 }, name = "dark red" },
    [14] = { color = { 0.753, 0.753, 0 }, name = "dark yellow" },
    [15] = { color = { 0, 0.753, 0 }, name = "dark green" },
    [16] = { color = { 0, 0.753, 0.753 }, name = "dark cyan" },
    [17] = { color = { 0, 0, 0.753 }, name = "dark blue" },
    [18] = { color = { 0.753, 0, 0.753 }, name = "dark magenta" },

    [19] = { color = { 1, 1, 1 }, name = "white" },
    [20] = { color = { 0, 0, 0 }, name = "black" }
}

for i = 1, #PALETTE do
    local entry = PALETTE[i]
    entry.index = i
    PALETTE[entry.name] = entry
end

return PALETTE
