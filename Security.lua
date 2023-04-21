-- Security.lua
-- Simple data file security for the WOW Hardcore addon
-- Written by Frank de Jong

local tampered_status = false

local WARNING_MESSAGE = "CHANGES TO THIS FILE ARE MONITORED AND WILL LEAD TO IRREVOCABLE LOSS OF VERIFICATION STATUS!"

-- Hash function for the checksum
local function Hardcore_Checksum(data)
	local sum1 = 0
	local sum2 = 0
	for index=1,#data do
		sum1 = (sum1 + string.byte(string.sub(data,index,index))) % 255;
		sum2 = (sum2 + sum1) % 255;
	end
	return bit.bor(bit.lshift(sum2,8), sum1)
end

-- Calculate a checksum for the relevant data
local function Hardcore_CalculateChecksum()
	if Hardcore_Character ~= nil then
		local function GetRunString( run )
			local d = run.name .. run.date .. run.level .. run.id
			if run.iid ~= nil then
				d = d .. run.iid
			end
			if run.party ~= nil then
				d = d .. run.party
			end
			if run.num_kills ~= nil then
				d = d .. run.num_kills
			end
			if run.start ~= nil then
				d = d .. run.start
			end
			if run.last_seen ~= nil then
				d = d .. run.last_seen
			end
			if run.idle ~= nil then
				d = d .. run.idle
			end
			if run.bosses ~= nil then
				d = d .. #run.bosses
			end
			return d
		end

		local function GetAchievementsString( ach )
			local d = ""
			for _, v in ipairs(ach) do
				d = d .. v
			end
			return d
		end

		local hc = Hardcore_Character
		local data = #hc.deaths .. #hc.trade_partners .. #hc.bubble_hearth_incidents ..
				#hc.achievements .. #hc.passive_achievements ..
				hc.time_played .. hc.time_tracked

		-- Checksum for the logged, pending and current runs
		if hc.dt.runs ~= nil then
			for i, v in ipairs( hc.dt.runs ) do
				data = data .. GetRunString( v )
			end
		end
		if hc.dt.pending ~= nil then
			for i, v in ipairs( hc.dt.pending ) do
				data = data .. GetRunString( v )
			end
		end
		if hc.dt.current ~= nil and next( hc.dt.current ) then
			data = data .. GetRunString( hc.dt.current )
		end
		if hc.dt.repeated_runs ~= nil then
			data = data .. hc.dt.repeated_runs
		end
		if hc.dt.overleveled_runs ~= nil then
			data = data .. hc.dt.overleveled_runs
		end

		-- Add achievement names
		if hc.achievements ~= nil then
			data = data .. GetAchievementsString( hc.achievements )
		end
		if hc.passive_achievements ~= nil then
			data = data .. GetAchievementsString( hc.passive_achievements )
		end

		return Hardcore_Checksum( data )
	end
	return ""
end

-- Insert a warning in the data file and on the console
local function Hardcore_InsertModificationWarning()
	if WARNING == nil or WARNING == "" then
		WARNING = "-- " .. WARNING_MESSAGE .. " --"
		Hardcore_Character.checksum = 1
		Hardcore:Print( "Data file security mechanism engaged")
	end
end

-- Returns a string identifying the data file security status
function Hardcore_GetSecurityStatus()
	if tampered_status == true then
		return "TAMPERED"
	end
	if Hardcore_Character.checksum == nil then
		return "?"
	elseif Hardcore_Character.checksum == -1 then
		return "TAMPERED"
	else
		return "OK"
	end
end

-- Calculate and store the checksum to the file
function Hardcore_StoreChecksum()
	if Hardcore_Character ~= nil then
		if tampered_status == false then
			Hardcore_Character["checksum"] = Hardcore_CalculateChecksum()
		else
			Hardcore_Character["checksum"] = -1			-- This will trigger data integrity warning the next time
		end
	end
end

-- Do a check of the checksum
function Hardcore_VerifyChecksum()
	if WARNING == nil or WARNING == "" then 
		Hardcore_InsertModificationWarning()
	elseif Hardcore_Character ~= nil then
		local the_checksum = Hardcore_CalculateChecksum()
		local tampered = false
		if Hardcore_Character["checksum"] == nil then
			tampered = true
		elseif Hardcore_Character["checksum"] ~= the_checksum then
			tampered = true
		end
		if tampered == true then
			Hardcore:Print( "You have tampered with the data file -- your run is now invalid!")
			Hardcore:Print( "The Hardcore mods will be notified.")
			-- Make sure the warning is displayed again!
			WARNING = "-- " .. WARNING_MESSAGE .. " ---"
			tampered_status = true
		else
			Hardcore:Print( "Data file integrity okay")
		end
	end
end
