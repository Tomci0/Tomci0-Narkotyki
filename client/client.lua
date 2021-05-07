ESX = nil
local inZone = ''
local collectedPlants = {}
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionKey = ''
local CurrentActionData = {}
local isProcessing = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

    TriggerServerEvent('Tomci0-Narko:RequestCoords')
end)

RegisterNetEvent('Tomci0-Narko:FetchCoords')
AddEventHandler('Tomci0-Narko:FetchCoords', function(zones, transform, itemy)
    Config.Zones = zones
    Config.Transform = transform
    Config.Itemy = itemy
end)

-- Citizen.CreateThread(function() 
--     while ESX == nil do
--         Citizen.Wait(1)
--     end

--     while true do
--         local wait = true
--         local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
        
--         for k,v in pairs(Config.Zones) do
--             if GetDistanceBetweenCoords(x, y, z, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size then
--                 local vector = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
--                 inZone = k
--                 wait = false
--                 --DrawMarker(1, v.Pos.x, v.Pos.y, v.Pos.z - 4.0, 0,0,0,0,0,0, v.Size * 2, v.Size * 2, 20.0, 218, 74, 74, 100, false, false, true, 2, nil, nil, false)
--                 ESX.Game.Utils.DrawText3D(vector, '~y~Ta gleba jest idealna do sadzenia', 0.8, 0)
--             end
--         end

--         if inZone ~= '' and (GetDistanceBetweenCoords(x, y, z, Config.Zones[inZone].Pos.x, Config.Zones[inZone].Pos.y, Config.Zones[inZone].Pos.z, false) > Config.Zones[inZone].Size) then
--             inZone = ''
-- 		end

--         for k,v in pairs(Config.Transform) do
--             if GetDistanceBetweenCoords(x, y, z, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size then
--                 CurrentAction = 'process_drug'

--                 if not isProcessing then
--                     CurrentActionMsg = 'Naciśnij ~INPUT_CONTEXT~, aby przerobić ~r~Narkotyki'
--                 end

--                 CurrentActionKey = k
--                 CurrentActionData.type = v.type
--             end
--         end

        -- if CurrentActionKey ~= '' and (GetDistanceBetweenCoords(x, y, z, Config.Transform[CurrentActionKey].Pos.x, Config.Transform[CurrentActionKey].Pos.y, Config.Transform[CurrentActionKey].Pos.z, false) > Config.Transform[CurrentActionKey].Size) then
        --     CurrentAction = nil
        --     CurrentActionMsg = ''
        --     CurrentActionKey = ''
        --     CurrentActionData.type = {}
        --     isProcessing = false
        --     ClearPedTasks(GetPlayerPed(-1))
		-- end
--         Citizen.Wait(0)
--     end
-- end)

CreateThread(function()
    while ESX == nil do
        Citizen.Wait(1)
    end

    while true do
        Wait(0)

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local isInMarker, hasExited, letSleep = false, false, true

        for i,v in pairs(Config.Zones) do
            local vector = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
            local distance = #(coords - vector)

            if distance < v.Size then
                letSleep = false
                inZone = i
                ESX.Game.Utils.DrawText3D(vector, '~y~Ta gleba jest idealna do sadzenia', 0.8, 0)
            end
        end

        for i,v in pairs(Config.Transform) do
            local vector = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
            local distance = #(coords - vector)
            
            if distance < 15.0 then
                letSleep = false

                DrawMarker(25, vector, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, v.Size * 2, v.Size * 2, 2.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)

                if distance < v.Size then
                    letSleep = false
                    CurrentAction = 'process_drug'
    
                    if not isProcessing then
                        CurrentActionMsg = 'Naciśnij ~INPUT_CONTEXT~, aby przerobić ~r~Narkotyki'
                    end
    
                    CurrentActionKey = i
                    CurrentActionData.type = v.type
                end
            end
        end
        
        if CurrentActionKey ~= '' then
            print(CurrentActionKey)
            local vector = vector3(Config.Transform[CurrentActionKey].Pos.x, Config.Transform[CurrentActionKey].Pos.y, Config.Transform[CurrentActionKey].Pos.z)
            local distance = #(vector - coords)

            if (distance > Config.Transform[CurrentActionKey].Size) then
                CurrentAction = nil
                CurrentActionMsg = ''
                CurrentActionKey = ''
                CurrentActionData.type = {}
                isProcessing = false
                ClearPedTasks(GetPlayerPed(-1))
            end
		end

        
        if inZone ~= '' then

            for k,v in pairs(Config.Itemy) do
                for i=1, #v.props, 1 do
                    local x = GetClosestObjectOfType(coords, 1.5, GetHashKey(v.props[i]), false, false, false)
                    local entity = nil
                    if DoesEntityExist(x) then
                        entity = x
                        local x, y, z = table.unpack(GetEntityCoords(entity))
                        z = z + 0.5
                        local plant = vector3(x, y, z)

                        local type = ''

                        ESX.Game.Utils.DrawText3D(plant, 'Naciśnij [~g~E~w~] aby sprawdzić roślinkę', 0.8)
                        if IsControlJustReleased(0, 38) and not clicked and GetEntityHealth(GetPlayerPed(-1)) > 1 and not IsPedInAnyVehicle(GetPlayerPed(-1), true) then
                            clicked = true
                            TriggerServerEvent('Tomci0-Narko:SprawdzStan', plant, v.props[i])
                            Citizen.Wait(7000)
                            clicked = false
                        end
                        break
                    end
                end
            end
            
            local vector = vector3(Config.Zones[inZone].Pos.x, Config.Zones[inZone].Pos.y, Config.Zones[inZone].Pos.z)
            local distance = #(vector - coords)
            if (distance > Config.Zones[inZone].Size) then
                inZone = ''
            end
		end

        if letSleep then
            Wait(1000)
        end
    end
end)

-- Citizen.CreateThread(function() 
--     while ESX == nil do
--         Citizen.Wait(1)
--     end

--     while true do
--        local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))

--         Citizen.Wait(0)
--     end
-- end)

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(1)
    end

    while true do
        Wait(0)
        if CurrentAction ~= nil then
            ESX.ShowHelpNotification(CurrentActionMsg)
            if IsControlJustPressed(0, 51) then
                isProcessing = not isProcessing
                if isProcessing then
                    CurrentActionMsg = 'Naciśnij ~INPUT_CONTEXT~, aby przestać przerabiać ~r~Narkotyki'
                    ESX.ShowNotification('~r~Rozpoczynasz przeróbkę narkotyków!')
                    StartProccesNarko()
                    BlockKeyBinds()
                    animka1()
                else
                    ClearPedTasks(GetPlayerPed(-1))
                    isProcessing = false
                    ESX.ShowNotification('~r~Zakończyłeś przerabianie narkotyków')
                    Wait(500)
                    ClearPedTasks(GetPlayerPed(-1))
                end
            end
        else
            Wait(1000)
        end
    end
end)

function StartProccesNarko()
    CreateThread(function()
        while isProcessing do
            Wait(Config.Transform[CurrentActionKey].Delay)
            TriggerServerEvent('Tomci0-Narko:GivePrzerobione',  CurrentActionKey)
        end
    end)
end

function BlockKeyBinds()
    CreateThread(function()
        while isProcessing do
            Wait(0)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)

            animka2()
        end
    end)
end

RegisterNetEvent('Tomci0-Narko:StopTransform')
AddEventHandler('Tomci0-Narko:StopTransform', function()
    CurrentAction = nil
    CurrentActionMsg = ''
    CurrentActionKey = ''
    CurrentActionData.type = {}
    isProcessing = false
    ClearPedTasks(GetPlayerPed(-1))
end)

function animka2()
	local dict = "amb@prop_human_bum_bin@idle_b"
		RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
	TaskPlayAnim(GetPlayerPed(-1), dict, "idle_d", 8.0, 8.0, -1, 1, 0, false, false, false)
end

function animka1()
	local dict = "amb@world_human_gardener_plant@male@base"
		RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
	TaskPlayAnim(GetPlayerPed(-1), dict, "base", 8.0, 8.0, -1, 1, 0, false, false, false)
end

sadzenie = false

RegisterNetEvent('Tomci0-Narko:UseZiarno')
AddEventHandler('Tomci0-Narko:UseZiarno', function(type)
    local mozna = true
    local woda = nil
    local ped = GetPlayerPed(-1)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    z = z - 1.0
    local krzak_coords = vector3(x, y, z)

    for k,v in pairs(Config.Itemy) do
        for i=1, #v.props, 1 do
            local x = GetClosestObjectOfType(coords, 1.5, GetHashKey(v.props[i]), false, false, false)
            if DoesEntityExist(x) then
                mozna = false
            end
        end
    end

    ESX.TriggerServerCallback('Tomci0-Narko:GetWater', function(jestwoda)
        woda = jestwoda 
    end)

    while woda == nil do
        Wait(1)
    end

    if not woda then
        ESX.ShowNotification('~r~Nie masz czym podlać roślinki!')
        return
    end

    if mozna then
        if not sadzenie then
            TriggerServerEvent('Tomci0-Narko:ZabierzItemy', type)
            animka1()
            sadzenie = true
            FreezeEntityPosition(ped, true)
            exports['progressBars']:startUI(5000, "Sadzenie Roślinki...")
            Wait(5000)
            FreezeEntityPosition(ped, false)
            sadzenie = false
            ClearPedTasks(GetPlayerPed(-1))

            if inZone ~= '' then
                local prop = ''

                for k,v in pairs(Config.Itemy) do
                    if k == type then
                        prop = v.props[1]
                        break
                    end
                end

                ESX.Game.SpawnObject(prop, krzak_coords, function(entity) 
                    TriggerServerEvent('Tomci0-Narko:AddNewPlant', krzak_coords, entity, prop, type)
                    FreezeEntityPosition(entity, true)
                end)
                ESX.ShowNotification('~r~Posadziłeś roślinkę!')
            else
                ESX.ShowNotification('~r~Posadziłeś roślinkę, ale gleba w tym miejscu jest słaba!')
            end
        else
            ESX.ShowNotification('~r~Aktualnie sadzisz roślinkę!')
        end
    else
        ESX.ShowNotification('~r~Sadzisz roślinkę za blisko innego krzaczka!')
    end
end)

RegisterNetEvent('Tomci0-Narko:RemoveEntity')
AddEventHandler('Tomci0-Narko:RemoveEntity', function(coords, prop, prop2, number)
    local object = GetClosestObjectOfType(coords, 1.0, GetHashKey(prop), false, false, false)
    if DoesEntityExist(object) then
        DeleteObject(object)
        ESX.Game.SpawnObject(prop2, coords, function(entity) 
            TriggerServerEvent('Tomci0-Narko:EditExistPlant', number, prop2, entity)
        end)
    end
end)

RegisterNetEvent('Tomci0-Narko:ForceRemoveEntity')
AddEventHandler('Tomci0-Narko:ForceRemoveEntity', function(coords, prop)
    local object = GetClosestObjectOfType(coords, 1.0, GetHashKey(prop), false, false, false)
    if DoesEntityExist(object) then
        DeleteObject(object)
    end
end)

-- Citizen.CreateThread(function()
--     local clicked = false
--     while ESX == nil do
--         Citizen.Wait(0)
--     end
--     while true do
--         Wait(0)
--         if inZone ~= '' then
--             local ped = PlayerPedId()
--             local coords = GetEntityCoords(ped)

--         else
--             Wait(1000)
--         end
--     end
-- end)

RegisterNetEvent('Tomci0-Narko:Harvest')
AddEventHandler('Tomci0-Narko:Harvest', function(number)
    animka2()
    FreezeEntityPosition(ped, true)
    exports['progressBars']:startUI(5000, "Zbieranie Liści Roślinki...")
    Wait(5000)
    TriggerServerEvent('Tomci0-Narko:GiveLiscie', number)
    FreezeEntityPosition(ped, false)
    ClearPedTasks(GetPlayerPed(-1))
end)