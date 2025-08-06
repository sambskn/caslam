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
local originX, originY = 100, -40

local numFont = gfx.font.new("fonts/topaz_serif_8")

local function getHexImage(height, hexType, hexNum)
    -- height of hexagon = long diameter of hexagon = 2x one side
    local hexagonSide = height / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (height - hexagonSide) / 2
    local hexImg = gfx.image.new(hexWidth + 2, height)

    gfx.pushContext(hexImg)
    -- shoutout https://gurgleapps.com/tools/matrix
    if hexType == 1 then
        -- dark herringbone
        gfx.setPattern({ 0x5a, 0xa5, 0x5a, 0xa5, 0x5a, 0xa5, 0x5a, 0xa5 })
    end
    if hexType == 2 then
        -- stripe
        gfx.setPattern({ 0xfc, 0xf9, 0xf3, 0xe7, 0xcf, 0x9f, 0x3f, 0x7e })
    end
    if hexType == 3 then
        -- dots
        gfx.setPattern({ 0xdd, 0x77, 0xdd, 0x77, 0xdd, 0x77, 0xdd, 0x77 })
    end
    if hexType == 4 then
        --mesh
        gfx.setPattern { 0xda, 0xba, 0xba, 0xfa, 0xd7, 0x57, 0x5d, 0x5d }
    end
    if hexType == 5 then
        --brick
        gfx.setPattern { 0x3f, 0x9f, 0xcf, 0xc7, 0x93, 0x39, 0x7c, 0x7e }
    end
    if hexType == 6 then
        --flower
        gfx.setPattern { 0x5a, 0xdb, 0x3c, 0xe7, 0xe7, 0x3c, 0xdb, 0x5a }
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
    gfx.fillRect(hexWidth * 9 / 24, height * 9 / 24, hexWidth * 5 / 24, height / 6)
    gfx.setColor(gfx.kColorBlack)
    gfx.setFont(numFont)
    gfx.drawTextAligned(hexNum, hexWidth * 5 / 12, height * 5 / 12, gfx.kAlignCenter)
    gfx.popContext()
    return hexImg
end

local indicatorRadius = 10

-- TODO: make indicator snap to hex vertices
local function drawIndicator()
    local bumpRad = (math.sin(pd.getCurrentTimeMilliseconds() * 0.005) + 1) * 0.5 * (indicatorRadius / 4);
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(7)
    gfx.drawCircleAtPoint(220, 100, indicatorRadius + bumpRad)
    gfx.setLineWidth(6)
    gfx.drawCircleAtPoint(220, 100, bumpRad)

    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(220, 100, indicatorRadius + bumpRad)
    gfx.fillCircleAtPoint(220, 100, bumpRad)
end


local hexRows = { { 1, 2, 3 }, { 4, 5, 6, 1 }, { 3, 4, 5, 6, 1 }, { 3, 2, 1, 4 }, { 2, 2, 5 } }


-- playdate.update function is required in every project!
function playdate.update()
    -- Clear screen
    gfx.clear()

    local hexagonSide = hexHeight / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (hexHeight - hexagonSide) / 2
    for row, hexesTable in pairs(hexRows) do
        for col, hexType in pairs(hexesTable) do
            local newHex = getHexImage(hexHeight, hexType, (row + col) % 12 + 1)
            local x = originX + (hexWidth * col) - (hexWidth / 2)
            if row % 2 == 0 then
                x -= hexWidth / 2
            end
            if #hexesTable > 4 then
                x -= hexWidth
            end
            local y = originY + row * (hexHeight - vertCornerOffset)
            newHex:drawAnchored(x, y, 0.0, 0.0)
        end
    end

    drawIndicator()
end
