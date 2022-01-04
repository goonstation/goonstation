/datum/action/bar/icon/antag_medbot_inject
	duration = 5 SECONDS
	interrupt_flags =  INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE
	id = "medbot_inject"
	icon = 'icons/obj/syringe.dmi'
	icon_state = "0"
	var/mob/living/critter/antag_medibot/master
	var/victim
	var/list/reagent_id
	var/ranged = FALSE

	New(var/the_bot, var/list/reagentid, var/rangedattack, var/injectamt,var/the_victim)
		src.master = the_bot
		src.reagent_id = reagentid
		src.ranged = rangedattack

		if(ranged)
			REMOVE_FLAG(interrupt_flags, INTERRUPT_MOVE) //move while creating gas
		else
			src.victim = the_victim

		..()

	onStart()
		..()

		attack_twitch(master)
		if(!ranged)
			master.visible_message("<span class='alert'><B>[master] is trying to inject [victim]!</B></span>")
		else
			master.visible_message("<span class='alert'><B>[master] is releasing smoke!</B></span>")
			//medbot code yoink
			if(prob(25))
				var/glitchsound = pick('sound/machines/romhack1.ogg', 'sound/machines/romhack2.ogg', 'sound/machines/romhack3.ogg',\
					'sound/machines/glitch1.ogg','sound/machines/glitch2.ogg','sound/machines/glitch3.ogg','sound/machines/glitch4.ogg','sound/machines/glitch5.ogg')
				playsound(master.loc, glitchsound, 50, 1)
				SPAWN_DBG(1 DECI SECOND)
					master.pixel_x += rand(-2,2)
					master.pixel_y += rand(-2,2)
					sleep(0.1 SECONDS)
					master.pixel_x += rand(-2,2)
					master.pixel_y += rand(-2,2)
					sleep(0.1 SECONDS)
					master.pixel_x += rand(-2,2)
					master.pixel_y += rand(-2,2)
					sleep(0.1 SECONDS)
					master.pixel_x = 0
					master.pixel_y = 0
				hit_twitch(master)

	onEnd()
		..()
		if ( !ranged && (get_dist(master, victim) <= 1))
			var/mob/living/carbon/victimm = victim
			var/list/syr_words = list()
			for(var/reag in reagent_id)
				victimm.reagents.add_reagent(reag, reagent_id[reag])
				syr_words += reagent_id_to_name(reag)

			master.visible_message("<span class='alert'><B>[master] injects [victim] with a dose of [english_list(syr_words)]!</B></span>")

		else

			var/list/sput_words = list()
			var/datum/reagents/sput = new/datum/reagents(1)
			for(var/reagent in reagent_id)
				sput.maximum_volume += round(reagent_id[reagent] / length(reagent_id))
				sput.add_reagent(reagent, round(reagent_id[reagent] / length(reagent_id)))
				sput_words += reagent_id_to_name(reagent)

			smoke_reaction(sput, 1, get_turf(master))
			master.visible_message("<span class='alert'>A shower of [english_list(sput_words)] shoots out of [master]'s hypospray!</span>")

		playsound(master, 'sound/items/hypo.ogg', 80, 0)

/datum/limb/medibot_syringe
	var/list/reagent_id = list(
	"formaldehyde" = 15,
	"ketamine" = 25,
	"haloperidol" = 15,
	"morphine" = 20,
	"cold_medicine" = 40,
	"simethicone" = 10,
	"sulfonal" = 5, /* its an oldetimey sedative */
	"atropine" = 10,
	"methamphetamine" = 30,
	"ethanol" = 20, /* rubbing alcohol */
	"ether" = 10,
	"cyanide" = 10,
	"chlorine" = 10, /* disinfectant */
	"lithium" = 5,
	"fluorine" = 5,
	"mercury" = 5)
	var/cooldown = 35 SECONDS
	var/next_shot_at = 0
	var/image/default_obscurer

	is_on_cooldown()
		if (ticker.round_elapsed_ticks < next_shot_at)
			return next_shot_at - ticker.round_elapsed_ticks
		return 0

	proc/attempt_inject(atom/target, var/mob/living/user, var/ranged)
		if (next_shot_at > ticker.round_elapsed_ticks)
			return
		next_shot_at = ticker.round_elapsed_ticks + cooldown

		if(!ranged && target == null)
			return
		if(!ranged && !iscarbon(target))
			return

		var/list/poisons = list()
		for(var/i in 1 to rand(2,4))
			var/reagent = pick(src.reagent_id)
			poisons[reagent] = src.reagent_id[reagent]

		actions.start(new/datum/action/bar/icon/antag_medbot_inject(user, poisons, ranged, target), user)

	help(mob/target, var/mob/user)
		attempt_inject(target,user,FALSE)
		return

	harm(mob/target, var/mob/user)
		attempt_inject(target,user,FALSE)
		return

	attack_range(atom/target, var/mob/user, params)
		attempt_inject(target,user,TRUE)

//datums about the medibots limbs probably fit here more
/mob/living/critter/antag_medibot
	name = "Medibot"
	real_name = "Medibot"
	desc = "You dont recognize this model."
	density = 1
	icon = 'icons/misc/evilreaverstation.dmi'
	icon_state = "medibot0"
	custom_gib_handler = /proc/robogibs
	hand_count = 2
	can_throw = 0
	can_grab = 1 //what could go wrong
	can_disarm = 0
	can_help = 1 // this is what intent it defaults to and nobody bothers to swap their intents, sooo
	blood_id = "oil"
	speechverb_say = "states"
	speechverb_gasp = "states"
	speechverb_stammer = "states"
	speechverb_exclaim = "declares"
	speechverb_ask = "queries"
	metabolizes = 0

	New()
		. = ..()
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/staggered_or_blocking, src.type)
		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).add_mob(src)
		add_simple_light("derelict_medbot", list(220, 220, 255, 0.5*255))
		APPLY_MOB_PROPERTY(src, PROP_THERMALVISION, src)
		APPLY_MOB_PROPERTY(src, PROP_BREATHLESS, src) //so you dont gas the medibot with their own attacks like last time
		APPLY_MOB_PROPERTY(src, PROP_CANTSPRINT, src)

	death(var/gibbed)
		..(gibbed, 0)
		if (!gibbed)
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)
			ghostize()
			qdel(src)
		else
			playsound(src.loc, "sound/impact_sounds/Machinery_Break_1.ogg", 100, 1)
			make_cleanable(/obj/decal/cleanable/oil,src.loc)

		get_image_group(CLIENT_IMAGE_GROUP_HEALTH_MON_ICONS).remove_mob(src)

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, "sound/voice/screams/robot_scream.ogg" , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> screams!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

	setup_equipment_slots()
		equipment += new /datum/equipmentHolder/ears/intercom(src)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.limb = new /datum/limb/medibot_syringe
		HH.name = "Hypospray Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "syringegun"
		HH.limb_name = "Cybernetic Injection Device"
		HH.can_hold_items = 0
		HH.can_attack = 1
		HH.can_range_attack = 1

		HH = hands[2]
		HH.limb = new /datum/limb/small_critter/strong
		HH.name = "Cybernetic Medi-Arm"
		HH.icon = 'icons/mob/critter_ui.dmi'
		HH.icon_state = "handn"
		HH.limb_name = "Cybernetic Manipulators"
		src.put_in_hand(new /obj/item/scalpel(),2)

	setup_healths()
		add_hh_robot(60, 1)
		add_hh_robot_burn(35, 1.5) //FRY THE THANG

	get_melee_protection(zone, damage_type)
		return 4

	get_ranged_protection()
		return 0

	get_disorient_protection()
		return max(..(), 80)

	attack_hand(mob/user)
		user.lastattacked = src
		if(!user.stat)
			if (user.a_intent != INTENT_HELP)
				actions.interrupt(src, INTERRUPT_ATTACKED)
			switch(user.a_intent)
				if(INTENT_HELP) //Friend person
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -2)
					user.visible_message("<span class='notice'>[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")].</span>")
				if(INTENT_DISARM) //Shove
					playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
					user.visible_message("<span class='alert'><B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B></span>")
				if(INTENT_GRAB) //Shake
					if (istype(user, /mob/living/carbon/human/machoman))
						return ..()
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1, -2)
					user.visible_message("<span class='alert'>[user] shakes [src] [pick_string("descriptors.txt", "borg_shake")]!</span>")
				if(INTENT_HARM) //Dumbo
					if (istype(user, /mob/living/carbon/human/machoman))
						return ..()
					if (ishuman(user))
						if (user.is_hulk())
							src.TakeDamage("All", 5, 0)
							if (prob(20))
								var/turf/T = get_edge_target_turf(user, user.dir)
								if (isturf(T))
									src.visible_message("<span class='alert'><B>[user] savagely punches [src], sending them flying!</B></span>")
									src.throw_at(T, 10, 2)
								else
									src.visible_message("<span class='alert'><B>[user] punches [src]!</B></span>")
							playsound(src.loc, pick(sounds_punch), 50, 1, -1)
						else
							user.visible_message("<span class='alert'><B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!</span>", "<span class='alert'><B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B></span>")
							random_brute_damage(user, rand(2,5))
							playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 60, 1)
							if(prob(10)) user.show_text("Your hand hurts...", "red")
					else
						return ..()
