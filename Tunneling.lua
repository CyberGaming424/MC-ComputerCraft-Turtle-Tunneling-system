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

-- Validates the block data
function CheckOre(block_data)
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

local function updatePosition()
    if currentHeading == "north" then
        currentCord.z = currentCord.z - 1
    elseif currentHeading == "east" then
        currentCord.x = currentCord.x + 1
    elseif currentHeading == "south" then
        currentCord.z = currentCord.z + 1
    elseif currentHeading == "west" then
        currentCord.x = currentCord.x - 1
    end
end

-- Recursively mines the ores
local function recursiveOreMine()
    local surrounding = checkSurrounding()
    if surrounding[1] == true then
        turtle.digUp()
        turtle.up()
        currentCord.y = currentCord.y + 1
        distanceTraveled = distanceTraveled + 1
        recursiveOreMine()
    elseif surrounding[2] == true then
        turtle.digDown()
        turtle.down()
        distanceTraveled = distanceTraveled + 1
        currentCord.y = currentCord.y - 1
        recursiveOreMine()
    elseif surrounding[3] == true then
        turtle.dig()
        turtle.forward()
        updatePosition()
        distanceTraveled = distanceTraveled + 1
        recursiveOreMine()
    elseif surrounding[4] == true then
        turtle.turnLeft()
        updateHeading("left")
        turtle.dig()
        turtle.forward()
        updatePosition()
        distanceTraveled = distanceTraveled + 1
        recursiveOreMine()
    elseif surrounding[5] == true then
        turtle.turnRight()
        updateHeading("right")
        turtle.dig()
        turtle.forward()
        updatePosition()
        distanceTraveled = distanceTraveled + 1
        recursiveOreMine()
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
            -- To be changed
            print("Reached Mining Depth")
            return false
        end
    else
        Homing()
        return false
    end
end

-- Brings the turtle to the home position
function Homing()
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

--while travel() == true do
--end
