-- consume as much fuel as to make the fuel level full
-- without any redundant use of fuel item
function refuelMax()
    initSlot = turtle.getSelectedSlot()
    maxFuel = turtle.getFuelLimit()
    slot = 1
    repeat
        refuelAmount = maxFuel - turtle.getFuelLevel()
        if(turtle.refuel(1)) then
            refuelPerItem = refuelAmount - (maxFuel - turtle.getFuelLevel())
            refuelAmount = refuelAmount - refuelPerItem
            turtle.refuel(math.min(math.ceil(refuelAmount / refuelPerItem), turtle.getItemCount()))
        end
        slot = slot + 1
    until(refuelAmount <= 0 or slot == 17)
    turtle.select(initSlot)
    return
end

refuelMax()
