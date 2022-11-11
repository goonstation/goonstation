/area/wizard_place
	name = "Mage Tower"
	icon_state = "yellow"

/turf/unsimulated/wall/adaptive
	var/base_name = null

	fullbright = 1 // temporary measure
	desc = "A magically infused wall. It appears to glow without emitting light."

	New()
		..()
		src.adapt()
		var/turf/N = locate(x, y+1, z)
		var/turf/S = locate(x, y-1, z)
		var/turf/W = locate(x-1, y, z)
		var/turf/E = locate(x+1, y, z)
		if (istype(N, /turf/unsimulated/wall/adaptive))
			N:adapt()
		if (istype(S, /turf/unsimulated/wall/adaptive))
			S:adapt()
		if (istype(E, /turf/unsimulated/wall/adaptive))
			E:adapt()
		if (istype(W, /turf/unsimulated/wall/adaptive))
			W:adapt()

	Del()
		var/turf/N = locate(x, y+1, z)
		var/turf/S = locate(x, y-1, z)
		var/turf/W = locate(x-1, y, z)
		var/turf/E = locate(x+1, y, z)
		if (istype(N, /turf/unsimulated/wall/adaptive))
			N:adapt()
		if (istype(S, /turf/unsimulated/wall/adaptive))
			S:adapt()
		if (istype(E, /turf/unsimulated/wall/adaptive))
			E:adapt()
		if (istype(W, /turf/unsimulated/wall/adaptive))
			W:adapt()
		..()

	proc/adapt()
		var/D = 0
		var/turf/N = locate(x, y+1, z)
		var/turf/S = locate(x, y-1, z)
		var/turf/W = locate(x-1, y, z)
		var/turf/E = locate(x+1, y, z)
		if (istype(N, /turf/unsimulated/wall/adaptive))
			D += 1
		else
			for (var/obj/O in N)
				if (O.adaptable)
					D += 1
					break
		if (istype(S, /turf/unsimulated/wall/adaptive))
			D += 2
		else
			for (var/obj/O in S)
				if (O.adaptable)
					D += 2
					break
		if (istype(E, /turf/unsimulated/wall/adaptive))
			D += 4
		else
			for (var/obj/O in E)
				if (O.adaptable)
					D += 4
					break
		if (istype(W, /turf/unsimulated/wall/adaptive))
			D += 8
		else
			for (var/obj/O in W)
				if (O.adaptable)
					D += 8
					break
		icon_state = "[base_name][D]"

	ex_act()
		return
	meteorhit()
		return
	blob_act(var/power)
		return
	bullet_act()
		return

/turf/unsimulated/wall/adaptive/wizard_window
	icon = 'icons/turf/adventure.dmi'
	icon_state = "wizard_window"
	density = 1
	opacity = 0
	name = "window"
	var/obj/opener

	desc = "A magically infused wall. It appears to be a normal wall that allows some light to pass through."

	adapt()
		return

/turf/unsimulated/wall/adaptive/wizard
	icon = 'icons/turf/adventure.dmi'
	icon_state = "wizard_wall_0"
	base_name = "wizard_wall_"

/obj/adventurepuzzle/triggerable/false_wall_opener
	icon = 'icons/obj/randompuzzles.dmi'
	icon_state = "false_wall"
	name = "false wall triggerable endpoint"
	var/turf/unsimulated/wall/adaptive/wizard_fake/attached
	invisibility = INVIS_ADVENTURE
	anchored = 1
	density = 0
	opacity = 0

	var/static/list/triggeracts = list("Do nothing" = "nop", "Open" = "open")

	New(var/L)
		attached = L
		..()

	trigger_actions()
		return triggeracts

	trigger(var/act)
		if (act == "open")
			attached.open()

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		..()
		F["[path].attached"] << "ser:\ref[attached]"

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		. = ..()
		F["[path].attached"] >> attached
		. |= DESERIALIZE_NEED_POSTPROCESS

	deserialize_postprocess()
		attached = locate(attached)

/datum/wizard_zone_controller
	var/list/triggerables = list()
	var/area/wizard_place/wizard_area

	New()
		..()
		ensure_wizard_area()

	proc/ensure_wizard_area()
		if (!wizard_area)
			wizard_area = locate() in world

	proc/zone_announce(var/message)
		ensure_wizard_area()
		for (var/mob/M in wizard_area)
			M.show_message(message, 2)


var/global/datum/wizard_zone_controller/wizard_zone_controller

/turf/unsimulated/wall/adaptive/wizard_fake
	icon = 'icons/turf/adventure.dmi'
	icon_state = "wizard_false_wall"
	density = 1
	var/opening = 0
	var/obj/opener
	var/id = null

	desc = "A magically infused wall. It seems to be unstable and phase in and out of existence."

	New()
		..()
		opener = new /obj/adventurepuzzle/triggerable/false_wall_opener(src)
		if (id)
			wizard_zone_controller.triggerables += src

	Del()
		qdel(opener)
		..()

	adapt()
		return

	proc/toggle()
		if (src.density || src.opening == -1)
			src.open()
		else if (!src.density || src.opening == 1)
			src.close()

	proc/close()
		if (density)
			return
		if (opening == -1)
			return
		src.opening = -1
		src.RL_SetOpacity(1)
		src.set_density(1)
		flick("wizard_false_wall_closing", src)
		SPAWN(1 SECOND)
			src.icon_state = "wizard_false_wall"
			src.opening = 0

	proc/open()
		if (!density)
			return
		if (opening == 1)
			return
		src.opening = 1
		flick("wizard_false_wall_opening", src)
		src.icon_state = "wizard_floor"
		SPAWN(1.2 SECONDS)
			src.set_density(0)
			src.opening = 0
			src.RL_SetOpacity(0)

	opened
		New()
			..()
			open()

/turf/unsimulated/floor/wizard
	icon = 'icons/turf/adventure.dmi'
	icon_state = "wizard_floor"

	New()
		..()
		var/turf/N = locate(x, y+1, z)
		var/turf/S = locate(x, y-1, z)
		var/turf/W = locate(x-1, y, z)
		var/turf/E = locate(x+1, y, z)
		if (istype(N, /turf/unsimulated/wall/adaptive))
			N:adapt()
		if (istype(S, /turf/unsimulated/wall/adaptive))
			S:adapt()
		if (istype(E, /turf/unsimulated/wall/adaptive))
			E:adapt()
		if (istype(W, /turf/unsimulated/wall/adaptive))
			W:adapt()

	Del()
		var/turf/N = locate(x, y+1, z)
		var/turf/S = locate(x, y-1, z)
		var/turf/W = locate(x-1, y, z)
		var/turf/E = locate(x+1, y, z)
		if (istype(N, /turf/unsimulated/wall/adaptive))
			N:adapt()
		if (istype(S, /turf/unsimulated/wall/adaptive))
			S:adapt()
		if (istype(E, /turf/unsimulated/wall/adaptive))
			E:adapt()
		if (istype(W, /turf/unsimulated/wall/adaptive))
			W:adapt()
		..()

	showcase
		icon_state = "showcase"

	stairs
		icon_state = "wizard_stairs"

	plating
		icon_state = "wizard_plating"

	carpet
		icon_state = "carpet_plain"

		edge
			icon_state = "carpet_edge"

		narrow
			icon_state = "carpet_narrow"

			crossing
				icon_state = "carpet_narrow_crossing"

		inner_corner_onetwo
			icon_state = "carpet_inner_corner_1_2"

		inner_corner_threefour
			icon_state = "carpet_inner_corner_3_4"

		cross
			icon_state = "carpet_cross"

/obj/border_dummy
	name = "border dummy"
	flags = ON_BORDER
	density = 1
	opacity = 0
	anchored = 1
	invisibility = INVIS_ALWAYS_ISH
	icon = null
	icon_state = null

/obj/cover
	name = "cover"
	desc = "A cover. Usually covers showcased objects. Hopefully."
	layer = EFFECTS_LAYER_BASE
	anchored = 1
	density = 1
	opacity = 0
	var/list/dummies = list()

	showcase
		name = "showcase cover"
		icon = 'icons/turf/adventure.dmi'
		icon_state = "showcase_top"

	New()
		..()
		dummies += new /obj/border_dummy { dir = 1; }(src.loc)
		dummies += new /obj/border_dummy { dir = 2; }(src.loc)
		dummies += new /obj/border_dummy { dir = 4; }(src.loc)
		dummies += new /obj/border_dummy { dir = 8; }(src.loc)
		for (var/obj/item/O in get_turf(src))
			O.pixel_y = 2
			O.pixel_x = 0

	disposing()
		for (var/obj/O in dummies)
			qdel(O)
		..()

/obj/item/orb
	name = "depleted orb"
	desc = "An empty husk of a strong magical force."
	icon = 'icons/turf/adventure.dmi'
	var/icon_pedestal = null
	var/pedestal_name = null

	proc/fire(var/target)
		return

/obj/item/orb/fire
	name = "orb of fire"
	desc = "A raging fire appears to be held inside this shell."
	icon_state = "orb_fire"
	pedestal_name = "fire"

	New()
		..()
		icon_pedestal = image('icons/turf/adventure.dmi', "pedestal_orb_fire")

/obj/item/orb/void
	name = "orb of void"
	desc = "An unmeasurable darkness is haunting this orb."
	icon_state = "orb_void"
	pedestal_name = "void"

	New()
		..()
		icon_pedestal = image('icons/turf/adventure.dmi', "pedestal_orb_void")

/obj/item/orb/acid
	name = "orb of corrosion"
	desc = "This orb is full of a dark green liquid."
	icon_state = "orb_acid"
	pedestal_name = "acid"

	New()
		..()
		icon_pedestal = image('icons/turf/adventure.dmi', "pedestal_orb_acid")

/obj/item/orb/magic
	name = "orb of magic"
	desc = "The pure arcane force contained by this orb seems to be barely held in place."
	icon_state = "orb_magic"
	pedestal_name = "magic"

	New()
		..()
		icon_pedestal = image('icons/turf/adventure.dmi', "pedestal_orb_magic")

/obj/item/orb/ice
	name = "orb of frost"
	desc = "As you move this orb around, the humidity in the air snap freezes and falls to the ground."
	icon_state = "orb_ice"
	pedestal_name = "ice"

	New()
		..()
		icon_pedestal = image('icons/turf/adventure.dmi', "pedestal_orb_ice")

/obj/item/orb/lightning
	name = "orb of lightning"
	desc = "A ruthless lightning storm is tearing up the inside of this orb."
	icon_state = "orb_lightning"
	pedestal_name = "lightning"

	New()
		..()
		icon_pedestal = image('icons/turf/adventure.dmi', "pedestal_orb_lightning")

/obj/pedestal
	name = "empty pedestal"
	desc = "A magical stand. Looks like it's missing a part."
	icon = 'icons/turf/adventure.dmi'
	icon_state = "pedestal_empty"
	anchored = 1
	density = 1
	opacity = 0
	var/obj/item/orb/O = null

	fire
		New()
			..()
			O = new /obj/item/orb/fire(src)
			overlays += O.icon_pedestal
			name = "[O.pedestal_name] pedestal"

	ice
		New()
			..()
			O = new /obj/item/orb/ice(src)
			overlays += O.icon_pedestal
			name = "[O.pedestal_name] pedestal"

	acid
		New()
			..()
			O = new /obj/item/orb/acid(src)
			overlays += O.icon_pedestal
			name = "[O.pedestal_name] pedestal"

	lightning
		New()
			..()
			O = new /obj/item/orb/lightning(src)
			overlays += O.icon_pedestal
			name = "[O.pedestal_name] pedestal"

	magic
		New()
			..()
			O = new /obj/item/orb/magic(src)
			overlays += O.icon_pedestal
			name = "[O.pedestal_name] pedestal"

	void
		New()
			..()
			O = new /obj/item/orb/void(src)
			overlays += O.icon_pedestal
			name = "[O.pedestal_name] pedestal"

	proc/fireMob()
		if (!O)
			return
		var/list/possible = list()
		for (var/mob/M in oview(7))
			possible += M
		O.fire(pick(possible))

	proc/fireTurf()
		if (!O)
			return
		var/list/possible = list()
		for (var/turf/T in oview(7))
			possible += T
		O.fire(pick(possible))

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/orb))
			if (!O)
				O = W
				O.set_loc(src)
				user.u_equip(O)
				if (user.client)
					user.client.screen -= O
				overlays += O.icon_pedestal
				name = "[O.pedestal_name] pedestal"
			else
				boutput(user, "<span class='alert'>This pedestal already holds an orb!</span>")

	proc/destroyOrb()
		if (O)
			overlays -= O.icon_pedestal
			name = "empty pedestal"
			qdel(O)
			O = null

/obj/item/potion
	name = "potion"
	desc = "An empty flask of potion."
	icon = 'icons/turf/adventure.dmi'
	icon_state = "potion_empty"
	var/reagent = null
	var/units = null
	var/potion_name = null
	var/static/list/red_potions = list("elixir of preservation" = "formaldehyde", "elixir of flesh" = "synthflesh")
	var/static/list/blue_potions = list("essence of ice" = "cryostylane", "draught of fresh water" = "water")
	var/static/list/magenta_potions = list("essence of motion" = "anima", "potion of rejuvenation" = "omnizine")
	var/static/list/green_potions = list("distillation of venom" = "sarin", "elixir of neutralize poison" = "charcoal")
	var/static/list/yellow_potions = list("distillation of madness" = "madness_toxin", "elixir of speed" = "methamphetamine")
	var/static/list/black_potions = list("essence of death" = "initropidril", "elixir invulnerability" = "juggernaut")
	var/static/list/white_potions = list("essence of creation" = "big_bang", "elixir of life" = "strange_reagent")
	var/static/list/orange_potions = list("essence of fire" = "foof", "potion of restoration" = "penteticacid")

	New(var/L, var/no_randomize = 0)
		..()
		if (!no_randomize)
			generate(null, 0)

	proc/generate(var/C, var/identified = 0)
		if (!C)
			C = pick("red", "green", "blue", "magenta", "yellow", "white", "black", "orange")
		icon_state = "potion_[C]"
		units = 20
		switch (C)
			if ("red")
				potion_name = pick(red_potions)
				reagent = red_potions[potion_name]
			if ("blue")
				potion_name = pick(blue_potions)
				reagent = blue_potions[potion_name]
			if ("green")
				potion_name = pick(green_potions)
				reagent = green_potions[potion_name]
			if ("magenta")
				potion_name = pick(magenta_potions)
				reagent = magenta_potions[potion_name]
			if ("yellow")
				potion_name = pick(yellow_potions)
				reagent = yellow_potions[potion_name]
			if ("black")
				potion_name = pick(black_potions)
				reagent = black_potions[potion_name]
			if ("white")
				potion_name = pick(white_potions)
				reagent = white_potions[potion_name]
			if ("orange")
				potion_name = pick(orange_potions)
				reagent = orange_potions[potion_name]

		if (!identified)
			name = "[C] potion"
			desc = "A flask of [C] liquid. You wonder what this could be."
		else
			name = potion_name
			desc = "A flask of [C] liquid."

	proc/identify()
		if (reagent && potion_name != name)
			name = potion_name
			desc = "A flask of liquid."

	proc/drink(var/mob/user)
		user.reagents.add_reagent(reagent, units)
		reagent = null
		potion_name = null
		units = null
		icon_state = "potion_empty"
		name = "empty potion"
		desc = initial(src.desc)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (!reagent)
			boutput(user, "<span class='alert'>The potion flask is empty.</span>")
		if (user == target)
			user.visible_message("<span class='notice'>[user] uncorks the potion and pours it down [his_or_her(user)] throat.</span>")
			logTheThing(LOG_COMBAT, user, "drinks [src] ([potion_name] -- [reagent])")
			drink(user)
		else if (ishuman(target))
			user.visible_message("<span class='alert'>[user] attempts to force [target] to drink [src].</span>")
			logTheThing(LOG_COMBAT, user, "tries to force [constructTarget(target,"combat")] to drink [src] ([potion_name] -- [reagent]).")
			if (do_after(user, 3 SECONDS))
				if (reagent)
					user.visible_message("<span class='alert'>[user] forces [target] to drink [src].</span>")
					logTheThing(LOG_COMBAT, user, "forces [constructTarget(target,"combat")] to drink [src] ([potion_name] -- [reagent]).")
					drink(target)

	identified
		New(var/L)
			..(L, 1)
			generate(null, 1)

	attack()
		return

ABSTRACT_TYPE(/obj/item/wizard_crystal)
/obj/item/wizard_crystal
	name = "enchanted quartz"
	desc = "A magically infused piece of crystal. It seems to emit a minimal amount of light. Some magical object could perhaps amplify this."
	var/light_r = 1
	var/light_g = 1
	var/light_b = 1
	var/lum = 5
	var/image/over_image
	var/assoc_material = "wiz_quartz"
	icon = 'icons/turf/adventure.dmi'

	proc/create_bar(var/obj/machinery/portable_reclaimer/creator)
		var/datum/material/MAT = new assoc_material()
		var/bar_type = getProcessedMaterialForm(MAT)
		var/obj/item/material_piece/BAR = new bar_type(creator.get_output_location())

		BAR.quality = rand(50, 100)
		BAR.name += getQualityName(BAR.quality)
		BAR.setMaterial(MAT)
		playsound(src.loc, creator.sound_process, 40, 1)

		return BAR

	New()
		..()
		//icon_state = name
		over_image = image(icon, name)

	quartz
		name = "enchanted quartz"
		assoc_material = "wiz_quartz"
		icon_state = "quartz"

	topaz
		name = "enchanted topaz"
		light_r = 1
		light_g = 0.8
		light_b = 0.5
		assoc_material = "wiz_topaz"
		icon_state = "topaz"

	ruby
		name = "enchanted ruby"
		light_r = 0.6
		light_g = 0.1
		light_b = 0.2
		assoc_material = "wiz_ruby"
		icon_state = "ruby"

	amethyst
		name = "enchanted amethyst"
		light_r = 0.6
		light_g = 0.4
		assoc_material = "wiz_amethyst"
		icon_state = "amethyst"

	emerald
		name = "enchanted emerald"
		light_r = 0.3
		light_g = 0.8
		light_b = 0.4
		assoc_material = "wiz_emerald"
		icon_state = "emerald"

	sapphire
		name = "enchanted sapphire"
		light_r = 0.1
		light_g = 0.4
		light_b = 0.7
		assoc_material = "wiz_sapphire"
		icon_state = "sapphire"

/obj/wizard_light
	name = "empty crystal socket"
	desc = "A holder for light crystals."
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/turf/adventure.dmi'
	icon_state = "crystal_holder"
	var/obj/item/wizard_crystal/crystal
	var/initial_crystal = null
	var/wall_mount = 1
	var/secured = 1
	var/datum/light/light
	// uncomment on cogmap 2 release
	//mats = 5

	stand
		wall_mount = 0
		density = 1
		icon_state = "crystal_stand"

		quartz
			initial_crystal = /obj/item/wizard_crystal/quartz

		topaz
			initial_crystal = /obj/item/wizard_crystal/topaz

		amethyst
			initial_crystal = /obj/item/wizard_crystal/amethyst

		ruby
			initial_crystal = /obj/item/wizard_crystal/ruby

		sapphire
			initial_crystal = /obj/item/wizard_crystal/sapphire

		emerald
			initial_crystal = /obj/item/wizard_crystal/emerald

	New(var/L, var/D)
		..()
		light = new /datum/light/point
		light.attach(src)
		if (D)
			update_dir(D)
		if (initial_crystal)
			crystal = new initial_crystal()
			apply_crystal()

	onVarChanged(var/varname, var/oldvalue, var/newvalue)
		if (varname == "dir")
			update_dir(newvalue)
			apply_crystal()

	proc/update_dir(var/D)
		src.set_dir(D)
		if (wall_mount)
			pixel_x = 0
			pixel_y = 0
			if (!(dir in cardinal))
				src.set_dir(2)
			switch (dir)
				if (1)
					pixel_y = -32
				if (2)
					pixel_y = 32
				if (4)
					pixel_x = -32
				if (8)
					pixel_x = 32

	attackby(var/obj/item/W, var/mob/user)
		if (istype(W, /obj/item/wizard_crystal))
			if (!src.crystal)
				boutput(user, "<span class='notice'>You place the crystal into the socket.</span>")
				crystal = W
				user.u_equip(W)
				W.set_loc(src)
				user.client.screen -= W
				apply_crystal()
			else
				boutput(user, "<span class='alert'>There already is a crystal inserted into this.</span>")

	proc/apply_crystal()
		if (!crystal)
			return
		name = "crystal light"

		if (wall_mount)
			if (dir == 4)
				crystal.over_image.pixel_x = 10
				crystal.over_image.pixel_y = 9
			else if (dir == 8)
				crystal.over_image.pixel_x = -10
				crystal.over_image.pixel_y = 9
			else
				crystal.over_image.pixel_x = 0
				crystal.over_image.pixel_y = 0
		else
			crystal.over_image.pixel_x = 0
			crystal.over_image.pixel_y = 0
		if (!(crystal.over_image in overlays))
			overlays += crystal.over_image
		light.set_color(crystal.light_r, crystal.light_g, crystal.light_b)
		light.set_brightness(crystal.lum / 7)
		light.enable()

	attack_hand(var/mob/user)
		if (src.crystal)
			user.put_in_hand_or_drop(src.crystal)
			overlays.len = 0
			src.crystal = null
			light.disable()
			name = "empty crystal socket"

	quartz
		initial_crystal = /obj/item/wizard_crystal/quartz

	topaz
		initial_crystal = /obj/item/wizard_crystal/topaz

	amethyst
		initial_crystal = /obj/item/wizard_crystal/amethyst

	ruby
		initial_crystal = /obj/item/wizard_crystal/ruby

	sapphire
		initial_crystal = /obj/item/wizard_crystal/sapphire

	emerald
		initial_crystal = /obj/item/wizard_crystal/emerald

/obj/overlay/tile_effect/secondary
	blend_mode = BLEND_MULTIPLY

	bookcase
		icon = 'icons/turf/adventure.dmi'
		icon_state = "bookcase_overlay"
		pixel_y = 28

		directional
			icon_state = "bookcase_overlay_directional"

/obj/tome
	name = "tome"
	desc = "A book laid out neatly on a pedestal."
	var/written = null

	examine(mob/user)
		. = ..()
		if (!written)
			. += "<span class='alert'>You cannot decipher the runes written in the book.</span>"
		else
			user.Browse(written, "window=tome;size=200x400")

/obj/bookcase
	name = "bookcase"
	desc = "A wooden furniture used for the storage of books."
	density = 0
	opacity = 0
	anchored = 1
	var/id = null
	icon = 'icons/turf/adventure.dmi'
	icon_state = "bookcase_empty_alone"
	var/obj/overlay/tile_effect/secondary/effect_overlay

	disposing()
		if (effect_overlay)
			qdel(effect_overlay)
			effect_overlay = null
		..()

	disposing()
		if (effect_overlay)
			qdel(effect_overlay)
		..()

	New(var/L)
		..()
		set_effect()
		update_dir(dir)

	onVarChanged(var/varname, var/oldvalue, var/newvalue)
		if (varname == "dir")
			update_dir(newvalue)

	proc/set_effect()
		effect_overlay = new/obj/overlay/tile_effect/secondary/bookcase(loc)

	proc/update_dir(var/D)
		src.set_dir(D)
		if (!(dir & 2))
			src.set_dir(2)
		pixel_y = 28
		effect_overlay.set_dir(dir)

	button
		var/pressed = 0
		icon = 'icons/turf/adventure.dmi'
		icon_state = "bookcase_full_alone_button"

		attack_hand(var/mob/user)
			if (user.y != src.y || user.x < src.x - 1 || user.x > src.x + 1)
				return 0
			if (!pressed)
				pressed = 1
				icon_state = "bookcase_full_alone_0"
				for (var/turf/unsimulated/wall/adaptive/wizard_fake/T in wizard_zone_controller.triggerables)
					if (T.id == src.id)
						T.toggle()

	full
		icon_state = "bookcase_full_alone"

		New()
			..()
			icon_state = "bookcase_full_alone_[rand(0,1)]"

	directional
		icon_state = "bookcase_empty_wall"

		set_effect()
			effect_overlay = new/obj/overlay/tile_effect/secondary/bookcase/directional(loc)

		full
			icon_state = "bookcase_full_wall"

/datum/scripted
