local rentalLocations = {
    {vector4(-683.0261, 301.9768, 82.4130, 175.3659)}, 
    {vector4(-245.3337, -992.9412, 29.2895, 251.2311)},           
          
    
}

local rentalPricePerMinute = 1000
local rentalVehicles = {
    {label = "Faggio", model = "faggio"},
    {label = "BF400", model = "bf400"}
}

local activeRental = false
local rentalTimeLeft = 0

CreateThread(function()
    for _, location in ipairs(rentalLocations) do
        local npcLocation = location[1]

        local npcModel = `a_m_y_business_02`
        RequestModel(npcModel)
        while not HasModelLoaded(npcModel) do
            Wait(100)
        end

        local npc = CreatePed(4, npcModel, npcLocation.x, npcLocation.y, npcLocation.z - 1.0, npcLocation.w, false, true)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetPedCanRagdoll(npc, false)
        FreezeEntityPosition(npc, true)
        TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true)

        local blip = AddBlipForCoord(npcLocation.x, npcLocation.y, npcLocation.z)
        SetBlipSprite(blip, 226 )
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.5)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Jármübérlés")
        EndTextCommandSetBlipName(blip)

        exports.ox_target:addLocalEntity(npc, {
            {
                name = "vehicle_rental",
                icon = "fas fa-car",
                label = "Jármű bérlés",
                onSelect = function()
                    openRentalMenu() 
                end
            }
        })
    end
end)

function openRentalMenu()
    local options = {}

    for _, vehicle in ipairs(rentalVehicles) do
        table.insert(options, {
            title = vehicle.label,
            description = "Bérelhető jármű",
            event = "vehicleRental:chooseVehicle",
            args = vehicle
        })
    end

    lib.registerContext({
        id = "rental_menu",
        title = "Jármű bérlés",
        options = options
    })

    lib.showContext("rental_menu")
end

RegisterNetEvent("vehicleRental:chooseVehicle", function(vehicle)
    local duration = lib.inputDialog("Bérlési időtartam", {"Időtartam (percben)"})

    if not duration or not tonumber(duration[1]) then
        lib.notify({
            title = "Hiba",
            description = "Érvénytelen időtartam!",
            type = "error"
        })
        return
    end

    local minutes = tonumber(duration[1])
    local cost = minutes * rentalPricePerMinute

    if lib.progressCircle({
        duration = 3000,
        label = "Fizetés feldolgozása...",
        position = "bottom"
    }) then
        TriggerServerEvent("vehicleRental:pay", cost, vehicle, minutes)
    end
end)

RegisterNetEvent("vehicleRental:success")
AddEventHandler("vehicleRental:success", function(vehicle, minutes)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    lib.notify({
        title = "Sikeres bérlés",
        description = "Járművedet megkaptad!",
        type = "success"
    })

    local vehicleHash = GetHashKey(vehicle.model)
    RequestModel(vehicleHash)
    while not HasModelLoaded(vehicleHash) do
        Wait(100)
    end

    local rentedVehicle = CreateVehicle(vehicleHash, playerCoords.x + 2, playerCoords.y, playerCoords.z, GetEntityHeading(playerPed), true, false)
    SetVehicleNumberPlateText(rentedVehicle, "RENTAL")
    TaskWarpPedIntoVehicle(playerPed, rentedVehicle, -1)

    rentalTimeLeft = minutes * 60
    activeRental = true

    CreateThread(function()
        while activeRental and rentalTimeLeft > 0 do
            Wait(1000)
            rentalTimeLeft = rentalTimeLeft - 1
        end

        if rentalTimeLeft <= 0 and DoesEntityExist(rentedVehicle) then
            DeleteEntity(rentedVehicle)
            lib.notify({
                title = "Bérlés vége",
                description = "A bérelt jármű eltávolítva.",
                type = "info"
            })
            activeRental = false
        end
    end)
end)

RegisterNetEvent("vehicleRental:failure")
AddEventHandler("vehicleRental:failure", function()
    lib.notify({
        title = "Hiba",
        description = "Nincs elég pénzed a bérléshez!",
        type = "error"
    })
end)

CreateThread(function()
    while true do
        Wait(0)
        if activeRental and rentalTimeLeft > 0 then
            local minutes = math.floor(rentalTimeLeft / 60)
            local seconds = rentalTimeLeft % 60
            local timeDisplay = string.format("~y~Bérlési idő hátra: %02d:%02d~s~", minutes, seconds)
            
            SetTextFont(4)
            SetTextScale(0.4, 0.4)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(timeDisplay)
            DrawText(0.55 - (string.len(timeDisplay) * 0.003), 0.02)
        end
    end
end)
