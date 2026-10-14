local PALETTE = {
    [1]  = { color = { 1, 0.753, 0.753 }, name = "light red", hue = 0, lightness = 0 },
    [2]  = { color = { 1, 1, 0.753 }, name = "light yellow", hue = 1, lightness = 0 },
    [3]  = { color = { 0.753, 1, 0.753 }, name = "light green", hue = 2, lightness = 0 },
    [4]  = { color = { 0.753, 1, 1 }, name = "light cyan", hue = 3, lightness = 0 },
    [5]  = { color = { 0.753, 0.753, 1 }, name = "light blue", hue = 4, lightness = 0 },
    [6]  = { color = { 1, 0.753, 1 }, name = "light magenta", hue = 5, lightness = 0 },

    [7]  = { color = { 1, 0, 0 }, name = "red", hue = 0, lightness = 1 },
    [8]  = { color = { 1, 1, 0 }, name = "yellow", hue = 1, lightness = 1 },
    [9]  = { color = { 0, 1, 0 }, name = "green", hue = 2, lightness = 1 },
    [10] = { color = { 0, 1, 1 }, name = "cyan", hue = 3, lightness = 1 },
    [11] = { color = { 0, 0, 1 }, name = "blue", hue = 4, lightness = 1 },
    [12] = { color = { 1, 0, 1 }, name = "magenta", hue = 5, lightness = 1 },

    [13] = { color = { 0.753, 0, 0 }, name = "dark red", hue = 0, lightness = 2 },
    [14] = { color = { 0.753, 0.753, 0 }, name = "dark yellow", hue = 1, lightness = 2 },
    [15] = { color = { 0, 0.753, 0 }, name = "dark green", hue = 2, lightness = 2 },
    [16] = { color = { 0, 0.753, 0.753 }, name = "dark cyan", hue = 3, lightness = 2 },
    [17] = { color = { 0, 0, 0.753 }, name = "dark blue", hue = 4, lightness = 2 },
    [18] = { color = { 0.753, 0, 0.753 }, name = "dark magenta", hue = 5, lightness = 2 },

    [19] = { color = { 1, 1, 1 }, name = "white" },
    [20] = { color = { 0, 0, 0 }, name = "black" }
}

for i = 1, #PALETTE do
    local entry = PALETTE[i]
    entry.index = i
    PALETTE[entry.name] = entry
end

return PALETTE
