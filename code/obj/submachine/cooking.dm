
TYPEINFO(/obj/submachine/chef_sink)
	mats = 12

/obj/submachine/chef_sink
	name = "kitchen sink"
	desc = "A water-filled unit intended for cookery purposes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "sink"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_WELDER
	flags = NOSPLASH

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/flour))
			user.show_text("You add water to the flour to make dough!", "blue")
			if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/flour/semolina))
				new /obj/item/reagent_containers/food/snacks/ingredient/dough/semolina(src.loc)
			else
				new /obj/item/reagent_containers/food/snacks/ingredient/dough(src.loc)
			qdel (W)
		else if (istype(W, /obj/item/reagent_containers/food/snacks/ingredient/rice))
			user.show_text("You add water to the rice to make sticky rice!", "blue")
			new /obj/item/reagent_containers/food/snacks/ingredient/sticky_rice(src.loc)
			qdel(W)
		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/) || istype(W, /obj/item/reagent_containers/balloon/) || istype(W, /obj/item/soup_pot))
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				user.show_text("[W] is too full already.", "red")
			else
				fill -= W.reagents.total_volume
				W.reagents.add_reagent("water", fill)
				user.show_text("You fill [W] with water.", "blue")
				playsound(src.loc, 'sound/misc/pourdrink.ogg', 100, 1)
		else if (istype(W, /obj/item/mop)) // dude whatever
			var/fill = W.reagents.maximum_volume
			if (W.reagents.total_volume >= fill)
				user.show_text("[W] is too wet already.", "red")
			else
				fill -= W.reagents.total_volume
				W.reagents.add_reagent("water", fill)
				user.show_text("You wet [W].", "blue")
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
		else if (istype(W, /obj/item/grab))
			var/obj/item/grab/GRAB = W
			if (ismob(GRAB.affecting))
				if (GRAB.state >= 1 && istype(GRAB.affecting, /mob/living/critter/small_animal))
					var/mob/M = GRAB.affecting
					var/mob/A = GRAB.assailant
					if (BOUNDS_DIST(src.loc, M.loc) > 0)
						return
					user.visible_message(SPAN_NOTICE("[A] shoves [M] in the sink and starts to wash them."))
					M.set_loc(src.loc)
					playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
					actions.start(new/datum/action/bar/private/critterwashing(A,src,M,GRAB),user)
				else
					playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
					user.visible_message(SPAN_NOTICE("[user] dunks [W:affecting]'s head in the sink!"))
					GRAB.affecting.lastgasp() // --BLUH
		else if (istype(W, /obj/item/gun/sprayer))
			var/obj/item/gun/sprayer/sprayer = W
			sprayer.clogged = FALSE
			playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
			boutput(user, SPAN_NOTICE("You clean out [W]'s nozzle."))
		else if (W.burning)
			W.combust_ended()
		else
			user.visible_message(SPAN_NOTICE("[user] cleans [W]."))
			W.clean_forensic() // There's a global proc for this stuff now (Convair880).
			if (istype(W, /obj/item/device/key/skull))
				W.icon_state = "skull"
			if (istype(W, /obj/item/reagent_containers/mender))
				var/obj/item/reagent_containers/mender/automender = W
				if(automender.borg)
					return
			if (W.reagents && W.is_open_container())
				W.reagents.clear_reagents()		// avoid null error

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	attack_hand(var/mob/user)
		src.add_fingerprint(user)
		user.lastattacked = get_weakref(src)
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (H.gloves)
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 1)
				user.visible_message(SPAN_NOTICE("[user] cleans [his_or_her(user)] gloves."))
				if (H.sims?.getValue("Hygiene"))
					user.show_text("If you want to improve your hygiene, you need to remove your gloves first.")
				H.gloves.clean_forensic() // Ditto (Convair880).
				H.set_clothing_icon_dirty()
			else
				if(H.sims?.getValue("Hygiene"))
					if (H.sims.getValue("Hygiene") >= SIMS_HYGIENE_THRESHOLD_MESSY)
						user.visible_message(SPAN_NOTICE("[user] starts washing [his_or_her(user)] hands."))
						actions.start(new/datum/action/bar/private/handwashing(user,src),user)
						return ..()
					else
						user.show_text("You're too messy to improve your hygiene this way, you need a shower or a bath.", "red")
				//simpler handwashing if hygiene isn't a concern
				playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
				user.visible_message(SPAN_NOTICE("[user] washes [his_or_her(user)] hands."))
				H.blood_DNA = null
				H.blood_type = null
				H.forensics_blood_color = null
				H.set_clothing_icon_dirty()
		..()

/datum/action/bar/private/handwashing
	duration = 1 SECOND //roughly matches the rate of manual clicking
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	var/mob/living/carbon/human/user
	var/obj/submachine/chef_sink/sink

	New(usermob,sink)
		user = usermob
		src.sink = sink
		..()

	proc/checkStillValid()
		if(BOUNDS_DIST(user, sink) > 1 || user == null || sink == null || user.l_hand || user.r_hand)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE

	onUpdate()
		checkStillValid()
		..()

	onStart()
		..()
		if(BOUNDS_DIST(user, sink) > 1) user.show_text("You're too far from the sink!")
		if(user.l_hand || user.r_hand) user.show_text("Both your hands need to be free to wash them!")
		src.loopStart()


	loopStart()
		..()
		if(!checkStillValid()) return
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)

	onEnd()
		if(!checkStillValid())
			..()
			return

		var/cleanup_rate = 2
		if(user.traitHolder.hasTrait("training_medical") || user.traitHolder.hasTrait("training_chef"))
			cleanup_rate = 3
		user.sims.affectMotive("Hygiene", cleanup_rate)
		user.blood_DNA = null
		user.blood_type = null
		user.forensics_blood_color = null
		user.set_clothing_icon_dirty()

		src.onRestart()

	onInterrupt()
		..()


/datum/action/bar/private/critterwashing
	duration = 7 DECI SECONDS
	var/mob/living/carbon/human/user
	var/obj/submachine/chef_sink/sink
	var/mob/living/critter/small_animal/victim
	var/obj/item/grab/grab
	var/datum/aiTask/timed/wandering
	New(usermob,sink,critter,thegrab)
		src.user = usermob
		src.sink = sink
		src.victim = critter
		src.grab = thegrab
		..()

	proc/checkStillValid()
		if(GET_DIST(victim, sink) > 0 || BOUNDS_DIST(user, sink) > 1 || victim == null || user == null || sink == null || !grab)
			interrupt(INTERRUPT_ALWAYS)
			return FALSE
		return TRUE
	onStart()
		if(BOUNDS_DIST(user, sink) > 1) user.show_text("You're too far from the sink!")
		if (istype(victim, /mob/living/critter/small_animal/cat) && victim.ai?.enabled)
			victim._ai_patience_count = 0
			victim.was_harmed(user)
			victim.visible_message(SPAN_NOTICE("[victim] resists [user]'s attempt to wash them!"))
			playsound(victim.loc, 'sound/voice/animal/cat_hiss.ogg', 50, 1)

		else if (victim.ai?.enabled && istype(victim.ai.current_task, /datum/aiTask/timed/wander) )
			victim.ai.wait(5)
		..()

	loopStart()
		..()
		if (!checkStillValid())
			return
		playsound(get_turf(sink), 'sound/impact_sounds/Liquid_Slosh_1.ogg', 15, 1)
		if(prob(50))
			animate_door_squeeze(victim)
		else
			animate_smush(victim, 0.65)


	onEnd()
		if(!checkStillValid())
			..()
			return
		victim.blood_DNA = null
		victim.blood_type = null
		victim.forensics_blood_color = null
		victim.set_clothing_icon_dirty()

		src.onRestart()


ADMIN_INTERACT_PROCS(/obj/submachine/ice_cream_dispenser, proc/add_flavor)
TYPEINFO(/obj/submachine/ice_cream_dispenser)
	mats = 18

/obj/submachine/ice_cream_dispenser
	name = "Ice Cream Dispenser"
	desc = "A machine designed to dispense space ice cream."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "ice_creamer0"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = NOSPLASH | TGUI_INTERACTIVE
	/// A list of reagent_ids we will dispense by default
	var/list/flavors = list("chocolate","vanilla","coffee")
	var/obj/item/reagent_containers/glass/beaker = null
	var/obj/item/reagent_containers/food/snacks/ice_cream_cone/cone = null
	var/doing_a_thing = 0

	ui_interact(mob/user, datum/tgui/ui)
		if (src.beaker)
			SEND_SIGNAL(src.beaker.reagents, COMSIG_REAGENTS_ANALYZED, user)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "IceCreamMachine")
			ui.open()

	ui_static_data(mob/user)
		var/list/flavorsTemp = list()
		if(!flavors)
			return
		for(var/reagent in flavors)
			var/datum/reagent/fooddrink/current_reagent = reagents_cache[reagent]
			flavorsTemp.Add(list(list(
				name = current_reagent.name,
				id = current_reagent.id,
				colorR = current_reagent.fluid_r,
				colorG = current_reagent.fluid_g,
				colorB = current_reagent.fluid_b
			)))
		. = list(
			"flavors" = flavorsTemp
		)

	ui_data(mob/user)
		. = list(
			"beaker" = ui_describe_reagents(src.beaker),
			"has_cone" = src.cone ? TRUE : FALSE
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return

		if (istype(src.loc, /turf) && (( BOUNDS_DIST(src, usr) == 0) || issilicon(usr) || isAI(usr)))
			if (!isliving(usr) || iswraith(usr) || isintangible(usr))
				return
			if (is_incapacitated(usr) || usr.restrained())
				return

		src.add_fingerprint(usr)
		switch(action)
			if("eject_cone")
				var/obj/item/target = src.cone
				if (!target)
					boutput(usr, SPAN_ALERT("There is no cone loaded!"))
					return
				usr.put_in_hand_or_eject(target)
				boutput(usr, SPAN_NOTICE("You have removed the cone from [src]."))
				src.cone = null
				src.UpdateIcon()
				. = TRUE

			if("eject_beaker")
				var/obj/item/target = src.beaker
				if (!target)
					boutput(usr, SPAN_ALERT("There is no beaker loaded!"))
					return

				usr.put_in_hand_or_eject(target)
				boutput(usr, SPAN_NOTICE("You have removed the beaker from [src]."))
				src.beaker = null
				src.UpdateIcon()
				. = TRUE

			if("insert_beaker")
				var/obj/item/reagent_containers/newbeaker = usr.equipped()
				if (istype(newbeaker, /obj/item/reagent_containers/glass/) || istype(newbeaker, /obj/item/reagent_containers/food/drinks/))
					if(!newbeaker.cant_drop)
						usr.drop_item()
						newbeaker.set_loc(src)
					src.beaker = newbeaker
					src.UpdateIcon()
					. = TRUE

			if("make_ice_cream")
				if(!cone)
					boutput(usr, SPAN_ALERT("There is no cone loaded!"))
					return

				var/flavor = params["flavor"]
				var/obj/item/reagent_containers/food/snacks/ice_cream/newcream = new(src)
				if(flavor == "beaker")
					if(!beaker.reagents.total_volume)
						boutput(usr, SPAN_ALERT("The beaker is empty!"))
						return

					beaker.reagents.trans_to(newcream,40)
				else if(flavor in src.flavors)
					newcream.reagents.add_reagent(flavor,40)

				usr.put_in_hand_or_eject(newcream)
				src.cone = null
				src.UpdateIcon()
				. = TRUE


	attack_ai(var/mob/user as mob)
		return ui_interact(user)

	attackby(obj/item/W, mob/user)
		if (W.cant_drop) // For borg held items
			boutput(user, SPAN_ALERT("You can't put that in \the [src] when it's attached to you!"))
			return

		if (istype(W, /obj/item/reagent_containers/food/snacks/ice_cream_cone))
			if(src.cone)
				boutput(user, "There is already a cone loaded.")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.cone = W
				boutput(user, SPAN_NOTICE("You load the cone into [src]."))

			src.UpdateIcon()
			tgui_process.update_uis(src)

		else if (istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/))
			if(src.beaker)
				boutput(user, "There is already a beaker loaded.")
				return
			else
				user.drop_item()
				W.set_loc(src)
				src.beaker = W
				boutput(user, SPAN_ALERT("You load [W] into [src]."))

			src.UpdateIcon()
			tgui_process.update_uis(src)
		else ..()

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if ((istype(W, /obj/item/reagent_containers/food/snacks/ice_cream_cone) || istype(W, /obj/item/reagent_containers/glass/) || istype(W, /obj/item/reagent_containers/food/drinks/)) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	update_icon()
		if(src.beaker)
			src.overlays += image(src.icon, "ice_creamer_beaker")
		else
			src.overlays.len = 0

		src.icon_state = "ice_creamer[src.cone ? "1" : "0"]"

		return

	proc/add_flavor()
		set name = "Add flavor"

		var/datum/reagent/reagent = pick_reagent(usr)
		if (!reagent)
			return

		if (reagent.id in src.flavors)
			boutput(usr, "[src] already has flavor [reagent.name]")
			return

		src.flavors += reagent.id
		src.update_static_data_for_all_viewers()

/// COOKING RECODE ///

var/list/oven_recipes = list()


TYPEINFO(/obj/submachine/chef_oven)
	mats = 18

/obj/submachine/chef_oven
	name = "oven"
	desc = "A multi-cooking unit featuring a hob, grill, oven and more."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven_off"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	flags = NOSPLASH
	object_flags = NO_GHOSTCRITTER
	var/emagged = 0
	var/working = 0
	var/time = 5
	var/heat = "Low"
	var/list/recipes = null
	//var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/parts/robot_parts/head, /obj/item/clothing/head/butt, /obj/item/organ/brain/obj/item)
	var/allowed = list(/obj/item)
	var/static/tmp/recipe_html = null // see: create_oven_recipe_html()

	var/list/possible_recipe_icons = list()
	var/list/possible_recipe_names = list()
	var/output_icon
	var/output_name
	var/cooktime

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!emagged)
			emagged = 1
			if (user)
				boutput(user, SPAN_NOTICE("[src] produces a strange grinding noise."))
			return 1
		else
			return 0

	attack_hand(var/mob/user)
		if (isghostdrone(user))
			boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
			return
		src.ui_interact(user)

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Oven")
			ui.open()

	ui_data(mob/user)
		src.get_recipes()
		. = list(
			"time" = src.time,
			"heat" = src.heat,
			"cooking" = src.working,
			"content_icons" = src.get_content_icons(),
			"content_names" = src.get_content_names(),
			"recipe_icons" = src.possible_recipe_icons,
			"recipe_names" = src.possible_recipe_names,
			"output_icon" = src.output_icon,
			"output_name" = src.output_name,
			"cook_time" = src.cooktime
		)

	ui_act(action, params)
		. = ..()
		if (.)
			return
		. = TRUE
		switch (action)
			if ("set_time")
				src.time = params["time"]
			if ("set_heat")
				src.heat = params["heat"]
			if ("start")
				src.cook_food()
			if ("eject_all")
				for (var/obj/item/I in src.contents)
					I.set_loc(src.loc)
			if ("eject")
				var/obj/item/thing_to_eject = src.contents[params["ejected_item"]]
				if (thing_to_eject)
					thing_to_eject.set_loc(src.loc)
			if ("open_recipe_book")
				usr.Browse(recipe_html, "window=recipes;size=500x700")

	proc/get_content_icons()
		if (!length(src.contents))
			return
		var/list/contained = list()
		for (var/obj/item/I in src.contents)
			contained += icon2base64(getFlatIcon(I), "chef_oven-\ref[src]")
		return contained

	proc/get_content_names()
		if (!length(src.contents))
			return
		var/list/contained = list()
		for (var/obj/item/I in src.contents)
			contained += I.name
		return contained

	proc/get_recipes()
		src.possible_recipe_icons = list()
		src.possible_recipe_names = list()
		src.output_icon = null
		src.output_name = null
		src.cooktime = null

		var/datum/cookingrecipe/possible = src.OVEN_get_valid_recipe()
		if (!possible)
			return

		for(var/I in possible.ingredients)
			var/atom/item_path = I
			src.possible_recipe_icons += icon2base64(icon(initial(item_path.icon), initial(item_path.icon_state)), "chef_oven-\ref[src]")
			src.possible_recipe_names += "[initial(item_path.name)][possible.ingredients[I] > 1 ? " x[possible.ingredients[I]]" : ""]"

		if (ispath(possible.output))
			var/atom/item_path = possible.output
			src.output_icon = icon2base64(icon(initial(item_path.icon), initial(item_path.icon_state)), "chef_oven-\ref[src]")
			src.output_name = initial(item_path.name)

		if (possible.cookbonus < 10)
			src.cooktime = "[possible.cookbonus] seconds low"
		else
			src.cooktime = "[floor(possible.cookbonus/2)] seconds high"

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	New()
		..()
		// Note - The order these are placed in matters! Put more complex recipes before simpler ones, or the way the
		//        oven checks through the recipe list will make it pick the simple recipe and finish the cooking proc
		//        before it even gets to the more complex recipe, wasting the ingredients that would have gone to the
		//        more complicated one and pissing off the chef by giving something different than what he wanted!

		src.recipes = oven_recipes
		if (!src.recipes)
			src.recipes = list()

		if (!src.recipes.len)
			src.recipes += new /datum/cookingrecipe/oven/haggass(src)
			src.recipes += new /datum/cookingrecipe/oven/haggis(src)
			src.recipes += new /datum/cookingrecipe/oven/scotch_egg(src)
			src.recipes += new /datum/cookingrecipe/oven/omelette(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/monster(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/c_butty(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/meatball(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/meatball_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/egg(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/bahnmi(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/bahnmi_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/human(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/monkey(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/synth(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/cheese(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/peanutbutter(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/peanutbutter_honey(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/blt(src)
			src.recipes += new /datum/cookingrecipe/oven/sandwich/custom(src)
			src.recipes += new /datum/cookingrecipe/oven/mapo_tofu(src)
			src.recipes += new /datum/cookingrecipe/oven/ramen_bowl(src)
			src.recipes += new /datum/cookingrecipe/oven/udon_bowl(src)
			src.recipes += new /datum/cookingrecipe/oven/curry_udon_bowl(src)
			src.recipes += new /datum/cookingrecipe/oven/coconutcurry(src)
			src.recipes += new /datum/cookingrecipe/oven/chickenpineapplecurry(src)
			src.recipes += new /datum/cookingrecipe/oven/tandoorichicken(src)
			src.recipes += new /datum/cookingrecipe/oven/potatocurry(src)
			src.recipes += new /datum/cookingrecipe/oven/onionchips(src)
			src.recipes += new /datum/cookingrecipe/oven/mint_chutney(src)
			src.recipes += new /datum/cookingrecipe/oven/refried_beans(src)
			src.recipes += new /datum/cookingrecipe/oven/ultrachili(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/aburgination(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/baconator(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/butterburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cheeseburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/wcheeseburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/tikiburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/luauburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/coconutburger(src)
			src.recipes += new /datum/cookingrecipe/oven/spicychickensandwich(src)
			src.recipes += new /datum/cookingrecipe/oven/chickensandwich(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/baconburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/meat
			src.recipes += new /datum/cookingrecipe/oven/burger/buttburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/heartburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/brainburger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/sloppyjoe(src)
			src.recipes += new /datum/cookingrecipe/oven/superchili(src)
			src.recipes += new /datum/cookingrecipe/oven/chili(src)
			src.recipes += new /datum/cookingrecipe/oven/chilifries(src)
			src.recipes += new /datum/cookingrecipe/oven/chilifries_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/poutine(src)
			src.recipes += new /datum/cookingrecipe/oven/poutine_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/fries(src)
			src.recipes += new /datum/cookingrecipe/oven/queso(src)
			src.recipes += new /datum/cookingrecipe/oven/creamofmushroom(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/cheeseborger(src)
			src.recipes += new /datum/cookingrecipe/oven/burger/roburger(src)
			src.recipes += new /datum/cookingrecipe/oven/swede_mball(src)
			src.recipes += new /datum/cookingrecipe/oven/donkpocket(src)
			src.recipes += new /datum/cookingrecipe/oven/donkpocket2(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread4(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread3(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread2(src)
			src.recipes += new /datum/cookingrecipe/oven/cornbread1(src)
			src.recipes += new /datum/cookingrecipe/oven/elvis_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/banana_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/pumpkin_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/spooky_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/banana_bread_alt(src)
			src.recipes += new /datum/cookingrecipe/oven/honeywheat_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/eggnog(src)
			src.recipes += new /datum/cookingrecipe/oven/meatloaf(src)
			src.recipes += new /datum/cookingrecipe/oven/brain_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/toast_bread(src)
			src.recipes += new /datum/cookingrecipe/oven/donut(src)
			src.recipes += new /datum/cookingrecipe/oven/bagel(src)
			src.recipes += new /datum/cookingrecipe/oven/crumpet(src)
			src.recipes += new /datum/cookingrecipe/oven/ice_cream_cone(src)
			src.recipes += new /datum/cookingrecipe/oven/waffles(src)
			src.recipes += new /datum/cookingrecipe/oven/lasagna(src)
			src.recipes += new /datum/cookingrecipe/oven/chickenparm(src)
			src.recipes += new /datum/cookingrecipe/oven/chickenalfredo(src)
			src.recipes += new /datum/cookingrecipe/oven/alfredo(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_pg(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_m(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_s(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_t(src)
			src.recipes += new /datum/cookingrecipe/oven/spaghetti_p(src)
			src.recipes += new /datum/cookingrecipe/oven/breakfast(src)
			src.recipes += new /datum/cookingrecipe/oven/french_toast(src)
			src.recipes += new /datum/cookingrecipe/oven/cheesetoast(src)
			src.recipes += new /datum/cookingrecipe/oven/bacontoast(src)
			src.recipes += new /datum/cookingrecipe/oven/eggtoast(src)
			src.recipes += new /datum/cookingrecipe/oven/churro(src)
			src.recipes += new /datum/cookingrecipe/oven/nougat(src)
			src.recipes += new /datum/cookingrecipe/oven/candy_cane(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_box(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_honey(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_tanhony(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_roach(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_syndie(src)
			src.recipes += new /datum/cookingrecipe/oven/cereal_flock(src)
			src.recipes += new /datum/cookingrecipe/oven/b_cupcake(src)
			src.recipes += new /datum/cookingrecipe/oven/beefood(src)
			src.recipes += new /datum/cookingrecipe/oven/zongzi(src)

			src.recipes += new /datum/cookingrecipe/oven/baguette(src)
			src.recipes += new /datum/cookingrecipe/oven/garlicbread_ch(src)
			src.recipes += new /datum/cookingrecipe/oven/garlicbread(src)
			src.recipes += new /datum/cookingrecipe/oven/cinnamonbun(src)
			src.recipes += new /datum/cookingrecipe/oven/fairybread(src)
			src.recipes += new /datum/cookingrecipe/oven/chocolate_cherry(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_apple(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_cherry(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_blueb(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_weed(src)
			src.recipes += new /datum/cookingrecipe/oven/danish_cheese(src)
			src.recipes += new /datum/cookingrecipe/oven/painauchocolat(src)
			src.recipes += new /datum/cookingrecipe/oven/croissant(src)

			src.recipes += new /datum/cookingrecipe/oven/pie_anything/pie_cream(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_anything(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_cherry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_blueberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_blackberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_raspberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_strawberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_apple(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_lime(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_lemon(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_slurry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_pumpkin(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_custard(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_strawberry(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/pot_pie(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_chocolate(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_ass(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_fish(src)
			src.recipes += new /datum/cookingrecipe/oven/pie_weed(src)
			src.recipes += new /datum/cookingrecipe/oven/candy_apple(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_true_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_meat(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_chocolate(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_cream(src)
			#ifdef XMAS
			src.recipes += new /datum/cookingrecipe/oven/cake_fruit(src)
			#endif
			src.recipes += new /datum/cookingrecipe/oven/cake_custom(src)
			src.recipes += new /datum/cookingrecipe/oven/stroopwafel(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_spooky(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_jaffa(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_oatmeal(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_chocolate_chip(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_iron(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_butter(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie_peanut(src)
			src.recipes += new /datum/cookingrecipe/oven/cookie(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie_chocolate(src)
			src.recipes += new /datum/cookingrecipe/oven/moon_pie(src)
			src.recipes += new /datum/cookingrecipe/oven/granola_bar(src)
			src.recipes += new /datum/cookingrecipe/oven/biscuit(src)
			src.recipes += new /datum/cookingrecipe/oven/dog_biscuit(src)
			src.recipes += new /datum/cookingrecipe/oven/hardtack(src)
			src.recipes += new /datum/cookingrecipe/oven/macguffin(src)
			src.recipes += new /datum/cookingrecipe/oven/eggsalad(src)
			src.recipes += new /datum/cookingrecipe/oven/lipstick(src)
			src.recipes += new /datum/cookingrecipe/oven/friedrice(src)
			src.recipes += new /datum/cookingrecipe/oven/risotto(src)
			src.recipes += new /datum/cookingrecipe/oven/omurice(src)
			src.recipes += new /datum/cookingrecipe/oven/riceandbeans(src)
			src.recipes += new /datum/cookingrecipe/oven/sushi_roll(src)
			src.recipes += new /datum/cookingrecipe/oven/nigiri_roll(src)
			src.recipes += new /datum/cookingrecipe/oven/porridge(src)
			src.recipes += new /datum/cookingrecipe/oven/ratatouille(src)
			src.recipes += new /datum/cookingrecipe/oven/flapjack_batch(src)
			// Put all single-ingredient recipes after this point
			src.recipes += new /datum/cookingrecipe/oven/pizza_custom(src)
			src.recipes += new /datum/cookingrecipe/oven/cake_custom_item(src)
			src.recipes += new /datum/cookingrecipe/oven/pancake(src)
			src.recipes += new /datum/cookingrecipe/oven/bread(src)
			src.recipes += new /datum/cookingrecipe/oven/oatmeal(src)
			src.recipes += new /datum/cookingrecipe/oven/salad(src)
			src.recipes += new /datum/cookingrecipe/oven/tomsoup(src)
			src.recipes += new /datum/cookingrecipe/oven/toast(src)
			src.recipes += new /datum/cookingrecipe/oven/taco_shell(src)
			src.recipes += new /datum/cookingrecipe/oven/bacon(src)
			src.recipes += new /datum/cookingrecipe/oven/steak_ling(src)
			src.recipes += new /datum/cookingrecipe/oven/shrimp(src)
			src.recipes += new /datum/cookingrecipe/oven/cook_meat(src)
			src.recipes += new /datum/cookingrecipe/oven/chocolate_egg(src)
			src.recipes += new /datum/cookingrecipe/oven/hardboiled(src)
			src.recipes += new /datum/cookingrecipe/oven/bakedpotato(src)
			src.recipes += new /datum/cookingrecipe/oven/rice_ball(src)
			src.recipes += new /datum/cookingrecipe/oven/hotdog(src)
			src.recipes += new /datum/cookingrecipe/oven/cheesewheel(src)
			src.recipes += new /datum/cookingrecipe/oven/melted_sugar(src)
			src.recipes += new /datum/cookingrecipe/oven/brownie_batch(src)

			// store the list for later
			oven_recipes = src.recipes

	proc/cook_food()
		var/amount = length(src.contents)
		if (!amount)
			boutput(usr, SPAN_ALERT("There's nothing in \the [src] to cook."))
			return
		var/output = null /// what path / item is (getting) created
		var/cook_amt = src.time * (src.heat == "High" ? 2 : 1) /// time the oven is set to cook
		var/bonus = 0 /// correct-cook-time bonus
		var/derivename = 0 /// if output should derive name from human meat inputs
		var/recipebonus = 0 /// the ideal amount of cook time for the bonus
		var/recook = 0
		// If emagged produce random output.
		if (emagged)
			// Enforce GIGO and prevent infinite reuse
			var/contentsok = 1
			for(var/obj/item/I in src.contents)
				if(istype(I, /obj/item/reagent_containers/food/snacks/yuck))
					contentsok = 0
					break
				if(istype(I, /obj/item/reagent_containers/food/snacks/yuck/burn))
					contentsok = 0
					break
				if(istype(I, /obj/item/reagent_containers/food))
					var/obj/item/reagent_containers/food/F = I
					if (F.from_emagged_oven) // hyphz checked heal_amt but I think this custom var is a nicer solution (also I'm not sure that valid food not from an emagged oven will never have a heal_amt of 0 (because I am lazy and don't want to read the code))
						contentsok = 0
						break
				// Pick a random recipe
			var/datum/cookingrecipe/xrecipe = pick(src.recipes)
			var/xrecipeok = 1
			// Don't choose recipes with human meat since we don't have a name for them
			if (xrecipe.useshumanmeat)
				xrecipeok = 0
			// Don't choose recipes with special outputs since we don't have valid inputs for them
			if (isnull(xrecipe.output))
				xrecipeok = 0
			// Bail out to a mess if we didn't get a valid recipe
			if (xrecipeok && contentsok)
				output = xrecipe.output
			else
				output = /obj/item/reagent_containers/food/snacks/yuck
			// Given the weird stuff coming out of the oven it presumably wouldn't be palatable..
			recipebonus = 0
			bonus = -1
		else
			// Non-emagged cooking
			var/datum/cookingrecipe/R = src.OVEN_get_valid_recipe()
			if (R)
				// this is null if it uses normal outputs (see below),
				// otherwise it will be the created item from this
				output = R.specialOutput(src)
				if (!output)
					if(R.variants)//replace all of this with getVariant() once cooking machines are given a common type
						for(var/specialIngredient in R.variants)
							if(output) break
							if(OVEN_checkitem(specialIngredient, R.variant_quantity))
								output = R.variants[specialIngredient]
					if(!output)
						output = R.output
				if (R.useshumanmeat) derivename = 1
				// derive the bonus amount from cooking
				// being off by one in either direction is OK
				// being off by 5 either burns it or makes it taste like shit
				// "cookbonus" here is actually "amount of cooking needed for bonus"
				recipebonus = R.cookbonus
				if (abs(cook_amt - R.cookbonus) <= 1)
					// if -1, 0, or 1, you did ok
					bonus = 1
				else if (cook_amt <= R.cookbonus - 5)
					// severely undercooked
					bonus = -1
				else if (cook_amt >= R.cookbonus + 5)
					// severely overcooked and burnt
					output = /obj/item/reagent_containers/food/snacks/yuck/burn
					bonus = 0
			// the case where there are no valid recipies is handled below in the outer context
			// (namely it replaces them with yuck)
		if (isnull(output))
			output = /obj/item/reagent_containers/food/snacks/yuck
		// this only happens if the output is a yuck item, either from an
		// invalid recipe or otherwise...
		if (amount == 1 && output == /obj/item/reagent_containers/food/snacks/yuck)
			for (var/obj/item/reagent_containers/food/snacks/F in src)
				if(F.quality < 1)
					// @TODO cook_amt == F.quality can never happen here
					// (cook_amt is the time the oven is set to from 1-10,
					//  and F.quality has to be 0 or below to get here)
					recook = 1
					if (cook_amt == F.quality) F.quality = 1.5
					else if (cook_amt == F.quality + 1) F.quality = 1
					else if (cook_amt == F.quality - 1) F.quality = 1
					else if (cook_amt <= F.quality - 5) F.quality = 0.5
					else if (cook_amt >= F.quality + 5)
						output = /obj/item/reagent_containers/food/snacks/yuck/burn
						bonus = 0
		// start cooking animation
		src.working = 1
		src.icon_state = "oven_bake"

		// this is src.time seconds instead of cook_amt,
		// because cook_amount is x2 if on "high" mode,
		// and it seems pretty silly to make it take twice as long
		// instead of, idk, just giving the oven 20 buttons
		SPAWN(src.time SECONDS)
			// this is all stuff relating to re-cooking with yuck items
			// suitably it is very gross
			if(recook && bonus !=0)
				for (var/obj/item/reagent_containers/food/snacks/F in src)
					if (bonus == 1)
						if (F.quality != 1)
							F.quality = 1
					else if (bonus == -1)
						if (F.quality > 0.5)
							F.quality = 0.5
					if (src.emagged)
						F.from_emagged_oven = 1
					F.set_loc(src.loc)
					if (istype(F, /obj/item/reagent_containers/food/snacks/yuck))
						src.food_crime(usr, F)
			else
				// normal cooking here
				var/obj/item/reagent_containers/food/snacks/F
				if (ispath(output))
					F = new output(src.loc)
				else
					F = output
					F.set_loc( get_turf(src) )
				// if this was a yuck item, it's bad enough to be criminal
				if (istype(F, /obj/item/reagent_containers/food/snacks/yuck))
					src.food_crime(usr, F)
				// "bonus" is 1 if cook time is within 1 of the required time,
				// 0 if it was off by 2-4 or over by 5+
				// -1 if it was under by 5 or more
				// basically:
				// -5  4  3  2 -1  0 +1  2  3  4 +5   diff. from required time
				//                 |
				//  0  1  2  3  5  5  5  3  2  1  0   food quality
				if (bonus == 1)
					F.quality = 5
				else
					F.quality = clamp(5 - abs(recipebonus - cook_amt), 0, 5)
				// emagged ovens cannot re-cook their own outputs
				if (src.emagged && istype(F))
					F.from_emagged_oven = 1
				// used for dishes that have their human's name in them
				if (derivename)
					var/foodname = F.name
					for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in src.contents)
						F.name = "[M.subjectname] [foodname]"
						F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
						if(!isnull(F.unlock_medal_when_eaten))
							continue
						else if (M.subjectjob && M.subjectjob == "Clown")
							F.unlock_medal_when_eaten = "That tasted funny"
						else
							F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method
			// done with checking outputs...
			// change icon back, ding, and remove used ingredients
			src.icon_state = "oven_off"
			src.working = 0
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			for (var/atom/movable/I in src.contents)
				qdel(I)

	proc/food_crime(mob/user, obj/item/food)
		// logTheThing(LOG_STATION, src, "[key_name(user)] commits a horrible food crime, creating [food] with quality [food.quality].")

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message(SPAN_ALERT("<b>[user] shoves [his_or_her(user)] head in the oven and turns it on.</b>"))
		src.icon_state = "oven_bake"
		user.TakeDamage("head", 0, 150)
		sleep(5 SECONDS)
		src.icon_state = "oven_off"
		SPAWN(55 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	attackby(obj/item/W, mob/user)
		if (isghostdrone(user))
			boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
			return
		if (W.cant_drop) //For borg held items
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return
		if(W.w_class > W_CLASS_BULKY)
			boutput(user, SPAN_ALERT("[W] is far too large and unwieldly to fit in [src]!"))
			return
		if (src.working)
			boutput(user, SPAN_ALERT("It's already on! Putting a new thing in could result in a collapse of the cooking waveform into a really lousy eigenstate, like a vending machine chili dog."))
			return
		var/amount = length(src.contents)
		if (amount >= 8)
			boutput(user, SPAN_ALERT("\The [src] cannot hold any more items."))
			return

		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (istype(W, /obj/item/grab))
			proceed = 0
		if (istype(W, /obj/item/card/emag))
			..()
			return
		if (amount == 1)
			var/cakecount
			for (var/obj/item/reagent_containers/food/snacks/cake/cream/C in src.contents) cakecount++
			if (cakecount == 1) proceed = 1
		if (!proceed)
			boutput(user, SPAN_ALERT("You can't put that in [src]!"))
			return
		user.visible_message(SPAN_NOTICE("[user] loads [W] into [src]."))
		user.u_equip(W)
		W.set_loc(src)
		W.dropped(user)
		src.ui_interact(user)

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && W.w_class <= W_CLASS_HUGE && !W.anchored && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	proc/OVEN_get_valid_recipe()
		// For every recipe, check if we can make it with our current contents
		for (var/datum/cookingrecipe/R in src.recipes)
			if (src.OVEN_can_cook_recipe(R))
				return R
		return null

	proc/OVEN_can_cook_recipe(datum/cookingrecipe/recipe)
		for(var/I in recipe.ingredients)
			if (!OVEN_checkitem(I, recipe.ingredients[I])) return FALSE

		return TRUE

	proc/OVEN_checkitem(var/recipeitem, var/recipecount)
		if (!locate(recipeitem) in src.contents) return FALSE
		var/count = 0
		for(var/obj/item/I in src.contents)
			if(istype(I, recipeitem))
				count++
		if (count < recipecount)
			return FALSE
		return TRUE


#define MIN_FLUID_INGREDIENT_LEVEL 10
TYPEINFO(/obj/submachine/foodprocessor)
	mats = 18

/obj/submachine/foodprocessor
	name = "Processor"
	desc = "Refines various food substances into different forms."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor-off"
	anchored = ANCHORED
	density = 1
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER
	var/working = 0
	var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/plant/, /obj/item/organ/brain, /obj/item/clothing/head/butt)

	attack_hand(var/mob/user)
		if (length(src.contents) < 1)
			boutput(user, SPAN_ALERT("There is nothing in the processor!"))
			return
		if (src.working == 1)
			boutput(user, SPAN_ALERT("The processor is busy!"))
			return
		src.icon_state = "processor-on"
		src.working = 1
		src.visible_message("The [src] begins processing its contents.")
		sleep(rand(30,70))
		// Dispense processed stuff
		for(var/obj/item/P in src.contents)
			if (istype(P,/obj/item/reagent_containers/food/drinks))
				var/milk_amount = P.reagents.get_reagent_amount("milk")
				var/yoghurt_amount = P.reagents.get_reagent_amount("yoghurt")
				if (milk_amount < 10 && yoghurt_amount < 10)
					continue

				var/cream_output = floor(milk_amount / 10)
				var/yoghurt_output = floor(yoghurt_amount / 10)
				P.reagents.remove_reagent("milk", cream_output * 10)
				P.reagents.remove_reagent("yoghurt", yoghurt_output * 10)
				for (var/i in 1 to cream_output)
					new/obj/item/reagent_containers/food/snacks/condiment/cream(src.loc)
				for (var/i in 1 to yoghurt_output)
					new/obj/item/reagent_containers/food/snacks/yoghurt(src.loc)

			switch( P.type )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = P:subjectname + " meatball"
					F.desc = "Meaty balls taken from the station's finest [P:subjectjob]."
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "monkey meatball"
					F.desc = "Welcome to Space Station 13, where you too can eat a rhesus macaque's balls."
					qdel( P )
				if (/obj/item/organ/brain)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "brain meatball"
					F.desc = "Oh jesus, brain meatballs? That's just nasty."
					F.icon_state = "meatball_brain"
					qdel( P )
				if (/obj/item/clothing/head/butt)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "buttball"
					F.desc = "The best you can hope for is that the meat was lean..."
					F.icon_state = "meatball_butt"
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "synthetic meatball"
					F.desc = "Let's be honest, this is probably as good as these things are going to get."
					F.icon_state = "meatball_plant"
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat)
					var/obj/item/reagent_containers/food/snacks/meatball/F = new(src.loc)
					F.name = "mystery meatball"
					F.desc = "A meatball of even more dubious quality than usual."
					F.icon_state = "meatball_mystery"
					qdel( P )
				if (/obj/item/plant/wheat/metal)
					new/obj/item/reagent_containers/food/snacks/condiment/ironfilings/(src.loc)
					qdel( P )
				if (/obj/item/plant/wheat/durum)
					new/obj/item/reagent_containers/food/snacks/ingredient/flour/semolina(src.loc)
					qdel( P )
				if (/obj/item/plant/wheat)
					new/obj/item/reagent_containers/food/snacks/ingredient/flour/(src.loc)
					qdel( P )
				if (/obj/item/plant/oat)
					new/obj/item/reagent_containers/food/snacks/ingredient/oatmeal/(src.loc)
					qdel( P )
				if (/obj/item/plant/oat/salt)
					var/obj/item/reagent_containers/food/snacks/ingredient/salt/F = new(src.loc)
					F.reagents.add_reagent("salt", P.reagents.get_reagent_amount("salt")) // item/plant has no plantgenes :(
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/rice_sprig)
					new/obj/item/reagent_containers/food/snacks/ingredient/rice(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/tomato)
					new/obj/item/reagent_containers/food/snacks/condiment/ketchup(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/peanuts)
					new/obj/item/reagent_containers/food/snacks/ingredient/peanutbutter(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/egg)
					new/obj/item/reagent_containers/food/snacks/condiment/mayo(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/pasta/sheet)
					new/obj/item/reagent_containers/food/snacks/ingredient/pasta/spaghetti(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/sheet)
					new/obj/item/reagent_containers/food/snacks/ingredient/wheat_noodles/ramen(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili/chilly)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/coldsauce/F = new(src.loc)
					F.reagents.add_reagent("cryostylane", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili/ghost_chili)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/hotsauce/ghostchilisauce/F = new(src.loc)
					F.reagents.add_reagent("ghostchilijuice", 5 + HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/chili)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/hotsauce/F = new(src.loc)
					F.reagents.add_reagent("capsaicin", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry/mocha)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/candy/chocolate/F = new(src.loc)
					F.reagents.add_reagent("chocolate", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry/latte)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/condiment/cream/F = new(src.loc)
					F.reagents.add_reagent("cream", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/plant/sugar)
					var/obj/item/reagent_containers/food/snacks/ingredient/sugar/F = new(src.loc)
					F.reagents.add_reagent("sugar", 20)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/condiment/cream)
					new/obj/item/reagent_containers/food/snacks/ingredient/butter(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/candy/chocolate)
					new/obj/item/reagent_containers/food/snacks/condiment/chocchips(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/corn)
					new/obj/item/reagent_containers/food/snacks/popcorn(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/corn/pepper)
					var/datum/plantgenes/DNA = P:plantgenes
					var/obj/item/reagent_containers/food/snacks/ingredient/pepper/F = new(src.loc)
					F.reagents.add_reagent("pepper", HYPfull_potency_calculation(DNA))
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/avocado)
					new/obj/item/reagent_containers/food/snacks/soup/guacamole(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/soy)
					new/obj/item/reagent_containers/food/drinks/milk/soy(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/coffeeberry)
					new/obj/item/reagent_containers/food/snacks/plant/coffeebean(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/meatpaste)
					new/obj/item/reagent_containers/food/snacks/ingredient/pepperoni_log(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/ingredient/fishpaste)
					new/obj/item/reagent_containers/food/snacks/ingredient/kamaboko_log(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/cucumber)
					new/obj/item/reagent_containers/food/snacks/pickle(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/cherry)
					new/obj/item/cocktail_stuff/maraschino_cherry(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/turmeric)
					new/obj/item/reagent_containers/food/snacks/ingredient/currypowder(src.loc)
					qdel( P )
				if (/obj/item/plant/herb/tea)
					new/obj/item/reagent_containers/food/snacks/condiment/matcha(src.loc)
					qdel( P )
				if (/obj/item/reagent_containers/food/snacks/plant/mustard)
					new/obj/item/reagent_containers/food/snacks/condiment/mustard(src.loc)
					qdel( P )
		// Wind down
		for(var/obj/item/S in src.contents)
			S.set_loc(get_turf(src))
		src.working = 0
		src.icon_state = "processor-off"
		playsound(src.loc, 'sound/machines/ding.ogg', 100, 1)
		return

	attack_ai(var/mob/user as mob)
		return attack_hand(user)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/satchel/))
			var/obj/item/satchel/S = W
			if (length(S.contents) < 1) boutput(user, SPAN_ALERT("There's nothing in the satchel!"))
			else
				user.visible_message(SPAN_NOTICE("[user] loads [S]'s contents into [src]!"))
				var/amtload = 0
				for (var/obj/item/reagent_containers/food/F in S.contents)
					F.set_loc(src)
					amtload++
				for (var/obj/item/plant/P in S.contents)
					P.set_loc(src)
					amtload++
				S.UpdateIcon()
				boutput(user, SPAN_NOTICE("[amtload] items loaded from satchel!"))
				S.tooltip_rebuild = 1
			return
		else
			var/proceed = 0
			for(var/check_path in src.allowed)
				if(istype(W, check_path))
					proceed = 1
					break
			if (!proceed)
				boutput(user, SPAN_ALERT("You can't put that in the processor!"))
				return
			// If item is attached to you, don't drop it in, ex Silicons can't load in their icing tubes
			if (W.cant_drop)
				boutput(user, SPAN_ALERT("You can't put that in the [src] when it's attached to you!"))
				return
			user.visible_message(SPAN_NOTICE("[user] loads [W] into the [src]."))
			user.u_equip(W)
			W.set_loc(src)
			W.dropped(user)
			return

	mouse_drop(over_object, src_location, over_location)
		..()
		if (BOUNDS_DIST(src, usr) > 0 || !isliving(usr) || iswraith(usr) || isintangible(usr))
			return
		if (is_incapacitated(usr) || usr.restrained())
			return
		if (over_object == usr && (in_interact_range(src, usr) || usr.contents.Find(src)))
			for(var/obj/item/P in src.contents)
				P.set_loc(get_turf(src))
			for(var/mob/O in AIviewers(usr, null))
				O.show_message(SPAN_NOTICE("[usr] empties the [src]."))
			return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (BOUNDS_DIST(src, user) > 0 || !isliving(user) || iswraith(user) || isintangible(user) || !isalive(user) || isintangible(user))
			return
		if (is_incapacitated(user) || user.restrained())
			return

		if (istype(O, /obj/storage))
			if (O:locked)
				boutput(user, SPAN_ALERT("You need to unlock it first!"))
				return
			user.visible_message(SPAN_NOTICE("[user] loads [O]'s contents into [src]!"))
			var/amtload = 0
			for (var/obj/item/reagent_containers/food/M in O.contents)
				M.set_loc(src)
				amtload++
			for (var/obj/item/plant/P in O.contents)
				P.set_loc(src)
				amtload++
			if (amtload) boutput(user, SPAN_NOTICE("[amtload] items of food loaded from [O]!"))
			else boutput(user, SPAN_ALERT("No food loaded!"))
		else if (istype(O, /obj/item/reagent_containers/food/) || istype(O, /obj/item/plant/))
			user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing food into [src]!"))
			var/staystill = user.loc
			for(var/obj/item/reagent_containers/food/M in view(1,user))
				// Stop putting attached items in processor, looking at you borgs with icing tubes...
				if (!M.cant_drop)
					M.set_loc(src)
					sleep(0.3 SECONDS)
					if (user.loc != staystill) break
			for(var/obj/item/plant/P in view(1,user))
				P.set_loc(src)
				sleep(0.3 SECONDS)
				if (user.loc != staystill) break
			boutput(user, SPAN_NOTICE("You finish stuffing food into [src]!"))
		else ..()
