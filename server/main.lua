ESX = nil
local shopItems = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


function UcitajItemeESXBalkan()

	local result = ESXBalkan
		for i=1, #result, 1 do
			if shopItems[result[i].zone] == nil then
				shopItems[result[i].zone] = {}
			end

			table.insert(shopItems[result[i].zone], {
				item  = result[i].item,
				price = result[i].price,
				label = ESX.GetWeaponLabel(result[i].item)
			})
		end

		TriggerClientEvent('esx_weaponshop:sendShop', -1, shopItems)
end

UcitajItemeESXBalkan()

ESX.RegisterServerCallback('esx_weaponshop:getShop', function(source, cb)
	cb(shopItems)
end)

ESX.RegisterServerCallback('esx_weaponshop:buyLicense', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= Config.LicensePrice then
		xPlayer.removeMoney(Config.LicensePrice)

		TriggerEvent('esx_license:addLicense', source, 'weapon', function()
			cb(true)
		end)
	else
		xPlayer.showNotification(_U('not_enough'))
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_weaponshop:buyWeapon', function(source, cb, weaponName, zone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = 0
	print(ESXBalkan)
	for i=1, #shopItems[zone], 1 do
		if shopItems[zone][i].item == weaponName then
			price = shopItems[zone][i].price
			break
		end
	end

	if price == 0 then
		print(('esx_weaponshop: %s attempted to buy a unknown weapon!'):format(xPlayer.identifier))
		cb(false)
	end

	if xPlayer.hasWeapon(weaponName) then
		TriggerClientEvent('esx:showNotification', source, _U('already_owned'))
		cb(false)
	else
		if zone == 'BlackWeashop' then

			if xPlayer.getAccount('bank').money >= price then
				xPlayer.removeAccountMoney('bank', price)
				xPlayer.addWeapon(weaponName, 42)

				cb(true)
			else
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_black'))
				cb(false)
			end

		else

			if xPlayer.getMoney() >= price then
				xPlayer.removeMoney(price)
				xPlayer.addWeapon(weaponName, 42)
				posaljinaDiscord("Weaponshop " .. xPlayer.getName() .. " bought " .. weaponName)
				cb(true)
			else
				TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
				cb(false)
			end
	
		end
	end
end)

function posaljinaDiscord(name, message)
	local vremeporuke = os.date('*t')
	local poruka = {
		{
			["color"] = 16711680,
			["title"] = "**".. name .."**",
			["description"] = message,
			["footer"] = {
			["text"] = "Logovi\nVreme: " .. vremeporuke.hour .. ":" .. vremeporuke.min .. ":" .. vremeporuke.sec,
			},
		}
	  }
	PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "Logovi", embeds = poruka, avatar_url = "https://cdn.discordapp.com/attachments/732353958349242460/764825950458085414/IMG_20201011_123627_852.jpg"}), { ['Content-Type'] = 'application/json' })
  end
