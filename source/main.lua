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

local hexHeight = 54
local originX, originY = 168, -28

local numFont = gfx.font.new("fonts/topaz_serif_8")

local TREES = 1
local CROPS = 2
local ANIMALS = 3
local ORE = 4
local CLAY = 5
local NOMANS = 6

local function getHexImage(height, hexType, hexNum)
    -- height of hexagon = long diameter of hexagon = 2x one side
    local hexagonSide = height / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (height - hexagonSide) / 2
    local hexImg = gfx.image.new(hexWidth + 2, height)

    gfx.pushContext(hexImg)
    -- shoutout https://gurgleapps.com/tools/matrix
    if hexType == TREES then
        gfx.setPattern({ 0x55, 0x55, 0x57, 0x75, 0x75, 0xad, 0xad, 0x77 }) -- funk blobs
    end
    if hexType == CROPS then
        -- good ol h-bone
        gfx.setPattern({ 0x6c, 0xc6, 0x93, 0x39, 0x6c, 0xc6, 0x93, 0x39 })
    end
    if hexType == ANIMALS then
        gfx.setPattern({ 0x99, 0x47, 0x1f, 0xa1, 0x1e, 0xf1, 0x0f, 0xfe }) -- tree fields
    end
    if hexType == ORE then
        --rocks
        gfx.setPattern { 0x00, 0x0c, 0x1e, 0x3f, 0x7e, 0x7d, 0xba, 0x55 }
    end
    if hexType == CLAY then
        --brick
        gfx.setPattern { 0x3f, 0x9f, 0xcf, 0xc7, 0x93, 0x39, 0x7c, 0x7e }
    end
    if hexType == NOMANS then
        --triangles?
        gfx.setPattern({ 0x01, 0x82, 0xc5, 0xea, 0xf5, 0xfa, 0xfd, 0xfe })
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
    -- only draw number if not desert
    if hexType ~= 6 then
        gfx.setFont(numFont)
        local textWidth = gfx.getTextSize(hexNum)
        gfx.fillCircleAtPoint(hexWidth * 1 / 2, hexHeight * 1 / 2 - 1, 9)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawTextAligned(hexNum, hexWidth * 1 / 2 - textWidth / 2, height * 5 / 12, gfx.kAlignCenter)
    end

    gfx.popContext()
    return hexImg
end

local P_RIGHT = 1
local P_LEFT = 2
local P_DOWN_LEFT = 3
local P_DOWN_RIGHT = 4
local P_UP_LEFT = 5
local P_UP_RIGHT = 6
local THREE_TO_ONE = 6
local function getPortImage(portType, portDir)
    -- two lines for the spots
    -- small symbol or text
    local hexagonSide = hexHeight / 2
    local hexWidth = math.sqrt(3) * hexagonSide

    local vertCornerOffset = (hexHeight - hexagonSide) / 2
    local portImg = gfx.image.new(hexWidth, hexHeight)
    gfx.pushContext(portImg)
    -- defaull case is pointing right
    local x1 = hexWidth
    local y1 = hexHeight - vertCornerOffset
    local x2 = hexWidth
    local y2 = vertCornerOffset
    if portDir == P_LEFT then
        x1 = 0
        x2 = 0
    elseif portDir == P_DOWN_RIGHT then
        x1 = hexWidth / 2
        y1 = hexHeight - vertCornerOffset / 2
        x2 = hexWidth
        y2 = hexHeight - vertCornerOffset
    elseif portDir == P_DOWN_LEFT then
        x1 = hexWidth / 2
        y1 = hexHeight - vertCornerOffset / 2
        x2 = 0
        y2 = hexHeight - vertCornerOffset
    elseif portDir == P_UP_RIGHT then
        x1 = hexWidth / 2
        y1 = vertCornerOffset / 2
        x2 = hexWidth
        y2 = vertCornerOffset
    elseif portDir == P_UP_LEFT then
        x1 = hexWidth / 2
        y1 = vertCornerOffset / 2
        x2 = 0
        y2 = vertCornerOffset
    end
    gfx.setPattern({ 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa9 })
    gfx.setLineWidth(2)
    gfx.drawLine(hexWidth / 2, hexHeight / 2, x1, y1)
    gfx.drawLine(hexWidth / 2, hexHeight / 2, x2, y2)
    -- resource based ports get a little pattern sample
    if portType == TREES then
        gfx.setPattern({ 0x55, 0x55, 0x57, 0x75, 0x75, 0xad, 0xad, 0x77 }) -- funk blobs
    elseif portType == CROPS then
        -- good ol h-bone
        gfx.setPattern({ 0x6c, 0xc6, 0x93, 0x39, 0x6c, 0xc6, 0x93, 0x39 })
    elseif portType == ANIMALS then
        gfx.setPattern({ 0x99, 0x47, 0x1f, 0xa1, 0x1e, 0xf1, 0x0f, 0xfe }) -- tree fields
    elseif portType == ORE then
        --rocks
        gfx.setPattern { 0x00, 0x0c, 0x1e, 0x3f, 0x7e, 0x7d, 0xba, 0x55 }
    elseif portType == CLAY then
        --brick
        gfx.setPattern { 0x3f, 0x9f, 0xcf, 0xc7, 0x93, 0x39, 0x7c, 0x7e }
    end
    if portType ~= THREE_TO_ONE then
        gfx.fillCircleAtPoint(hexWidth / 2, hexHeight / 2, 10)
    else
        -- for 3:1 ports draw a ?
        gfx.setColor(gfx.kColorClear)
        gfx.fillCircleAtPoint(hexWidth / 2, hexHeight / 2, 10)
        gfx.setColor(gfx.kColorBlack)
        gfx.setFont(numFont)
        local textWidth = gfx.getTextSize("3:1")
        gfx.drawTextAligned("3:1", hexWidth / 2 - textWidth / 2, hexHeight / 2 - 4, gfx.kAlignCenter)
    end


    gfx.setColor(gfx.kColorClear)
    local clearLineWidth = 2
    gfx.setLineWidth(clearLineWidth)
    if portDir == P_RIGHT then
        x1 = hexWidth - clearLineWidth
        y1 = 0
        x2 = hexWidth - clearLineWidth
        y2 = hexHeight
    elseif portDir == P_LEFT then
        x1 = clearLineWidth - 1
        y1 = 0
        x2 = clearLineWidth - 1
        y2 = hexHeight
    elseif portDir == P_DOWN_RIGHT then
        x1 = hexWidth / 2
        y1 = hexHeight - clearLineWidth
        x2 = hexWidth - clearLineWidth
        y2 = hexHeight - vertCornerOffset
    elseif portDir == P_DOWN_LEFT then
        x1 = hexWidth / 2
        y1 = hexHeight - clearLineWidth
        x2 = clearLineWidth
        y2 = hexHeight - vertCornerOffset
    elseif portDir == P_UP_RIGHT then
        x1 = hexWidth / 2
        y1 = clearLineWidth
        x2 = hexWidth - clearLineWidth
        y2 = vertCornerOffset
    elseif portDir == P_UP_LEFT then
        x1 = hexWidth / 2
        y1 = clearLineWidth
        x2 = clearLineWidth
        y2 = vertCornerOffset
    end
    gfx.drawLine(x1, y1, x2, y2)

    gfx.drawCircleAtPoint(hexWidth / 2, hexHeight / 2, 11)
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)
    gfx.drawCircleAtPoint(hexWidth / 2, hexHeight / 2, 12)


    gfx.popContext()
    return portImg
end

-- 9 ports total
-- static locations
-- catan.bunge.io has:
--          3:1    3:1
-- SHEEP
--                         BRICK
-- 3:1
--                         WOOD
-- ORE
--         WHEAT   3:1
-- 1 of each resource + 4 3:1 ports
local ports = {
    {
        ["offsetFromOrigin"] = { 48, 6 },
        ["portType"] = THREE_TO_ONE,
        ["portDir"] = P_DOWN_RIGHT,
        ["image"] = getPortImage(THREE_TO_ONE, P_DOWN_RIGHT)
    },
    {
        ["offsetFromOrigin"] = { 136, 6 },
        ["portType"] = THREE_TO_ONE,
        ["portDir"] = P_DOWN_LEFT,
        ["image"] = getPortImage(THREE_TO_ONE, P_DOWN_LEFT)
    },
    {
        ["offsetFromOrigin"] = { -20, 46 },
        ["portType"] = ANIMALS,
        ["portDir"] = P_DOWN_RIGHT,
        ["image"] = getPortImage(ANIMALS, P_DOWN_RIGHT)
    },
    {
        ["offsetFromOrigin"] = { 182, 82 },
        ["portType"] = CLAY,
        ["portDir"] = P_LEFT,
        ["image"] = getPortImage(CLAY, P_LEFT)
    },
    {
        ["offsetFromOrigin"] = { -66, 121 },
        ["portType"] = THREE_TO_ONE,
        ["portDir"] = P_RIGHT,
        ["image"] = getPortImage(THREE_TO_ONE, P_RIGHT)
    },
    {
        ["offsetFromOrigin"] = { 182, 162 },
        ["portType"] = TREES,
        ["portDir"] = P_LEFT,
        ["image"] = getPortImage(TREES, P_LEFT)
    },
    {
        ["offsetFromOrigin"] = { -20, 200 },
        ["portType"] = ORE,
        ["portDir"] = P_UP_RIGHT,
        ["image"] = getPortImage(ORE, P_UP_RIGHT)
    },
    {
        ["offsetFromOrigin"] = { 49, 236 },
        ["portType"] = CROPS,
        ["portDir"] = P_UP_RIGHT,
        ["image"] = getPortImage(CROPS, P_UP_RIGHT)
    },
    {
        ["offsetFromOrigin"] = { 135, 236 },
        ["portType"] = THREE_TO_ONE,
        ["portDir"] = P_UP_LEFT,
        ["image"] = getPortImage(THREE_TO_ONE, P_UP_LEFT)
    }
}

local function newHexPos(r, c)
    return {
        ["row"] = r,
        ["col"] = c
    }
end

local function doesHexHaveNumber(r, c, hexes)
    if hexes == nil then
        print("no hexes provided")
        return nil
    end
    if hexes[r] == nil then
        print("invalid row")
        return nil
    end
    if hexes[r][c] == nil then
        print("invalid col")
        return nil
    end

    return hexes[r][c]["number"] ~= nil
end

local function isDesert(r, c, hexes)
    if hexes == nil then
        print("no hexes provided")
        return nil
    end
    if hexes[r] == nil then
        print("invalid row: ", r, ", ", c)
        return nil
    end
    if hexes[r][c] == nil then
        print("invalid col: ", r, ", ", c)
        return nil
    end
    return hexes[r][c]["type"] == 6
end

local firstChoiceLookup = {
    {
        { 2, 1 },
        { 1, 1 },
        { 1, 2 },
    },
    {
        { 3, 1 },
        { 3, 2 },
        { 2, 2 },
        { 1, 3 }
    },
    {
        { 4, 1 },
        { 4, 2 },
        { 3, 3 }, -- center goes to center? i guess?
        { 2, 3 },
        { 2, 4 }
    },
    {
        { 5, 1 },
        { 4, 3 },
        { 3, 4 },
        { 3, 5 }
    },
    {
        { 5, 2 },
        { 5, 3 },
        { 4, 4 },
    }
}
-- basically just rotated 60 deg or so
local secondChoiceLookup = {
    {
        { 2, 2 },
        { 2, 2 },
        { 2, 3 },
    },
    {
        { 3, 2 },
        { 3, 3 },
        { 3, 3 },
        { 2, 3 }
    },
    {
        { 3, 2 },
        { 3, 3 },
        { 3, 3 },
        { 3, 3 },
        { 3, 4 }
    },
    {
        { 4, 2 },
        { 3, 3 },
        { 3, 3 },
        { 3, 4 }
    },
    {
        { 4, 2 },
        { 4, 3 },
        { 4, 3 },
    }
}

local function getNextPosition(currentPos, hexes)
    -- go to next posiition counterclockwise spiral way, or return nil
    local currRow = currentPos["row"]
    local currCol = currentPos["col"]
    local spotChoice = firstChoiceLookup[currRow][currCol]
    -- check if it's occupied
    if isDesert(spotChoice[1], spotChoice[2], hexes) then
        -- get next one
        return getNextPosition(newHexPos(spotChoice[1], spotChoice[2]), hexes)
    elseif doesHexHaveNumber(spotChoice[1], spotChoice[2], hexes) then
        -- first choice not available, get next choice
        spotChoice = secondChoiceLookup[currRow][currCol]
        -- check if it's occupied
        if isDesert(spotChoice[1], spotChoice[2], hexes) then
            -- get next one
            return getNextPosition(newHexPos(spotChoice[1], spotChoice[2]), hexes)
        elseif doesHexHaveNumber(spotChoice[1], spotChoice[2], hexes) then
            -- choice not available, uhhhhhhh this shouldnt happen
            return nil
        else
            -- return choice
            return newHexPos(spotChoice[1], spotChoice[2])
        end
    else
        -- return choice
        return newHexPos(spotChoice[1], spotChoice[2])
    end
end

local numberSet = {
    5, 2, 6,
    3, 8, 10,
    9, 12, 11,
    4, 8, 10,
    9, 4, 5,
    6, 3, 11
} -- note: ordered
local function generateHexes()
    -- number of tiles of each type
    local hexTypePool = {
        [TREES] = 4,
        [CROPS] = 4,
        [ANIMALS] = 4,
        [ORE] = 3,
        [CLAY] = 3,
        [NOMANS] = 1
    }
    local rowSizes = { 3, 4, 5, 4, 3 }
    local hexes = {}
    for rowIndex, rowSize in pairs(rowSizes) do
        hexes[rowIndex] = {}
        for col = 1, rowSize do
            -- get hex type with retry if empty already
            local randHexType = math.random(#hexTypePool)
            if hexTypePool[randHexType] == 0 then
                while hexTypePool[randHexType] == 0 do
                    randHexType = math.random(#hexTypePool)
                end
            end
            -- add to main hexes output
            hexes[rowIndex][col] = { ["type"] = randHexType }
            if randHexType == NOMANS then
                -- generate the image for the desert, we don't need to know it's number so we can do that now
                hexes[rowIndex][col]["image"] = getHexImage(hexHeight, NOMANS)
            end
            -- decremnt value in pool
            hexTypePool[randHexType] = hexTypePool[randHexType] - 1
        end
    end
    -- can start in any of the corners
    local startingPostitions = {
        {
            ["row"] = 1,
            ["col"] = 1,
        },
        {
            ["row"] = 1,
            ["col"] = 3,
        },
        {
            ["row"] = 3,
            ["col"] = 1,
        },
        {
            ["row"] = 3,
            ["col"] = 5,
        },
        {
            ["row"] = 5,
            ["col"] = 1,
        },
        {
            ["row"] = 5,
            ["col"] = 3,
        },
    }
    local currentPos = startingPostitions[math.random(#startingPostitions)]
    local numberOfNumAssigned = 0
    local numbersToAssign = #numberSet
    while numberOfNumAssigned < numbersToAssign do
        -- check if it's a desert, if not, give it a number and iterate
        if hexes[currentPos["row"]][currentPos["col"]]["type"] ~= NOMANS then
            local numIndex = numberOfNumAssigned + 1
            hexes[currentPos["row"]][currentPos["col"]]["number"] = numberSet[numIndex]
            numberOfNumAssigned = numberOfNumAssigned + 1
        end
        -- save image of hex
        hexes[currentPos["row"]][currentPos["col"]]["image"] = getHexImage(
            hexHeight,
            hexes[currentPos["row"]][currentPos["col"]]["type"],
            hexes[currentPos["row"]][currentPos["col"]]["number"]
        )
        if numberOfNumAssigned < numbersToAssign then
            -- iterate current pos
            local newPos = getNextPosition(currentPos, hexes)
            if newPos ~= nil then
                currentPos = newPos
            end
        end
    end
    return hexes
end

local currentHexes = generateHexes()

local indicatorX = 220
local indicatorY = 100
local targetIndicatorX = indicatorX
local targetIndicatorY = indicatorY
local slowdownRadius = 10
local indicatorSpeed = 2

local velX = 0
local velY = 0

local indicatorRow = 5
local indicatorCol = 3
-- local indicatorSpotType = "hex_vertices"
local indicatorRadius = 10
local indicatorRowMax = 12
local indicatorColMax = 5

local hexVerticeCounts = {
    3, 4, 4, 5, 5, 6, 6, 5, 5, 4, 4, 3
}
local function drawIndicator()
    local bumpRad = (math.sin(pd.getCurrentTimeMilliseconds() * 0.005) + 1) * 0.5 * (indicatorRadius / 4);
    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(7)
    gfx.drawCircleAtPoint(indicatorX, indicatorY, indicatorRadius + bumpRad)
    gfx.setLineWidth(6)
    gfx.drawCircleAtPoint(indicatorX, indicatorY, bumpRad)

    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawCircleAtPoint(indicatorX, indicatorY, indicatorRadius + bumpRad)
    gfx.fillCircleAtPoint(indicatorX, indicatorY, bumpRad)
end

local verticeRowOffsetAmount = {
    0, 1, 1, 2, 2, 3, 3, 2, 2, 1, 1, 0
}

local function getXYFromRowCol()
    local hexagonSide = hexHeight / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (hexHeight - hexagonSide) / 2
    local x = originX + (hexWidth * indicatorCol) - (verticeRowOffsetAmount[indicatorRow] * hexWidth / 2)
    local y = originY + hexagonSide + vertCornerOffset
    if indicatorRow > 1 then
        local counter = 1
        while counter < indicatorRow do
            if counter % 2 == 0 then
                y = y + hexagonSide
            else
                y = y + vertCornerOffset
            end
            counter = counter + 1
        end
    end
    return { x, y }
end

local function updateIndicatorPos()
    local rowChanged = false
    if pd.buttonJustReleased(pd.kButtonUp) and indicatorRow > 1 then
        indicatorRow = indicatorRow - 1
        rowChanged = true
    end

    if pd.buttonJustReleased(pd.kButtonDown) and indicatorRow < indicatorRowMax then
        indicatorRow = indicatorRow + 1
        rowChanged = true
    end
    if rowChanged then
        --update max for cols based on current row
        indicatorColMax = hexVerticeCounts[indicatorRow]
        if indicatorCol > indicatorColMax then
            indicatorCol = indicatorColMax
        end
    end
    if pd.buttonJustReleased(pd.kButtonLeft) and indicatorCol > 1 then
        indicatorCol = indicatorCol - 1
    end

    if pd.buttonJustReleased(pd.kButtonRight) and indicatorCol < indicatorColMax then
        indicatorCol = indicatorCol + 1
    end
    local targetCoords = getXYFromRowCol()
    if targetIndicatorX ~= targetCoords[1] then
        targetIndicatorX = targetCoords[1]
    end
    if targetIndicatorY ~= targetCoords[2] then
        targetIndicatorY = targetCoords[2]
    end
    -- get diff between target and current location
    local diffX = targetIndicatorX - indicatorX
    local diffY = targetIndicatorY - indicatorY
    local diffTotal = math.sqrt(diffX * diffX + diffY * diffY)
    -- update velocity
    velX = velX + (diffX / diffTotal) * indicatorSpeed
    velY = velY + (diffY / diffTotal) * indicatorSpeed
    if diffTotal < slowdownRadius then
        local slowdown = math.max(diffTotal / slowdownRadius, 0.5)
        velX = velX * slowdown
        velY = velY * slowdown
    end
    if math.abs(diffX) > 1 then
        indicatorX = indicatorX + velX
    end
    if math.abs(diffY) > 1 then
        indicatorY =indicatorY + velY
    end
end

local p1Color = 1
local p2Color = 2
local p3Color = 3
local p4Color = 4

local NO_FILL = 1
local TWO_BY_ONE_FILL = 2
local BLACK_FILL = 3
local OTHER_FILL = 4

local function drawSettlementImage(settlementWidth, settlementHeight, fillType)
    local output = gfx.image.new(settlementWidth, settlementHeight)
    gfx.pushContext(output)
    if fillType == NO_FILL then
        gfx.setColor(gfx.kColorWhite)
    elseif fillType == BLACK_FILL then
        gfx.setColor(gfx.kColorBlack)
    elseif fillType == TWO_BY_ONE_FILL then
        gfx.setPattern({ 0x87, 0x78, 0x78, 0x78, 0x78, 0x87, 0x87, 0x87 })
    elseif fillType == OTHER_FILL then
        gfx.setPattern({ 0x3c, 0x1e, 0x0f, 0x87, 0xc3, 0xe1, 0xf0, 0x78 })
    end
    local offset = 2
    gfx.fillPolygon(
        offset, offset,
        settlementWidth - offset, offset,
        settlementWidth - offset, settlementHeight - offset,
        offset, settlementHeight - offset,
        offset, offset
    )
    gfx.setColor(gfx.kColorWhite)

    gfx.setLineWidth(5)
    offset = -1

    gfx.drawPolygon(
        offset, offset,
        settlementWidth - offset, offset,
        settlementWidth - offset, settlementHeight - offset,
        offset, settlementHeight - offset,
        offset, offset
    )

    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    offset = 2
    gfx.drawPolygon(
        offset, offset,
        settlementWidth - offset, offset,
        settlementWidth - offset, settlementHeight - offset,
        offset, settlementHeight - offset,
        offset, offset
    )
    gfx.popContext()
    return output
end

local ROAD_DIR_VERT = 1
local ROAD_DIR_UPRIGHT = 2
local ROAD_DIR_UPLEFT = 3
local ROAD_DIR_HORIZ = 4
local roadWidth = 6
local roadLength = 16
local function getRoadImage(direction, fillType)
    local output = gfx.image.new(roadLength, roadLength)
    if fillType == NO_FILL then
        gfx.setColor(gfx.kColorWhite)
    elseif fillType == BLACK_FILL then
        gfx.setColor(gfx.kColorBlack)
    elseif fillType == TWO_BY_ONE_FILL then
        gfx.setPattern({ 0x87, 0x78, 0x78, 0x78, 0x78, 0x87, 0x87, 0x87 })
    elseif fillType == OTHER_FILL then
        gfx.setPattern({ 0x3c, 0x1e, 0x0f, 0x87, 0xc3, 0xe1, 0xf0, 0x78 })
    end
    gfx.pushContext(output)
    if direction == ROAD_DIR_VERT then

        gfx.fillPolygon(
            roadLength / 2 - roadWidth / 2, 0,
            roadLength / 2 + roadWidth / 2, 0,
            roadLength / 2 + roadWidth / 2, roadLength,
            roadLength / 2 - roadWidth / 2, roadLength,
            roadLength / 2 - roadWidth / 2, 0
        )
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(4)
        gfx.drawPolygon(
            roadLength / 2 - roadWidth / 2 + 2, 2,
            roadLength / 2 + roadWidth / 2 -2, 2,
            roadLength / 2 + roadWidth / 2 - 2, roadLength -2,
            roadLength / 2 - roadWidth / 2 + 2, roadLength -2,
            roadLength / 2 - roadWidth / 2 + 2, 2 
        )
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(2)
        gfx.drawPolygon(
            roadLength / 2 - roadWidth / 2, 0,
            roadLength / 2 + roadWidth / 2, 0,
            roadLength / 2 + roadWidth / 2, roadLength,
            roadLength / 2 - roadWidth / 2, roadLength,
            roadLength / 2 - roadWidth / 2, 0
        )
    elseif direction == ROAD_DIR_UPRIGHT then

    end
    gfx.popContext()
    return output
end

local allColors = { NO_FILL, TWO_BY_ONE_FILL, BLACK_FILL, OTHER_FILL }
local villages = {}

local function getPlayerStatusBarImage(playerName)
    local mainColor = gfx.kColorBlack
    local subColor = gfx.kColorWhite
    local playerStatusBarImage = gfx.image.new(123, 18)
    gfx.pushContext(playerStatusBarImage)
    local leftSideBuffer = 0
    -- player box
    gfx.setColor(subColor)
    gfx.fillRoundRect(
        0, 0, 123, 18, 4
    )
    -- player name
    gfx.setFont(numFont)
    gfx.drawTextAligned(playerName, 5, 5, gfx.kAlignLeft)
    leftSideBuffer = leftSideBuffer + 32
    -- num special cards
    gfx.setColor(mainColor)
    gfx.fillRoundRect(leftSideBuffer + 12, 3, 8, 11, 1)
    gfx.setLineWidth(1)
    gfx.setColor(subColor)
    gfx.drawRect(leftSideBuffer + 13, 4, 6, 9)
    gfx.drawTextAligned("0", leftSideBuffer + 24, 5, gfx.kAlignLeft)
    leftSideBuffer = leftSideBuffer + 46
    -- num resources
    gfx.setColor(mainColor)
    gfx.setLineWidth(1)
    gfx.drawRect(leftSideBuffer - 1, 3, 6, 6)
    gfx.drawRect(leftSideBuffer + 2, 8, 6, 6)
    gfx.drawRect(leftSideBuffer - 3, 8, 6, 6)
    gfx.drawTextAligned("0", leftSideBuffer + 12, 5, gfx.kAlignLeft)
    leftSideBuffer = leftSideBuffer + 6
    -- vps
    local vpCount = "0"
    local vpCountWidth = gfx.getTextSize(vpCount)
    gfx.fillCircleAtPoint(leftSideBuffer + 27, 9, 7)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) --  set this to draw white on black text
    gfx.drawTextAligned("0", leftSideBuffer + 27 - vpCountWidth / 2, 5, gfx.kAlignCenter)

    gfx.setImageDrawMode(gfx.kDrawModeCopy) -- this the default fyi
    gfx.popContext()
    return playerStatusBarImage
end

local player1BarImage = getPlayerStatusBarImage("SAM")
local player2BarImage = getPlayerStatusBarImage("JOE")
local player3BarImage = getPlayerStatusBarImage("STVN")
local player4BarImage = getPlayerStatusBarImage("KAI")

local function drawUI()
    player1BarImage:drawAnchored(5, 5, 0.0, 0.0)
    player2BarImage:drawAnchored(5, 25, 0.0, 0.0)
    player3BarImage:drawAnchored(5, 45, 0.0, 0.0)
    player4BarImage:drawAnchored(5, 65, 0.0, 0.0)
    -- TODO: animate movement of this bar as turn transitions
    -- (+20 to y per player)
    gfx.setColor(gfx.kColorXOR)
    gfx.fillRoundRect(5, 5, 123, 18, 4)
end

local roadImage = getRoadImage(ROAD_DIR_VERT, NO_FILL)

-- playdate.update function is required in every project!
function playdate.update()
    -- Clear screen
    gfx.clear()

    -- draw ports
    for key, port in pairs(ports) do
        port["image"]:drawAnchored(originX + port["offsetFromOrigin"][1], originY + port["offsetFromOrigin"][2], 0.0, 0.0)
    end

    -- draw hexes and numbers
    local hexagonSide = hexHeight / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (hexHeight - hexagonSide) / 2
    for row, hexesTable in pairs(currentHexes) do
        for col, hex in pairs(hexesTable) do
            local number = hex["number"]
            if number == nil then
                number = 99
            end
            local newHex = hex["image"]
            local x = originX + (hexWidth * col) - (hexWidth / 2)
            if row % 2 == 0 then
                x = x - hexWidth / 2
            end
            if #hexesTable > 4 then
                x = x - hexWidth
            end
            local y = originY + row * (hexHeight - vertCornerOffset)
            newHex:drawAnchored(x, y, 0.0, 0.0)
        end
    end

    for villageIdx, village in pairs(villages) do
        village["image"]:drawAnchored(village["x"], village["y"], 0.5, 0.5)
    end

    -- draw ui
    drawUI()


    -- regenerate tiles
    if pd.buttonJustPressed(pd.kButtonB) then
        currentHexes = generateHexes()
    end

    -- place random village
    if pd.buttonJustPressed(pd.kButtonA) then
        local xy = getXYFromRowCol()
        local randColor = allColors[math.random(#allColors)]
        villages[#villages + 1] = {
            ["x"] = xy[1],
            ["y"] = xy[2],
            ["image"] = drawSettlementImage(14, 14, randColor)
        }
    end

    roadImage:drawAnchored(100, 100, 0.0, 0.0)

    drawIndicator()
    updateIndicatorPos()
end
