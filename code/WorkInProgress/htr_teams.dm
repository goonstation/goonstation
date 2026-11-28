#define WEAPON_VENDOR_CATEGORY_SIDEARM "sidearm"
#define WEAPON_VENDOR_CATEGORY_LOADOUT "loadout"
#define WEAPON_VENDOR_CATEGORY_UTILITY "utility"
#define WEAPON_VENDOR_CATEGORY_AMMO "ammo"

/obj/submachine/weapon_vendor/htr
	icon_state = "weapon"
	token_accepted = /obj/item/requisition_token/htr_team
	color = list(0.0915563,0.174466,1.18311,0.886063,0.627332,-1.22787,0.0223806,0.198203,1.04476)

/obj/submachine/weapon_vendor/htr/medical
	name = "Medical Equipment Vendor"
	desc = "An automated quartermaster service for supplying medical equipment?"

	New()
		materiel_stock += new/datum/materiel/sidearm/htr_team/medic/syringe_gun
		materiel_stock += new/datum/materiel/sidearm/htr_team/medic/tranqu_rifle

		materiel_stock += new/datum/materiel/utility/htr_team/medical/pfd
		materiel_stock += new/datum/materiel/utility/htr_team/medical/haloperidol
		materiel_stock += new/datum/materiel/utility/htr_team/medical/atropine
		materiel_stock += new/datum/materiel/utility/htr_team/janitor/biohazard
		materiel_stock += new/datum/materiel/utility/htr_team/janitor/bodybags

		..()

	accepted_token()
		src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]+=2
		..()

/datum/materiel/sidearm/htr_team/medic/syringe_gun
	name = "Syringe Gun"
	path = /obj/item/gun/reagent/syringe/NT
	description = "For when you need to apply medical aid from range."

/datum/materiel/sidearm/htr_team/medic/tranqu_rifle
	name = "Tranquilizer Rifle"
	path = /obj/item/gun/reagent/syringe/NT
	description = "A veterinary tranquilizer rifle chambered in .308 caliber. For the unruley patient."
/datum/materiel/utility/htr_team/medical/pfd
	name = "perfluorodecalin bottle"
	path = /obj/item/reagent_containers/glass/bottle/pfd
	description = "A small bottle of perfluorodecalin, an experimental liquid-breathing medicine."

/datum/materiel/utility/htr_team/medical/haloperidol
	name = "haloperidol bottle"
	path = /obj/item/reagent_containers/glass/bottle/haloperidol
	description = "A small bottle of haloperidol, a powerful anti-psychotic."

/datum/materiel/utility/htr_team/medical/atropine
	name = "atropine bottle"
	path = /obj/item/reagent_containers/glass/bottle/atropine
	description = "A small bottle containing atropine, used for cardiac emergencies and as a stabilizer in extreme medical cases."


/datum/materiel/sidearm/htr_team/medic/tranqu_pistol
	name = "\improper Gwydion tranquilizer pistol"
	path = /obj/item/gun/kinetic/tranq_pistol
	description = "A subtle but very capable tranquilizer pistol. For the uncooperative patient."

/obj/submachine/weapon_vendor/htr/janitor
	name = "Janitor Equipment Vendor"
	desc = "An automated quartermaster service for supplying janitors with gear. And weapons?"

	New()
		materiel_stock += new/datum/materiel/sidearm/htr_team/janitor/sponge
		materiel_stock += new/datum/materiel/sidearm/htr_team/janitor/mop
		//materiel_stock += new/datum/materiel/sidearm/htr_team/janitor/taser

		materiel_stock += new/datum/materiel/utility/htr_team/janitor/cleaner_grenade
		materiel_stock += new/datum/materiel/utility/htr_team/janitor/trashbags
		materiel_stock += new/datum/materiel/utility/htr_team/janitor/biohazard
		materiel_stock += new/datum/materiel/utility/htr_team/janitor/bodybags

		materiel_stock += new/datum/materiel/loadout/htr_team/tsunami
		//materiel_stock += new/datum/materiel/loadout/htr_team/cleansing_fire

		..()

	accepted_token()
		src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]+=2
		..()

/obj/item/requisition_token/htr_team
	name = "requisition token"
	desc = "An NT-provided token compatible with the High Threat Response Vendors."
	icon_state = "req-token-sec"

/datum/materiel/sidearm/htr_team/janitor/sponge
	name = "Sponge"
	path = /obj/item/sponge
	description = "A sponge for when you really want to be hands on."

/datum/materiel/sidearm/htr_team/janitor/mop
	name = "Mop"
	path = /obj/item/mop
	description = "A mop for when you are on the move."

/datum/materiel/sidearm/htr_team/janitor/taser
	name = "Stun Gun"
	path = /obj/item/gun/energy/taser_gun
	description = "A stun gun? What?"

/datum/materiel/utility/htr_team/janitor/trashbags
	name = "Trashbags"
	path = /obj/item/storage/box/trash_bags
	description = "Box of trashbags."

/datum/materiel/utility/htr_team/janitor/biohazard
	name = "Biobags"
	path = /obj/item/storage/box/biohazard_bags
	description = "Box of biohazard bags. Eww"

/datum/materiel/utility/htr_team/janitor/bodybags
	name = "Body bags"
	path = /obj/item/storage/box/body_bag
	description = "Box of body bags.  For when things are really stacking up."

/obj/item/storage/grenade_pouch/cleaner
	name = "cleaner grenade pouch"
	spawn_contents = list(/obj/item/chem_grenade/cleaner = 6)

/datum/materiel/utility/htr_team/janitor/cleaner_grenade
	name = "Cleaner Grenade Pouch"
	path = /obj/item/storage/grenade_pouch/cleaner
	description = "A foaming space cleaner brought to you by BLAM! The cleanest!"

/obj/item/storage/belt/htr/tsunami
	spawn_contents = list(/obj/item/sponge, /obj/item/spraybottle/cleaner/tsunami)

/datum/materiel/loadout/htr_team/tsunami
	name = "Spray Away"
	path = /obj/item/storage/belt/htr/tsunami
	description = "One belt containing a sponge and a state of the art spray bottle."

/obj/item/gun/flamethrower/backtank/cleansing_fire
	New()
		..()
		gastank.reagents.add_reagent("fuel", 1000)
		gastank.reagents.add_reagent("cleaner", 3000)
		color = list(0.315206,0.388882,1.89671,0.251797,1.38374,-2.6323,0.341149,-0.60873,1.57955)

/datum/materiel/loadout/htr_team/cleansing_fire
	name = "Fire Away"
	path = /obj/item/gun/flamethrower/backtank/cleansing_fire
	description = "A flamethrower. Sometimes you need to burn it all away..."


/obj/submachine/weapon_vendor/htr/security
	name = "Security Weapons Vendor"
	desc = "An automated quartermaster service for supplying your security team with weapons and gear."
	icon_state = "weapon-sec"

	New()
		..()
		materiel_stock += new/datum/materiel/loadout/standard
		materiel_stock += new/datum/materiel/loadout/offense
		materiel_stock += new/datum/materiel/loadout/control
		materiel_stock += new/datum/materiel/loadout/suppression
		materiel_stock += new/datum/materiel/utility/morphineinjectors
		materiel_stock += new/datum/materiel/utility/donuts
		materiel_stock += new/datum/materiel/utility/crowdgrenades
		materiel_stock += new/datum/materiel/utility/prisonerscanner
		materiel_stock += new/datum/materiel/ammo/medium
		materiel_stock += new/datum/materiel/ammo/self_charging

	accepted_token()
		//src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]+=2
		src.credits[WEAPON_VENDOR_CATEGORY_AMMO]++
		..()


/obj/submachine/weapon_vendor/htr/security/detective
	color = list(1.05185,0.296296,-0.0814815,-0.0752689,0.569892,0.11828,0.0234172,0.133811,0.963202)
	New()
		..()
		materiel_stock += new/datum/materiel/ammo/htr/detective/a38_stun
		materiel_stock += new/datum/materiel/ammo/htr/detective/a38
		materiel_stock += new/datum/materiel/loadout/htr_team/gadget_hat
		materiel_stock += new/datum/materiel/utility/htr_team/janitor/bodybags

/datum/materiel/ammo/htr/detective/a38
	name = ".38 speedloader"
	path = /obj/item/ammo/bullets/a38
	description = "When you need to shoot someone dead."

/datum/materiel/ammo/htr/detective/a38_stun
	name = ".38 Stun speedloader"
	path = /obj/item/ammo/bullets/a38/stun
	description = "When you need to shoot someone but gently."

/datum/materiel/loadout/htr_team/gadget_hat
	name = "DetGadget hat"
	path = /obj/item/clothing/head/det_hat/gadget
	description = "The acme of technological haberdashery."

/obj/submachine/weapon_vendor/htr/purge
	name = "Purge Team Weapons Vendor"
	desc = "An automated quartermaster service for the removal and silencing of assets."
	color = null

	New()
		..()
		materiel_stock += new/datum/materiel/loadout/htr_team/acid_fire
		materiel_stock += new/datum/materiel/loadout/htr_team/rpg
		materiel_stock += new/datum/materiel/loadout/htr_team/lmg
		materiel_stock += new/datum/materiel/loadout/htr_team/sniper
		materiel_stock += new/datum/materiel/loadout/htr_team/grenade_launcher

		materiel_stock += new/datum/materiel/utility/rpg_ammo
		materiel_stock += new/datum/materiel/utility/htr_team/lmg_ammo
		materiel_stock += new/datum/materiel/utility/htr_team/sniper_ammo
		materiel_stock += new/datum/materiel/utility/htr_team/grenade_rounds
		materiel_stock += new/datum/materiel/utility/donk
		materiel_stock += new/datum/materiel/utility/belt
		materiel_stock += new/datum/materiel/utility/saxitoxin_grenade
		materiel_stock += new/datum/materiel/utility/htr_team/grenades_mixed
		materiel_stock += new/datum/materiel/utility/htr_team/janitor/bodybags

	accepted_token()
		//src.credits[WEAPON_VENDOR_CATEGORY_SIDEARM]++
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]+=2
		..()

/datum/materiel/loadout/htr_team/grenade_launcher
	name = "\improper Rigil grenade launcher"
	path = /obj/item/gun/kinetic/grenade_launcher
	description = "A 40mm hand-held grenade launcher for bringing the grenades to them."

/datum/materiel/utility/htr_team/grenade_rounds
	name = "Grenade Round Pouch"
	path = /obj/item/storage/pouch/grenade_round
	description = "A mix of 40mm Explosive Grenades."

/datum/materiel/utility/htr_team/grenades_mixed
	name = "Grenade Pouch"
	path = /obj/item/storage/grenade_pouch/mixed_standard
	description = "2 Flash, 2 Frag, 2 Stinger."

/datum/materiel/utility/crowdgrenades
	name = "Crowd Dispersal Grenades"
	path = /obj/item/storage/box/crowdgrenades
	description = "Four 'Crowd Dispersal' pepper gas grenades, capable of clearing out riots. Also seasons food quite well!"

/datum/materiel/loadout/htr_team/sniper
	name = "\improper Betelgeuse sniper rifle"
	path = /obj/item/gun/kinetic/sniper
	description = "A semi-automatic bullpup sniper rifle for when you need really reach outo and touch someone."

/datum/materiel/utility/htr_team/sniper_ammo
	name = "Sniper Ammo Pouch"
	path = /obj/item/storage/pouch/sniper
	description = "Pouch filled with 7.62×51mm NATO magazines."

/datum/materiel/loadout/htr_team/lmg
	name = "\improper Antares light machine gun"
	path = /obj/item/gun/kinetic/light_machine_gun
	description = "When you need maximum bullets down range."

/datum/materiel/utility/htr_team/lmg_ammo
	name = "LMG Ammo Pouch"
	path = /obj/item/storage/pouch/lmg
	description = "When you need more bullets so you can send them down range."

/datum/materiel/loadout/htr_team/rpg
	name = "Rocket Launcher"
	path = /obj/item/gun/kinetic/rpg7
	description = "A rocket-propelled grenade launcher."

/datum/materiel/loadout/htr_team/acid_fire
	name = "Flamethrower Pack"
	path = /obj/item/gun/flamethrower/backtank/acid_fire
	description = "A flamethrower with proprietary blend of pain."

/obj/item/gun/flamethrower/backtank/acid_fire
	New()
		..()
		gastank.reagents.add_reagent("oil", 2000)
		gastank.reagents.add_reagent("napalm_goo", 1000)
		gastank.reagents.add_reagent("clacid", 1000)


/datum/materiel/utility/htr_team/engineer/oxy_grenades
	name = "Oxygen Grenade Pouch"
	path = /obj/item/storage/grenade_pouch/oxygen
	description = "A pouch filled 6 red oxygen grenades for rapid repressurization."
/datum/materiel/utility/htr_team/engineer/foam_grenades
	name = "Metal Foam Grenade Pouch"
	path = /obj/item/storage/grenade_pouch/metal_foam
	description = "A pouch filled with 6 metal foam grenades for rapid breach filling."
/datum/materiel/utility/htr_team/engineer/rcd_ammo
	name = "Extended RCD Cartridge"
	path = /obj/item/rcd_ammo/big
	description = "An extra large RCD cartridge for extended repair efforts."
/datum/materiel/loadout/htr_team/engineer/jetpack
	name = "EVA Mobility Kit"
	path = /obj/item/tank/jetpack
	description = "A high capacity jetpack for maneuvering through the void of space."

/datum/materiel/loadout/htr_team/engineer/hand_tele
	name = "Stationside Mobility Kit"
	path = /obj/item/hand_tele
	description = "A handheld teleporter for travel around the station."

/obj/submachine/weapon_vendor/htr/engineer
	name = "Engineering Equipment Vendor"
	desc = "An automated quartermaster service for supplying your Engineering team with gear."

	New()
		materiel_stock += new/datum/materiel/utility/htr_team/engineer/oxy_grenades
		materiel_stock += new/datum/materiel/utility/htr_team/engineer/foam_grenades
		materiel_stock += new/datum/materiel/utility/htr_team/engineer/rcd_ammo

		materiel_stock += new/datum/materiel/loadout/htr_team/engineer/jetpack
		materiel_stock += new/datum/materiel/loadout/htr_team/engineer/hand_tele
		..()

	accepted_token()
		src.credits[WEAPON_VENDOR_CATEGORY_LOADOUT]++
		src.credits[WEAPON_VENDOR_CATEGORY_UTILITY]+=2
		..()

#undef WEAPON_VENDOR_CATEGORY_SIDEARM
#undef WEAPON_VENDOR_CATEGORY_LOADOUT
#undef WEAPON_VENDOR_CATEGORY_UTILITY
#undef WEAPON_VENDOR_CATEGORY_AMMO

/obj/machinery/computer/transit_shuttle/htr_team
	shuttlename = "High Threat Response Team Shuttle"
	ejectdir = NORTH

	New()
		..()
		destinations = list(/area/shuttle/htr_team/station)
		currentlocation = locate(/area/shuttle/htr_team/transit)

/area/shuttle/htr_team/station
	name="HTR Team Destination"

/area/shuttle/htr_team/transit
	name="HTR Team Setup"

/datum/random_event/special/htr_team
	name = "High Threat Response Team"
	description = "Generates a staging ship and offers ghosts to respawn as a special emergency crew role to assist the station"
	customization_available = 1
	announce_to_admins = 0 // Doing it manually.
	disabled = TRUE
	var/lock = FALSE
	var/team_count = 0
	var/ghost_confirmation_delay = 20 SECONDS // time to acknowledge or deny respawn offer.
	var/allow_antags = FALSE
	var/respawn_job
	var/delay_spawn
	var/list/team_type = list("Nanotrasen Special Operative"=list("vendor"=/obj/submachine/weapon_vendor/htr/security, "bot"=null/*/obj/machinery/bot/secbot*/), // bot path commented out for mob secbot test merge
							"Detective"=list("vendor"=/obj/submachine/weapon_vendor/htr/security/detective, "bot"=/obj/machinery/bot/guardbot),
							"Janitor"=list("vendor"=/obj/submachine/weapon_vendor/htr/janitor, "bot"=/obj/machinery/bot/cleanbot),
							"Nanotrasen Emergency Repair Technician"=list("vendor"=/obj/submachine/weapon_vendor/htr/engineer, "bot"=/obj/machinery/bot/floorbot),
							"Nanotrasen Emergency Medic"=list("vendor"=/obj/submachine/weapon_vendor/htr/medical, "bot"=/obj/machinery/bot/medbot))
	var/objective_text
	var/list/regions = list()

	admin_call(var/source)
		if (..())
			return

		src.team_count = input(usr, "How big of a team to spawn? ([length(eligible_dead_player_list(allow_dead_antags = allow_antags, for_antag = FALSE))] players eligible)", src.name, 0) as num|null

		src.respawn_job = tgui_input_list(usr,"Team of...", "Team Type", team_type, "Nanotrasen Security Consultant")

		src.objective_text = tgui_input_text(usr, "Custom objective text", "Objective", "Ensure the station is safe.")

		if(alert("Do you want to delay for any customization?","Delay Ghost Call?","Yes","No") == "Yes")
			delay_spawn = TRUE

		if(!isnull(src.team_count) && src.respawn_job)
			src.event_effect(source)

	event_effect(var/source)
		if(src.lock) return
		if(isnull(src.team_count)) return
		if(!src.respawn_job) return

		src.lock = TRUE

		var/is_antag = FALSE
		var/datum/allocated_region/region = get_singleton(/datum/mapPrefab/allocated/htr_team).load()
		regions += region

		var/vendor_type = src.team_type[src.respawn_job]["vendor"]
		var/bot_type = src.team_type[src.respawn_job]["bot"]
		for(var/turf/T in landmarks[LANDMARK_HTR_VENDOR])
			if(vendor_type) new vendor_type(T)
			landmarks[LANDMARK_HTR_VENDOR] -= T
		for(var/turf/T in landmarks[LANDMARK_HTR_BOTS])
			if(bot_type) new bot_type(T)
			landmarks[LANDMARK_HTR_BOTS] -= T

		message_admins("HTR vessel generated at [log_loc(region.bottom_left)].")

		if(delay_spawn)
			tgui_alert(usr, "Continue when you are complete...","Ready?!?",list("Continue"))

		// 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as member of an elite team? Your name will be added to the list of eligible candidates and may be selected at random by the game.")
		text_messages.Add("You are eligible to be respawned as a member of an elite team. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages, allow_dead_antags = allow_antags, for_antag = FALSE)

		objective_text = {"Ensure the station and its crew are safe."}

		for (var/i = 1 to src.team_count)
			if (!length(candidates))
				break
			var/datum/mind/mind = candidates[1]
			log_respawn_event(mind, "HRT: [src.respawn_job]", source)
			src.spawn_as_job(src.respawn_job, mind.current, pick_landmark(LANDMARK_HTR_TEAM), is_antag)
			candidates -= mind
			if (src.objective_text)
				new /datum/objective/crew/custom(src.objective_text, mind)
				boutput(mind.current, "<span style='font-size:24px'>You have respawned as a [src.respawn_job].</span>")
				boutput(mind.current, "<span style='font-size:24px'>Your objective is: [src.objective_text]</span>")
				SPAWN(0)
					tgui_alert(mind.current, "You have respawned as a [src.respawn_job]. Your objective is: [src.objective_text]", "Respawned", list("Ok"))



		src.post_event()

	proc/spawn_as_job(job, mob/player, turf/location, antag)
		var/mob/living/carbon/human/normal/M = new/mob/living/carbon/human/normal(location)
		SPAWN(0)
			M.JobEquipSpawned(job)
			M.equip_new_if_possible(/obj/item/requisition_token/htr_team, SLOT_IN_BACKPACK)

		player.mind?.wipe_antagonists()
		if(!player.mind)
			player.mind = new (player)
		player.mind.assigned_role = job
		M.job = job
		player.mind.transfer_to(M)
		SPAWN(5 SECONDS)
			if(player && !player:client)
				qdel(player)

	proc/post_event()
		if (!src || !istype(src, /datum/random_event/special/htr_team))
			return

		src.lock = initial(src.lock)
		src.team_count = initial(src.team_count)
		src.ghost_confirmation_delay = initial(src.ghost_confirmation_delay)
		src.allow_antags = initial(src.allow_antags)

		//Purge landmark if another ship is desired...
		landmarks[LANDMARK_HTR_TEAM] = list()

		return
