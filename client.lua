ESX = nil
local PlayerData = {}
local npc = nil
local canSell = true

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
    print("Pawnshop fait par Thom512 avec amour :)")
	local blip = AddBlipForCoord(Config.Loc.x, Config.Loc.y, Config.Loc.z)
	SetBlipSprite(blip, 431)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 24)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Prêteur sur gage")
	EndTextCommandSetBlipName(blip)
	Wait(5000)
	PlayerData = ESX.GetPlayerData()
end)

function OpenShopMenu(itemPrices)
	PlayerData = ESX.GetPlayerData()
	local inventory = PlayerData.inventory
	local elements = {}
	for i=1, #inventory, 1 do
		local item = inventory[i]
		if item.count > 0 and Config.Prices[item.name] ~= nil then
			if Config.Prices[item.name].legal then
				color = "limegreen"
			else
				color = "red"
			end
			table.insert(elements, {
				label = '<span>' .. item.count .. ' '.. item.label .. '</span> <span style="color: limegreen;">$' .. Config.Prices[item.name].price .. '</span>',--getItemPrice(item.name)
				itemLabel = item.label,
				item  = item.name,
				itemCount = item.count
			})
		end
	end
	
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'inventory', {
		css      = "Inventaire",
		title    = "Prêteur sur gage",
		align    = 'bottom-right',
		elements = elements
	}, function(data, menu)
		local itemName = data.current.value
		local itemCount = data.current.itemCount
        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = "Quantité"
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil or count > itemCount or count > 50 then
              ESX.ShowNotification("Quantité Invalide")
            else
              menu2.close()
			  menu.close()
			  Analyse(count, data.current.item, Config.Prices[data.current.item].price, Config.Prices[data.current.item].legal)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )
		
		
	end, function(data, menu)
		menu.close()
	end)
end

function getItemPrice(item)
  local itemPrice = 0
  if item ~= nil then
	   itemPrice = 0
	   if Config.Prices[item] ~= nil then
	        itemPrice = Config.Prices[item]
	   end
	end
  return itemPrice
end

function Analyse(count, item, value, legal)
	canSell = false
	TaskGoToCoordAnyMeans(npc, 377.86, 332.95, 103.56, 1.0, 0, 0, 786603)
	ESX.ShowAdvancedNotification(Config.Name, "~b~Prêteur sur gage", "Attends là, je vais vérifier ce que tu m'as donné", Config.ImageNotif, 1)
	--TriggerServerEvent('pawnshop:analyse', count, item, value, legal)
	ESX.TriggerServerCallback('pawnshop:analyse', function(appelPolice)
		local police = appelPolice
		Wait(500)
		if police then
			Wait(30000)
		else
			Wait(10000)
		end
		TaskGoToCoordAnyMeans(npc, Config.Loc.x, Config.Loc.y, Config.Loc.z, 1.0, 0, 0, 786603)
		while GetDistanceBetweenCoords(Config.Loc.x, Config.Loc.y, Config.Loc.z, GetEntityCoords(npc), false) > 0.5 do Wait(0) end
		if GetInteriorFromEntity(GetPlayerPed(-1)) == 0 then
			ESX.ShowAdvancedNotification(Config.Name, "~b~Prêteur sur gage", "Tu es parti où ?", Config.ImageNotif, 1)
			SetEntityHeading(npc, Config.Loc.heading)
			canSell = true
		else
			SetEntityHeading(npc, Config.Loc.heading)
			TriggerServerEvent('pawnshop:sellItem', count, item, value, legal)
			TriggerServerEvent('Logs:custom', "a vendu ".. count.." ".. item .." au préteur sur gage pour ".. count * value.." $")
			canSell = true
		end
	end, count, item, value, legal)
end



Citizen.CreateThread(function()
	RequestModel(GetHashKey(Config.Model))
	while not HasModelLoaded(GetHashKey(Config.Model)) do
		Citizen.Wait(10)
	end
	npc = CreatePed(5, Config.Model, Config.Loc.x, Config.Loc.y, Config.Loc.z, Config.Loc.heading, false, false)
	SetPedFleeAttributes(npc, 0, 0)
	SetPedDropsWeaponsWhenDead(npc, false)
	SetPedDiesWhenInjured(npc, false)
	Citizen.Wait(1500)
	SetEntityInvincible(npc , true)
	--FreezeEntityPosition(npc, true)
	SetBlockingOfNonTemporaryEvents(npc, true)

	while true do
		local distance = GetDistanceBetweenCoords(Config.Loc.x, Config.Loc.y, Config.Loc.z, GetEntityCoords(GetPlayerPed(-1)), true)
		if distance < 3 and canSell then
			ESX.ShowHelpNotification("~INPUT_CONTEXT~ pour parler à ~b~" .. Config.Name)
			if IsControlJustReleased(0, 38) then
				--TriggerServerEvent('pawnshop:showMenu')
				OpenShopMenu()
			end
		else 
			ESX.UI.Menu.Close('default', GetCurrentResourceName(), 'inventory')
		end
		Citizen.Wait(1)
	end
end)

RegisterNetEvent('pawnshop:policeNotif')
AddEventHandler('pawnshop:policeNotif', function(label)
	if PlayerData.job.name == 'police' then
		SetNotificationBackgroundColor(6)
		ESX.ShowAdvancedNotification(Config.Name, "~h~~b~Prêteur sur gage", "~h~Y'a une personne bizarre qui me vend des ~b~"..label, Config.ImageNotif, 1)
		PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
		Wait(250)
		PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
		
		local transT = 250
		local Blip = AddBlipForCoord(Config.Loc.x, Config.Loc.y, Config.Loc.z)
		SetBlipSprite(Blip,  431)
		SetBlipColour(Blip,  1)
		SetBlipAlpha(Blip,  transT)
		SetBlipAsShortRange(Blip,  false)
		Wait(12000)
		while transT ~= 0 do
			Wait(50)
			transT = transT - 1
			SetBlipAlpha(Blip,  transT)
			if transT == 0 then
				SetBlipSprite(Blip,  2)
				return
			end
		end
	end
end)

