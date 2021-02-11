--################################################################################--

-- First version done by rubylium then adapted for esx and finished by Ozne#4870

-- question or more scripts here : https://discord.gg/nx3TKM5

--################################################################################--

WarMenu = { }

WarMenu.debug = false

local function RGBRainbow( frequency )
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = 0
	result.g = 90
	result.b = 255
	
	return result
end

ESX = nil
superadmin = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function Notify(text)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(text)
	DrawNotification(false, true)
end


local menus = { }
local keys = { up = 172, down = 173, left = 174, right = 175, select = 176, back = 177 }
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local menuWidth = 0.23
local titleHeight = 0.11
local titleYOffset = 0.045
local titleScale = 1.2

local buttonHeight = 0.038
local buttonFont = 4
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.002

local function debugPrint(text)
	if WarMenu.debug then
		Citizen.Trace('[WarMenu] '..tostring(text))
	end
end


local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
		debugPrint(id..' menu property changed: { '..tostring(property)..', '..tostring(value)..' }')
	end
end


local function isMenuVisible(id)
	if id and menus[id] then
		return menus[id].visible
	else
		return false
	end
end


local function setMenuVisible(id, visible, holdCurrent)
	if id and menus[id] then
		setMenuProperty(id, 'visible', visible)

		if not holdCurrent and menus[id] then
			setMenuProperty(id, 'currentOption', 1)
		end

		if visible then
			if id ~= currentMenu and isMenuVisible(currentMenu) then
				setMenuVisible(currentMenu, false)
			end

			currentMenu = id
		end
	end
end


local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropShadow(2, 2, 0, 0, 0)
	end

	if menus[currentMenu] then
		if center then
			SetTextCentre(center)
		elseif alignRight then
			SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
			SetTextRightJustify(true)
		end
	end
	SetTextEntry('STRING')
	AddTextComponentString(text)
	DrawText(x, y)
end


local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end


local function drawTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight / 2

		if menus[currentMenu].titleBackgroundSprite then
			DrawSprite(menus[currentMenu].titleBackgroundSprite.dict, menus[currentMenu].titleBackgroundSprite.name, x, y, menuWidth, titleHeight, 0., 255, 255, 255, 255)
		else
			drawRect(x, y, 0, titleHeight, menus[currentMenu].titleBackgroundColor)
		end

		drawText(menus[currentMenu].title, x, y - titleHeight / 2 + titleYOffset, menus[currentMenu].titleFont, menus[currentMenu].titleColor, titleScale, true)
	end
end


local function drawSubTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight + buttonHeight / 2

		local subTitleColor = { r = menus[currentMenu].titleBackgroundColor.r, g = menus[currentMenu].titleBackgroundColor.g, b = menus[currentMenu].titleBackgroundColor.b, a = 255 }

		drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
		drawText(menus[currentMenu].subTitle, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTitleColor, 0.4, false)

		if optionCount > menus[currentMenu].maxOptionCount then
			drawText(tostring(menus[currentMenu].currentOption)..' / '..tostring(optionCount), menus[currentMenu].x + menuWidth, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTitleColor, 0.4, false, false, true)
		end
	end
end


local function drawButton(text, subText)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = menus[currentMenu].menuTextColor
			subTextColor = menus[currentMenu].menuSubTextColor
			shadow = true
		end

		drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
		drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, 0.5, false, shadow)

		if subText then
			drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, 0.5, false, shadow, true)
		end
	end
end


function WarMenu.CreateMenu(id, title)
	-- Default settings
	menus[id] = { }
	menus[id].title = title
	menus[id].subTitle = 'INTERACTION MENU'

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.75
	menus[id].y = 0.19

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 10

	menus[id].titleFont = 4
	menus[id].titleColor = { r = 0, g = 0, b = 0, a = 255 }
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			local ra = RGBRainbow(1.0)
			menus[id].titleBackgroundColor = { r = ra.r, g = ra.g, b = ra.b, a = 255 }
			menus[id].menuFocusBackgroundColor = { r = ra.r, g = ra.g, b = ra.b, a = 255 }
		end
	end)
	menus[id].titleBackgroundSprite = nil

	menus[id].menuTextColor = { r = 255, g = 255, b = 255, a = 255 }
	menus[id].menuSubTextColor = { r = 255, g = 255, b = 255, a = 255 }
	menus[id].menuFocusTextColor = { r = 0, g = 0, b = 0, a = 255 }
	menus[id].menuFocusBackgroundColor = { r = 0, g = 0, b = 0, a = 255 }
	menus[id].menuBackgroundColor = { r = 0, g = 0, b = 0, a = 100 }

	menus[id].subTitleBackgroundColor = { r = menus[id].menuBackgroundColor.r, g = menus[id].menuBackgroundColor.g, b = menus[id].menuBackgroundColor.b, a = 130 }

	menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" } --https://pastebin.com/0neZdsZ5

	debugPrint(tostring(id)..' menu created')
end


function WarMenu.CreateSubMenu(id, parent, subTitle)
	if menus[parent] then
		WarMenu.CreateMenu(id, menus[parent].title)

		if subTitle then
			setMenuProperty(id, 'subTitle', string.upper(subTitle))
		else
			setMenuProperty(id, 'subTitle', string.upper(menus[parent].subTitle))
		end

		setMenuProperty(id, 'previousMenu', parent)

		setMenuProperty(id, 'x', menus[parent].x)
		setMenuProperty(id, 'y', menus[parent].y)
		setMenuProperty(id, 'maxOptionCount', menus[parent].maxOptionCount)
		setMenuProperty(id, 'titleFont', menus[parent].titleFont)
		setMenuProperty(id, 'titleColor', menus[parent].titleColor)
		setMenuProperty(id, 'titleBackgroundColor', menus[parent].titleBackgroundColor)
		setMenuProperty(id, 'titleBackgroundSprite', menus[parent].titleBackgroundSprite)
		setMenuProperty(id, 'menuTextColor', menus[parent].menuTextColor)
		setMenuProperty(id, 'menuSubTextColor', menus[parent].menuSubTextColor)
		setMenuProperty(id, 'menuFocusTextColor', menus[parent].menuFocusTextColor)
		setMenuProperty(id, 'menuFocusBackgroundColor', menus[parent].menuFocusBackgroundColor)
		setMenuProperty(id, 'menuBackgroundColor', menus[parent].menuBackgroundColor)
		setMenuProperty(id, 'subTitleBackgroundColor', menus[parent].subTitleBackgroundColor)
	else
		debugPrint('Failed to create '..tostring(id)..' submenu: '..tostring(parent)..' parent menu doesn\'t exist')
	end
end


function WarMenu.CurrentMenu()
	return currentMenu
end


function WarMenu.OpenMenu(id)
	if id and menus[id] then
		PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
		setMenuVisible(id, true)

		if menus[id].titleBackgroundSprite then
			RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
			while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do Citizen.Wait(0) end
		end

		debugPrint(tostring(id)..' menu opened')
	else
		debugPrint('Failed to open '..tostring(id)..' menu: it doesn\'t exist')
	end
end


function WarMenu.IsMenuOpened(id)
	return isMenuVisible(id)
end


function WarMenu.IsAnyMenuOpened()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then return true end
	end

	return false
end


function WarMenu.IsMenuAboutToBeClosed()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end


function WarMenu.CloseMenu()
	if menus[currentMenu] then
		if menus[currentMenu].aboutToBeClosed then
			menus[currentMenu].aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			debugPrint(tostring(currentMenu)..' menu closed')
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			optionCount = 0
			currentMenu = nil
			currentKey = nil
		else
			menus[currentMenu].aboutToBeClosed = true
			debugPrint(tostring(currentMenu)..' menu about to be closed')
		end
	end
end


function WarMenu.Button(text, subText)
	local buttonText = text
	if subText then
		buttonText = '{ '..tostring(buttonText)..', '..tostring(subText)..' }'
	end

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText)

		if isCurrent then
			if currentKey == keys.select then
				PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				debugPrint(buttonText..' button pressed')
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		debugPrint('Failed to create '..buttonText..' button: '..tostring(currentMenu)..' menu doesn\'t exist')

		return false
	end
end


function WarMenu.MenuButton(text, id)
	if menus[id] then
		if WarMenu.Button(text) then
			setMenuVisible(currentMenu, false)
			setMenuVisible(id, true, true)

			return true
		end
	else
		debugPrint('Failed to create '..tostring(text)..' menu button: '..tostring(id)..' submenu doesn\'t exist')
	end

	return false
end


function WarMenu.CheckBox(text, bool, callback)
	local checked = '~r~~h~Off'
	if bool then
		checked = '~g~~h~On'
	end

	if WarMenu.Button(text, checked) then
		bool = not bool
		debugPrint(tostring(text)..' checkbox changed to '..tostring(bool))
		callback(bool)

		return true
	end

	return false
end


function WarMenu.ComboBox(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = '← '..tostring(selectedItem)..' →'
	end

	if WarMenu.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
			if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end
		elseif currentKey == keys.right then
			if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end
		end
	else
		currentIndex = selectedIndex
	end

	callback(currentIndex, selectedIndex)
	return false
end


function WarMenu.Display()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			WarMenu.CloseMenu()
		else
			ClearAllHelpMessages()

			drawTitle()
			drawSubTitle()

			currentKey = nil

			if IsDisabledControlJustPressed(0, keys.down) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption < optionCount then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				else
					menus[currentMenu].currentOption = 1
				end
			elseif IsDisabledControlJustPressed(0, keys.up) then
				PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption > 1 then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				else
					menus[currentMenu].currentOption = optionCount
				end
			elseif IsDisabledControlJustPressed(0, keys.left) then
				currentKey = keys.left
			elseif IsDisabledControlJustPressed(0, keys.right) then
				currentKey = keys.right
			elseif IsDisabledControlJustPressed(0, keys.select) then
				currentKey = keys.select
			elseif IsDisabledControlJustPressed(0, keys.back) then
				if menus[menus[currentMenu].previousMenu] then
					PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					setMenuVisible(menus[currentMenu].previousMenu, true)
				else
					WarMenu.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end


function WarMenu.SetMenuWidth(id, width)
	setMenuProperty(id, 'width', width)
end


function WarMenu.SetMenuX(id, x)
	setMenuProperty(id, 'x', x)
end


function WarMenu.SetMenuY(id, y)
	setMenuProperty(id, 'y', y)
end


function WarMenu.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, 'maxOptionCount', count)
end


function WarMenu.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, 'titleColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleColor.a })
end
 
 
function WarMenu.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(id, 'titleBackgroundColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleBackgroundColor.a })
end


function WarMenu.SetTitleBackgroundSprite(id, textureDict, textureName)
	setMenuProperty(id, 'titleBackgroundSprite', { dict = textureDict, name = textureName })
end


function WarMenu.SetSubTitle(id, text)
	setMenuProperty(id, 'subTitle', string.upper(text))
end


function WarMenu.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(id, 'menuBackgroundColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuBackgroundColor.a })
end


function WarMenu.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, 'menuTextColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuTextColor.a })
end

function WarMenu.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, 'menuSubTextColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuSubTextColor.a })
end

function WarMenu.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, 'menuFocusColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuFocusColor.a })
end


function WarMenu.SetMenuButtonPressedSound(id, name, set)
	setMenuProperty(id, 'buttonPressedSound', { ['name'] = name, ['set'] = set })
end


function KeyboardInput(TextEntry, ExampleText, MaxStringLength)

	AddTextEntry('FMMC_KEY_TIP1', TextEntry .. ':')
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true 

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end


--#################################################################################--

-- First version done by rubylium then adapted for esx and finished by Ozne#4870

-- question or more scripts here : https://discord.gg/nx3TKM5

--#################################################################################--


function math.round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function RGBRainbow( frequency )
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = 66
	result.g = 244
	result.b = 86
	
	return result
end

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

local allWeapons = {"WEAPON_KNIFE","WEAPON_KNUCKLE","WEAPON_NIGHTSTICK","WEAPON_HAMMER","WEAPON_BAT","WEAPON_GOLFCLUB","WEAPON_CROWBAR","WEAPON_BOTTLE","WEAPON_DAGGER","WEAPON_HATCHET","WEAPON_MACHETE","WEAPON_FLASHLIGHT","WEAPON_SWITCHBLADE","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_COMBATPISTOL","WEAPON_APPISTOL","WEAPON_PISTOL50","WEAPON_SNSPISTOL","WEAPON_HEAVYPISTOL","WEAPON_VINTAGEPISTOL","WEAPON_STUNGUN","WEAPON_FLAREGUN","WEAPON_MARKSMANPISTOL","WEAPON_REVOLVER","WEAPON_MICROSMG","WEAPON_SMG","WEAPON_SMG_MK2","WEAPON_ASSAULTSMG","WEAPON_MG","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2","WEAPON_COMBATPDW","WEAPON_GUSENBERG","WEAPON_MACHINEPISTOL","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_ADVANCEDRIFLE","WEAPON_SPECIALCARBINE","WEAPON_BULLPUPRIFLE","WEAPON_COMPACTRIFLE","WEAPON_PUMPSHOTGUN","WEAPON_SAWNOFFSHOTGUN","WEAPON_BULLPUPSHOTGUN","WEAPON_ASSAULTSHOTGUN","WEAPON_MUSKET","WEAPON_HEAVYSHOTGUN","WEAPON_DBSHOTGUN","WEAPON_SNIPERRIFLE","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_MARKSMANRIFLE","WEAPON_GRENADELAUNCHER","WEAPON_GRENADELAUNCHER_SMOKE","WEAPON_RPG","WEAPON_STINGER","WEAPON_FIREWORK","WEAPON_HOMINGLAUNCHER","WEAPON_GRENADE","WEAPON_STICKYBOMB","WEAPON_PROXMINE","WEAPON_BZGAS","WEAPON_SMOKEGRENADE","WEAPON_MOLOTOV","WEAPON_FIREEXTINGUISHER","WEAPON_PETROLCAN","WEAPON_SNOWBALL","WEAPON_FLARE","WEAPON_BALL"}


local Enabled = true

local function TeleportToWaypoint()
	
	if DoesBlipExist(GetFirstBlipInfoId(8)) then
		local blipIterator = GetBlipInfoIdIterator(8)
		local blip = GetFirstBlipInfoId(8, blipIterator)
		WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --       EN DEV
		wp = true
	else
		drawNotification("~r~No waypoint!")
	end
	
	local zHeigt = 0.0 height = 1000.0
	while true do
		Citizen.Wait(0)
		if wp then
			if IsPedInAnyVehicle(GetPlayerPed(-1), 0) and (GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), 0), -1) == GetPlayerPed(-1)) then
				entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
			else
				entity = GetPlayerPed(-1)
			end

			SetEntityCoords(entity, WaypointCoords.x, WaypointCoords.y, height)
			FreezeEntityPosition(entity, true)
			local Pos = GetEntityCoords(entity, true)
			
			if zHeigt == 0.0 then
				height = height - 25.0
				SetEntityCoords(entity, Pos.x, Pos.y, height)
				bool, zHeigt = GetGroundZFor_3dCoord(Pos.x, Pos.y, Pos.z, 0)
			else
				SetEntityCoords(entity, Pos.x, Pos.y, zHeigt)
				FreezeEntityPosition(entity, false)
				wp = false
				height = 1000.0
				zHeigt = 0.0
				drawNotification("~g~Teleported to waypoint!")
				break
			end
		end
	end
end

local Spectating = false

function SpectatePlayer(player)
	local playerPed = PlayerPedId()
	Spectating = not Spectating
	local targetPed = GetPlayerPed(player)

	if(Spectating)then

		local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx,targety,targetz)
		NetworkSetInSpectatorMode(true, targetPed)

		drawNotification('Spectating '..GetPlayerName(player))
	else

		local targetx,targety,targetz = table.unpack(GetEntityCoords(targetPed, false))

		RequestCollisionAtCoord(targetx,targety,targetz)
		NetworkSetInSpectatorMode(false, targetPed)

		drawNotification('Stopped Spectating '..GetPlayerName(player))
	end
end



-- MAIN CODE --
function GetPlayers()
	local players = {}

	for _, i in ipairs(GetActivePlayers()) do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end

	return players
end


local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
	
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
	
		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next
	
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

function KillAllPeds()
	local pedweapon
	local pedid
	for ped in EnumeratePeds() do 
		if DoesEntityExist(ped) then
			pedid = GetEntityModel(ped)
			pedweapon = GetSelectedPedWeapon(ped)
			if (AntiCheat == true)then
				if pedweapon == -1312131151 or not IsPedHuman(ped) then 
					ApplyDamageToPed(ped, 1000, false)
					DeleteEntity(ped)
				else
					switch = function (choice)
					choice = choice and tonumber(choice) or choice
					
					case =
						{
						[451459928] = function ( )
							ApplyDamageToPed(ped, 1000, false)
							DeleteEntity(ped)
						end,
					
						[1684083350] = function ( )
							ApplyDamageToPed(ped, 1000, false)
							DeleteEntity(ped)
						end,
					
						[451459928] = function ( )
							ApplyDamageToPed(ped, 1000, false)
							DeleteEntity(ped)
						end,
					
						[1096929346] = function ( )
							ApplyDamageToPed(ped, 1000, false)
							DeleteEntity(ped)
						end,
					
						[880829941] = function ( )
							ApplyDamageToPed(ped, 1000, false)
							DeleteEntity(ped)
						end,
					
						[-1404353274] = function ( )
							ApplyDamageToPed(ped, 1000, false)
							DeleteEntity(ped)
						end,
					
						[2109968527] = function ( )
							ApplyDamageToPed(ped, 1000, false)
							DeleteEntity(ped)
						end,
					
						default = function ( )
						end,
					}
				
					if case[choice] then
						case[choice]()
					else
						case["default"]()
					end

					end
					switch(pedid) 
				end
			end
		end
	end
end


--#################################################################################--

-- First version done by rubylium then adapted for esx and finished by Ozne#4870

-- question or more scripts here : https://discord.gg/nx3TKM5

--#################################################################################--

Citizen.CreateThread(function()
	local currentPlayer = PlayerId()

	while Enabled do
		Citizen.Wait(0)

		local players = GetPlayers()
		
		SetPlayerInvincible(PlayerId(), Godmode)
		SetEntityInvincible(PlayerPedId(), Godmode)
	
		if ClearPNJ then
			thePeds = EnumeratePeds()
			PedStatus = 0
			for ped in thePeds do
				PedStatus = PedStatus + 1
				if PedStatus >= 1 then
					if not (IsPedAPlayer(ped))then
						DeleteEntity(ped)
						RemoveAllPedWeapons(ped, true)
					end
				end
			end
		end

		DisplayRadar(true)

		if Invisible then
			SetEntityVisible(GetPlayerPed(-1), false, 0)
		else
			SetEntityVisible(GetPlayerPed(-1), true, 0)
		end
	end
end)


-- FONCTION NOCLIP 
local noclip = false
local noclip_speed = 1.0

function admin_no_clip()
	noclip = not noclip
	local ped = GetPlayerPed(-1)
	if noclip then -- activé
		SetEntityVisible(ped, false, false)
		Notify("Noclip ~g~activé")
	else -- désactivé
		SetEntityVisible(ped, true, false)
		Notify("Noclip ~r~désactivé")
	end
end

function getPosition()
	local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
	return x,y,z
end

function getCamDirection()
	local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(GetPlayerPed(-1))
	local pitch = GetGameplayCamRelativePitch()

	local x = -math.sin(heading*math.pi/180.0)
	local y = math.cos(heading*math.pi/180.0)
	local z = math.sin(pitch*math.pi/180.0)

	local len = math.sqrt(x*x+y*y+z*z)
	if len ~= 0 then
		x = x/len
		y = y/len
		z = z/len
	end

	return x,y,z
end

function isNoclip()
	return noclip
end

-- noclip/invisible
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if noclip then
			local ped = GetPlayerPed(-1)
			local x,y,z = getPosition()
			local dx,dy,dz = getCamDirection()
			local speed = noclip_speed

			-- reset du velocity
			SetEntityVelocity(ped, 0.0001, 0.0001, 0.0001)

		-- aller vers le haut
		if IsControlPressed(0,32) then -- MOVE UP
			x = x+speed*dx
			y = y+speed*dy
			z = z+speed*dz
		end

		-- aller vers le bas
		if IsControlPressed(0,269) then -- MOVE DOWN
			x = x-speed*dx
			y = y-speed*dy
			z = z-speed*dz
		end

		SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
		end
	end
end)
-- FIN NOCLIP

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		if deleteVeh then
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed, false)
			local vehicle   = ESX.Game.GetVehicleInDirection()
			if IsPedInAnyVehicle(playerPed, true) then
				vehicle = GetVehiclePedIsIn(playerPed, false)
			end
			local entity = vehicle
			NetworkRequestControlOfEntity(entity)
			SetEntityAsMissionEntity(entity, true, true)
			Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
			if (DoesEntityExist(entity)) then 
				DeleteEntity(entity)
			end 
		end
	end
end)

local blipsStatus = 0

Citizen.CreateThread(function() 
	local headId = {}
	while true do
		Citizen.Wait(500)
		if blips1 then
			for _, id in ipairs(GetActivePlayers()) do
				if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= GetPlayerPed(-1) then
					ped = GetPlayerPed(id)
					blip = GetBlipFromEntity(ped)
					vehicule = IsPedInAnyVehicle(ped, true)

					if not DoesBlipExist(blip) then
						blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						ShowHeadingIndicatorOnBlip(blip, true)
					else
						veh = GetVehiclePedIsIn(ped, false)
						blipSprite = GetBlipSprite(blip)
						if GetEntityHealth(ped) < 1 then
							if blipSprite ~= 274 then
								SetBlipSprite(blip, 274)
								ShowHeadingIndicatorOnBlip(blip, false)
							end
						elseif veh then
							vehClass = GetVehicleClass(veh)
							vehModel = GetEntityModel(veh)
							if vehClass == 15 then
								if blipSprite ~= 422 then
									SetBlipSprite(blip, 422)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehClass == 8 then
								if blipSprite ~= 226 then
									SetBlipSprite(blip, 226)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehClass == 14 then
								if blipSprite ~= 427 then
									SetBlipSprite(blip, 427)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("rhino") then
								if blipSprite ~= 421 then
									SetBlipSprite(blip, 421)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("trash") or vehModel == GetHashKey("trash2") then
								if blipSprite ~= 318 then
									SetBlipSprite(blip, 318)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("seashark") or vehModel == GetHashKey("seashark2") or vehModel == GetHashKey("seashark3") then
								if blipSprite ~= 471 then
									SetBlipSprite(blip, 471)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("cargobob") or vehModel == GetHashKey("cargobob2") or vehModel == GetHashKey("cargobob3") or vehModel == GetHashKey("cargobob4") then
								if blipSprite ~= 481 then
									SetBlipSprite(blip, 481)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("taxi") then
								if blipSprite ~= 198 then
									SetBlipSprite(blip, 198)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif vehModel == GetHashKey("fbi") or vehModel == GetHashKey("fbi2") or vehModel == GetHashKey("police2") or vehModel == GetHashKey("police3")
								or vehModel == GetHashKey("police") or vehModel == GetHashKey("sheriff2") or vehModel == GetHashKey("sheriff")
								or vehModel == GetHashKey("policeold2") or vehModel == GetHashKey("policeold1") then
								if blipSprite ~= 56 then
									SetBlipSprite(blip, 56)
									SetBlipColour(blip, 38)
									ShowHeadingIndicatorOnBlip(blip, false)
								end
							elseif IsPedInAnyVehicle(ped, true) then
								local plate = GetVehicleNumberPlateText(veh)
								if plate == 'RESELLER' then
									SetBlipSprite(blip, 225)
									SetBlipColour(blip, 52)
									ShowHeadingIndicatorOnBlip(blip, false)
								elseif plate == ' GOFAST ' then
									SetBlipSprite(blip, 225)
									SetBlipColour(blip, 49)
									ShowHeadingIndicatorOnBlip(blip, false)
								else
									if blipSprite ~= 225 then
										SetBlipSprite(blip, 225)
										ShowHeadingIndicatorOnBlip(blip, false)
									end
								end
							elseif blipSprite ~= 1 then 
								SetBlipSprite(blip, 1)
								ShowHeadingIndicatorOnBlip(blip, true)
							end
							--passengers = GetVehicleNumberOfPassengers(veh)        EN DEV
							--if passengers then
							--	if not IsVehicleSeatFree(veh, -1) then
							--		passengers = passengers + 1
							--	end
							--	ShowNumberOnBlip(blip, passengers)
							--else
							--	HideNumberOnBlip(blip)
							--end
						else
							--HideNumberOnBlip(blip)        EN DEV
							if blipSprite ~= 1 then
								SetBlipSprite(blip, 1)
								ShowHeadingIndicatorOnBlip(blip, true)
							end
						end
						
						SetBlipRotation(blip, math.ceil(GetEntityHeading(veh)))
						--SetBlipNameToPlayerName(blip, id)
						SetBlipScale(blip,  0.85)
						if IsPauseMenuActive() then
							SetBlipAlpha( blip, 255 )
						else
							x1, y1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
							x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
							distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900

							if distance < 0 then
								distance = 0
							elseif distance > 255 then
								distance = 255
							end
							SetBlipAlpha(blip, distance)
						end
					end
				end
			end
		else
			for _, id in ipairs(GetActivePlayers()) do
				ped = GetPlayerPed(id)
				blip = GetBlipFromEntity(ped)
				if DoesBlipExist(blip) then
					RemoveBlip(blip)
				end
			end
		end
	end
end)


function DelVeh(veh)
	SetEntityAsMissionEntity(Object, 1, 1)
	DeleteEntity(Object)
	SetEntityAsMissionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, 1)
	DeleteEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false))
end

local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
	local generatedPlate
	local doBreak = false

	while true do
		Citizen.Wait(2)
		math.randomseed(GetGameTimer())
		generatedPlate = string.upper(GetRandomLetter(3) .. ' ' .. GetRandomNumber(3))

		ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function (isPlateTaken)
			if not isPlateTaken then
				doBreak = true
			end
		end, generatedPlate)

		if doBreak then
			break
		end
	end

	return generatedPlate
end

-- mixing async with sync tasks
function IsPlateTaken(plate)
	local callback = 'waiting'

	ESX.TriggerServerCallback('esx_vehicleshop:isPlateTaken', function(isPlateTaken)
		callback = isPlateTaken
	end, plate)

	while type(callback) == 'string' do
		Citizen.Wait(0)
	end

	return callback
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end


Citizen.CreateThread(function()

	WarMenu.CreateMenu('MainMenu', '')
	WarMenu.SetSubTitle('MainMenu', 'Menu Administration')
	WarMenu.CreateSubMenu('SelfMenu', 'MainMenu', 'Options ~b~>~s~')
-- Vehicule mod
	WarMenu.CreateSubMenu('VehMenu', 'MainMenu', 'Vehicule Custom ~b~>~s~')
-- Other	
	WarMenu.CreateSubMenu('PlayerMenu', 'MainMenu', 'Player Options ~b~>~s~')
	WarMenu.CreateSubMenu('OnlinePlayerMenu', 'PlayerMenu', 'Online Player Menu ~b~>~s~')
	WarMenu.CreateSubMenu('PlayerOptionsMenu', 'OnlinePlayerMenu', 'Player Options ~b~>~s~')
	WarMenu.CreateSubMenu('SingleWepPlayer', 'OnlinePlayerMenu', 'Single Weapon Menu ~b~>~s~')
	WarMenu.CreateSubMenu('SingleWepMenu', 'WepMenu', 'Single Weapon Menu ~b~>~s~')
	WarMenu.CreateSubMenu('kickall', 'PlayerMenu', 'Tu Est Sur ?')


	local SelectedPlayer
	

	while Enabled do
		if WarMenu.IsMenuOpened('MainMenu') then
			scaleform = RequestScaleformMovie('mp_menu_glare')
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(1)
			end
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			if WarMenu.MenuButton('Menu Admin ~b~>~s~', 'SelfMenu') then
			elseif WarMenu.MenuButton('Vehicule ~b~>~s~', 'VehMenu') then
			elseif WarMenu.MenuButton('Joueurs ~b~>~s~', 'PlayerMenu') then
		end

-- Self Menu			

		WarMenu.Display()
		DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		elseif WarMenu.IsMenuOpened('SelfMenu') then
		if WarMenu.CheckBox('Clear les PNJ humains', ClearPNJ, function(enabled)
			ClearPNJ = enabled
		end) then
		elseif WarMenu.CheckBox("Invisible",Invisible,function(enabled)
			Invisible = enabled
		end) then
		elseif WarMenu.Button('no clip') then
			admin_no_clip()
		--elseif WarMenu.Button('No Clip plus rapide ') then       EN DEV
			noclip_speed = noclip_speed + 0.3
		--elseif WarMenu.Button('No Clip moins rapide ') then       EN DEV
			noclip_speed = noclip_speed - 0.3
		elseif WarMenu.Button("~h~~r~Delete Vehicle") then
			--DelVeh(GetVehiclePedIsUsing(PlayerPedId()))       EN DEV
			TriggerEvent('esx:deleteVehicle')
			drawNotification("Vehicle Deleted")
		elseif WarMenu.Button('Se heal') then
			SetEntityHealth(PlayerPedId(), 200)
			TriggerServerEvent("logMenuAdmin", '\n- Se redonne de la vie ( Heal )')
		elseif WarMenu.Button('Se donner de l\'armure') then 
			SetPedArmour(PlayerPedId(), 200)
			TriggerServerEvent("logMenuAdmin", '\n- Se redonne de l\'armure( Heal )')
		elseif WarMenu.CheckBox('God Mode', Godmode, function(enabled)
			Godmode = enabled
		end) then
		elseif WarMenu.Button('Teleport to waypoint') then
			TeleportToWaypoint()
		--elseif WarMenu.Button("Refresh les ventes de véhicule") then
			TriggerEvent('esx-qalle-sellvehicles:refreshVehicles')
		elseif WarMenu.Button("Teleporte véhicule le plus proche") then
			local playerPed = GetPlayerPed(-1)
			local playerPedPos = GetEntityCoords(playerPed, true)
			local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
			local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
			local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
			local NearestPlanePos = GetEntityCoords(NearestPlane, true)
		drawNotification("~y~Attend...")
		Citizen.Wait(1000)
		if (NearestVehicle == 0) and (NearestPlane == 0) then
			drawNotification("~r~Pas de véhicule trouvé")
		elseif (NearestVehicle == 0) and (NearestPlane ~= 0) then
			if IsVehicleSeatFree(NearestPlane, -1) then
				SetPedIntoVehicle(playerPed, NearestPlane, -1)
				SetVehicleAlarm(NearestPlane, false)
				SetVehicleDoorsLocked(NearestPlane, 1)
				SetVehicleNeedsToBeHotwired(NearestPlane, false)
			else
				local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
				ClearPedTasksImmediately(driverPed)
				SetEntityAsMissionEntity(driverPed, 1, 1)
				DeleteEntity(driverPed)
				SetPedIntoVehicle(playerPed, NearestPlane, -1)
				SetVehicleAlarm(NearestPlane, false)
				SetVehicleDoorsLocked(NearestPlane, 1)
				SetVehicleNeedsToBeHotwired(NearestPlane, false)
			end
			drawNotification("~g~Teleported Into Nearest Vehicle!")
		elseif (NearestVehicle ~= 0) and (NearestPlane == 0) then
			if IsVehicleSeatFree(NearestVehicle, -1) then
				SetPedIntoVehicle(playerPed, NearestVehicle, -1)
				SetVehicleAlarm(NearestVehicle, false)
				SetVehicleDoorsLocked(NearestVehicle, 1)
				SetVehicleNeedsToBeHotwired(NearestVehicle, false)
			else
				local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
				ClearPedTasksImmediately(driverPed)
				SetEntityAsMissionEntity(driverPed, 1, 1)
				DeleteEntity(driverPed)
				SetPedIntoVehicle(playerPed, NearestVehicle, -1)
				SetVehicleAlarm(NearestVehicle, false)
				SetVehicleDoorsLocked(NearestVehicle, 1)
				SetVehicleNeedsToBeHotwired(NearestVehicle, false)
			end
			drawNotification("~g~Teleported Into Nearest Vehicle!")
		elseif (NearestVehicle ~= 0) and (NearestPlane ~= 0) then
			if Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
				if IsVehicleSeatFree(NearestVehicle, -1) then
					SetPedIntoVehicle(playerPed, NearestVehicle, -1)
					SetVehicleAlarm(NearestVehicle, false)
					SetVehicleDoorsLocked(NearestVehicle, 1)
					SetVehicleNeedsToBeHotwired(NearestVehicle, false)
				else
					local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
					ClearPedTasksImmediately(driverPed)
					SetEntityAsMissionEntity(driverPed, 1, 1)
					DeleteEntity(driverPed)
					SetPedIntoVehicle(playerPed, NearestVehicle, -1)
					SetVehicleAlarm(NearestVehicle, false)
					SetVehicleDoorsLocked(NearestVehicle, 1)
					SetVehicleNeedsToBeHotwired(NearestVehicle, false)
				end
			elseif Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
				if IsVehicleSeatFree(NearestPlane, -1) then
					SetPedIntoVehicle(playerPed, NearestPlane, -1)
					SetVehicleAlarm(NearestPlane, false)
					SetVehicleDoorsLocked(NearestPlane, 1)
					SetVehicleNeedsToBeHotwired(NearestPlane, false)
				else
					local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
					ClearPedTasksImmediately(driverPed)
					SetEntityAsMissionEntity(driverPed, 1, 1)
					DeleteEntity(driverPed)
					SetPedIntoVehicle(playerPed, NearestPlane, -1)
					SetVehicleAlarm(NearestPlane, false)
					SetVehicleDoorsLocked(NearestPlane, 1)
					SetVehicleNeedsToBeHotwired(NearestPlane, false)
				end
			end
			drawNotification("~g~Teleported Into Nearest Vehicle!")
		end
		elseif WarMenu.Button('Suicide') then
			SetEntityHealth(PlayerPedId(), 0)
			drawNotification("~r~You Committed Suicide.")
		--elseif WarMenu.Button('Debug Vehicule plate (DEV)') then       EN DEV
			local newPlate	= GeneratePlate()
			local vehicle = GetVehiclePedIsUsing(PlayerPedId())
			SetVehicleNumberPlateText(vehicle, newPlate)
		--elseif WarMenu.Button('Debug Vehicule perso (DEV)') then       EN DEV
			local vehicle = GetVehiclePedIsUsing(PlayerPedId())
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			TriggerServerEvent("esx_vehicleshop:setVehicleOwned", vehicleProps)
		end

-- Véhicule Menu

			WarMenu.Display()
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		elseif WarMenu.IsMenuOpened('VehMenu') then
			if WarMenu.MenuButton('Vehicle Spawner ~b~>~s~', 'SpawnVehMenu') then
			elseif WarMenu.Button('Repair Vehicle') then
				SetVehicleFixed(GetVehiclePedIsUsing(PlayerPedId()))
				TriggerServerEvent("logMenuAdmin", 'Réparation de véhicule')
			elseif WarMenu.Button("~h~~r~Delete Vehicle") then
				TriggerEvent('esx:deleteVehicle')
				TriggerServerEvent("logMenuAdmin", 'Delete de véhicule')
			elseif WarMenu.CheckBox('Delete Veh boucle', deleteVeh, function(enabled)
					deleteVeh = enabled
				end) then
			--elseif WarMenu.Button("~g~Vente d'occasion : Retiré tout les véhicules") then       EN DEV
				TriggerServerEvent("deleteVehAll")
			--elseif WarMenu.Button("~g~Vente d'occasion : Mettre tout les véhicules") then       EN DEV
				TriggerServerEvent("spawnVehAll")
			end




			WarMenu.Display()
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		elseif WarMenu.IsMenuOpened('PlayerMenu') then
			if WarMenu.CheckBox('Activer les Blips des Joueurs', blips1, function(enabled)
					blips1 = enabled
					blipsStatus = blipsStatus + 1
					if blipsStatus == 1 then
						TriggerServerEvent("logMenuAdmin", '\n- Blips activer ( Voir les joueurs sur la map )')
					elseif blipsStatus >= 2 then
						TriggerServerEvent("logMenuAdmin", '\n- Blips désactiver ( Voir les joueurs sur la map )')
						blipsStatus = 0
					end
				end) then
			elseif WarMenu.MenuButton('~h~~r~Action sur tout les joueurs', 'kickall') then
			--elseif WarMenu.Button("~h~~r~Kick all") then       EN DEV
			--	TriggerServerEvent('kickAllPlayer')			       EN DEV
			elseif WarMenu.MenuButton("Online Players ~b~>~s~", "OnlinePlayerMenu") then
			end
		
			WarMenu.Display()
		elseif WarMenu.IsMenuOpened('kickall') then
			if WarMenu.MenuButton('~g~Non', 'PlayerMenu') then
			--elseif WarMenu.MenuButton('~g~Non', 'PlayerMenu') then       EN DEV
			--elseif WarMenu.MenuButton('~g~Non', 'PlayerMenu') then       EN DEV
			--elseif WarMenu.MenuButton('~g~Non', 'PlayerMenu') then       EN DEV
			elseif WarMenu.Button("~h~~r~Kick all ( Avant les restart serveur )") then
				TriggerServerEvent('kickAllPlayer2')	
			elseif WarMenu.Button('~g~forcer la save des iventaires de tlm') then
				TriggerServerEvent('SavellPlayer')
			elseif WarMenu.Button('~g~Revive all') then
				TriggerServerEvent('ReviveAll')
			--elseif WarMenu.MenuButton('~g~Non', 'PlayerMenu') then       EN DEV
			--elseif WarMenu.MenuButton('~g~Non', 'PlayerMenu') then       EN DEV
			--elseif WarMenu.MenuButton('~g~Non', 'PlayerMenu') then       EN DEV
			--elseif WarMenu.MenuButton('~g~Non', 'PlayerMenu') then 
			end

-- Menu autre joueur
			
			WarMenu.Display()
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		elseif WarMenu.IsMenuOpened('PlayerMenu') then
			if WarMenu.CheckBox('Activer les Blips des Joueurs', blips1, function(enabled)
					blips1 = enabled
				end) then
			elseif WarMenu.MenuButton("Online Players ~b~>~s~", "OnlinePlayerMenu") then
			end

			WarMenu.Display()
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		elseif WarMenu.IsMenuOpened("OnlinePlayerMenu") then
			for _, i in ipairs(GetActivePlayers()) do
				if GetPlayerServerId(i) ~= 0 and WarMenu.MenuButton("~p~["..GetPlayerServerId(i).."]~w~ "..GetPlayerName(i).." "..(IsPedDeadOrDying(GetPlayerPed(i), 1) and "~r~[MORT]" or "~g~[VIVANT]"), 'PlayerOptionsMenu') then
					SelectedPlayer = i
				end
			end
			
			WarMenu.Display()
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		elseif WarMenu.IsMenuOpened("PlayerOptionsMenu") then
			WarMenu.SetSubTitle("PlayerOptionsMenu", "Player Options ["..GetPlayerName(SelectedPlayer).."]")
			if WarMenu.Button('Spectate le joueur', (Spectating and "~g~[SPECTATING]")) then
				SpectatePlayer(SelectedPlayer)
				name = GetPlayerName(SelectedPlayer)
				TriggerServerEvent("logMenuAdmin", '\nSpec un joueur ('..name..')')
			elseif WarMenu.Button('Se téléporter') then
				local Entity = IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsUsing(PlayerPedId()) or PlayerPedId()
				SetEntityCoords(Entity, GetEntityCoords(GetPlayerPed(SelectedPlayer)), 0.0, 0.0, 0.0, false)
			elseif WarMenu.MenuButton('Give une arme', 'SingleWepPlayer') then
			elseif WarMenu.Button('Give Vehicule') then
				local ped = GetPlayerPed(SelectedPlayer)
				local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)

				if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
					RequestModel(ModelName)
					while not HasModelLoaded(ModelName) do
						Citizen.Wait(0)
					end

					local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped), true, true)
					name = GetPlayerName(SelectedPlayer)
					TriggerServerEvent("logMenuAdmin", '\n- Give de véhicule pour ('..name..')\nLe véhicule : '..ModelName..'')
				else
					drawNotification("~r~Model is not valid!")
				end
			elseif WarMenu.Button("Expulser du Vehicle") then
				ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
			elseif WarMenu.Button("Revive le joueur") then
				TriggerServerEvent('esx_ambulancejob:revive2', GetPlayerServerId(SelectedPlayer))
			end
			
			WarMenu.Display()
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
			DrawScaleformMovie(scaleform, 1.183, 0.6247, 0.9, 0.9, 255, 255, 255, 255, 0)
		elseif WarMenu.IsMenuOpened("SingleWepPlayer") then
			for player=1, #allWeapons do
				if WarMenu.Button(allWeapons[player]) then
					GiveWeaponToPed(GetPlayerPed(SelectedPlayer), GetHashKey(allWeapons[player]), 1000, false, true)
					name = GetPlayerName(SelectedPlayer)
					TriggerServerEvent("logMenuAdmin", '\n- Give une arme à un joueur ('..name..')\nArme en question : '..allWeapons[player]..' ')
				end
			end
			


			WarMenu.Display()
		elseif IsDisabledControlPressed(0, 289) then
			ESX.TriggerServerCallback('RubyMenu:getUsergroup', function(group)
				playergroup = group
				if playergroup == 'superadmin' or playergroup == 'owner' then
					superadmin = true
					Citizen.Wait(10)
					WarMenu.OpenMenu('MainMenu')
					ESX.ShowAdvancedNotification('STAFF INFO', 'STAFF MENU ~g~ON', 'Menu staff ouvert.\nTon grade:~g~ '..playergroup..'', 'CHAR_ACTING_UP	', 8)
				elseif playergroup == 'dev' or playergroup == 'mod' or playergroup == 'admin' then
					superadmin = false
					Citizen.Wait(10)
					WarMenu.OpenMenu('MainMenu')
					ESX.ShowAdvancedNotification('STAFF INFO', 'STAFF MENU ~g~ON', 'Menu staff ouvert.\nTon grade:~g~ '..playergroup..'', 'CHAR_ACTING_UP	', 8)
				end
			end)
		end

		Citizen.Wait(0)
	end
end)



--##################################################################################--

-- First version done by rubylium then adapted for esx and finished by Ozne#4870

-- question or more scripts here : https://discord.gg/nx3TKM5

--##################################################################################--
