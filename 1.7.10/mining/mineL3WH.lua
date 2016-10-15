-- the turtle is supposed to be placed at the bottom of the cuboid
-- that has to be digged.
--
-- command line usage:
-- mineL3WH <Width> <Height>
--
-- <Width> >= 0, <Height> : Integer

function mineLR()
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnLeft()
end


function mineL3WH(...)
    local args = {...}
    if #args ~= 2 then
        error("usage:\nmineL3WH <Width> <Height>")
    end
    local width = tonumber(args[1])
    local height= tonumber(args[2])
    if width == nil or height == nil then
        error("Invalid argument data")
    end
    local isDirUp = height > 0 
    width = math.floor(width)
    height= math.floor(math.abs(height) - 1)

    local isDirUp = true
    for w = 1, width do
        turtle.dig()
        turtle.forward()
        mineLR()

        for h = 1, height do
            if isDirUp then
                turtle.digUp()
                turtle.up()
            else 
                turtle.digDown()
                turtle.down()
            end
            mineLR()
        end
        isDirUp = not isDirUp
    end

    if not isDirUp then
        for h = 1, height do
            turtle.down()
        end
    end
end

mineL3WH(...)

