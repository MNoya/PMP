---------------------------------------------------------------------------
if PMP == nil then
	_G.PMP = class({})
end
---------------------------------------------------------------------------

require('libraries/timers')
require('libraries/popups')
require('libraries/notifications')
require('libraries/animations')
require('libraries/attachments')
require('statcollection/init')
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
	PrecacheUnitByNameSync("peon_ghost", context)

	PrecacheUnitByNameSync("undead", context)
	PrecacheUnitByNameSync("undead_leader", context)
	PrecacheUnitByNameSync("super_undead", context)
	PrecacheUnitByNameSync("undead_garage", context)
	PrecacheUnitByNameSync("undead_pimpery", context)	
	PrecacheUnitByNameSync("undead_tower", context)
	PrecacheUnitByNameSync("undead_ghost", context)

	PrecacheUnitByNameSync("human", context)
	PrecacheUnitByNameSync("human_leader", context)
	PrecacheUnitByNameSync("super_human", context)
	PrecacheUnitByNameSync("human_garage", context)
	PrecacheUnitByNameSync("human_pimpery", context)	
	PrecacheUnitByNameSync("human_tower", context)
	PrecacheUnitByNameSync("human_ghost", context)

	PrecacheUnitByNameSync("nian_boss", context)

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
	_G.HATS = LoadKeyValues("scripts/kv/upgrades.kv")
	for k,slot_table in pairs(HATS) do
		for key,value in pairs(slot_table) do
			if type(value) ~= "table" then
				if string.match(value, "vmdl") then
					PrecacheModel(value, context)
				end
			end
		end
	end

	local AttachmentDatabase = LoadKeyValues("scripts/attachments.txt")
	local Particles = AttachmentDatabase['Particles']
	for k,modelName in pairs(Particles) do
		local effectName = modelName['EffectName']
		if effectName then
			PrecacheResource("particle", effectName, context)
		end
	end
end

-- Create our game mode and initialize it
function Activate()
	print ( '[PMP] Creating Game Mode' )
	PMP:InitGameMode()
end

---------------------------------------------------------------------------