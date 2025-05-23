
/* -------------------- Standard Toolboxes -------------------- */

ABSTRACT_TYPE(/obj/item/storage/toolbox)
/obj/item/storage/toolbox
	name = "toolbox"
	icon = 'icons/obj/items/storage.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_storage.dmi'
	icon_state = "red"
	item_state = "toolbox-red"
	flags = TABLEPASS | CONDUCT | NOSPLASH
	force = 8
	throwforce = 10
	throw_speed = 1
	throw_range = 7
	w_class = W_CLASS_BULKY
	max_wclass = W_CLASS_NORMAL
	prevent_holding = list(/obj/item/storage/box)

	//cogwerks - burn vars
	burn_point = 4500
	burn_output = 4800
	burn_remains = BURN_REMAINS_MELT
	stamina_damage = 50
	stamina_cost = 20
	stamina_crit_chance = 10

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] slams the toolbox closed on [his_or_her(user)] head repeatedly!</b>"))
		user.TakeDamage("head", 150, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tile) && !length(src.storage.get_contents()) && !isrobot(user)) // we are making a floorbot!
			var/obj/item/toolbox_tiles/B = new /obj/item/toolbox_tiles

			user.put_in_hand_or_drop(B)
			W.change_stack_amount(-1)

			if(istype(src, /obj/item/storage/toolbox/emergency))
				B.color_overlay = "floorbot_overlay_red"
			else if(istype(src, /obj/item/storage/toolbox/electrical))
				B.color_overlay = "floorbot_overlay_yellow"
			else if(istype(src, /obj/item/storage/toolbox/artistic))
				B.color_overlay = "floorbot_overlay_green"

			if(B.color_overlay)
				B.UpdateOverlays(image(B.icon, icon_state = B.color_overlay), "coloroverlay")

			user.drop_item(src)
			src.set_loc(B)
			src.storage.hide_all_huds()
			boutput(user, "You add the tiles into the empty toolbox. They stick oddly out the top.")
			return

		return ..()

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox-red"
	desc = "A metal container designed to hold various tools. This variety holds supplies required for emergencies."
	spawn_contents = list(/obj/item/crowbar/red,\
	/obj/item/extinguisher,\
	/obj/item/device/light/flashlight,\
	/obj/item/device/radio,\
	/obj/item/roadflare)

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox-blue"
	desc = "A metal container designed to hold various tools. This variety holds standard construction tools."
	spawn_contents = list(/obj/item/screwdriver,\
	/obj/item/wrench,\
	/obj/item/weldingtool,\
	/obj/item/crowbar,\
	/obj/item/wirecutters,\
	/obj/item/device/analyzer/atmospheric)

	engineer_spawn
		spawn_contents = list(/obj/item/device/analyzer/atmospheric/upgraded,\
		/obj/item/electronics/soldering,\
		/obj/item/device/t_scanner,\
		/obj/item/electronics/scanner,\
		/obj/item/cable_coil,\
		/obj/item/reagent_containers/food/snacks/sandwich/pb,\
		/obj/item/reagent_containers/food/drinks/milk)

	yellow_tools
		spawn_contents = list(/obj/item/screwdriver/yellow,\
		/obj/item/wrench/yellow,\
		/obj/item/weldingtool/yellow,\
		/obj/item/crowbar/yellow,\
		/obj/item/wirecutters/yellow,\
		/obj/item/device/analyzer/atmospheric)

	orange_tools //used for QM bought tools
		spawn_contents = list(/obj/item/screwdriver/orange,\
		/obj/item/wrench/orange,\
		/obj/item/weldingtool/orange,\
		/obj/item/crowbar/orange,\
		/obj/item/wirecutters/orange,\
		/obj/item/device/analyzer/atmospheric)

	empty
		spawn_contents = list()

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox-yellow"
	desc = "A metal container designed to hold various tools. This variety holds electrical supplies."
	spawn_contents = list(/obj/item/screwdriver,\
	/obj/item/wirecutters,\
	/obj/item/device/t_scanner,\
	/obj/item/crowbar)

	make_my_stuff()
		..()
		var/picked = pick(/obj/item/cable_coil,\
		/obj/item/cable_coil/yellow,\
		/obj/item/cable_coil/orange,\
		/obj/item/cable_coil/blue,\
		/obj/item/cable_coil/green,\
		/obj/item/cable_coil/purple,\
		/obj/item/cable_coil/black,\
		/obj/item/cable_coil/hotpink,\
		/obj/item/cable_coil/brown,\
		/obj/item/cable_coil/white)
		src.storage.add_contents(new picked(src))
		if (!istype(src, /obj/item/storage/toolbox/electrical/mechanic_spawn))
			for (var/i = 1 to 2)
				src.storage.add_contents(new picked(src))


	// The extra items (scanner and soldering iron) take up precious space in the backpack.
	mechanic_spawn
		spawn_contents = list(/obj/item/electronics/scanner,\
		/obj/item/electronics/soldering,\
		/obj/item/device/t_scanner,\
		/obj/item/reagent_containers/food/snacks/sandwich/cheese,\
		/obj/item/reagent_containers/food/snacks/chips,\
		/obj/item/reagent_containers/food/drinks/coffee)

	orange_tools //used for QM bought tools
		spawn_contents = list(/obj/item/screwdriver/orange,\
		/obj/item/wirecutters/orange,\
		/obj/item/device/t_scanner,\
		/obj/item/crowbar/orange)

/obj/item/storage/toolbox/artistic
	name = "artistic toolbox"
	desc = "A metal container designed to hold various tools. This variety holds art supplies."
	icon_state = "green"
	item_state = "toolbox-green"
	spawn_contents = list(/obj/item/paint_can/random = 6, /obj/item/item_box/crayon = 1)

/* -------------------- Memetic Toolbox -------------------- */

TYPEINFO(/obj/item/storage/toolbox/memetic)
	start_listen_effects = list(LISTEN_EFFECT_MEMETIC_TOOLBOX)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD)

/obj/item/storage/toolbox/memetic
	name = "artistic toolbox"
	desc = "His Grace."
	icon_state = "green"
	item_state = "toolbox-green"
	var/list/servantlinks = list()
	var/hunger = 0
	var/hunger_message_level = 0
	var/original_owner = null
	cant_other_remove = 1

	examine(mob/user)
		. = ..()
		var/mob/living/carbon/human/H = user
		if(!istype(H))
			. += "It almost hurts to look at that, it's all out of focus."
			return
		if (!H.find_ailment_by_type(/datum/ailment/disability/memetic_madness))
			H.contract_memetic_madness(src)
			if (!original_owner)
				original_owner = H

	mouse_drop(over_object, src_location, over_location)
		if(!ishuman(usr) || !usr:find_ailment_by_type(/datum/ailment/disability/memetic_madness))
			boutput(usr, SPAN_ALERT("You can't seem to find the latch. Maybe you need to examine it more thoroughly?"))
			return
		return ..()

	attack_hand(mob/user)
		if (src.loc == user)
			if(!ishuman(user) || !user:find_ailment_by_type(/datum/ailment/disability/memetic_madness))
				boutput(user, SPAN_ALERT("You can't seem to find the latch. Maybe you need to examine it more thoroughly?"))
				return
		return ..()

	attackby(obj/item/W, mob/user)
		if(!ishuman(user) || !user:find_ailment_by_type(/datum/ailment/disability/memetic_madness))
			boutput(user, SPAN_ALERT("You can't seem to find the latch to open this. Maybe you need to examine it more thoroughly?"))
			return
		if (src.storage.is_full())
			return
		if (((W.storage && W.w_class > W_CLASS_SMALL) || src.loc == W))
			return
		if(istype(W, /obj/item/grab))	// It will devour people! It's an evil thing!
			var/obj/item/grab/G = W
			if(!G.affecting) return
			if(!G.affecting.stat && !G.affecting.restrained() && !G.affecting.getStatusDuration("knockdown"))
				boutput(user, SPAN_ALERT("[capitalize(hes_or_shes(G.affecting))] moving too much to feed to His Grace!"))
				return
			user.visible_message(SPAN_ALERT("<b>[user] is trying to feed [G.affecting] to [src]!</b>"))
			if(!do_mob(user, G.affecting, 30)) return
			G.affecting.set_loc(src)
			user.visible_message(SPAN_ALERT("<b>[user] has fed [G.affecting] to [src]!</b>"))

			src.consume(G.affecting, G)

			boutput(user, "<i><b><font face = Tempus Sans ITC>You have done well...</font></b></i>")
			src.force += 5
			src.throwforce += 5
			return

		return ..()

	proc/consume(mob/M as mob, var/obj/item/grab/G)
		if (!M)
			return

		src.hunger = 0
		src.hunger_message_level = 0
		playsound(src.loc, pick('sound/voice/burp_alien.ogg'), 50, 0)
		//Neatly sort everything they have into handy little boxes.
		var/obj/item/storage/box/per_person = new /obj/item/storage/box(src)
		src.storage.add_contents(per_person)
		var/obj/item/storage/box/Gcontents = new /obj/item/storage/box(src)
		per_person.storage.add_contents(Gcontents)
		per_person.name = "Box-'[M.real_name]'"
		for(var/obj/item/looted in M)
			if(Gcontents.storage.is_full())
				Gcontents = new /obj/item/storage/box(src)
				per_person.storage.add_contents(Gcontents)
			if(istype(looted, /obj/item/implant)) continue
			M.u_equip(looted)
			if (looted == src)
				src.layer = initial(src.layer)
				src.set_loc(get_turf(M))
				continue

			if (looted)
				Gcontents.storage.add_contents(looted)
				looted.layer = initial(looted.layer)
				looted.dropped(M)

		M.remove()
		var/we_need_to_die = (M == original_owner)
		SPAWN(0.5 SECONDS)
			if (G)
				qdel(G)
			if (we_need_to_die)
				new /obj/item/storage/toolbox/emergency {name = "artistic toolbox"; desc = "It looks a lot duller than it used to."; icon_state = "green"; item_state = "toolbox-green";} (get_turf(src))
				qdel(src)

		return

	disposing()
		for(var/mob/M in src) //Release trapped dudes...
			M.set_loc(get_turf(src))
			src.visible_message(SPAN_ALERT("[M] bursts out of [src]!"))

		for(var/datum/ailment_data/A in src.servantlinks) //Remove the plague...
			if (istype(A.master,/datum/ailment/disability/memetic_madness/))
				A.dispose()
				break

		if (servantlinks)
			servantlinks.len = 0
		servantlinks = null

		src.visible_message(SPAN_ALERT("<b>[src]</b> screams!"))
		playsound(src.loc, 'sound/effects/screech.ogg', 50, 1)

		..()
		return

/mob/living/proc/contract_memetic_madness(var/obj/item/storage/toolbox/memetic/newprogenitor)
	if(src.find_ailment_by_type(/datum/ailment/disability/memetic_madness))
		return

	src.resistances -= /datum/ailment/disability/memetic_madness
	// just going to have to set it up manually i guess
	var/datum/ailment_data/memetic_madness/AD = get_disease_from_path(/datum/ailment/disability/memetic_madness).setup_strain()

	if(istype(newprogenitor,/obj/item/storage/toolbox/memetic/))
		AD.progenitor = newprogenitor
		AD.affected_mob = src
		src.contract_disease(/datum/ailment/disability/memetic_madness, null, AD, TRUE)
		newprogenitor.servantlinks.Add(AD)
		newprogenitor.force += 4
		newprogenitor.throwforce += 4
	else
		qdel(AD)
		return

	var/acount = 0
	var/amax = rand(10,15)
	var/screamstring = null
	var/asize = 1
	while(acount <= amax)
		screamstring += "<font size=[asize]>a</font>"
		if(acount > (amax/2))
			asize--
		else
			asize++
		acount++
	src.playsound_local(src.loc,'sound/effects/screech.ogg', 50, 1)
	shake_camera(src, 20, 16)
	boutput(src, SPAN_ALERT("[screamstring]"))
	boutput(src, "<i><b><font face = Tempus Sans ITC>His Grace accepts thee, spread His will! All who look close to the Enlightened may share His gifts.</font></b></i>")
	return

/*
 *	MEMETIC DISEASE
 */

/datum/ailment_data/memetic_madness
	var/obj/item/storage/toolbox/memetic/progenitor = null
	stage_prob = 8

	New()
		..()
		master = get_disease_from_path(/datum/ailment/disability/memetic_madness)

	stage_act(mult)
		if (!istype(master,/datum/ailment/) || !src.progenitor)
			affected_mob.ailments -= src
			qdel(src)
			return

		if(stage > master.max_stages)
			stage = master.max_stages

		if(probmult(stage_prob) && stage < master.max_stages)
			stage++

		master.stage_act(affected_mob,src,mult,progenitor)

		return

/datum/ailment/disability/memetic_madness
	name = "Memetic Kill Agent"
	cure_flags = CURE_UNKNOWN
	affected_species = list("Human")
	max_stages = 4
	stage_prob = 8
	strain_type = /datum/ailment_data/memetic_madness

	stage_act(var/mob/living/affected_mob,var/datum/ailment_data/D,mult,var/obj/item/storage/toolbox/memetic/progenitor)
		if (..())
			return
		if(progenitor in affected_mob.contents)
			if(affected_mob.get_oxygen_deprivation())
				affected_mob.take_oxygen_deprivation(-5 * mult)
			affected_mob:HealDamage("All", 12 * mult, 12 * mult)
			if(affected_mob.get_toxin_damage())
				affected_mob.take_toxin_damage(-5 * mult)
			affected_mob.remove_stuns()
			affected_mob.dizziness = max(0,affected_mob.dizziness-10 * mult)
			affected_mob.changeStatus("drowsy", -20 * mult SECONDS)
			affected_mob:sleeping = 0
			D.stage = 1
			switch (progenitor.hunger)
				if (10 to 60)
					if (progenitor.hunger_message_level < 1)
						progenitor.hunger_message_level = 1
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>Feed Me the unclean ones...They will be purified...</font></b></i>")
				if (61 to 120)
					if (progenitor.hunger_message_level < 2)
						progenitor.hunger_message_level = 2
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>I hunger for the flesh of the impure...</font></b></i>")
				if (121 to 210)
					if (prob(10) && progenitor.hunger_message_level < 3)
						progenitor.hunger_message_level = 3
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>The hunger of Your Master grows with every passing moment.  Feed Me at once.</font></b></i>")
				if (230 to 399)
					if (progenitor.hunger_message_level < 4)
						progenitor.hunger_message_level = 4
						boutput(affected_mob, "<i><b><font face = Tempus Sans ITC>His Grace starves in your hands.  Feed Me the unclean or suffer.</font></b></i>")
				if (300 to INFINITY)
					affected_mob.visible_message(SPAN_ALERT("<b>[progenitor] consumes [affected_mob] whole!</b>"))
					progenitor.consume(affected_mob)
					return

			progenitor.hunger += clamp((progenitor.force / 10), 1, 10) * mult

		else if(D.stage == 4)
			if(GET_DIST(get_turf(progenitor),src) <= 7)
				D.stage = 1
				return
			if(probmult(4))
				boutput(affected_mob, SPAN_ALERT("We are too far from His Grace..."))
				affected_mob.take_toxin_damage(5)
			else if(probmult(6))
				boutput(affected_mob, SPAN_ALERT("You feel weak."))
				random_brute_damage(affected_mob, 5)

			if (ismob(progenitor.loc))
				progenitor.hunger += 1 * mult

		return

	/*
	disposing()
		if(src.affected_mob)
			src.affected_mob.playsound_local(src.affected_mob.loc,'sound/effects/screech.ogg', 100, 1)
			boutput(src.affected_mob, "<i><b><font face = Tempus Sans ITC>NOOOO</font></b></i>")
			src.affected_mob.paralysis = 10
			if (src.affected_mob.ailments)
				src.affected_mob.ailments -= src
			src.affected_mob = null
			src.progenitor = null
		..()
	*/

/*
 *	His Grace for Dummies
 */

/obj/item/paper/memetic_manual
	name = "paper- 'So You Want to Worship His Grace'"
	info = {"<center><h4>Worship QuickStart</h4></center><ol>
	<li>Gaze into His Grace. Observe His magnificence. Examine the quality of His form.</li>
	<li>Carry His Grace. Show the unbelievers the power of Him.  Know that all who gaze upon the splendor of His Chosen will know of Him.</li>
	<li>His Grace hungers! Take the unworthy ones in your hands and place them inside Him!</li>
	<li>After every nourishment, His Grace will hold their spoils. Remove these from Him and make great use of them, as gifts.</li>
	<li>Know that the His might will grow with every new Chosen and, in turn, the power of the Chosen carrying Him. But be warned! As He grows in strength, so doth His appetite!</li>
	</ol>
	"}
