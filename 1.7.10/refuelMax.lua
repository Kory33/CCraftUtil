-- returns how much more fuel can be filled
function getFuelFillAmount()
    return turtle.getFuelLimit() - turtle.getFuelLevel()
end

-- consume as much fuel as to make the fuel level full
-- without any redundant use of fuel item
function refuelMax()
    local initSlot = turtle.getSelectedSlot()
    for slot = 1, 16 do
        turtle.select(slot)
        local refuelAmount = getFuelFillAmount()
        if(turtle.refuel(1)) then
            local refuelPerItem = refuelAmount - getFuelFillAmount()
            local refuelAmount = refuelAmount - refuelPerItem
            turtle.refuel(math.min(math.ceil(refuelAmount / refuelPerItem), turtle.getItemCount()))
        end
        if(getFuelFillAmount() == 0) then
            break
        end
    end
    turtle.select(initSlot)
    return
end

refuelMax()
