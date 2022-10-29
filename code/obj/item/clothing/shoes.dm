// OMG SHOES

//defines in setup.dm:
//LACES_NORMAL 0, LACES_TIED 1, LACES_CUT 2, LACES_NONE -1

/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/item_shoes.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	wear_image_icon = 'icons/mob/clothing/feet.dmi'
	var/chained = 0
	var/laces = LACES_NORMAL // Laces for /obj/item/gun/energy/pickpocket harass mode.
	var/kick_bonus = 0 //some shoes will yield extra kick damage!
	compatible_species = list("human")
	protective_temperature = 500
	//cogwerks - burn vars
	burn_point = 400
	burn_output = 800
	burn_possible = 1
	health = 5
	tooltip_flags = REBUILD_DIST
	var/step_sound = "step_default"
	var/step_priority = STEP_PRIORITY_NONE
	var/step_lots = 0 //classic steps (used for clown shoos)

	var/magnetic = 0    //for magboots, to avoid type checks on shoe

	setupProperties()
		..()
		setProperty("coldprot", 5)
		setProperty("heatprot", 5)
		setProperty("chemprot", 5)

	get_desc(dist)
		..()
		if (dist < 1) // on our tile or our person
			if (.) // we're returning something
				. += " " // add a space
			switch (src.laces)
				if (LACES_TIED)
					. += "The laces are tied."
				if (LACES_CUT)
					. += "The laces are cut."

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tank/air) || istype(W, /obj/item/tank/oxygen) || istype(W, /obj/item/tank/mini_oxygen) || istype(W, /obj/item/tank/jetpack))
			var/uses = 0

			if(istype(W, /obj/item/tank/mini_oxygen)) uses = 2
			else if(istype(W, /obj/item/tank/air)) uses = 4
			else if(istype(W, /obj/item/tank/oxygen)) uses = 4
			else if(istype(W, /obj/item/tank/jetpack)) uses = 6

			var/turf/T = get_turf(user)
			var/obj/item/clothing/shoes/rocket/R = new/obj/item/clothing/shoes/rocket(T)
			R.uses = uses
			boutput(user, "<span class='notice'>You haphazardly kludge together some rocket shoes.</span>")
			qdel(W)
			qdel(src)

		if (src.laces == LACES_TIED && istool(W, TOOL_CUTTING | TOOL_SNIPPING))
			boutput(user, "You neatly cut the knot and most of the laces away. Problem solved forever!")
			src.laces = LACES_CUT
			tooltip_rebuild = 1

/obj/item/clothing/shoes/rocket
	name = "rocket shoes"
	desc = "A gas tank taped to some shoes. Brilliant. They also look kind of silly."
	icon_state = "rocketshoes"
	protective_temperature = 0
	var/uses = 6
	var/emagged = 0
	burn_possible = 0
	step_sound = "step_plating"
	step_priority = STEP_PRIORITY_LOW

	setupProperties()
		..()
		setProperty("movespeed", 0.5)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				user.show_text("You swipe the card over the pressure regulator, breaking it.", "blue")
			src.emagged = 1
			src.desc += " Something seems to be wrong with them, though."
			return 1
		else
			if (user)
				user.show_text("The regulator seems to have already been tampered with.", "red")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		else
			if (user)
				user.show_text("You repair the pressure regulator on the [src].", "blue")
			src.emagged = 0
			src.desc = "A gas tank taped to some shoes. Brilliant. They also look kind of silly."
			return 1


/obj/item/clothing/shoes/rocket/abilities = list(/obj/ability_button/shoerocket)

/obj/item/clothing/shoes/sonic
	name = "Sahnic the Bushpig's Shoes"
	icon_state = "red"
	desc = "Have got to go swiftly."
	var/soniclevel = 9.999
	var/soniclength = 50
	var/sonicbreak = 0
	protective_temperature = 1500

	setupProperties()
		..()
		setProperty("movespeed", -10)

/obj/item/clothing/shoes/sonic/abilities = list(/obj/ability_button/sonic)

/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	desc = "These shoes somewhat protect you from fire."
	protective_temperature = 1500

	setupProperties()
		..()
		setProperty("heatprot", 7)

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	icon_state = "brown"
	desc = "Brown shoes, camouflage on this kind of station."

/obj/item/clothing/shoes/red
	name = "red shoes"
	icon_state = "red"

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blu"

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	uses_multiple_icon_states = 1
	desc = "Shoes, now in prisoner orange! Can be made into shackles."

	attack_self(mob/user as mob)
		if (src.chained)
			src.chained = null
			src.cant_self_remove = 0
			new /obj/item/handcuffs(get_turf(user))
			src.name = "orange shoes"
			src.icon_state = "orange"
			src.desc = "Shoes, now in prisoner orange! Can be made into shackles."

	attackby(H as obj, loc)
		if (istype(H, /obj/item/handcuffs) && !src.chained)
			qdel(H)
			src.chained = 1
			src.cant_self_remove = 1
			src.name = "shackles"
			src.desc = "Used to restrain prisoners."
			src.icon_state = "orange1"
		..()

/obj/item/clothing/shoes/pink
	name = "pink shoes"
	icon_state = "pink"

/obj/item/clothing/shoes/magnetic
	name = "magnetic shoes"
	desc = "Keeps the wearer firmly anchored to the ground. Provided the ground is metal, of course."
	icon_state = "magboots"
	// c_flags = NOSLIP
	mats = 8
	burn_possible = 0
	laces = LACES_NONE
	kick_bonus = 2
	step_sound = "step_plating"
	step_priority = STEP_PRIORITY_LOW
	abilities = list(/obj/ability_button/magboot_toggle)

	proc/activate()
		src.magnetic = 1
		src.setProperty("movespeed", 0.5)
		src.setProperty("disorient_resist", 10)
		step_sound = "step_lattice"
		playsound(src.loc, 'sound/items/miningtool_on.ogg', 30, 1)
	proc/deactivate()
		src.magnetic = 0
		src.delProperty("movespeed")
		src.delProperty("disorient_resist")
		step_sound = "step_plating"
		playsound(src.loc, 'sound/items/miningtool_off.ogg', 30, 1)

/obj/item/clothing/shoes/hermes
	name = "sacred sandals" // The ultimate goal of material scientists.
	desc = "Sandals blessed by the all-powerful goddess of victory and footwear."
	icon_state = "wizard" //TODO: replace with custom sprite, thinking winged sandals
	c_flags = NOSLIP
	mats = 0
	magical = 1
	burn_possible = 0
	laces = LACES_NONE
	step_sound = "step_flipflop"
	step_priority = STEP_PRIORITY_LOW

	setupProperties()
		..()
		setProperty("movespeed", -2)
		delProperty("chemprot")

/obj/item/clothing/shoes/industrial
#ifdef UNDERWATER_MAP
	name = "mechanised diving boots"
	icon_state = "divindboots"
	desc = "Industrial-grade boots fitted with mechanised balancers and stabilisers to increase running speed under a heavy workload."
#else
	icon_state = "indboots"
	name = "mechanised boots"
	desc = "Industrial-grade boots fitted with mechanised balancers and stabilisers to increase running speed under a heavy workload."
#endif
	mats = list("MET-3"= 15,"CON-2" = 10,"POW-3" = 10)
	burn_possible = 0
	laces = LACES_NONE
	kick_bonus = 2

/obj/item/clothing/shoes/industrial/equipped(mob/user, slot)
	. = ..()
	APPLY_MOVEMENT_MODIFIER(user, /datum/movement_modifier/reagent/energydrink, src.type)

/obj/item/clothing/shoes/industrial/unequipped(mob/user)
	. = ..()
	REMOVE_MOVEMENT_MODIFIER(user, /datum/movement_modifier/reagent/energydrink, src.type)

/obj/item/clothing/shoes/white
	name = "white shoes"
	desc = "Protects you against biohazards that would enter your feet."
	icon_state = "white"

	setupProperties()
		..()
		setProperty("chemprot", 7)

/obj/item/clothing/shoes/galoshes
	name = "galoshes"
	desc = "Rubber boots that prevent slipping on wet surfaces."
	icon_state = "galoshes"
	c_flags = NOSLIP
	step_sound = "step_rubberboot"
	step_priority = STEP_PRIORITY_LOW

	setupProperties()
		..()
		setProperty("chemprot", 7)

	torn
		desc = "Rubber boots that would prevent slipping on wet surfaces, were they not all torn up. Like these are. Damn."
		c_flags = null

		setupProperties()
			..()
			delProperty("chemprot")

/obj/item/clothing/shoes/clown_shoes
	name = "clown shoes"
	desc = "Damn, thems some big shoes."
	icon_state = "clown"
	item_state = "clown_shoes"
	step_sound = "clownstep"
	compatible_species = list("human", "cow")
	step_lots = 1
	step_priority = 999
	var/list/crayons = list() // stonepillar's crayon project
	var/max_crayons = 5

	attackby(obj/item/W, mob/living/user)
		if (istype(W, /obj/item/pen/crayon))
			if (user.bioHolder.HasEffect("clumsy"))
				var/obj/item/pen/crayon/C = W
				if (!length(C.symbol_setting))
					boutput(user, "<span class='alert'>You need to set the crayon's symbol first!</span>")
					return
				if (src.crayons)
					if (length(src.crayons) == src.max_crayons)
						boutput(user, "<span class='alert'>You try your best to shove [C] into [src], but there's not enough room!</span>")
						return
					else
						boutput(user, "<span class='notice'>You shove [C] into the soles of [src].</span>")
						src.crayons.Add(C)
						user.u_equip(W)
						C.set_loc(src)
						return
			else
				boutput(user, "<span class='alert'>You aren't funny enough to do that. Wait, did the shoes just laugh at you?</span>")
		else
			return ..()

	attack_hand(mob/user)
		if (length(src.crayons) && src.loc == user)
			if (!user.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span class='alert'>You aren't funny enough to do that. Wait, did the shoes just laugh at you?</span>")
				return
			var/obj/item/pen/crayon/picked = pick(src.crayons)
			src.crayons.Remove(picked)
			user.put_in_hand_or_drop(picked)
			boutput(user, "<span class='notice'>You pull [picked] out from the soles of [src].</span>")
			src.add_fingerprint(user)
			return
		return ..()


/obj/item/clothing/shoes/clown_shoes/New()
	. = ..()
	AddComponent(/datum/component/wearertargeting/tripsalot, list(SLOT_SHOES))
	AddComponent(/datum/component/wearertargeting/crayonwalk, list(SLOT_SHOES))

/obj/item/clothing/shoes/flippers
	name = "flippers"
	desc = "A pair of rubber flippers that improves swimming ability when worn."
	icon_state = "flippers"
	laces = LACES_NONE
	step_sound = "step_flipflop"
	step_priority = STEP_PRIORITY_LOW

	New()
		..()
		setProperty("chemprot", 7)
		setProperty("negate_fluid_speed_penalty",0.6)

/obj/item/clothing/shoes/moon
	name = "moon shoes"
	desc = "Recent developments in trampoline-miniaturization technology have made these little wonders possible."
	icon_state = "moonshoes"
	mats = 2

	equipped(var/mob/user, var/slot)
		..()
		user.visible_message("<b>[user]</b> starts hopping around!","You start hopping around.")
		animate(user, pixel_y=3, time=0.1 SECONDS, loop=-1, flags=ANIMATION_PARALLEL | ANIMATION_RELATIVE)
		animate(pixel_y=-6, time=0.2 SECONDS, flags=ANIMATION_RELATIVE)
		animate(pixel_y=3, time=0.1 SECONDS, flags=ANIMATION_RELATIVE)

	unequipped(var/mob/user)
		animate(user)
		..()

/obj/item/clothing/shoes/cowboy
	name = "Cowboy boots"
	icon_state = "cowboy"
	compatible_species = list("human", "cow")

/obj/item/clothing/shoes/cowboy/boom
	name = "Boom Boots"
	desc = "Boom shake shake shake the room. Tick tick tick tick boom!"
	icon_state = "cowboy"
	color = "#FF0000"
	step_sound = "explosion"
	contraband = 10
	step_priority = 999
	is_syndicate = 1

/obj/item/clothing/shoes/ziggy
	name = "familiar boots"
	desc = "A pair of striking red boots. Though they look clean, the soles are absolutely coated in a really fine, white powder."
	icon_state = "ziggy"

/obj/item/clothing/shoes/sandal
	name = "magic sandals"
	desc = "They magically stop you from slipping on magical hazards. It's not the mesh on the underside that does that. It's MAGIC. Read a fucking book."
	icon_state = "wizard"
	c_flags = NOSLIP
	magical = 1
	laces = LACES_NONE
	step_sound = "step_flipflop"
	step_priority = STEP_PRIORITY_LOW
	duration_remove = 10 SECONDS

	/// Subtype that wizards spawn with, and is in their vendor. Cows can wear them, unlike regular sandals (might also be useful in the future)
	wizard
		compatible_species = list("human", "cow")

/obj/item/clothing/shoes/tourist
	name = "flip-flops"
	desc = "These cheap sandals don't look very comfortable."
	icon_state = "tourist"
	protective_temperature = 0
	step_sound = "step_flipflop"
	step_priority = STEP_PRIORITY_LOW

	setupProperties()
		..()
		setProperty("coldprot", 0)
		setProperty("heatprot", 0)
		delProperty("chemprot")

/obj/item/clothing/shoes/detective
	name = "worn boots"
	desc = "This pair of leather boots has seen better days."
	icon_state = "detective"

/obj/item/clothing/shoes/chef
	name = "chef's clogs"
	desc = "Sturdy shoes that minimize injury from falling objects or knives."
	icon_state = "chef"
	kick_bonus = 1
	step_sound = "step_wood"
	step_priority = STEP_PRIORITY_LOW
	setupProperties()
		..()
		setProperty("chemprot", 7)
		setProperty("meleeprot", 1)

/obj/item/clothing/shoes/swat
	name = "military boots"
	desc = "Polished and very shiny military boots."
	icon_state = "swat"
	protective_temperature = 1250
	step_sound = "step_military"
	step_priority = STEP_PRIORITY_LOW
	step_lots = 1
	kick_bonus = 2

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)
		setProperty("chemprot", 7)
		setProperty("meleeprot", 1)

/obj/item/clothing/shoes/swat/noslip
	name = "hi-grip assault boots"
	desc = "Specialist combat boots designed to provide enhanced grip and ankle stability."
	icon_state = "swatheavy"
	compatible_species = list("cow", "human")
	c_flags = NOSLIP

/obj/item/clothing/shoes/swat/heavy
	name = "heavy military boots"
	desc = "Fairly worn out military boots."
	icon_state = "swatheavy"
	step_sound = "step_heavyboots"
	step_priority = STEP_PRIORITY_LOW
	tooltip_flags = REBUILD_DIST | REBUILD_USER

	get_desc(var/dist, var/mob/user)
		if (user.mind && user.mind.assigned_role == "Head of Security")
			. = "Still fit like a glove! Or a shoe."
		else
			. = "Looks like some big shoes to fill!"
		. = ..()

/obj/item/clothing/shoes/swat/knight // so heavy you can't get shoved!
	name = "combat sabatons"
	desc = "Massive, magnetic, slip-resistant armored footwear for syndicate super-heavies."
	icon_state = "knightboots"
	magnetic = 1
	c_flags = NOSLIP
	compatible_species = list("cow", "human")

/obj/item/clothing/shoes/fuzzy //not boolean slippers
	name = "fuzzy slippers"
	desc = "A pair of cute little pink rabbit slippers."
	icon_state = "fuzzy"
	step_sound = "step_carpet"
	step_priority = STEP_PRIORITY_LOW

	setupProperties()
		..()
		setProperty("coldprot", 15)

/obj/item/clothing/shoes/gogo
	name = "go-go boots"
	desc = "These boots complete your Space Age look."
	icon_state = "gogo"
	step_sound = "step_rubberboot"
	step_priority = STEP_PRIORITY_LOW

	setupProperties()
		..()
		setProperty("coldprot", 10)
		setProperty("heatprot", 10)

/obj/item/clothing/shoes/jetpack
	name = "jet boots"
	desc = "Some kind of fancy boots with little propulsion rockets attached to them, that let you move through space with ease and grace! Okay, maybe not grace. That part depends on you. Also, they are a fashion disaster. On the plus side, you can more easily escape the fashion police while wearing them!"
	icon_state = "rocketboots"
	laces = LACES_NONE
	burn_possible = 0
	step_sound = "step_plating"
	step_priority = STEP_PRIORITY_LOW
	var/on = 1
	var/obj/item/tank/tank = null
	tooltip_flags = REBUILD_ALWAYS

	New()
		..()
		src.tank = new /obj/item/tank/mini_oxygen(src)

	setupProperties()
		..()
		setProperty("movespeed", 0.3)

	proc/toggle()
		src.on = !(src.on)
		boutput(usr, "<span class='notice'>The jet boots are now [src.on ? "on" : "off"].</span>")
		return


	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/tank))
			if (src.tank)
				boutput(user, "<span class='alert'>There's already a tank installed!</span>")
				return
			if (!istype(W, /obj/item/tank/mini_oxygen))
				boutput(user, "<span class='alert'>[W] doesn't fit!</span>")
				return
			boutput(user, "<span class='notice'>You install [W] into [src].</span>")
			user.u_equip(W)
			W.set_loc(src)
			src.tank = W
			return
		else
			..()

	attack_self(mob/user)
		var/list/actions = list()
		if (src.tank)
			actions += "Toggle"
			actions += "Remove Tank"
		if (!actions.len)
			user.show_text("[src] has no tank attached!", "red")
			return ..()

		var/action = input(user, "What do you want to do with [src]?") as null|anything in actions

		switch (action)
			if ("Toggle")
				src.on = !(src.on)
				boutput(user, "<span class='notice'>The jet boots are now [src.on ? "on" : "off"].</span>")
				return
			if ("Remove Tank")
				boutput(user, "<span class='notice'>You eject [src.tank] from [src].</span>")
				user.put_in_hand_or_drop(src.tank)
				src.tank = null
				return
		..()

	proc/allow_thrust(num, mob/user as mob) // blatantly c/p from jetpacks
		if (!src.on || !istype(src.tank))
			return 0
		if (!isnum(num) || num < 0.01 || TOTAL_MOLES(src.tank.air_contents) < num)
			return 0

		var/datum/gas_mixture/G = src.tank.air_contents.remove(num)

		if (G.oxygen >= 0.01)
			return 1
		if (G.toxins > 0.001)
			if (user)
				var/d = G.toxins / 2
				d = min(abs(user.health + 100), d, 25)
				user.TakeDamage("chest", 0, d)
			return (G.oxygen >= 0.0075 ? 0.5 : 0)
		else
			if (G.oxygen >= 0.0075)
				return 0.5
			else
				return 0

	get_desc(dist)
		if (dist <= 1)
			. += "<br>They're currently [src.on ? "on" : "off"].<br>[src.tank ? "The tank's current air pressure reads [MIXTURE_PRESSURE(src.tank.air_contents)]." : "<span class='alert'>They have no tank attached!</span>"]"

/obj/item/clothing/shoes/jetpack/abilities = list(/obj/ability_button/jetboot_toggle)

/obj/item/clothing/shoes/witchfinder
	name = "witchfinder general's boots"
	desc = "You can almost hear the authority in each step."
	icon_state = "witchfinder"
	kick_bonus = 1
	step_sound = "step_wood"
	step_priority = STEP_PRIORITY_LOW

/obj/item/clothing/shoes/jester
	name = "jester's shoes"
	desc = "The shoes of a not-so-funny-clown."
	icon_state = "jester"

/obj/item/clothing/shoes/scream
	name = "scream shoes"
	icon_state = "pink"
	step_sound = list('sound/voice/screams/male_scream.ogg', 'sound/voice/screams/mascream6.ogg', 'sound/voice/screams/mascream7.ogg')
	desc = "AAAAAAAAAAAAAAAAAAAAAAA"

/obj/item/clothing/shoes/fart
	name = "fart-flops"
	icon_state = "tourist"
	step_sound = list('sound/voice/farts/poo2.ogg', 'sound/voice/farts/fart4.ogg', 'sound/voice/farts/poo2_robot.ogg')
	desc = "Do I really need to tell you what these do?"

/obj/item/clothing/shoes/crafted
	name = "shoes"
	desc = "A custom pair of shoes"
	icon_state = "white"

	onMaterialChanged()
		..()
		if(istype(src.material))
			if(src.material.hasProperty("thermal"))
				protective_temperature = (100 - src.material.getProperty("thermal")) ** 1.65
				setProperty("coldprot", round((100 - src.material.getProperty("thermal")) * 0.1))
				setProperty("heatprot", round((100 - src.material.getProperty("thermal")) * 0.1))
			else
				protective_temperature = 0
				setProperty("coldprot", 0)
				setProperty("heatprot", 0)
			if(src.material.hasProperty("hard") && src.material.hasProperty("density"))
				kick_bonus = round((src.material.getProperty("hard") * src.material.getProperty("density")) / 1500)
			else
				kick_bonus = 0
		return

/obj/item/clothing/shoes/bootsblk
	name = "Black Boots"
	icon_state = "bootsblk"
	desc = "Fashionable, synthleather black boots."

/obj/item/clothing/shoes/bootswht
	name = "White Boots"
	icon_state = "bootswht"
	desc = "Fashionable, synthleather white boots."

/obj/item/clothing/shoes/bootsbrn
	name = "Brown Boots"
	icon_state = "bootsbrn"
	desc = "Fashionable, synthleather brown boots."

/obj/item/clothing/shoes/bootsblu
	name = "Blue Boots"
	icon_state = "bootsblu"
	desc = "Fashionable, synthleather blue boots."

/obj/item/clothing/shoes/flatsblk
	name = "Black Flats"
	icon_state = "flatsblk"
	desc = "Simple black flats. Goes with anything!"

/obj/item/clothing/shoes/flatswht
	name = "White Flats"
	icon_state = "flatswht"
	desc = "Simple white flats. Minimal."

/obj/item/clothing/shoes/flatsbrn
	name = "Brown Flats"
	icon_state = "flatsbrn"
	desc = "Simple brown flats. Would look great with tweed."

/obj/item/clothing/shoes/flatsblu
	name = "Blue Flats"
	icon_state = "flatsblu"
	desc = "Simple blue flats. Reminds you of the ocean."

/obj/item/clothing/shoes/flatspnk
	name = "Pink Flats"
	icon_state = "flatspnk"
	desc = "Simple pink flats. So bright they almost glow! Almost."

/obj/item/clothing/shoes/mjblack
	name = "Black Mary Janes"
	icon_state = "mjblack"
	desc = "Dainty and formal. This pair is black."
	step_sound = "footstep"

/obj/item/clothing/shoes/mjbrown
	name = "Brown Mary Janes"
	icon_state = "mjbrown"
	desc = "Dainty and formal. This pair is brown."
	step_sound = "footstep"

/obj/item/clothing/shoes/mjnavy
	name = "Navy Mary Janes"
	icon_state = "mjnavy"
	desc = "Dainty and formal. This pair is navy."
	step_sound = "footstep"

/obj/item/clothing/shoes/mjwhite
	name = "White Mary Janes"
	icon_state = "mjwhite"
	desc = "Dainty and formal. This pair is white."
	step_sound = "footstep"

/obj/item/clothing/shoes/slasher_shoes
	name = "Industrial Boots"
	icon_state = "boots"
	desc = "Bulky boots with thick soles, protecting your feet."
	step_sound = "step_plating"

	noslip
		magnetic = 1
		c_flags = NOSLIP
		cant_self_remove = 1
		cant_other_remove = 1
		step_sound = "step_lattice"

		setupProperties()
			..()
			setProperty("coldprot", 5)
			setProperty("heatprot", 5)
			setProperty("exploprot", 15)

/obj/item/clothing/shoes/witchboots
	name = "Witch Boots"
	icon_state = "witchboots"
	desc = "The curved front of these boots is reminiscent of a crescent moon, how magical."
	step_sound = "footstep"

//Western Boots

/obj/item/clothing/shoes/westboot
	name = "Real Cowboy Boots"
	icon_state = "westboot"
	desc = "Perfect for riding horses, if only you had one!"
	compatible_species = list("human", "cow")

/obj/item/clothing/shoes/westboot/black
	name = "Black Cowboy Boots"
	icon_state = "westboot_black"

/obj/item/clothing/shoes/westboot/dirty
	name = "Dirty Cowboy Boots"
	icon_state = "westboot_dirty"

/obj/item/clothing/shoes/westboot/brown
	name = "Brown Cowboy Boots"
	icon_state = "westboot_brown"

/obj/item/clothing/shoes/westboot/brown/rancher
	name = "Rancher Boots"
	var/vault_speed_bonus = 1

	setupProperties()
		..()
		setProperty("vault_speed", vault_speed_bonus)
