local ESX, QBCore = nil, nil
local Framework = Config.Framework

if Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
    print("[vertex_coins] Using ESX Framework")
elseif Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
    print("[vertex_coins] Using QBCore Framework")
else
    print("[vertex_coins] No Framework Detected")
end

local function Notify(src, msg, type)
    TriggerClientEvent("vertex_coins:clientShowNotify", src, msg, type)
end

local function getLicense(source)
    for _, v in ipairs(GetPlayerIdentifiers(source)) do
        if v:sub(1, 8) == "license:" then
            return v
        end
    end
    return nil
end

local function getCoins(source)
    local license = getLicense(source)
    if not license then return 0 end
    local finished = promise.new()
    MySQL.query("SELECT coins FROM vertex_coins WHERE license = ?", {license}, function(result)
        if result[1] then
            finished:resolve(result[1].coins)
        else
            finished:resolve(0)
        end
    end)
    return Citizen.Await(finished)
end

local function addCoins(source, amount)
    local license = getLicense(source)
    if not license then return false end
    MySQL.update(
        "INSERT INTO vertex_coins (license, coins) VALUES (?, ?) ON DUPLICATE KEY UPDATE coins = coins + ?",
        {license, amount, amount}
    )
    return true
end

local function removeCoins(source, amount)
    local license = getLicense(source)
    if not license then return false end
    local finished = promise.new()
    MySQL.query("SELECT coins FROM vertex_coins WHERE license = ?", {license}, function(result)
        if result[1] and result[1].coins >= amount then
            MySQL.update("UPDATE vertex_coins SET coins = coins - ? WHERE license = ?", {amount, license})
            finished:resolve(true)
        else
            finished:resolve(false)
        end
    end)
    return Citizen.Await(finished)
end

exports("getCoins", getCoins)
exports("addCoins", addCoins)
exports("removeCoins", removeCoins)

local function isAdmin(src)
    if Framework == "esx" and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getGroup() == "admin" then
            return true
        end
    end
    if Framework == "qb" and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData.group == "admin" then
            return true
        end
    end
    return false
end

RegisterCommand(Config.givecoinsCommand, function(source, args)
    if not isAdmin(source) then
        Notify(source, "No tienes permiso para usar este comando.", "error")
        return
    end
    local targetId, amount = tonumber(args[1]), tonumber(args[2])
    if not targetId or not amount then
        Notify(source, "Uso correcto: /" .. Config.givecoinsCommand .. " [id] [cantidad]", "error")
        return
    end
    local license = getLicense(targetId)
    if not license then
        Notify(source, "No se encontro la licencia del jugador.", "error")
        return
    end
    addCoins(targetId, amount)
    Notify(targetId, "Has recibido " .. amount .. " coins.", "success")
    Notify(source, "Has dado " .. amount .. " coins al jugador ID " .. targetId, "success")
end)

RegisterCommand(Config.removecoinsCommand, function(source, args)
    if not isAdmin(source) then
        Notify(source, "No tienes permiso para usar este comando.", "error")
        return
    end
    local targetId, amount = tonumber(args[1]), tonumber(args[2])
    if not targetId or not amount then
        Notify(source, "Uso correcto: /" .. Config.removecoinsCommand .. " [id] [cantidad]", "error")
        return
    end
    if removeCoins(targetId, amount) then
        Notify(targetId, "Se te removieron " .. amount .. " coins.", "error")
        Notify(source, "Has removido " .. amount .. " coins al jugador ID " .. targetId, "success")
    else
        Notify(source, "El jugador no tiene suficientes coins.", "error")
    end
end)

if Config.CoinReward then
    local interval = (Config.CoinInterval or 60) * 60 * 1000
    local reward = tonumber(Config.CoinAmmount) or 0
    CreateThread(function()
        while true do
            Wait(interval)
            local players = GetPlayers()
            if #players > 0 and reward > 0 then
                for i = 1, #players do
                    local src = tonumber(players[i])
                    addCoins(src, reward)
                    Notify(src, ("Has recibido %s coins por jugar."):format(reward), "success")
                end
            end
        end
    end)
end

RegisterServerEvent("vertex_coins:requestCoins", function()
    local src = source
    local coins = getCoins(src)
    TriggerClientEvent("vertex_coins:showCoins", src, coins)
end)
