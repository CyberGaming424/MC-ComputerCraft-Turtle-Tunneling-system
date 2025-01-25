local maxTravelDistance = 50
local distanceTraveled = 0
local miningDepth = 50
local currentHeading = ""
local homeCord = vector.new(0, 0, 0)
local homeHeading = ""
local currentCord = vector.new(0, 0, 0)

-- Ores to mine
local ores = {
    "minecraft:coal_ore",
    "minecraft:iron_ore",
    "minecraft:gold_ore",
    "minecraft:redstone_ore",
    "minecraft:diamond_ore",
    "minecraft:emerald_ore",
    "minecraft:lapis_ore",
    "thermal:sulfur_ore",
    "thermal:silver_ore",
    "mekanism:osmium_ore",
    "mekanism:deepslate_osmium_ore",
    "mekanism:uranium_ore",
    "mekanism:deepslate_uranium_ore",
    "thermal:deepslate_silver_ore",
    "thermal:deepslate_sulfur_ore",
    "thermal:deepslate_redstone_ore",
    "thermal:deepslate_diamond_ore",
    "thermal:deepslate_emerald_ore",
    "thermal:deepslate_lapis_ore",
    "thermal:deepslate_coal_ore",
    "thermal:deepslate_iron_ore",
    "thermal:deepslate_gold_ore",
}

-- Location of ores discoverd by the turtle
local oreLocations = {}

-- Validates the block data
local function CheckOre(block_data)
    if (block_data["name"] ~= nil) then
        for i, ore in ipairs(ores) do
            if (block_data["name"] == ore) then
                return true
            end
        end
        return false
    else
        return false
    end
end

-- Gets the coordinates of the ores via the turtle
local function getOreLocation(location)
    if location == 1 then
        return vector.new(currentCord.x, currentCord.y + 1, currentCord.z)
    elseif location == 2 then
        return vector.new(currentCord.x, currentCord.y - 1, currentCord.z)
    elseif location == 3 then
        if currentHeading == "north" then
            return vector.new(currentCord.x, currentCord.y, currentCord.z + 1)
        elseif currentHeading == "south" then
            return vector.new(currentCord.x, currentCord.y, currentCord.z - 1)
        elseif currentHeading == "east" then
            return vector.new(currentCord.x + 1, currentCord.y, currentCord.z)
        elseif currentHeading == "west" then
            return vector.new(currentCord.x - 1, currentCord.y, currentCord.z)
        end
    elseif location == 4 then
        if currentHeading == "north" then
            return vector.new(currentCord.x - 1, currentCord.y, currentCord.z)
        elseif currentHeading == "south" then
            return vector.new(currentCord.x + 1, currentCord.y, currentCord.z)
        elseif currentHeading == "east" then
            return vector.new(currentCord.x, currentCord.y, currentCord.z - 1)
        elseif currentHeading == "west" then
            return vector.new(currentCord.x, currentCord.y, currentCord.z + 1)
        end
    elseif location == 5 then
        if currentHeading == "north" then
            return vector.new(currentCord.x + 1, currentCord.y, currentCord.z)
        elseif currentHeading == "south" then
            return vector.new(currentCord.x - 1, currentCord.y, currentCord.z)
        elseif currentHeading == "east" then
            return vector.new(currentCord.x, currentCord.y, currentCord.z + 1)
        elseif currentHeading == "west" then
            return vector.new(currentCord.x, currentCord.y, currentCord.z - 1)
        end
    end
end

-- Adds the ore location to the oreLocations table
local function addOreLocation(checkedLocations)
    local isNewOre = false
    for i, location in ipairs(checkedLocations) do
        if location == true then
            oreVector = getOreLocation(i)
            for i, oreLocation in ipairs(oreLocations) do
                if oreLocation == oreVector then
                    isNewOre = false
                else
                    isNewOre = true
                end
            end
            if isNewOre == true then
                table.insert(oreLocations, oreVector)
            end
        end
    end
end

-- Checks the surrounding blocks for ores
local function checkSurrounding()
    local has_block, data = turtle.inspectUp()
    local up_block_ore = CheckOre(data)
    local has_block, data = turtle.inspectDown()
    local down_block_ore = CheckOre(data)
    local has_block, data = turtle.inspect()
    local forward_block_ore = CheckOre(data)
    turtle.turnLeft()
    local has_block, data = turtle.inspect()
    local left_block_ore = CheckOre(data)
    turtle.turnRight()
    turtle.turnRight()
    local has_block, data = turtle.inspect()
    local right_block_ore = CheckOre(data)
    turtle.turnLeft()
    return { up_block_ore, down_block_ore, forward_block_ore, left_block_ore, right_block_ore }
end

-- Checks if the coordinate is valid
local function cooridateIsValid(value)
    if tonumber(value) == nil then
        return false
    else
        return true
    end
end

-- Valid directions are north, east, south, west
local function directionIsValid(value)
    if value == "north" or value == "east" or value == "west" or value == "south" then
        return true
    else
        return false
    end
end

-- Updates the current Heading
local function updateHeading(rotation)
    if currentHeading == "north" then
        if rotation == "left" then
            currentHeading = "west"
        elseif rotation == "right" then
            currentHeading = "east"
        end
    elseif currentHeading == "east" then
        if rotation == "left" then
            currentHeading = "north"
        elseif rotation == "right" then
            currentHeading = "south"
        end
    elseif currentHeading == "south" then
        if rotation == "left" then
            currentHeading = "east"
        elseif rotation == "right" then
            currentHeading = "west"
        end
    elseif currentHeading == "west" then
        if rotation == "left" then
            currentHeading = "south"
        elseif rotation == "right" then
            currentHeading = "north"
        end
    end
end

local function updateHeading(rotation)
    local directions = { "north", "east", "south", "west" }
    local index = 0

    -- Find current direction's index
    for i, direction in ipairs(directions) do
        if currentHeading == direction then
            index = i
            break
        end
    end

    if rotation == "left" then
        index = (index - 2) % 4 + 1
    elseif rotation == "right" then
        index = index % 4 + 1
    end

    currentHeading = directions[index]
end

local function removedMinedOres()
    for i, oreLocation in ipairs(oreLocations) do
        if oreLocation == currentCord then
            table.remove(oreLocations, i)
        end
    end
end

-- Recursively mines the ores
local function recursiveOreMine()
    local surrounding = checkSurrounding()
    addOreLocation(surrounding)
    if surrounding[1] == true then
        turtle.digUp()
        turtle.up()
        currentCord.y = currentCord.y + 1
        distanceTraveled = distanceTraveled + 1
        removedMinedOres()
        recursiveOreMine()
    elseif surrounding[2] == true then
        turtle.digDown()
        turtle.down()
        distanceTraveled = distanceTraveled + 1
        currentCord.y = currentCord.y - 1
        removedMinedOres()
        recursiveOreMine()
    elseif surrounding[3] == true then
        turtle.dig()
        turtle.forward()
        updatePosition()
        distanceTraveled = distanceTraveled + 1
        removedMinedOres()
        recursiveOreMine()
    elseif surrounding[4] == true then
        turtle.turnLeft()
        updateHeading("left")
        turtle.dig()
        turtle.forward()
        updatePosition()
        distanceTraveled = distanceTraveled + 1
        removedMinedOres()
        recursiveOreMine()
    elseif surrounding[5] == true then
        turtle.turnRight()
        updateHeading("right")
        turtle.dig()
        turtle.forward()
        updatePosition()
        distanceTraveled = distanceTraveled + 1
        removedMinedOres()
        recursiveOreMine()
    end
end

local function heuristic(pos, goal)
    -- Simple Manhattan distance for the grid
    return math.abs(pos.x - goal.x) + math.abs(pos.y - goal.y) + math.abs(pos.z - goal.z)
end

local function pathfinding(goalCord)
    local openSet = {}
    local closedSet = {}
    local cameFrom = {}

    local function isVectorEqual(a, b)
        return a.x == b.x and a.y == b.y and a.z == b.z
    end

    local startNode = { position = currentCord, g = 0, h = heuristic(currentCord, goalCord) }
    startNode.f = startNode.g + startNode.h
    table.insert(openSet, startNode)

    while #openSet > 0 do
        -- Sort openSet to get the node with the lowest f score (A*-like)
        table.sort(openSet, function(a, b) return a.f < b.f end)
        local currentNode = table.remove(openSet, 1)

        if isVectorEqual(currentNode.position, goalCord) then
            -- Reconstruct path
            local path = {}
            while currentNode do
                table.insert(path, 1, currentNode.position)
                currentNode = cameFrom[currentNode]
            end
            return path
        end

        table.insert(closedSet, currentNode.position)

        local neighbors = {
            vector.new(currentNode.position.x + 1, currentNode.position.y, currentNode.position.z),
            vector.new(currentNode.position.x - 1, currentNode.position.y, currentNode.position.z),
            vector.new(currentNode.position.x, currentNode.position.y + 1, currentNode.position.z),
            vector.new(currentNode.position.x, currentNode.position.y - 1, currentNode.position.z),
            vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z + 1),
            vector.new(currentNode.position.x, currentNode.position.y, currentNode.position.z - 1),
        }

        for _, neighbor in ipairs(neighbors) do
            -- Skip invalid positions and positions already in closedSet
            if not containsVector(closedSet, neighbor) and isPositionValid(neighbor) then
                local tentative_g = currentNode.g + 1

                local neighborNode = {
                    position = neighbor,
                    g = tentative_g,
                    h = heuristic(neighbor, goalCord),
                }
                neighborNode.f = neighborNode.g + neighborNode.h

                -- Check if neighbor is already in openSet with a lower f score
                local inOpenSet = false
                for _, openNode in ipairs(openSet) do
                    if isVectorEqual(openNode.position, neighbor) and tentative_g >= openNode.g then
                        inOpenSet = true
                        break
                    end
                end

                if not inOpenSet then
                    table.insert(openSet, neighborNode)
                    cameFrom[neighborNode] = currentNode
                end
            end
        end
    end
    return nil -- No path found
end

-- Helper function to check if a vector is in a table
function containsVector(tbl, vec)
    for _, v in ipairs(tbl) do
        if vec.x == v.x and vec.y == v.y and vec.z == v.z then
            return true
        end
    end
    return false
end

-- Placeholder function to determine if a given position is valid
function isPositionValid(pos)
    -- Check boundaries and other conditions
    -- For now, assume all positions are valid for simplicity
    return true
end

-- Commands the turtle to rotate to a specific heading
local function rotateToHeading(targetHeading)
    while currentHeading ~= targetHeading do
        turtle.turnRight()
        updateHeading("right")
    end
end

-- Moves the turtle to a specific coordinate using the path
local function navigatePath(path)
    for i = 2, #path do
        local previous = path[i - 1]
        local current = path[i]

        if current.x > previous.x then
            rotateToHeading("east")
        elseif current.x < previous.x then
            rotateToHeading("west")
        elseif current.z > previous.z then
            rotateToHeading("south")
        elseif current.z < previous.z then
            rotateToHeading("north")
        end

        if current.y > previous.y then
            turtle.up()
        elseif current.y < previous.y then
            turtle.down()
        else
            turtle.forward()
        end

        currentCord = vector.new(current.x, current.y, current.z)
    end
end

-- Finishes mining any of the ores that were missed
function clearMissedOres()
    for _, oreLocation in ipairs(oreLocations) do
        local path = pathfinding(oreLocation)
        if path then
            navigatePath(path)
            -- Assume this then initiates mining at the target location
            turtle.dig()
            removedMinedOres()
        end
    end
end

-- Travels the turtle out to the max travel distance, while mining, if the turtle reaches the mining depth it will return to the home position
local function travel()
    if distanceTraveled < maxTravelDistance then
        if currentCord.y > miningDepth then
            turtle.digDown()
            turtle.down()
            currentCord.y = currentCord.y - 1
            print("Traveled to " .. currentCord.y)
            return true
        else
            recursiveOreMine()
            clearMissedOres()
            turtle.dig()
            turtle.forward()
            updatePosition()
            distanceTraveled = distanceTraveled + 1
            return false
        end
    else
        Homing()
        return false
    end
end

-- Brings the turtle to the home position
function Homing()
    -- TODO: Add homing routine
end

local function locationSetup()
    if gps.locate() == nil then
        write("What is my current x position? ")
        homeCord.x = read()
        if cooridateIsValid(homeCord.x) then
            homeCord.x = tonumber(homeCord.x)
            currentCord.x = homeCord.x
        else
            print("Invalid input")
            return
        end
        write("What is my current y position? ")
        homeCord.y = read()
        if cooridateIsValid(homeCord.y) then
            homeCord.y = tonumber(homeCord.y)
            currentCord.y = homeCord.y
        else
            print("Invalid input")
            return
        end
        write("What is my current z position? ")
        homeCord.z = read()
        if cooridateIsValid(homeCord.z) then
            homeCord.z = tonumber(homeCord.z)
            currentCord.z = homeCord.z
        else
            print("Invalid input")
            return
        end
    else
        local x, y, z = gps.locate()
        homeCord.x = x
        homeCord.y = y
        homeCord.z = z
        currentCord.x = x
        currentCord.y = y
        currentCord.z = z
    end

    write("What direction am I facing? ")
    homeHeading = string.lower(read())
    if directionIsValid(homeHeading) ~= true then
        print("Invalid input")
        return
    end
    currentHeading = homeHeading
end

locationSetup()

-- Test of pathfinding
local path = pathfinding(vector.new(-79, 62, -46))
navigatePath(path)

--while travel() == true do
--end
