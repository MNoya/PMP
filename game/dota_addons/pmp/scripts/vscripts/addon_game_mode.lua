---------------------------------------------------------------------------
if PMP == nil then
	_G.PMP = class({})
end
---------------------------------------------------------------------------

require('libraries/timers')
require('libraries/popups')
require('libraries/notifications')
require('pmp')
require('orders')
require('mechanics')
require('developer')
require('upgrades')
require('utilities')
require('wearables')

---------------------------------------------------------------------------

function Precache( context )
	print("[PMP] Performing pre-load precache")

	PrecacheResource("soundfile", "soundevents/pmp_custom_sounds.vsndevts", context)

	PrecacheUnitByNameSync("peon", context)
	PrecacheUnitByNameSync("peon_leader", context)
	PrecacheUnitByNameSync("super_peon", context)
	PrecacheUnitByNameSync("peon_garage", context)
	PrecacheUnitByNameSync("peon_pimpery", context)	
	PrecacheUnitByNameSync("peon_tower", context)

	PrecacheUnitByNameSync("npc_dota_hero_axe", context)
	PrecacheUnitByNameSync("npc_dota_hero_sven", context)

	PrecacheItemByNameSync("upgrade_critical_strike", context)
	PrecacheItemByNameSync("upgrade_stun_hit", context)
	PrecacheItemByNameSync("upgrade_pulverize", context)
	PrecacheItemByNameSync("upgrade_poisoned_weapons", context)
	PrecacheItemByNameSync("upgrade_dodge", context)
	PrecacheItemByNameSync("upgrade_spiked_armor", context)

	PrecacheResource("particle_folder", "particles/custom", context)

	--Barricade models
	GameRules.Barricades = LoadKeyValues("scripts/kv/barricades.kv")
	for k,v in pairs(GameRules.Barricades) do
		if type(v) == "table" then
			local model = v["Model"]
			if model then
				PrecacheModel(model, context)
			end
		end
	end
	
	-- Wearables
	_G.HATS = LoadKeyValues("scripts/kv/wearables.kv")
	for race,v1 in pairs(HATS) do
		for slot,v2 in pairs(v1) do
			for k,v in pairs(v2) do
				local model = v["Model"]
				if model and model ~= "" then
					PrecacheModel(model, context)
				end

				local particle = v["Particle"]
				if particle and particle ~= "" then
					PrecacheResource("particle", particle, context)
				end
			end
		end
	end

end

-- Create our game mode and initialize it
function Activate()
	print ( '[PMP] Creating Game Mode' )
	PMP:InitGameMode()
end

---------------------------------------------------------------------------