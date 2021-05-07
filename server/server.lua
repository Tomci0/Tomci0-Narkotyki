ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('Tomci0-Narko:RequestCoords')
AddEventHandler('Tomci0-Narko:RequestCoords', function()
    TriggerClientEvent('Tomci0-Narko:FetchCoords', source, Config.Strefy, Config.Przerobki, Config.Itemy)
end)

local roslinki = {}

ESX.RegisterServerCallback('Tomci0-Narko:GetWater', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local woda = xPlayer.getInventoryItem('water')

    if woda.count >= 1 then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('Tomci0-Narko:GivePrzerobione')
AddEventHandler('Tomci0-Narko:GivePrzerobione', function(zone)
    local xPlayer = ESX.GetPlayerFromId(source)
    local vector1 = xPlayer.getCoords(true)
    local needsItems = true
    local canCarry = true
    local vector2 = vector3(Config.Przerobki[zone].Pos.x, Config.Przerobki[zone].Pos.y, Config.Przerobki[zone].Pos.z)
    local distance = #(vector1 - vector2)

    if distance < (Config.Przerobki[zone].Size + 1.0) then
        for k,v in pairs(Config.Przerobki[zone].itemsNeed) do
            local item = xPlayer.getInventoryItem(v.Name)

            if item.count < v.Count then
                needsItems = false
            end
        end

        if needsItems then
            for k,v in pairs(Config.Przerobki[zone].itemsAdd) do
                local item = xPlayer.getInventoryItem(v.Name)

                if not xPlayer.canCarryItem(v.Name, v.Count) then
                    canCarry = false
                end
            end

            if canCarry then

                for k,v in pairs(Config.Przerobki[zone].itemsNeed) do
                    xPlayer.removeInventoryItem(v.Name, v.Count)
                end

                for k,v in pairs(Config.Przerobki[zone].itemsAdd) do
                    xPlayer.addInventoryItem(v.Name, v.Count)
                end
            else
                xPlayer.showNotification('~r~Nie możesz unieść tyle przedmiotów!')
                TriggerClientEvent('Tomci0-Narko:StopTransform', source)
            end
        else
            xPlayer.showNotification('~r~Nie posiadasz wymaganych przedmiotów!')
            TriggerClientEvent('Tomci0-Narko:StopTransform', source)
        end
    else
        print('Cheater')
    end
end)

RegisterNetEvent('Tomci0-Narko:ZabierzItemy')
AddEventHandler('Tomci0-Narko:ZabierzItemy', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    xPlayer.removeInventoryItem('water', 1)
    xPlayer.removeInventoryItem(item, 1)
end)

RegisterNetEvent('Tomci0-Narko:AddNewPlant')
AddEventHandler('Tomci0-Narko:AddNewPlant', function(coords, entity, prop, type)
    local delay = 0
    prop2 = nil
    local numerroslinki = 0
    local state = 1

    repeat
        numerroslinki = numerroslinki + 1
    until( roslinki[numerroslinki] == nil )

    local randomstate = math.random(1, 10)

    if randomstate >= 4 then
        state = 1
    else
        state = 3
    end

    for k,v in pairs(Config.Itemy) do
        if k == type then
            delay = v.delay or 1000
            prop2 = v.props[2]
            items = v.items
            break
        end
    end

    roslinki[numerroslinki] = {
        coords = coords,
        entity = entity,
        prop = prop,
        state = state,
        items = items
    }

    Wait(tonumber(delay))

    TriggerClientEvent('Tomci0-Narko:RemoveEntity', -1, coords, prop, prop2, numerroslinki)
end)

RegisterNetEvent('Tomci0-Narko:EditExistPlant')
AddEventHandler('Tomci0-Narko:EditExistPlant', function(number, newprop, newentity)
    local coords = roslinki[number].coords
    local state = roslinki[number].state

    if state == 3 then
        state = 3
    elseif state == 1 then
        state = 2
    end
    
    roslinki[number] = {
        coords = coords,
        entity = newentity,
        prop = newprop, 
        state = state
    }
end)

RegisterNetEvent('Tomci0-Narko:SprawdzStan')
AddEventHandler('Tomci0-Narko:SprawdzStan', function(coords, prop)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k,v in pairs(roslinki) do
        if v.coords.x == coords.x and v.coords.y == coords.y then
            if v.state == 2 then
                local nozyczki = xPlayer.getInventoryItem('bread').count
                    if roslinki[k].zebrane ~= 1 then
                        roslinki[k].zebrane = 1

                        if nozyczki >= 1 then
                            TriggerClientEvent('Tomci0-Narko:Harvest', source, k)
                            Wait(5000)
                            TriggerClientEvent('Tomci0-Narko:ForceRemoveEntity', -1, v.coords, v.prop)
                        else
                            xPlayer.showNotification('~r~Ta roślinka została już zebrana!')
                        end
                    else
                        xPlayer.showNotification('Nie masz nożyczek, aby ściąć liście!')
                    end
            elseif v.state == 1 then
                xPlayer.showNotification('~r~Ta roślinka jeszcze rośnie!')
            elseif v.state == 3 then
                if roslinki[k].zebrane ~= 1 then
                    roslinki[k].zebrane = 1
                    xPlayer.showNotification('~r~Ta roślinka zwiędniała!')
                    TriggerClientEvent('Tomci0-Narko:ForceRemoveEntity', -1, v.coords, v.prop)
                else
                    xPlayer.showNotification('~r~Ta roślinka została już zebrana!')
                end
            end
        end
    end
end)

for i,v in pairs(Config.Itemy) do
    ESX.RegisterUsableItem(i, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent('Tomci0-Narko:UseZiarno', source, i)
    end)
end

RegisterNetEvent('Tomci0-Narko:GiveLiscie')
AddEventHandler('Tomci0-Narko:GiveLiscie', function(numer)
    local xPlayer = ESX.GetPlayerFromId(source)
    local krzak = roslinki[numer]
    local coords = xPlayer.getCoords(true)

    if krzak.state == 2 then
        if krzak.zebrane == 1 then
            local distance = #(krzak.coords - coords)
            if distance < 2.0 then

                local random = math.random(1, #items)

                local item_name = items[random].name
                local count = math.random(items[random].min, items[random].max)

                print(item_name)
                print(count)

                if xPlayer.canCarryItem(item_name, count) then
                    xPlayer.addInventoryItem(item_name, count)
                else
                    xPlayer.showNotification('Nie możesz unieść tych liści!')
                end
            end
        end
    end
end)