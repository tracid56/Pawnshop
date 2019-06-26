ESX             = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--[[RegisterServerEvent('pawnshop:analyse')
AddEventHandler('pawnshop:analyse', function(count, item, value, legal)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local label = xPlayer.getInventoryItem(item).label
	local money = value * count
    
    if not legal then
		if count > 20 and math.random(1, 100) <= count then
			--TriggerClientEvent('pawnshop:alarmNotif', _source)
			TriggerClientEvent('pawnshop:policeNotif', -1, label)
		end
    end
end)]]

ESX.RegisterServerCallback('pawnshop:analyse', function (source, cb, count, item, value, legal)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local label = xPlayer.getInventoryItem(item).label
    
    xPlayer.removeInventoryItem(item, count)

    if not legal and count > 5 and math.random(1, 100) <= count * 2 then
        --TriggerClientEvent('pawnshop:alarmNotif', _source)
        TriggerClientEvent('pawnshop:policeNotif', -1, label)
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('pawnshop:sellItem')
AddEventHandler('pawnshop:sellItem', function(count, item, value, legal)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local label = xPlayer.getInventoryItem(item).label
	local money = value * count
    
    xPlayer.addMoney(money)
    --xPlayer.removeInventoryItem(item, count)
	TriggerClientEvent('esx:showAdvancedNotification', _source, Config.Name, "~b~Prêteur sur gage", "Tu as vendu ".. count.." " .. label.. " pour ~g~".. money.. " $", Config.ImageNotif, 1)
end)