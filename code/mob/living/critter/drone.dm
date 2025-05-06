/mob/living/critter/robotic/drone
	name = "drone"
	real_name = "drone"
	var/drone_designation = "SC"
	var/num_max = 999
	desc = "An armed and automated Syndicate scout drone."
	density = 1
	icon = 'icons/mob/critter/robotic/drone/phaser.dmi'
	icon_state = "drone_phaser"
	custom_gib_handler = /proc/robogibs
	hand_count = 1
	can_throw = 0
	can_grab = 0
	can_disarm = 0
	blood_id = "oil"
	var/dying = 0
	speech_verb_say = "states"
	speech_verb_gasp = "states"
	speech_verb_stammer = "states"
	speech_verb_exclaim = "declares"
	speech_verb_ask = "queries"
	metabolizes = 0
	var/list/loot_table = list()
	var/smashes_shit = 1
	var/list/alert_sounds = list('sound/machines/whistlealert.ogg', 'sound/machines/whistlebeep.ogg')

	faction = list(FACTION_SYNDICATE)

	New()
		..()
		setup_loot_table()
		name = "[initial(name)] [drone_designation]-[rand(num_max)]"

	bump(atom/movable/AM)
		if(smashes_shit)
			if(isobj(AM))
				if (istype(AM, /obj/critter) || istype(AM, /obj/machinery/vehicle))
					return
				if(istype(AM, /obj/window))
					var/obj/window/W = AM
					W.health = 0
					W.smash()
				else if(istype(AM,/obj/mesh/grille))
					var/obj/mesh/grille/G = AM
					G.damage_blunt(30)
				else if(istype(AM, /obj/table))
					AM.meteorhit()
				else if(istype(AM, /obj/foamedmetal))
					AM.dispose()
				else
					AM.meteorhit()
				playsound(src.loc, 'sound/effects/exlow.ogg', 70,1)
				src.visible_message(SPAN_ALERT("<B>[src]</B> smashes into \the [AM]!"))
		..()

	proc/setup_loot_table()
		loot_table = list(/obj/item/device/prox_sensor = 25)

	death(var/gibbed)
		. = ..()
		if (dying)
			return
		dying = 1
		var/image/dying_overlay = SafeGetOverlayImage("dying", 'icons/mob/critter/robotic/drone/overlays.dmi', "dying-overlay", MOB_OVERLAY_BASE)
		src.UpdateOverlays(dying_overlay, "dying")
		SPAWN(2 SECONDS)
			ghostize()
			var/turf/L = get_turf(src)
			for (var/T in loot_table)
				var/P = loot_table[T]
				while (P > 0)
					if (P > 100)
						new T(L)
						P -= 100
					else
						if (prob(P))
							new T(L)
						P = 0
						break
			qdel(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream", "alert")
				if (src.emote_check(voluntary, 50))
					playsound(src, pick(alert_sounds) , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> broadcasts an alert!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream", "alert")
				return 2
		return ..()

	is_spacefaring()
		return 1

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1
		inertia_dir = 0

	examine(mob/user)
		. = ..()
		var/perc = get_health_percentage()
		switch(perc)
			if(75 to 100)
				return
			if(50 to 74)
				. += "[src] looks lightly [pick("dented", "burned", "scorched", "scratched")]."
			if(25 to 49)
				. += "[src] looks [pick("quite", "pretty", "rather")] [pick("dented", "busted", "messed up", "burned", "scorched", "haggard")]."
			if(0 to 24)
				. += "[src] looks [pick("really", "totally", "very", "all sorts of", "super")] [pick("mangled", "busted", "messed up", "burned", "broken", "haggard", "smashed up", "trashed")]."

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/gun/energy/phaser
		HH.name = "S-1 Light Anti-Personnel Energy Sling"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handphs"
		HH.limb_name = "S-1 Light Anti-Personnel Energy Sling"
		HH.can_hold_items = 0
		HH.can_attack = 0
		HH.can_range_attack = 1

	setup_healths()
		add_hh_robot(50, 1)
		add_hh_robot_burn(50, 1)
