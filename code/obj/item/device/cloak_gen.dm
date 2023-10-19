//Contents
//Cloak field generator
//Remote for said generator

// TODO cloak gen remote needs a TGUI menu real fucking bad. so many verbs

TYPEINFO(/obj/item/cloak_gen)
	mats = 12

/obj/item/cloak_gen
	name = "cloaking field generator"
	desc = "It's humming softly."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "cloakgen_off"
	var/range = 3
	var/maxrange = 5
	var/active = FALSE
	var/image/noise_image
	var/list/fields = new/list()
	is_syndicate = TRUE
	contraband = 2
	HELP_MESSAGE_OVERRIDE({"Place the cloaking field generator on the floor, then use the associated remote to turn it on or off. While on, the cloaking field generator is immovable."})

	New()
		..()
		var/obj/item/remote/cloak_gen/remote = new /obj/item/remote/cloak_gen(src.loc)
		remote.my_gen = src

		src.update_noise_image("noise2")

	disposing()
		if (src.active)
			src.turn_off()
		..()
		return

	attack_self(mob/user)
		boutput(user, "<span class='alert'>I need to place it on the ground to use it.</span>")

	// Shouldn't be required, but there have been surplus crate-related bugs in the past (Convair880).
	attackby(obj/item/W, mob/user)
		if (!W || !istype(W, /obj/item/remote/cloak_gen/))
			..()
			return
		if (istype(W, /obj/item/remote/cloak_gen/))
			var/obj/item/remote/cloak_gen/R = W
			if (!R.my_gen)
				user.show_text("Connection to [src.name] established", "blue")
				R.my_gen = src
			else
				var/choice = tgui_alert(user, "Remote is already linked to a generator. Reset and establish new connection?", "Connection override", list("Yes", "No"))
				if (choice == "Yes")
					R.my_gen = src
					user.show_text("Connection to [src.name] established", "blue")
		return

	pickup(var/mob/living/M)
		. = ..()
		if(active)
			turn_off(M)

	proc/setup_tile_cloak(obj/overlay/O)
		// First, get the appearance of the turf and use it as the base for the overlay
		// we can't use vis_contents for the turf, as putting turfs in vis_contents also displays every atom on the turf
		var/turf/T = get_turf(O)
		O.appearance = T.appearance
		O.dir = T.dir

		// List of types we want to copy to the overlay, other than the turf
		var/static/mimicked_types = list(/obj/window, /obj/machinery/door, /obj/grille)
		for (var/atom/movable/AM as anything in T)
			for (var/checktype in mimicked_types)
				if (ispath(AM.type, checktype))
					// These flags are never unset currently. Messy but likely irrelevant. sorry!
					AM.vis_flags |= VIS_INHERIT_ID | VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
					O.vis_contents += AM

		O.add_filter("cloak noise", 1, alpha_mask_filter(render_source="*noise_[ref(src)]"))

	proc/turn_on(mob/user)
		if (active) return

		if (!isturf(loc))
			if (user && ismob(user))
				boutput(user, "<span class='alert'>The field generator must be on the floor to be activated.</span>")
			return

		active = TRUE
		anchored = ANCHORED

		if (user && ismob(user))
			boutput(user, "<span class='notice'>You activate the cloak field generator.</span>")

		for(var/turf/T in range(range, src))
			var/obj/overlay/O = new /obj/overlay(T)
			src.setup_tile_cloak(O)
			O.mouse_opacity = FALSE
			O.layer = EFFECTS_LAYER_4
			O.plane = PLANE_NOSHADOW_ABOVE
			fields += O

	proc/turn_off(mob/user)
		if (!src.active)
			return

		src.active = FALSE
		src.anchored = UNANCHORED
		boutput(user, "<span class='notice'>You deactivate the cloak field generator.</span>")
		for(var/obj/overlay/O in fields)
			qdel(O)

	proc/update_noise_image(var/set_icon_state)
		src.overlays -= noise_image
		qdel(src.noise_image)
		src.noise_image = image(icon='icons/misc/old_or_unused.dmi', icon_state=set_icon_state)
		noise_image.render_target = "*noise_[ref(src)]"
		// hacky- we need the image on the map somewhere so it'll actually render as a render_source
		// it won't actually render as an overlay since we prefix render_target with `*`
		src.overlays += noise_image

/obj/item/remote/cloak_gen
	name = "cloaking field generator remote"
	desc = "A remote control for a cloaking field generator."
	icon = 'icons/obj/porters.dmi'
	icon_state = "remote"
	item_state = "electronic"
	is_syndicate = 1
	w_class = W_CLASS_SMALL
	var/obj/item/cloak_gen/my_gen = null
	var/anti_spam = 0 // Creating and deleting overlays en masse can cause noticeable lag (Convair880).
	contraband = 2
	HELP_MESSAGE_OVERRIDE({"Use the remote in hand to turn the generator on or off.
							Right click the remote to access a list of parameters that will affect the generator.
							Hit the remote on a generator to link it to that generator."})

	attack_self(mob/user)
		. = ..()
		if (isliving(user))
			if (my_gen)
				if (my_gen.active)
					src.anti_spam = world.time
					my_gen.turn_off(user)
				else
					if (src.anti_spam && world.time < src.anti_spam + 100)
						user.show_text("The cloaking field generator is recharging!", "red")
						return
					src.anti_spam = world.time
					my_gen.turn_on(user)
			else
				boutput(user, "<span class='alert'>No signal detected. Swipe remote on a cloaking generator to establish a connection.</span>")

	verb/set_pattern()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		var/input = input(usr,"Select cloaking pattern:","Set pattern","Noise") in list("Noise","Linear","Chaos","Cubic","Interference","Rotating")
		var/icon_to_use
		switch(input)
			if("Linear")
				icon_to_use = "noise1"
			if("Noise")
				icon_to_use = "noise2"
			if("Chaos")
				icon_to_use = "noise3"
			if("Cubic")
				icon_to_use = "noise4"
			if("Interference")
				icon_to_use = "noise5"
			if("Rotating")
				icon_to_use = "noise6"
		my_gen.update_noise_image(icon_to_use)
		boutput(usr, "<span class='notice'>You set the pattern to '[input]'.</span>")

	verb/set_range()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		var/input = input(usr,"Range 0-[my_gen.maxrange]:","Set range",my_gen.range) as num
		if(input > my_gen.maxrange || input < 0 || !isnum_safe(input))
			boutput(usr, "<span class='alert'>Invalid setting.</span>")
			return
		my_gen.range = input
		if(my_gen.active)
			my_gen.turn_off(usr)
			my_gen.turn_on(usr)
		boutput(usr, "<span class='notice'>You set the range to [my_gen.range].</span>")

	verb/increase_range()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		if (my_gen.range + 1 > my_gen.maxrange)
			boutput(usr, "<span class='alert'>Maximum range reached ([my_gen.maxrange]).</span>")
			return
		my_gen.range++
		if(my_gen.active)
			my_gen.turn_off(usr)
			my_gen.turn_on(usr)
		boutput(usr, "<span class='notice'>You set the range to [my_gen.range].</span>")

	verb/decrease_range()
		set src in view(1)
		if (!isliving(usr) || !my_gen) return
		if (my_gen.range - 1 < 0)
			boutput(usr, "<span class='alert'>Minimum range reached (0).</span>")
			return
		my_gen.range--
		if(my_gen.active)
			my_gen.turn_off(usr)
			my_gen.turn_on(usr)
		boutput(usr, "<span class='notice'>You set the range to [my_gen.range].</span>")

	verb/turn_on()
		set src in view(1)
		if (!isliving(usr) || !my_gen || my_gen.active) return
		my_gen.turn_on(usr)
		boutput(usr, "<span class='notice'>You turn the cloaking field generator on.</span>")

	verb/turn_off()
		set src in view(1)
		if (!isliving(usr) || !my_gen || !my_gen.active) return
		my_gen.turn_off(usr)
		boutput(usr, "<span class='notice'>You turn the cloaking field generator off.</span>")
