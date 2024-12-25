

ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("vehicleRental:pay")
AddEventHandler("vehicleRental:pay", function(cost, vehicle, minutes)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getMoney() >= cost then
        xPlayer.removeMoney(cost)
        TriggerClientEvent("vehicleRental:success", source, vehicle, minutes)
    else
        TriggerClientEvent("vehicleRental:failure", source)
    end
end)
