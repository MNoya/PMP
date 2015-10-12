---------------------------------------------------------------------------
if PMP == nil then
	_G.PMP = class({})
end
---------------------------------------------------------------------------

require('libraries/timers')
require('libraries/physics')
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
require('sounds')
require('damage')

---------------------------------------------------------------------------

function Precache( context )
	print("[PMP] Performing pre-load precache")

	PrecacheResource("soundfile", "soundevents/pmp_custom_sounds.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/undead_soundset.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/blood_elf_soundset.vsndevts", context)

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

	PrecacheUnitByNameSync("goblin", context)
	PrecacheUnitByNameSync("goblin_leader", context)
	PrecacheUnitByNameSync("super_goblin", context)
	PrecacheUnitByNameSync("goblin_garage", context)
	PrecacheUnitByNameSync("goblin_pimpery", context)	
	PrecacheUnitByNameSync("goblin_tower", context)
	PrecacheUnitByNameSync("goblin_ghost", context)

	PrecacheUnitByNameSync("blood_elf", context)
	PrecacheUnitByNameSync("blood_elf_leader", context)
	PrecacheUnitByNameSync("super_blood_elf", context)
	PrecacheUnitByNameSync("blood_elf_garage", context)
	PrecacheUnitByNameSync("blood_elf_pimpery", context)
	PrecacheUnitByNameSync("blood_elf_tower", context)
	PrecacheUnitByNameSync("blood_elf_ghost", context)

	PrecacheUnitByNameSync("skeleton", context)
	PrecacheUnitByNameSync("skeleton_leader", context)
	PrecacheUnitByNameSync("super_skeleton", context)
	PrecacheUnitByNameSync("skeleton_garage", context)
	PrecacheUnitByNameSync("skeleton_pimpery", context)
	PrecacheUnitByNameSync("skeleton_tower", context)
	PrecacheUnitByNameSync("skeleton_shade", context)
	PrecacheUnitByNameSync("skeleton_ghost", context)

	PrecacheUnitByNameSync("night_elf", context)
	PrecacheUnitByNameSync("night_elf_leader", context)
	PrecacheUnitByNameSync("super_night_elf", context)
	PrecacheUnitByNameSync("night_elf_garage", context)
	PrecacheUnitByNameSync("night_elf_pimpery", context)
	PrecacheUnitByNameSync("night_elf_tower", context)
	PrecacheUnitByNameSync("night_elf_ghost", context)
	PrecacheUnitByNameSync("nightelf_owl", context)

	PrecacheUnitByNameSync("treant", context)
	PrecacheUnitByNameSync("treant_leader", context)
	PrecacheUnitByNameSync("super_treant", context)
	PrecacheUnitByNameSync("treant_garage", context)
	PrecacheUnitByNameSync("treant_pimpery", context)
	PrecacheUnitByNameSync("treant_tower", context)
	PrecacheUnitByNameSync("treant_ghost", context)

	PrecacheUnitByNameSync("nian_boss", context)

	PrecacheUnitByNameSync("npc_dota_hero_axe", context)
	PrecacheUnitByNameSync("npc_dota_hero_sven", context)
	PrecacheUnitByNameSync("npc_dota_hero_faceless_void", context)

	PrecacheItemByNameSync("upgrade_critical_strike", context)
	PrecacheItemByNameSync("upgrade_stun_hit", context)
	PrecacheItemByNameSync("upgrade_pulverize", context)
	PrecacheItemByNameSync("upgrade_poisoned_weapons", context)
	PrecacheItemByNameSync("upgrade_dodge", context)
	PrecacheItemByNameSync("upgrade_spiked_armor", context)

	PrecacheResource("particle", "particles/radiant_fx2/frostivus_wking_altar_smokering.vpcf", context)
	PrecacheResource("particle_folder", "particles/custom", context)
	PrecacheResource("particle_folder", "particles/units/heroes/hero_techies", context)

	-- Absolutely necessary end game effects
	PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_ursa/ursa_earthshock_soil1.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_thundergods_wrath_start_bolt_parent.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_disruptor/disruptor_thunder_strike_bolt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_disruptor/disruptor_kf_formation.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_gyrocopter/gyro_calldown_explosion_second.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lina/lina_spell_light_strike_array_explosion.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_warlock/warlock_rain_of_chaos_explosion.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/leshrac/leshrac_tormented_staff/leshrac_split_tormented.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", context)
	
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

	local projectiles = HATS['quiver']['projectile']
	for k,effectName in pairs(projectiles) do
		PrecacheResource("particle", effectName, context)
	end

	local AttachmentDatabase = LoadKeyValues("scripts/attachments.txt")
	local Particles = AttachmentDatabase['Particles']
	for k,model in pairs(Particles) do
		for effectName,values in pairs(model) do
			if string.match(effectName, "vpcf") then
				PrecacheResource("particle", effectName, context)
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