-- Starting from the left-near side, attempt to harvest the crops
-- Judging algorithm is based on the turtle.detect method and turtle.forward,
-- hence no obstructions(solid materials) should be placed at the same level of the crops
-- and the farm should have guard at the far and right side.

function dropAllItems(sDirUD)
    local initSlot = turtle.getSelectedSlot()
    for slot = 1, 16 do
        turtle.select(slot)
        if sDirUD == "Up" or sDirUD == "Down" then
            turtle["drop" .. sDirUD]()
        else
            turtle.drop()
        end
    end
    turtle.select(initSlot)
end


function harvestIfDetectedDown()
    if turtle.detectDown() then
        turtle.digDown()
    end
    -- attempt to replant
    return turtle.placeDown()
end


-- The turtle is expected to be at the left-near side of the farm
-- when this funciton is called
function harvestRectFarm()
    -- measure the width(near-far) of the farm 
    local width = 0
    repeat
        harvestIfDetectedDown()
        width = width + 1
    until not turtle.forward()
    turtle.turnRight()

    -- measure the length(left-right) of the farm
    local length = 0
    repeat
        harvestIfDetectedDown()
        length = length + 1
    until not turtle.forward()
    turtle.turnRight()

    -- start harvesting the rest of the farm
    local isFacingFar = false
    if width > 1 then
        turtle.forward()
        harvestIfDetectedDown()
    end

    for i = 1, length - 1 do
        for j = 1, width - 2 do
            turtle.forward()
            harvestIfDetectedDown()
        end

        -- move to the next row
        for j = 1, 2 do
            if isFacingFar then
                turtle.turnLeft()
            else 
                turtle.turnRight()
            end
            if j == 1 then 
                turtle.forward()
                harvestIfDetectedDown()
            end
        end

        isFacingFar = not isFacingFar
    end

    -- bring back the turtle to the oroginal place if not already reached
    if not isFacingFar then
        for i = 1, width - 2 do
            turtle.forward()
        end
        turtle.turnLeft()
        turtle.turnLeft()
    end
end

while true do
    turtle.up()
    turtle.forward()
    harvestRectFarm()
    turtle.back()
    turtle.down()
    dropAllItems("Down")
    sleep(600)
end
