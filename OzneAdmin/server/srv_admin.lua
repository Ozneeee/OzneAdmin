--#################################################################################--

-- First version done by rubylium then adapted for esx and finished by Ozne#4870

-- question or more scripts here : https://discord.gg/nx3TKM5

--#################################################################################--


ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('RubyMenu:getUsergroup', function(source, cb)
     local xPlayer = ESX.GetPlayerFromId(source)
     local group = xPlayer.getGroup()
     cb(group)
end)

platenum = math.random(00001, 99998)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		local r = math.random(00001, 99998)
		platenum = r
	end
end)

function SendWebhookMessageMenuStaff(webhook,message)
	webhook = ""
	if webhook ~= "none" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

RegisterServerEvent("AdminMenu:StaffOnOff")
AddEventHandler("AdminMenu:StaffOnOff", function(status)

	local xPlayers	= ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
          local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
          if status == true then
               TriggerClientEvent('chatMessage', xPlayers[i], '', {255, 0, 0}, "Un staff vient de passer un mode modération : "..source..".")
               print(status)
          elseif status == false then
               TriggerClientEvent('chatMessage', xPlayers[i], '', {255, 0, 0}, "Un staff vient de quitter le mode modération : "..source..".")
               print(status)
		end
	end	
end)


RegisterServerEvent("logMenuAdmin")
AddEventHandler("logMenuAdmin", function(option)
	local date = os.date('*t')
	
	if date.day < 10 then date.day = '0' .. tostring(date.day) end
	if date.month < 10 then date.month = '0' .. tostring(date.month) end
	if date.hour < 10 then date.hour = '0' .. tostring(date.hour) end
	if date.min < 10 then date.min = '0' .. tostring(date.min) end
	if date.sec < 10 then date.sec = '0' .. tostring(date.sec) end
	name = GetPlayerName(source)
	SendWebhookMessageMenuStaff(webhook,"**Menu Admin Utilisé** \n```diff\nJoueurs: "..name.."\nID du joueurs: "..source.." \nOption activé: "..option.."\n+ Date: " .. date.day .. "." .. date.month .. "." .. date.year .. " - " .. date.hour .. ":" .. date.min .. ":" .. date.sec .. "\n[Detection #".. platenum .."].```")
end)


RegisterServerEvent("kickAllPlayer2")
AddEventHandler("kickAllPlayer2", function()
	local message = money
	print(message)
	local xPlayers	= ESX.GetPlayers()
	TriggerEvent('SavellPlayerAuto')
	Citizen.Wait(2000)
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		DropPlayer(xPlayers[i], 'RESTART DU SERVEUR. Vous avez été exlus du serveur avant son restart pour sauvgarder votre personnage\nMerci d\'attendre le message comme quoi le serveur à restart sur le discord avant de vous connecté')
	end
	

end)


RegisterServerEvent("ReviveAll")
AddEventHandler("ReviveAll", function()
	name = GetPlayerName(source)
	local xPlayers	= ESX.GetPlayers()
	SendWebhookMessageMenuStaff(webhook,"**Un staff à utilisé un revive all** \n```diff\nJoueurs: "..name.."\nID du joueurs: "..source.." \n[Detection #".. platenum .."].```")
	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		TriggerEvent('esx_ambulancejob:revive2', xPlayers[i])
	end
end)

RegisterServerEvent("deleteVehAll")
AddEventHandler("deleteVehAll", function()
	TriggerClientEvent("RemoveAllVeh", -1)
end)

RegisterServerEvent("spawnVehAll")
AddEventHandler("spawnVehAll", function()
	TriggerClientEvent("SpawnAllVeh", -1)
end)



--RegisterServerEvent("SavellPlayer")
--AddEventHandler("SavellPlayer", function(source)
--	local _source = source
--	local xPlayer = ESX.GetPlayerFromId(_source)
--	--ESX.SavePlayers(cb)
--	ESX.SavePlayer(xPlayer, cb)
--	print('^2Save de '..xPlayer..' ^3Effectué')
--	--for i=1, #xPlayers, 1 do
--	--	local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
--	--	--TriggerClientEvent('esx:showNotification', xPlayers[i], '✅ Synchronisation inventaire effectuée.')
--	--end
--	
--
--end)


RegisterServerEvent("SavellPlayerAuto")
AddEventHandler("SavellPlayerAuto", function()
	ESX.SavePlayers(cb)
	print('^2Save des joueurs ^3Effectué')
end)


count = 0
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		count = count + 1

		if count >= 240 then
			ESX.SavePlayers(cb)
			print('^2Save des joueurs ^3Effectué')
			count = 0
		end
	end
end)


--#################################################################################--

-- First version done by rubylium then adapted for esx and finished by Ozne#4870

-- question or more scripts here : https://discord.gg/nx3TKM5

--#################################################################################--