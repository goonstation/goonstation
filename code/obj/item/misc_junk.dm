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
	desc = "what"
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
		START_TRACKING
		BLOCK_SETUP(BLOCK_TANK)

	disposing()
		. = ..()
		STOP_TRACKING

	attack_self(mob/user as mob)
		if(last_laugh + 50 < world.time)
			user.visible_message("<span class='notice'><b>[user]</b> hugs [src]!</span>","<span class='notice'>You hug [src]!</span>")
			playsound(src.loc, 'sound/misc/gnomegiggle.ogg', 50, 1)
			last_laugh = world.time

	process()
		if (prob(50) || current_state < GAME_STATE_PLAYING) // Takes around 12 seconds for ol chompski to vanish
			return
		// No teleporting if youre in a container
		if (istype(src.loc,/obj/storage) || istype(src.loc,/mob/living))
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

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_ROD)

	attackby(obj/item/W, mob/user)
		if(issnippingtool(W))
			boutput(user, "<span class='notice'>You cut [src] horizontally across and flatten it out.</span>")
			new /obj/item/c_sheet(get_turf(src))
			qdel(src)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] attempts to beat [him_or_her(user)]self to death with the cardboard tube, but fails!</b></span>")
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
		boutput(user, "<span class='notice'>You deftly fold [src] into a party hat!.</span>")
		user.put_in_hand_or_drop(new /obj/item/clothing/head/party)
		qdel(src)

/obj/item/disk
	name = "disk"
	icon = 'icons/obj/items/items.dmi'
	mats = 8

/obj/item/dummy
	name = "dummy"
	invisibility = INVIS_ALWAYS
	anchored = 2
	flags = TABLEPASS | UNCRUSHABLE
	burn_possible = 0

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
	flags = FPRINT|TABLEPASS|CONDUCT
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
	w_class = W_CLASS_TINY
	throwforce = 10
	rand_pos = 1
	stamina_damage = 40
	stamina_cost = 20
	stamina_crit_chance = 5

/obj/item/emeter
	name = "E-Meter"
	desc = "A device for measuring Body Thetan levels."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "emeter"

	attack(mob/M, mob/user, def_zone)
		if (ismob(M))
			user.visible_message("<b>[user]</b> takes a reading with the [src].",\
			"[M]'s Thetan Level: [user == M ? 0 : rand(1,10)]")
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

		playsound(user, 'sound/effects/mag_pandroar.ogg', 100, 0)
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
	flags = FPRINT | ONBELT | TABLEPASS
	force = 0

	New()
		..()
		BLOCK_SETUP(BLOCK_ALL)

	attack(mob/M, mob/user)
		src.add_fingerprint(user)

		playsound(M, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1, -1)
		playsound(M, "sound/misc/boing/[rand(1,6)].ogg", 20, 1)
		user.visible_message("<span class='alert'><B>[user] bonks [M] on the head with [src]!</B></span>",\
							"<span class='alert'><B>You bonk [M] on the head with [src]!</B></span>",\
							"<span class='alert'>You hear something squeak.</span>")


	earthquake

		New()
			..()
			src.setItemSpecial(/datum/item_special/slam)


/obj/item/reagent_containers/vape //yeet
	name = "e-cigarette"
	desc = "The pinacle of human technology. An electronic cigarette!"
	icon = 'icons/obj/items/cigarettes.dmi'
	inhand_image_icon = 'icons/obj/items/cigarettes.dmi'
	initial_volume = 50
	initial_reagents = "nicotine"
	item_state = "ecig"
	icon_state = "ecig"
	mats = 6
	flags = FPRINT | TABLEPASS | OPENCONTAINER | ONBELT | NOSPLASH
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
				src.visible_message("<span class='alert'>[src] identifies and removes a non-smokable substance.</span>")


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
				if(PH.parent.linked && PH.parent.linked.handset && PH.parent.linked.handset.holder)
					target_loc = PH.parent.linked.handset.holder.loc


			R.my_atom = src
			src.reagents.trans_to(usr, 5)
			src.reagents.trans_to_direct(R, 5)
			if(PH?.parent.linked?.handset?.holder)
				smoke_reaction(R, range, get_turf(PH.parent.linked.handset.holder))
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
				usr.visible_message("<span class='alert'><B>[usr] blows a cloud of smoke with their [prob(90) ? "ecig" : "mouth fedora"]! They look [pick("really lame", "like a total dork", "unbelievably silly", "a little ridiculous", "kind of pathetic", "honestly pitiable")]. </B></span>",\
				"<span class='alert'>You puff on the ecig and let out a cloud of smoke. You feel [pick("really cool", "totally awesome", "completely euphoric", "like the coolest person in the room", "like everybody respects you", "like the latest trend-setter")].</span>")
			else
				usr.visible_message("<span class='alert'><B>[usr] blows a cloud of smoke right into the phone! They look [pick("really lame", "like a total dork", "unbelievably silly", "a little ridiculous", "kind of pathetic", "honestly pitiable")]. </B></span>",\
				"<span class='alert'>You puff on the ecig and blow a cloud of smoke right into the phone. You feel [pick("really cool", "totally awesome", "completely euphoric", "like the coolest person in the room", "like everybody respects you", "like the latest trend-setter")].</span>")
				if(PH.parent.linked && PH.parent.linked.handset && PH.parent.linked.handset.holder)
					boutput(PH.parent.linked.handset.holder,"<span class='alert'><B>[usr] blows a cloud of smoke right through the phone! What a total [pick("dork","loser","dweeb","nerd","useless piece of shit","dumbass")]!</B></span>")

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
	flags = FPRINT | TABLEPASS

/obj/item/wrestlingbell
	name = "Wrestling bell"
	desc = "A bell used to signal the start of a wrestling match"
	anchored = 1
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

/obj/item/trophy
	name = "trophy"
	desc = "You're winner! You did it! You did the thing! Good job!"
	anchored = 0
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
			boutput(user, "<h3><span class='alert'>You have captured [src.name]!</span></h3>")
			boutput(user, "<h3><span class='alert'>Don't let anyone else pick it up for 30 seconds and you'll respawn!</span></h3>")
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
			boutput(owner, "<h3><span class='alert'>You have held [src.name] long enough! Good job!</span></h3>")
			if(owner?.client)
				src.set_loc(pick_landmark(LANDMARK_ASS_ARENA_SPAWN))
				INVOKE_ASYNC(owner.client, /client.proc/respawn_target, owner, 1)
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
		user.visible_message("<span style=\"color:red\">[user.name] unwraps [g]!</span>")
		qdel(src)
