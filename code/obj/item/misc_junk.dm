// The misc crap that used to clutter up item.dm and didn't fit elsewhere.

/obj/item/lens
	name = "Lens"
	desc = "A lens of some sort. Not super useful on its own."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lens"
	amount = 1
	throwforce = 1
	force = 1
	w_class = W_CLASS_TINY

/obj/item/coil
	desc = "A coil. Not really useful without additional components."
	icon = 'icons/obj/items/items.dmi'
	amount = 1

	small
		name = "small coil"
		icon_state = "small_coil"
		throwforce = 3
		force = 3
		w_class = W_CLASS_TINY

/obj/item/gnomechompski
	name = "Gnome Chompski"
	desc = "What."
	icon = 'icons/obj/junk.dmi'
	icon_state = "gnome"
	w_class = W_CLASS_BULKY
	stamina_damage = 40
	stamina_cost = 20
	stamina_crit_chance = 5
	var/last_laugh = 0

	New()
		..()
		processing_items.Add(src)
		START_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)
		BLOCK_SETUP(BLOCK_TANK)

	disposing()
		. = ..()
		STOP_TRACKING_CAT(TR_CAT_GHOST_OBSERVABLES)

	attack_self(mob/user as mob)
		if(last_laugh + 50 < world.time)
			user.visible_message(SPAN_NOTICE("<b>[user]</b> hugs [src]!"),SPAN_NOTICE("You hug [src]!"))
			playsound(src.loc, 'sound/misc/gnomegiggle.ogg', 50, 1)
			last_laugh = world.time

	process()
		if (src.anchored)
			return
		if (prob(50) || current_state < GAME_STATE_PLAYING) // Takes around 12 seconds for ol chompski to vanish
			return
		// No teleporting if youre in a container
		if (istype(src.loc,/obj/storage) || istype(src.loc,/mob/living) || istype(src.loc,/obj/item/reagent_containers/glass/jar) || istype(src.loc,/obj/cabinet))
			return
		// Nobody can ever see Chompski move
		for (var/mob/M in viewers(src))
			if (M.mind) // Only players. Monkeys and NPCs are fine. Chompski trusts them.
				return
		//oh boy time to move

		var/obj/storage/container = null

		var/list/eligible_containers = list()
		for_by_tcl(iterated_container, /obj/storage)
			if (!iterated_container.open && iterated_container.z == Z_LEVEL_STATION)
				eligible_containers += iterated_container
		if (!length(eligible_containers))
			return
		container = pick(eligible_containers)

		playsound(src.loc, 'sound/misc/gnomegiggle.ogg', 50, 1)
		src.set_loc(container)

/obj/item/c_tube
	name = "cardboard tube"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "c_tube"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 5
	desc = "A tube made of cardboard. Extremely non-threatening."
	stamina_damage = 5
	stamina_cost = 1
	hitsound = 'sound/impact_sounds/tube_bonk.ogg'

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

	attackby(obj/item/W, mob/user)
		if(issnippingtool(W))
			boutput(user, SPAN_NOTICE("You cut [src] horizontally across and flatten it out."))
			new /obj/item/c_sheet(get_turf(src))
			qdel(src)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] attempts to beat [him_or_her(user)]self to death with the cardboard tube, but fails!</b>"))
		user.suiciding = 0
		return 1

/obj/item/c_sheet
	name = "cardboard sheet"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "c_sheet"
	throwforce = 1
	w_class = W_CLASS_TINY
	throw_speed = 4
	throw_range = 5
	desc = "A sheet of creased cardboard."
	stamina_damage = 0
	stamina_cost = 0

	attack_self(mob/user as mob)
		boutput(user, SPAN_NOTICE("You deftly fold [src] into a party hat!."))
		user.put_in_hand_or_drop(new /obj/item/clothing/head/party)
		qdel(src)

TYPEINFO(/obj/item/disk)
	mats = 8

/obj/item/disk
	name = "disk"
	icon = 'icons/obj/items/items.dmi'

/obj/item/dummy
	name = "dummy"
	invisibility = INVIS_ALWAYS
	anchored = ANCHORED_ALWAYS
	flags = TABLEPASS | UNCRUSHABLE
	burn_possible = FALSE
	item_function_flags = IMMUNE_TO_ACID

	disposing()
		disposed = FALSE
		..()
		CRASH("Something tried to delete the can_reach dummy!")

	ex_act()
		return

	changeHealth(change)
		return

/obj/item/rubber_chicken
	name = "Rubber Chicken"
	desc = "A rubber chicken, isn't that hilarious?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "rubber_chicken"
	item_state = "rubber_chicken"
	w_class = W_CLASS_SMALL
	stamina_damage = 10
	stamina_cost = 5
	stamina_crit_chance = 3

/obj/item/module
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = W_CLASS_SMALL
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	item_state = "electronic"
	flags = TABLEPASS|CONDUCT
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/module/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."

/obj/item/module/id_auth
	name = "ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."

/obj/item/brick
	name = "brick"
	desc = "A ceramic building block."
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "brick"
	item_state = "brick"
	force = 8
	w_class = W_CLASS_SMALL
	throwforce = 15
	rand_pos = 1
	stamina_damage = 40
	stamina_cost = 20
	stamina_crit_chance = 5
	custom_suicide = TRUE

	throw_impact(obj/window/window)
		if (istype(window) && window.health <= (/obj/window/auto::health * /obj/window/auto::health_multiplier))
			window.smash()
			return
		..()

	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		APPLY_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "brick_suicide")
		user.visible_message(SPAN_ALERT("<b>[user] throws [src] into the air!</b>"))

		src.set_loc(get_turf(user))
		src.pixel_x = 0
		src.pixel_y = 0
		src.anchored = ANCHORED_ALWAYS
		src.layer += 4
		animate(src, pixel_y = 80, easing = EASE_OUT | QUAD_EASING, time = 0.7 SECONDS)
		playsound(get_turf(src), 'sound/effects/throw.ogg', 50, FALSE)
		SPAWN(0.7 SECONDS)
			animate(src, pixel_y = 15, easing = EASE_IN | QUAD_EASING, time = 0.5 SECONDS)
			SPAWN(0.5 SECONDS)
				playsound(get_turf(src), 'sound/impact_sounds/Flesh_Break_1.ogg', 50, FALSE)
				user.take_brain_damage(999)
				user.TakeDamage("Head", 999, 0, 0, DAMAGE_CRUSH, TRUE)
				REMOVE_ATOM_PROPERTY(user, PROP_MOB_CANTMOVE, "brick_suicide")
				SPAWN(0.2 SECONDS)
					animate(src, pixel_y = 0, easing = EASE_OUT | BOUNCE_EASING, time = 0.5 SECOND)
					SPAWN(0.5 SECONDS)
						src.anchored = UNANCHORED
						src.layer -= 4
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

/obj/item/emeter
	name = "E-Meter"
	desc = "A device for measuring Body Thetan levels."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "emeter"

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (ismob(target))
			user.visible_message("<b>[user]</b> takes a reading with the [src].",\
			"[target]'s Thetan Level: [(user == target) ? 0 : rand(1, 10)]")
			return
		else
			return ..()

/obj/item/hell_horn
	name = "decrepit instrument"
	desc = "It appears to be a musical instrument of some sort."
	icon = 'icons/obj/artifacts/artifactsitem.dmi'
	icon_state = "eldritch-1" // temp
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "eldritch" // temp
	w_class = W_CLASS_NORMAL
	force = 1
	throwforce = 5
	var/spam_flag = 0
	var/pitch = 0

/obj/item/hell_horn/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1

		playsound(user, 'sound/effects/mag_pandroar.ogg', 100, FALSE)
		for (var/mob/M in view(user))
			if (M != user)
				M.change_misstep_chance(50)

		SPAWN(6 SECONDS)
			spam_flag = 0

/obj/item/rubber_hammer
	name = "rubber hammer"
	desc = "Looks like one of those fair toys."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "rubber_hammer"
	c_flags = ONBELT
	force = 0

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		src.add_fingerprint(user)

		playsound(target, 'sound/musical_instruments/Bikehorn_1.ogg', 50, TRUE, -1)
		playsound(target, "sound/misc/boing/[rand(1,6)].ogg", 20, 1)
		user.visible_message(SPAN_ALERT("<B>[user] bonks [target] on the head with [src]!</B>"),\
							SPAN_ALERT("<B>You bonk [target] on the head with [src]!</B>"),\
							SPAN_ALERT("You hear something squeak."))


	earthquake

		New()
			..()
			src.setItemSpecial(/datum/item_special/slam)


TYPEINFO(/obj/item/reagent_containers/vape)
	mats = 6

/obj/item/reagent_containers/vape //yeet
	name = "e-cigarette"
	desc = "The pinacle of human technology. An electronic cigarette!"
	icon = 'icons/obj/items/cigarettes.dmi'
	inhand_image_icon = 'icons/obj/items/cigarettes.dmi'
	initial_volume = 50
	initial_reagents = "nicotine"
	item_state = "ecig"
	icon_state = "ecig"
	flags = TABLEPASS | OPENCONTAINER | NOSPLASH
	c_flags = ONBELT
	var/emagged = 0
	var/last_used = 0
	var/list/safe_smokables = list("nicotine", "THC", "CBD")
	var/datum/effects/system/bad_smoke_spread/smoke
	var/range = 1

	New()
		..()
		src.smoke = new /datum/effects/system/bad_smoke_spread/
		src.smoke.attach(src)
		src.smoke.set_up(1, 0, src.loc)
		if (prob(5))
			src.reagents.clear_reagents()
			src.reagents.add_reagent("THC", 50) //blaze it


	proc/check_whitelist(var/mob/user as mob)
		if (src.emagged || !src.safe_smokables || (islist(src.safe_smokables) && !length(src.safe_smokables)))
			return

		var/found = 0
		for (var/reagent_id in src.reagents.reagent_list)
			if (!src.safe_smokables.Find(reagent_id))
				src.reagents.del_reagent(reagent_id)
				found = 1
		if (found)
			if (user)
				user.show_text("[src] identifies and removes a non-smokable substance.", "red")
			else if (ismob(src.loc))
				var/mob/M = src.loc
				M.show_text("[src] identifies and removes a non-smokable substance.", "red")
			else
				src.visible_message(SPAN_ALERT("[src] identifies and removes a non-smokable substance."))


	on_reagent_change(add)
		..()
		if (!src.emagged && add)
			src.check_whitelist()

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.emagged)
			if (user)
				user.show_text("[src]'s safeties have been enabled.", "blue")
			src.emagged = 0
		else
			if (user)
				user.show_text("[src]'s safeties have been disabled.", "red")
			src.emagged = 1
		return 1

	attackby(obj/item/reagent_containers/ecig_refill_cartridge/E, mob/usr) //you may call this redundantly overdoing it. I say fuck you
		if (istype(E, /obj/item/reagent_containers/ecig_refill_cartridge))
			if (!E.reagents.total_volume)
				usr.show_text("\The [src] is empty.", "red")
				return
			usr.show_text("You refill the [src] with the cartridge.", "red")
			E.reagents.trans_to(src, 50)
			src.reagents.add_reagent("nicotine", 50)
			qdel(E) //this technically implies that vapes infinitely eat these refills. I say the catriges are made of pure nicotine and are slowly absorbed

	attack_self()
		if(world.time - last_used <= 60)
			usr.show_text("It's still resetting, be patient!", "red")
			return
		if (!reagents.total_volume)
			usr.show_text("You breathe in nothing and exhale nothing. You feel really lame!", "red") //wamp wamp
			return
		else
			var/datum/reagents/R = new /datum/reagents(5)
			var/target_loc = src.loc
			var/obj/item/phone_handset/PH = null
			if(istype(usr.l_hand,/obj/item/phone_handset) || istype(usr.r_hand,/obj/item/phone_handset)) // You can vape over the phone now. Why am I doing this.
				if(istype(usr.l_hand,/obj/item/phone_handset))
					PH = usr.l_hand
				else
					PH = usr.r_hand
				if(PH.parent.linked && PH.parent.linked.handset && PH.parent.linked.handset.get_holder())
					target_loc = PH.parent.linked.handset.get_holder().loc


			R.my_atom = src
			src.reagents.trans_to(usr, 5)
			src.reagents.trans_to_direct(R, 5)
			if(PH?.parent.linked?.handset?.get_holder())
				smoke_reaction(R, range, get_turf(PH.parent.linked.handset.get_holder()))
			else
				smoke_reaction(R, range, get_turf(usr))
			particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(target_loc, NORTH))
			particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(target_loc, SOUTH))
			particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(target_loc, EAST))
			particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(target_loc, WEST))
			usr.restrain_time = TIME + 40
			src.smoke.set_up(1, 0, target_loc,null,R.get_average_color())
			src.smoke.attach(target_loc)
			SPAWN(0) //vape is just the best for not annoying crowds I swear
				src.smoke.start()
				sleep(1 SECOND)

			if(!PH)
				usr.visible_message(SPAN_ALERT("<B>[usr] blows a cloud of smoke with their [prob(90) ? "ecig" : "mouth fedora"]! They look [pick("really lame", "like a total dork", "unbelievably silly", "a little ridiculous", "kind of pathetic", "honestly pitiable")]. </B>"),\
				SPAN_ALERT("You puff on the ecig and let out a cloud of smoke. You feel [pick("really cool", "totally awesome", "completely euphoric", "like the coolest person in the room", "like everybody respects you", "like the latest trend-setter")]."))
			else
				usr.visible_message(SPAN_ALERT("<B>[usr] blows a cloud of smoke right into the phone! They look [pick("really lame", "like a total dork", "unbelievably silly", "a little ridiculous", "kind of pathetic", "honestly pitiable")]. </B>"),\
				SPAN_ALERT("You puff on the ecig and blow a cloud of smoke right into the phone. You feel [pick("really cool", "totally awesome", "completely euphoric", "like the coolest person in the room", "like everybody respects you", "like the latest trend-setter")]."))
				if(PH.parent.linked && PH.parent.linked.handset && PH.parent.linked.handset.get_holder())
					boutput(PH.parent.linked.handset.get_holder(),SPAN_ALERT("<B>[usr] blows a cloud of smoke right through the phone! What a total [pick("dork","loser","dweeb","nerd","useless piece of shit","dumbass")]!</B>"))

			logTheThing(LOG_COMBAT, usr, "vapes a cloud of [log_reagents(src)] at [log_loc(target_loc)].")
			last_used = world.time

/obj/item/reagent_containers/vape/medical //medical cannabis got nothing on this!!
	name = "Medi-Vape"
	desc = "Smoking, now in a doctor approved form!"
	initial_reagents = "nicotine"
	item_state = "medivape"
	icon_state = "medivape"

	New()
		..()
		safe_smokables += chem_whitelist
		src.reagents.clear_reagents()
		src.reagents.add_reagent(pick(safe_smokables), 50)

/obj/item/reagent_containers/vape/medical/o2 //sweet oxygen
	desc = "Smoking, now in a doctor approved form! This one comes preloaded with salbutamol."

	New()
		..()
		src.reagents.clear_reagents()
		src.reagents.add_reagent("salbutamol", 50)


/obj/item/reagent_containers/ecig_refill_cartridge
	name = "e-cigarette refill cartridge"
	desc = "A small black box full of nicotine"
	icon = 'icons/obj/items/cigarettes.dmi'
	inhand_image_icon = 'icons/obj/items/cigarettes.dmi'
	initial_volume = 50
	initial_reagents = "nicotine"
	item_state = "ecigrefill"
	icon_state = "ecigrefill"
	flags = TABLEPASS

/obj/item/wrestlingbell
	name = "Wrestling bell"
	desc = "A bell used to signal the start of a wrestling match"
	anchored = ANCHORED
	density = 1
	icon = 'icons/obj/wrestlingbell.dmi'
	icon_state = "wrestlingbell"
	deconstruct_flags = DECON_WRENCH
	var/last_ring = 0

	attack_hand(mob/user)
		if(last_ring + 20 >= world.time)
			return
		else
			last_ring = world.time
			playsound(src.loc, 'sound/misc/Boxingbell.ogg', 50,1)

/obj/item/reagent_containers/bone_fragments
	name = "bone fragments"
	desc = "Little crushed up bits of bone that can fit in the reagent extractor."
	icon = 'icons/obj/materials.dmi'
	item_state = "shard"
	icon_state = "shard"
	initial_volume = 10
	initial_reagents = "bonemeal"

/obj/item/trophy
	name = "trophy"
	desc = "You're winner! You did it! You did the thing! Good job!"
	anchored = UNANCHORED
	density = 0
	icon = 'icons/obj/junk.dmi'
	icon_state = "trophy"

/obj/item/ass_day_artifact
	name = "Ass Day Artifact"
	desc = "Gives the power of new life, but only on the most holy of days"
	icon = 'icons/misc/racing.dmi'
	icon_state = "superbuttshell"
	c_flags = EQUIPPED_WHILE_HELD
	w_class = W_CLASS_BULKY
	var/mob/living/carbon/human/owner = null
	var/changed = 0
	var/pickup_time = 0

	New()
		..()
		name = "The [pick("Most Holey","Sacred","Hallowed","Divine")] relic of [pick("Azzdey","Ah Sday","Ahsh dei","A s'dai","Ahes d'hei")]"
		processing_items.Add(src)

	setupProperties()
		. = ..()
		src.setProperty("movespeed", 1)

	pickup(mob/user as mob)
		if(user != owner)
			user.bioHolder.AddEffect("fire_resist")
			if(owner?.bioHolder.HasEffect("fire_resist"))
				owner.bioHolder.RemoveEffect("fire_resist")
			pickup_time = world.time
			boutput(user, SPAN_ALERT("<h3>You have captured [src.name]!</h3>"))
			boutput(user, SPAN_ALERT("<h3>Don't let anyone else pick it up for 30 seconds and you'll respawn!</h3>"))
			if(owner)
				boutput(owner, "<h2>You have lost [src.name]!</h2>")
			owner = user
			DEBUG_MESSAGE("The new artifact owner is [owner.name]")
		..()

	dropped(mob/user)
		. = ..()
		if(owner)
			boutput(owner, "<h2>You have lost [src.name]!</h2>")
			if(owner?.bioHolder.HasEffect("fire_resist"))
				owner.bioHolder.RemoveEffect("fire_resist")
			owner = null

	process()
		if(!owner) return
		if(world.time - pickup_time >= 300)
			boutput(owner, SPAN_ALERT("<h3>You have held [src.name] long enough! Good job!</h3>"))
			if(owner?.client)
				src.set_loc(pick_landmark(LANDMARK_ASS_ARENA_SPAWN))
				INVOKE_ASYNC(owner.client, TYPE_PROC_REF(/client, respawn_target), owner, 1)
				DEBUG_MESSAGE("[owner.name] has been ass arena respawned!")
				owner.gib()
				owner = null


	disposing()
		if(owner?.bioHolder.HasEffect("fire_resist"))
			owner.bioHolder.RemoveEffect("fire_resist")
		DEBUG_MESSAGE("Heck someone broke the artifact")
		var/obj/item/ass_day_artifact/next_artifact
		next_artifact = new /obj/item/ass_day_artifact
		next_artifact.set_loc(pick_landmark(LANDMARK_ASS_ARENA_SPAWN))
		processing_items.Remove(src)
		..()

/obj/item/scpgnome
	name = "strange sarcophagus"
	desc = "A sarcophagus bound by magical chains."
	icon = 'icons/obj/junk.dmi'
	icon_state = "sarc_0"
	density = 1
	var/gnome = 1

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/scpgnome_lid) && ((src.icon_state == "sarc_2")||(src.icon_state == "sarc_3")))
			user.u_equip(W)
			qdel(W)
			src.icon_state = "sarc_1"
		else if(istype(W,/obj/item/gnomechompski/mummified) && (src.icon_state == "sarc_3"))
			user.u_equip(W)
			qdel(W)
			src.icon_state = "sarc_2"
			src.gnome = 1
		else if(istype(W,/obj/item/device/key/generic/chompskey) && (src.icon_state == "sarc_0"))
			user.u_equip(W)
			qdel(W)
			src.icon_state = "sarc_key"
		else
			..()

	attack_hand(mob/user)
		if(src.icon_state == "sarc_key")
			src.icon_state = "opening"
			animate(src, time = 2.3 SECONDS)
			animate(icon_state = "sarc_1")
		else if(src.icon_state == "sarc_1")
			if(src.gnome)
				src.icon_state = "sarc_2"
			else
				src.icon_state = "sarc_3"
			user.put_in_hand_or_drop(new /obj/item/scpgnome_lid)
		else if(src.icon_state == "sarc_2")
			src.gnome = 0
			src.icon_state = "sarc_3"
			user.put_in_hand_or_drop(new /obj/item/gnomechompski/mummified)

/obj/item/scpgnome_lid
	name = "strange sarcophagus lid"
	desc = "The lid to some sort of sarcophagus"
	icon = 'icons/obj/junk.dmi'
	icon_state = "sarc_1"

/obj/item/gnomechompski/mummified
	name = "mummified object"
	icon_state = "mummified"
	var/list/gnomes = list("gnelf","chome-gnompski","chrome-chompski","gnuigi-chompini","usagi-tsukinompski","sans-undertaleski","gnoctor-florpski","gnos-secureski","crime-chompski","antignome-negachompski")

	attack_self(mob/user as mob)
		user.u_equip(src)
		src.set_loc(user)
		var/obj/item/gnomechompski/g = new /obj/item/gnomechompski
		if(prob(30))
			g.icon_state = pick(gnomes)
			switch(g.icon_state)
				if("gnelf")
					g.name = "Gnelf Chompski"
				if("chome-gnompski")
					g.name = "Chome Gnompski"
				if("chrome-chompski")
					g.name = "Chrome Chompski"
				if("gnuigi-chompini")
					g.name = "Gnuigi Chompini"
				if("usagi-tsukinompski")
					g.name = "Usagi Tsukinompski"
				if("sans-undertaleski")
					g.name = "Boss Musicski"
				if("gnoctor-florpski")
					g.name = "Gnoctor Florpski"
				if("gnos-secureski")
					g.name = "Gnos Secureski"
				if("crime-chompski")
					g.name = "Crime Chompski"
				if("antignome-negachompski")
					g.name = "Ikspmohc-Emong"
		user.put_in_hand_or_drop(g)
		user.visible_message(SPAN_ALERT("[user.name] unwraps [g]!"))
		qdel(src)

/obj/item/nuclear_waste
	name = "radioactive waste"
	desc = "Radioactive waste produced as a by product of reprocessing fuel. It may still contain some fuel to be extracted."
	icon = 'icons/misc/reactorcomponents.dmi'
	icon_state = "waste"
	default_material = "slag"
	var/datum/gas_mixture/leak_gas = new

	New()
		. = ..()
		src.AddComponent(/datum/component/radioactive, 40, FALSE, FALSE, 1)
		leak_gas.radgas = 100
		leak_gas.temperature = T20C
		leak_gas.volume = 200 //I guess??

	return_air(direct = FALSE)
		return src.leak_gas

	ex_act(severity) //blowing up nuclear waste is always a good idea
		var/turf/current_loc = get_turf(src)
		current_loc.assume_air(src.leak_gas)
		qdel(src)

/obj/tombstone/nuclear_warning
	name = "inscribed stone"
	desc = {"A stone block, inscribed with a message. It says:<br>
	This place is a message... and part of a system of messages... pay attention to it!<br>
    Sending this message was important to us. We considered ourselves to be a powerful culture.<br>
    This place is not a place of honor... no highly esteemed deed is commemorated here... nothing valued is here.<br>
    What is here was dangerous and repulsive to us. This message is a warning about danger.<br>
    The danger is in a particular location... it increases towards a center... the center of danger is here... of a particular size and shape, and below us.<br>
    The danger is still present, in your time, as it was in ours.<br>
    The danger is to the body, and it can kill.<br>
    The form of the danger is an emanation of energy.<br>
    The danger is unleashed only if you substantially disturb this place physically. This place is best shunned and left uninhabited.<br>
	<br>
	...spooky!"}

	ex_act(severity)
		// we look for the nearest floor because the jerks are probably gonna blow up a hole under the stone or something, rude
		for(var/turf/simulated/floor/floor in range(3, get_turf(src)))
			if(floor.parent?.spaced)
				continue
			var/datum/gas_mixture/gas = new
			gas.radgas = 10 * 2 ** (3 - severity)
			floor.assume_air(gas)
			break // only the first floor we found

/obj/item/boarvessel
	name = "\improper Boar Vessel, 600-500 BC, Etruscan, ceramic"
	desc = "Oh my God! A REAL Boar Vessel, 600-500 BC, Etruscan, ceramic."
	icon_state = "boarvessel"

	attack_self(mob/user as mob)
		user.visible_message(SPAN_NOTICE("[user] pets [src]!"), SPAN_NOTICE("You pet [src]!"))

/obj/item/boarvessel/forgery
	name = "\improper Boar Vessel, 600-500 BC, Etruscan, ceramic"
	desc = "Whatever, it's probably not a REAL Boar Vessel, 600-500 BC, Etruscan, ceramic."

	New()
		. = ..()
		src.AddComponent(/datum/component/radioactive, 1, FALSE, FALSE, 1)

/obj/item/yoyo
	name = "Atomic Yo-Yo"
	desc = "Molded into the transparent neon plastic are the words \"ATOMIC CONTAGION F VIRAL YO-YO.\"  It's as extreme as the 1990s."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "yoyo"
	item_state = "yoyo"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'

	New()
		..()
		BLOCK_SETUP(BLOCK_ROPE)

/obj/item/cash_briefcase
	name = "Cash Briefcase"
	desc = "A foldable briefcase that can hold a large amount of cash. "
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "briefcase"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	item_state = "briefcase"
	w_class = W_CLASS_BULKY

	var/balance = 0 // Current amount of cash in the case
	var/maximum_balance = 30000 // Maximum amount of cash in the case
	var/open = FALSE // Is the briefcase open?
	var/open_icon_state = "briefcase-open"
	var/closed_icon_state = "briefcase"

	get_desc()
		. = ""
		if(src.balance > 0)
			.+= "It has [src.balance] credits inside!"
		else
			.+= "It's empty!"

	update_icon()
		. = ..()
		var/overlay_icon_state = null
		var/image/cashoverlay = null
		if (src.open)
			src.icon_state = open_icon_state
			switch (src.balance)
				if (12 to 119)
					overlay_icon_state = "briefcashgreen"
				if (120 to 1199)
					overlay_icon_state = "briefcashblue"
				if (1200 to 5999)
					overlay_icon_state = "briefcashindi"
				if (6000 to 11999)
					overlay_icon_state = "briefcashpurp"
				if (12000 to INFINITY)
					overlay_icon_state = "briefcashred"
				else
					overlay_icon_state = null
			if (overlay_icon_state)
				cashoverlay = image(src.icon, overlay_icon_state)
		else
			src.icon_state = closed_icon_state
		src.UpdateOverlays(cashoverlay, "cash_overlay")

	attack_self(mob/user)
		src.toggleCase(user)

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/currency/spacecash))
			if (!src.open)
				boutput(user, "You need to open the briefcase to put cash in it.")
				return
			else if (src.balance >= src.maximum_balance)
				boutput(user, "The briefcase is full!")
				return
			else
				var/space_left = src.maximum_balance - src.balance
				var/obj/item/currency/spacecash/cashstack = W
				if (space_left < cashstack.amount)
					src.balance += space_left
					var/money_to_destroy = cashstack.split_stack(space_left)
					qdel(money_to_destroy)
				else
					src.balance += cashstack.amount
					user.u_equip(W)
					qdel(W)
				src.UpdateIcon()
				src.tooltip_rebuild = TRUE
		else
			. = ..()

	attack_hand(mob/user)
		if (src.open && (user.a_intent != INTENT_GRAB))
			var/amount = round(tgui_input_number(user, "How much cash do you want to take from the briefcase?", "Cash Briefcase", src.balance, src.balance))
			if (isnum_safe(amount))
				if (amount > src.balance || amount < 1)
					boutput(user, SPAN_ALERT("You wish!"))
					return
				var/obj/item/currency/spacecash/taken_cash = new /obj/item/currency/spacecash
				taken_cash.setup(src.loc, amount)
				src.balance -= amount
				user.put_in_hand_or_drop(taken_cash)
				src.UpdateIcon()
				src.tooltip_rebuild = TRUE
		else
			..(user)

	verb/openclose()
		set src in view(1)
		set category = "Local"
		set name = "Open/Close briefcase"
		toggleCase(usr)

	proc/toggleCase(mob/user)
		if (src.open)
			playsound(src.loc, 'sound/machines/click.ogg', 30, 0)
			src.open = FALSE
			src.UpdateIcon()
		else
			playsound(src.loc, 'sound/machines/click.ogg', 30, 0)
			src.open = TRUE
			src.UpdateIcon()
			return

/obj/item/cash_briefcase/syndicate
	icon_state = "syndiecase"
	item_state = "syndiecase"

	maximum_balance = 50000
	open_icon_state = "syndiecase-open"
	closed_icon_state = "syndiecase"

	loaded
		balance = 15000
