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
        -- plant???
        gfx.setPattern({ 0xad, 0x8e, 0x3f, 0x1f, 0xbb, 0xf1, 0x7b, 0x2f })
    end
    if hexType == 2 then
        -- stripe grass
        gfx.setPattern({ 0xdf, 0x75, 0xee, 0xbf, 0xeb, 0x75, 0xfe, 0xab })
    end
    if hexType == 3 then
        -- dots
        gfx.setPattern({ 0xfd, 0xdf, 0xf7, 0x7f, 0xfd, 0xdf, 0xf7, 0x7f })
    end
    if hexType == 4 then
        --flower
        gfx.setPattern { 0x5a, 0xdb, 0x3c, 0xe7, 0xe7, 0x3c, 0xdb, 0x5a }
    end
    if hexType == 5 then
        --brick
        gfx.setPattern { 0x3f, 0x9f, 0xcf, 0xc7, 0x93, 0x39, 0x7c, 0x7e }
    end
    if hexType == 6 then
        --mesh
        gfx.setPattern { 0x3b, 0xb5, 0x67, 0x6b, 0xcc, 0xb2, 0xad, 0x4b }
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
        gfx.fillRect(hexWidth * 1 / 2 - textWidth / 2 - 2, height * 9 / 24, textWidth + 4, height / 6)
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

local TREES = 1
local CROPS = 2
local ANIMALS = 3
local ORE = 4
local CLAY = 5
local NOMANS = 6

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
    return hexes[r][c]["type"] == 6
end

local function getNextPosition(currentPos, hexes)
    -- go to next posiition counterclockwise spiral way, or return nil
    local currRow = currentPos["row"]
    local currCol = currentPos["col"]
    -- if we're above the middle we go 'left'
    if currRow <= 3 then
        -- check if we're at the edge
        if currCol == 1 then
            -- check next 'first' and see if empty
            if doesHexHaveNumber(currRow + 1, 1, hexes) then
                -- check next hex on row
                if doesHexHaveNumber(currRow + 1, 2, hexes) then
                    -- use center? I think this should only happen on row 3
                    print("wow this never happens i swear what row is thia?    ", currRow + 1)
                    return newHexPos(currRow + 1, 3)
                else
                    return newHexPos(currRow + 1, 2)
                end
            else
                -- use that one
                return newHexPos(currRow + 1, 1)
            end
        else
            -- if on the far edge, go up
            if (currCol == #(hexes[currRow]) or doesHexHaveNumber(currRow, currCol + 1, hexes) or isDesert(currRow, currCol + 1, hexes)) and currRow > 1 then
                if doesHexHaveNumber(currRow - 1, #(hexes[currRow - 1]), hexes) then
                    if doesHexHaveNumber(currRow - 1, #(hexes[currRow - 1]) - 1, hexes) then
                        if not doesHexHaveNumber(currRow - 1, #(hexes[currRow - 1]) - 2, hexes) then
                            return newHexPos(currRow - 1, #(hexes[currRow - 1]) - 2)
                        end
                        -- no else
                    else
                        return newHexPos(currRow - 1, #(hexes[currRow - 1]) - 1)
                    end
                else
                    return newHexPos(currRow - 1, #(hexes[currRow - 1]))
                end
            end
            -- not on the edge huh? lets go one left, ot go down if thats full
            if doesHexHaveNumber(currRow, currCol - 1, hexes) then
                -- uh lets go check down one, but offset
                if doesHexHaveNumber(currRow + 1, currCol, hexes) or isDesert(currRow + 1, currCol, hexes) then
                    -- bruh how


                    if doesHexHaveNumber(currRow + 1, currCol + 1, hexes) or isDesert(currRow + 1, currCol + 1, hexes) then
                        print("return center, trust me bro")
                        return newHexPos(3, 3)
                    else
                        return newHexPos(currRow + 1, currCol + 1)
                    end
                else
                    -- ok cool going down one
                    return newHexPos(currRow + 1, currCol)
                end
            else
                -- use that one to the left
                return newHexPos(currRow, currCol - 1)
            end
        end
    else
        -- we in the lower half, so do basically the saem stuff but the other way
        -- (no sam don't just copy the code and edit ti hey wait)
        -- check if we're at the edge
        if currCol == #(hexes[currRow]) then
            -- check next 'end' and see if empty
            if doesHexHaveNumber(currRow - 1, #(hexes[currRow - 1]), hexes) then
                -- check next hex on row
                if doesHexHaveNumber(currRow - 1, #(hexes[currRow - 1]) - 1, hexes) or isDesert(currRow - 1, #(hexes[currRow - 1]) - 1, hexes) then
                    -- use center? I think this should only happen on row 3
                    print("wow this never happens i swear what row is thia?    ", currRow + 1)
                    return newHexPos(3, 3)
                else
                    return newHexPos(currRow - 1, #(hexes[currRow - 1]) - 1)
                end
            else
                -- use that one
                return newHexPos(currRow - 1, #(hexes[currRow - 1]))
            end
        else
            -- check if on close edge and room to go
            if currCol == 1 and currRow + 1 < 6 then
                if doesHexHaveNumber(currRow + 1, 1, hexes) or isDesert(currRow + 1, 1, hexes) then
                    if doesHexHaveNumber(currRow + 1, 2, hexes) or isDesert(currRow + 1, 2, hexes) then
                        if not (doesHexHaveNumber(currRow + 1, 3, hexes) or isDesert(currRow + 1, 3, hexes)) then
                            return newHexPos(currRow + 1, 3)
                        end
                        -- no else clause here, logic below will handle it
                    else
                        return newHexPos(currRow + 1, 2)
                    end
                else
                    return newHexPos(currRow + 1, 1)
                end
            end

            -- not on the edge huh? lets go one right, or go up if thats full
            if doesHexHaveNumber(currRow, currCol + 1, hexes) then
                -- uh lets go check up one, but offset
                if doesHexHaveNumber(currRow - 1, currCol + 1, hexes) then
                    -- bruh how
                    print("return center, trust for sho")
                    return newHexPos(3, 3)
                else
                    -- ok cool going down one
                    return newHexPos(currRow - 1, currCol + 1)
                end
            else
                -- use that one to the right
                return newHexPos(currRow, currCol + 1)
            end
        end
    end
end

-- local numberSet = {
--     5, 2, 6,
--     3, 8, 10,
--     9, 12, 11,
--     4, 8, 10,
--     9, 4, 5,
--     6, 3, 11
-- } -- note: ordered
local numberSet = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }
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
    local loopCount = 0
    while numberOfNumAssigned < numbersToAssign and loopCount < 1000 do
        print("posiition")
        print("r: ", currentPos["row"])
        print("c: ", currentPos["col"])
        -- check if it's a desert, if not, give it a number and iterate
        if hexes[currentPos["row"]][currentPos["col"]]["type"] ~= 6 then
            local numIndex = numberOfNumAssigned + 1
            hexes[currentPos["row"]][currentPos["col"]]["number"] = numberSet[numIndex]
            numberOfNumAssigned += 1
        end
        -- iterate current pos
        local newPos = getNextPosition(currentPos, hexes)
        local checkNewPos = doesHexHaveNumber(newPos["row"], newPos["col"], hexes)
        if checkNewPos == true then
            print("bro it gave us a bad one")
        end
        if newPos ~= nil then
            currentPos = newPos
        else
            print("oh god why is it nil")
        end
        loopCount += 1
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
