-- Below is a small example program where you can move a circle
-- around with the crank. You can delete everything in this file,
-- but make sure to add back in a playdate.update function since
-- one is required for every Playdate game!
-- =============================================================

-- Importing libraries used for drawCircleAtPoint and crankIndicator
import "CoreLibs/graphics"
import "CoreLibs/ui"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

local hexHeight = 58
local minHeight = 12
local maxHeight = 256
local originX, originY = 100, -40

local function getHexImage(height, hexType)
    -- height of hexagon = long diameter of hexagon = 2x one side
    local hexagonSide = height / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (height - hexagonSide) / 2
    local hexImg = gfx.image.new(hexWidth + 2, height)

    gfx.pushContext(hexImg)
    -- shoutout https://gurgleapps.com/tools/matrix
    if hexType == 1 then
        -- dark herringbone
        gfx.setPattern({0x5a,0xa5,0x5a,0xa5,0x5a,0xa5,0x5a,0xa5})
    end
    if hexType == 2 then
        -- stripe
        gfx.setPattern({0xfc,0xf9,0xf3,0xe7,0xcf,0x9f,0x3f,0x7e})
    end
    if hexType == 3 then
        -- dots
        gfx.setPattern({0xdd,0x77,0xdd,0x77,0xdd,0x77,0xdd,0x77})
    end
    if hexType == 4 then
        --mesh
        gfx.setPattern{0xda,0xba,0xba,0xfa,0xd7,0x57,0x5d,0x5d}
    end
    if hexType == 5 then
        --brick
        gfx.setPattern{0x3f,0x9f,0xcf,0xc7,0x93,0x39,0x7c,0x7e}
    end
    if hexType == 6 then
        --flower
        gfx.setPattern{0x5a,0xdb,0x3c,0xe7,0xe7,0x3c,0xdb,0x5a}
    end
    gfx.fillPolygon(
        0, vertCornerOffset,
        hexWidth / 2, 0,
        hexWidth, vertCornerOffset,
        hexWidth, vertCornerOffset + hexagonSide,
        hexWidth / 2, height,
        0, vertCornerOffset + hexagonSide,
        0, vertCornerOffset
    )
    gfx.setColor(gfx.kColorClear)
    gfx.setLineWidth(2)
    gfx.drawPolygon(
        0, vertCornerOffset,
        hexWidth / 2, 0,
        hexWidth, vertCornerOffset,
        hexWidth, vertCornerOffset + hexagonSide,
        hexWidth / 2, height,
        0, vertCornerOffset + hexagonSide,
        0, vertCornerOffset
    )
    gfx.popContext()
    return hexImg
end


local hexRows = { 3, 4, 5, 4, 3 }


-- playdate.update function is required in every project!
function playdate.update()
    -- Clear screen
    gfx.clear()

    local hexagonSide = hexHeight / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (hexHeight - hexagonSide) / 2
    for row, numHexes in pairs(hexRows) do
        for i = 1, numHexes, 1 do
            local hexType = (row + i) % 6 + 1
            local newHex = getHexImage(hexHeight, hexType)
            local x = originX + (hexWidth * i) - (hexWidth / 2)
            if row % 2 == 0 then
                x -= hexWidth / 2
            end
            if numHexes > 4 then
                x -= hexWidth
            end
            local y = originY + row * (hexHeight - vertCornerOffset)
            newHex:drawAnchored(x, y, 0.0, 0.0)
        end
    end

    if playdate.buttonJustPressed("b") then
        if hexHeight > minHeight then
            hexHeight -= 2
        end
    end
    if playdate.buttonJustPressed("a") then
        if hexHeight < maxHeight then
            hexHeight += 2
        end
    end
    if playdate.buttonJustPressed("up") then
        originY -= 4
    end
    if playdate.buttonJustPressed("down") then
        originY += 4
    end
    if playdate.buttonJustPressed("right") then
        originX += 4
    end
    if playdate.buttonJustPressed("left") then
        originX -= 4
    end
end
