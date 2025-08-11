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
        gfx.setPattern({ 0x00, 0x23, 0x57, 0x26, 0x00, 0x32, 0x75, 0x62 }) -- funk blobs
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
        gfx.fillCircleAtPoint(hexWidth * 1 / 2, hexHeight * 1 / 2 - 1, 10)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawTextAligned(hexNum, hexWidth * 1 / 2 - textWidth / 2, height * 5 / 12, gfx.kAlignCenter)
    end

    gfx.popContext()
    return hexImg
end

local indicatorRadius = 10
local indicatorX = 220
local indicatorY = 100

-- TODO: make indicator snap to *all* hex vertices
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
            -- decremnt value in pool
            hexTypePool[randHexType] -= 1
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
        if hexes[currentPos["row"]][currentPos["col"]]["type"] ~= 6 then
            local numIndex = numberOfNumAssigned + 1
            hexes[currentPos["row"]][currentPos["col"]]["number"] = numberSet[numIndex]
            numberOfNumAssigned += 1
        end
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

local targetIndicatorX = indicatorX
local targetIndicatorY = indicatorY
local slowdownRadius = 10
local indicatorSpeed = 2

local velX = 0
local velY = 0

local row = 1
local col = 2

local function getXYFromRowCol()
    local hexagonSide = hexHeight / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (hexHeight - hexagonSide) / 2
    local x = originX + (hexWidth * col) - (hexWidth / 2)
    if row % 2 == 0 then
        x -= hexWidth / 2
    end
    if #currentHexes[row] > 4 then
        x -= hexWidth
    end
    local y = originY + vertCornerOffset + row * (hexHeight - vertCornerOffset)
    return { x, y }
end

local function updateIndicatorPos()
    if pd.buttonJustPressed(pd.kButtonUp) and row > 1 then
        row -= 1
    end

    if pd.buttonJustPressed(pd.kButtonDown) and row < #currentHexes then
        row += 1
    end

    if pd.buttonJustPressed(pd.kButtonLeft) and col > 1 then
        col -= 1
    end

    if pd.buttonJustPressed(pd.kButtonRight) and col < #currentHexes[row] then
        col += 1
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
    velX += (diffX / diffTotal) * indicatorSpeed
    velY += (diffY / diffTotal) * indicatorSpeed
    if diffTotal < slowdownRadius then
        local slowdown = math.max(diffTotal / slowdownRadius, 0.5)
        velX *= slowdown
        velY *= slowdown
    end
    if math.abs(diffX) > 1 then
        indicatorX += velX
    end
    if math.abs(diffY) > 1 then
        indicatorY += velY
    end
end


-- playdate.update function is required in every project!
function playdate.update()
    -- Clear screen
    gfx.clear()

    local hexagonSide = hexHeight / 2
    local hexWidth = math.sqrt(3) * hexagonSide
    local vertCornerOffset = (hexHeight - hexagonSide) / 2
    for row, hexesTable in pairs(currentHexes) do
        for col, hex in pairs(hexesTable) do
            local hexType = hex["type"]
            local number = hex["number"]
            if number == nil then
                number = 99
            end
            local newHex = getHexImage(hexHeight, hexType, number)
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

    -- regenerate tiles
    if pd.buttonJustPressed(pd.kButtonA) then
        currentHexes = generateHexes()
    end

    drawIndicator()
    updateIndicatorPos()
end
