local ESX, QBCore = nil, nil

if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterNetEvent('vertex_coins:clientShowNotify', function(msg, type)
    if Config.NotifySystem == "vertex" then
        exports['vertex_notify']:ShowNotification(msg, type)
    elseif Config.NotifySystem == "esx" then
        ESX.ShowNotification(msg)
    elseif Config.NotifySystem == "qb" then
        QBCore.Functions.Notify(msg, type, '5000')
    end
end)


RegisterCommand(Config.vercoinsCommand, function()
    TriggerServerEvent("vertex_coins:requestCoins")
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    cb({})
end)

RegisterNetEvent("vertex_coins:showCoins", function(coins)
    SendNUIMessage({
        action = "showCoins",
        coins = coins
    })
    SetNuiFocus(true, true)
end)

TriggerEvent('chat:addSuggestion', '/' .. Config.givecoinsCommand, 'Give Coins', {
    { name = 'id', help = 'Player ID' },
    { name = 'Coins', help = 'Coins Ammount' }
})

TriggerEvent('chat:addSuggestion', '/' .. Config.removecoinsCommand, 'Remove Coins', {
    { name = 'id', help = 'Player ID' },
    { name = 'Coins', help = 'Coins Ammount' }
})

TriggerEvent('chat:addSuggestion', '/' .. Config.vercoinsCommand, 'See your coins', {
})

