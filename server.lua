ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('reventaos:userpeds:pedCheck', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll('SELECT * FROM reventaos_user_peds WHERE licence = @licence', {
			['@licence'] = xPlayer.licence,
		}, function(result)
			if result[1] ~= nil then
				cb(result[1])
			else
				cb(nil)
			end
		end)
	else
		cb(nil)
	end
end)

RegisterServerEvent('reventaos:userpeds:saveRandomized')
AddEventHandler('reventaos:userpeds:saveRandomized', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchAll('SELECT * FROM reventaos_user_peds WHERE licence = @licence', {['@licence'] = xPlayer.licence}, function(result2)
		if result2[1] ~= nil then
			MySQL.Async.execute('UPDATE reventaos_user_peds SET randomized = @randomized WHERE licence = @licence',{['@randomized'] = true, ['@licence'] = xPlayer.licence})
		end
	end)
end)
			

TriggerEvent('es:addGroupCommand', 'darped', 'superadmin', function(source, args, user)
	local _source = source
	local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))
	local pedModel   = args[2]

	if xTarget ~= nil then
		if pedModel ~= nil then
			MySQL.Async.fetchAll('SELECT * FROM reventaos_user_peds WHERE pedmodel = @pedmodel', {
				['@pedmodel'] = pedModel,
			}, function(result)
				if result[1] == nil then
					MySQL.Async.fetchAll('SELECT * FROM reventaos_user_peds WHERE licence = @licence', {
						['@licence'] = xTarget.licence,
					}, function(result2)
						if result2[1] == nil then
							MySQL.Async.execute('INSERT INTO reventaos_user_peds (licence, pedmodel) VALUES (@licence, @pedmodel)',{
								['@licence'] = xTarget.licence, ['@pedmodel'] = pedModel})
							TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, { type = 'inform', text = 'Your ped have confirmed. Please re-enter!'})
						else
							TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'This people already have a pedmodel!'})
						end
					end)
				else
					TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'This model is already in use!'})
				end
			end)
		else
			TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'empty_pedmodel'})
		end
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'empty_id'})
	end
end,  function(source, args, user)
	TriggerClientEvent('chat:addMessage', _source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end)

TriggerEvent('es:addGroupCommand', 'borrarped', 'superadmin', function(source, args, user)
	local _source = source
	local xTarget = ESX.GetPlayerFromId(tonumber(args[1]))

	if xTarget ~= nil then
		MySQL.Async.fetchAll('SELECT * FROM reventaos_user_peds WHERE licence = @licence', {
			['@licence'] = xTarget.licence,
		}, function(result)
			if result[1] ~= nil then
				MySQL.Async.fetchAll('DELETE FROM reventaos_user_peds WHERE licence = @licence',{['@licence'] = xTarget.licence})
				TriggerClientEvent('mythic_notify:client:SendAlert', xTarget.source, { type = 'error', text = 'Your peds been removed. Please re-enter!'})
			else
				TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'This people don\'t already have a model!'})
			end
		end)
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'error', text = 'empty_id'})
	end
end,  function(source, args, user)
	TriggerClientEvent('chat:addMessage', _source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end)


