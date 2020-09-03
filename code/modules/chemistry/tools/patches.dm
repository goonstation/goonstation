


/mob/living/proc/handle_skin(var/mult = 1)
	if (src.skin_process && src.skin_process.len)
		for(var/obj/item/reagent_containers/patch/P in skin_process)
			//P.process_skin(src, XXX * mult)
			continue


/* ================================================= */
/* -------------------- Patches -------------------- */
/* ================================================= */

/obj/item/reagent_containers/patch
	name = "patch"
	desc = "A small adhesive chemical pouch, for application to the skin."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "patch"
	var/image/fluid_image
	var/medical = 0
	var/borg = 0
	var/style = "patch"
	initial_volume = 30
	event_handler_flags = HANDLE_STICKER | USE_FLUID_ENTER
	rc_flags = RC_SPECTRO		// only spectroscopic analysis
	module_research = list("medicine" = 1, "science" = 1)
	module_research_type = /obj/item/reagent_containers/patch
	var/in_use = 0
	var/good_throw = 0

	var/active = 0
	var/overlay_key = 0
	var/atom/attached = 0
	var/sticker_icon_state = "patch"

	New()
		..()
		if (src.reagents)
			src.reagents.temperature_cap = 440 //you can remove/adjust these afterr you fix burns from reagnets being super strong
			src.reagents.temperature_min = 270	//you can remove/adjust these afterr you fix burns from reagnets being super strong

	on_reagent_change()
		src.update_icon()
		if (src.reagents)
			src.reagents.temperature_cap = 440
			src.reagents.temperature_min = 270
			if (src.reagents.total_temperature >= src.reagents.temperature_cap)
				if (ismob(src.loc))
					var/mob/M = src.loc
					M.drop_item(src)
				qdel(src)
			if (src.reagents && src.reagents.total_temperature < src.reagents.temperature_min)
				src.reagents.total_temperature = src.reagents.temperature_min


	proc/clamp_reagents()
		if (src.reagents.total_temperature > src.reagents.temperature_cap)
			src.reagents.total_temperature = src.reagents.temperature_cap
		if (src.reagents.total_temperature < src.reagents.temperature_min)
			src.reagents.total_temperature = src.reagents.temperature_min


	proc/update_icon()
		src.underlays = null
		if (src.reagents && src.reagents.total_volume)
			icon_state = "[src.style]1"
			if (medical == 1)
				icon_state = "[src.style]_med1"
			if (reagents.has_reagent("LSD",1))
				icon_state = "[src.style]_LSD"

			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/chemical.dmi', "[src.style]-fluid", -1)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.underlays += src.fluid_image

		else
			icon_state = "[src.style]"
			if (medical == 1)
				icon_state = "[src.style]_med"
		signal_event("icon_updated")

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (src.medical == 1)
			if (user)
				user.show_text("The patch is sealed already.", "red")
			return 0
		else
			if (user && E)
				user.show_text("You press on the patch with [E]. The current from [E] closes the tamper-proof seal.", "blue")
			src.medical = 1
			src.update_icon()
			return 1

	attackby(obj/item/W as obj, mob/user as mob)
		return

	attack_self(mob/user as mob)
		if (src.in_use)
			return

		if (src.borg == 1 && !issilicon(user))
			user.show_text("This item is not designed with organic users in mind.", "red")
			return

		if (iscarbon(user) || ismobcritter(user))
			src.in_use = 1
			user.visible_message("[user] applies [src] to [his_or_her(user)]self.",\
			"<span class='notice'>You apply [src] to yourself.</span>")
			logTheThing("combat", user, null, "applies a patch to themself [log_reagents(src)] at [log_loc(user)].")
			apply_to(user,0,user=user)
			attach_sticker_manual(user)
		return

	throw_impact(mob/M as mob)
		..()
		if (src.medical && !borg && !src.in_use && (iscarbon(M) || ismobcritter(M)))
			if (prob(30) || good_throw && prob(70))
				src.in_use = 1
				M.visible_message("<span class='alert'>[src] lands on [M] sticky side down!</span>")
				logTheThing("combat", M, usr, "is stuck by a patch [log_reagents(src)] thrown by [constructTarget(usr,"combat")] at [log_loc(M)].")
				apply_to(M,usr)
				attach_sticker_manual(M)

	attack(mob/M as mob, mob/user as mob)
		if (src.in_use)
			//DEBUG_MESSAGE("[src] in use")
			return

		if (src.borg == 1 && !issilicon(user))
			user.show_text("This item is not designed with organic users in mind.", "red")
			return

		// No src.reagents check here because empty patches can be used to counteract bleeding.

		if (iscarbon(M) || ismobcritter(M))
			src.in_use = 1
			if (M == user)
				//M.show_text("You put [src] on your arm.", "blue")
				M.visible_message("[user] applies [src] to [his_or_her(user)]self.",\
				"<span class='notice'>You apply [src] to yourself.</span>")
			else
				if (medical == 0)
					user.visible_message("<span class='alert'><b>[user]</b> is trying to stick [src] to [M]'s arm!</span>",\
					"<span class='alert'>You try to stick [src] to [M]'s arm!</span>")
					logTheThing("combat", user, M, "tries to apply a patch [log_reagents(src)] to [constructTarget(M,"combat")] at [log_loc(user)].")

					if (!do_mob(user, M))
						if (user && ismob(user))
							user.show_text("You were interrupted!", "red")
						src.in_use = 0
						return
					// No src.reagents check here because empty patches can be used to counteract bleeding.

					user.visible_message("<span class='alert'><b>[user]</b> sticks [src] to [M]'s arm.</span>",\
					"<span class='alert'>You stick [src] to [M]'s arm.</span>")
					attach_sticker_manual(M)

				else if (borg == 1)
					user.visible_message("<span class='notice'><b>[user]</b> stamps [src] on [M].</span>",\
					"<span class='notice'>You stamp [src] on [M].</span>")
					if (user.mind && user.mind.objectives && M.health < 90) //might as well let people complete this even if they're borged
						for (var/datum/objective/crew/medicaldoctor/heal/H in user.mind.objectives)
							H.patchesused ++
						JOB_XP(user, "Medical Doctor", 1)
				else
					user.visible_message("<span class='notice'><b>[user]</b> applies [src] to [M].</span>",\
					"<span class='notice'>You apply [src] to [M].</span>")
					if (user.mind && user.mind.objectives && M.health < 90)
						for (var/datum/objective/crew/medicaldoctor/heal/H in user.mind.objectives)
							H.patchesused ++
						JOB_XP(user, "Medical Doctor", 1)

			logTheThing("combat", user, M, "applies a patch to [constructTarget(M,"combat")] [log_reagents(src)] at [log_loc(user)].")

			src.clamp_reagents()

			apply_to(M,user=user)
			return 1

		return 0

	proc/apply_to(mob/M as mob, mob/user as mob)
		repair_bleeding_damage(M, 25, 1)
		active = 1

		if (reagents && reagents.total_volume)
			if (!borg)
				user.drop_item(src)
				//user.u_equip(src)
				//qdel(src)
				src.set_loc(M)
				if (isliving(M))
					var/mob/living/L = M
					L.skin_process += src
			else
				reagents.reaction(M, TOUCH, paramslist = list("nopenetrate"))

				var/datum/reagents/R = new
				reagents.copy_to(R)
				R.trans_to(M, reagents.total_volume/2)
				src.in_use = 0

			playsound(get_turf(src), 'sound/items/sticker.ogg', 50, 1)

		else
			if (!borg)
				user.drop_item(src)
				qdel(src)
			else
				src.in_use = 0

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		.= 0
		if (!attached && ismob(A) && medical)
			//do image stuff
			var/pox = src.pixel_x
			var/poy = src.pixel_y
			if (params)
				if (islist(params) && params["icon-y"] && params["icon-x"])
					pox = text2num(params["icon-x"]) - 16
					poy = text2num(params["icon-y"]) - 16

			var/image/sticker = image('icons/misc/stickers.dmi', sticker_icon_state)

			sticker.layer = A.layer + 1
			sticker.icon_state = sticker_icon_state
			sticker.appearance_flags = RESET_COLOR

			sticker.pixel_x = pox
			sticker.pixel_y = poy
			overlay_key = "patch[world.timeofday]"
			attached = A
			A.UpdateOverlays(sticker, overlay_key)

			.= 1

	proc/attach_sticker_manual(var/atom/A as mob|obj|turf)
		.= 0
		if (!attached)
			//do image stuff
			var/pox = rand(-2,2)
			var/poy = rand(-2,2)

			var/image/sticker = image('icons/misc/stickers.dmi', sticker_icon_state)

			sticker.layer = A.layer + 1
			sticker.icon_state = sticker_icon_state
			sticker.appearance_flags = RESET_COLOR

			sticker.pixel_x = pox
			sticker.pixel_y = poy
			overlay_key = "patch[world.timeofday]"
			attached = A
			A.UpdateOverlays(sticker, overlay_key)
			.= 1


	disposing()
		if (attached)
			attached.ClearSpecificOverlays(overlay_key)

			if (isliving(attached))
				var/mob/living/L = attached
				L.skin_process -= src
		..()

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/patch/bruise
	name = "styptic powder patch"
	desc = "Heals brute damage wounding."
	medical = 1
	initial_reagents = "styptic_powder"

/obj/item/reagent_containers/patch/bruise/medbot
	name = "tissue reapplication stamp"
	borg = 1

/obj/item/reagent_containers/patch/burn
	name = "silver sulfadiazine patch"
	desc = "Heals burn damage wounding."
	medical = 1
	initial_reagents = "silver_sulfadiazine"

/obj/item/reagent_containers/patch/burn/medbot
	name = "post-incendary dermal repair stamp"
	borg = 1

/obj/item/reagent_containers/patch/synthflesh
	name = "synthflesh patch"
	desc = "Heals both brute and burn damage wounding."
	medical = 1
	initial_reagents = "synthflesh"

/obj/item/reagent_containers/patch/synthflesh/medbot
	name = "skin soothing ultra-damage repair stamp"
	borg = 1

/obj/item/reagent_containers/patch/nicotine
	name = "nicotine patch"
	desc = "Satisfies the needs of nicotine addicts."
	initial_reagents = list("nicotine"=10)

/obj/item/reagent_containers/patch/LSD
	name = "blotter"
	desc = "What is this?"
	icon_state = "patch_LSD"
	initial_reagents = list("LSD"=20)
	module_research = list("vice" = 10)

	cyborg
		borg = 1

/obj/item/reagent_containers/patch/vr
	icon = 'icons/effects/VR.dmi'
	icon_state = "patch_med"

	update_icon()
		return

/obj/item/reagent_containers/patch/vr/bruise
	name = "healing patch"
	desc = "Heals brute damage wounding."
	icon_state = "patch_med-brute"
	medical = 1
	initial_reagents = list("styptic_powder"=20)

/obj/item/reagent_containers/patch/vr/burn
	name = "burn patch"
	desc = "Heals burn damage wounding."
	icon_state = "patch_med-burn"
	medical = 1
	initial_reagents = list("silver_sulfadiazine"=20)

/* ====================================================== */
/* -------------------- Mini-Patches -------------------- */
/* ====================================================== */

/obj/item/reagent_containers/patch/mini // like normal patches but smaller and cuter!!!
	name = "mini-patch"
	icon_state = "minipatch"
	style = "minipatch"
	initial_volume = 15
	sticker_icon_state = "mini-patch"

/* =================================================== */
/* -------------------- Sub-Types -------------------- */
/* =================================================== */

/obj/item/reagent_containers/patch/mini/bruise
	name = "healing mini-patch"
	desc = "Heals brute damage wounding."
	medical = 1
	initial_reagents = "styptic_powder"

/obj/item/reagent_containers/patch/mini/burn
	name = "burn mini-patch"
	desc = "Heals burn damage wounding."
	medical = 1
	initial_reagents = "silver_sulfadiazine"

/obj/item/reagent_containers/patch/mini/synthflesh
	name = "skin soothing ultra-damage repair mini-patch"
	desc = "Heals both brute and burn damage wounding."
	medical = 1
	initial_reagents = "synthflesh"

/obj/item/patch_stack
	name = "Patch Stack"
	desc = "A stack, holding patches. The top patch can be used."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "patch_stack"
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	var/list/patches = list()

	proc/update_overlay()
		overlays.len = 0
		if (patches.len)
			var/obj/item/reagent_containers/patch/P = patches[patches.len]
			if (P)
				src.overlays += image(P.icon, P.icon_state)
				name = "[initial(src.name)] ([P.name]; [patches.len] patches)"
				signal_event("icon_updated")
		else
			name = initial(src.name)

	examine()
		. = ..()
		if (patches.len)
			var/obj/item/reagent_containers/patch/P = patches[patches.len]
			if (P)
				. += "The topmost patch is a [P.name]; [patches.len] patch(es) on the stack."
		else
			. += "0 patches on the stack."

	attackby(var/obj/item/W, var/mob/user)
		if (patches.len)
			var/obj/item/reagent_containers/patch/P = patches[patches.len]
			P.attackby(W, user)

	attack_self(var/mob/user)
		if (patches.len)
			var/obj/item/reagent_containers/patch/P = patches[patches.len]
			P.set_loc(user.loc)
			patches -= P
			update_overlay()
			boutput(user, "<span class='notice'>You remove [P] from the stack.</span>")
		else
			boutput(user, "<span class='alert'>There are no patches on the stack.</span>")

	attack() //Or you're gonna literally attack someone with it. *thwonk* style
		return

	afterattack(var/atom/movable/target, var/mob/user)
		if (istype(target, /obj/item/reagent_containers/patch))
			if (target.loc != src && (!isrobot(user) || target.loc != user))
				if (ismob(target.loc))
					var/mob/U = target.loc
					U.u_equip(target)
				else if (istype(target.loc, /obj/item/storage))
					var/obj/item/storage/U = target.loc
					U.contents -= target
					if (U.hud)
						U.hud.update()
				target.set_loc(src)
				patches += target
				update_overlay()
				boutput(user, "<span class='notice'>You add [target] to the stack.</span>")
		else if (isliving(target))
			if (patches.len)
				var/obj/item/reagent_containers/patch/P = patches[patches.len]
				patches -= P
				var/mob/living/H = target
				P.attack(H, user, user.zone_sel && user.zone_sel.selecting ? user.zone_sel.selecting : null)

				update_overlay()
				SPAWN_DBG(6 SECONDS)
					update_overlay()


//mender
/obj/item/reagent_containers/mender
	name = "auto-mender"
	desc = "A small electronic device designed to topically apply healing chemicals."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mender"
	var/image/fluid_image
	var/tampered = 0
	var/borg = 0
	initial_volume = 200
	flags = FPRINT | TABLEPASS | OPENCONTAINER | ONBELT | NOSPLASH
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO
	module_research = list("medicine" = 4, "science" = 4)
	module_research_type = /obj/item/reagent_containers/patch

	var/list/whitelist = list()
	var/use_volume = 8

	var/static/list/sfx = list('sound/items/mender.ogg','sound/items/mender2.ogg')


	New()
		..()
		if (!tampered && islist(chem_whitelist) && chem_whitelist.len)
			src.whitelist = chem_whitelist
		if (src.reagents)
			src.reagents.temperature_cap = 330
			src.reagents.temperature_min = 270

	on_reagent_change()
		src.update_icon()
		if (src.reagents)
			src.reagents.temperature_cap = 330
			src.reagents.temperature_min = 270

	is_open_container()
		if (borg)
			.= 0
		else
			. = ..()

	proc/can_operate_on(atom/A)
		.= (iscarbon(A) || ismobcritter(A))

	proc/update_icon()
		src.overlays = null
		if (reagents.total_volume)
			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/chemical.dmi', "mender-fluid", -1)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.overlays += src.fluid_image
		signal_event("icon_updated")

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (user && E)
			user.show_text("You press on [src] with [E]. The anti-tamper lock is broken.", "blue")
		src.tampered = 1
		src.update_icon()
		return 1

	on_reagent_change(add)
		if (!tampered && add)
			check_whitelist(src, src.whitelist)
		src.update_icon()

	attack_self(mob/user as mob)
		if (can_operate_on(user))
			src.attack(user,user) //do self operation
		return

	attack(mob/M as mob, mob/user as mob)
		if (src.borg == 1 && !issilicon(user))
			user.show_text("This item is not designed with organic users in mind.", "red")
			return

		if (can_operate_on(M) && !actions.hasAction(user,"automender_apply"))
			if (M == user)
				M.visible_message("[user] begins mending [his_or_her(user)]self with [src].",\
					"<span class='notice'>You begin mending yourself with [src].</span>")
			else
				user.visible_message("<span class='alert'><b>[user]</b> begins mending [M] with [src].</span>",\
					"<span class='alert'>You begin mending [M] with [src].</span>")
				if (M.health < 90)
					JOB_XP(user, "Medical Doctor", 2)

			logTheThing("combat", user, M, "begins automending [constructTarget(M,"combat")] [log_reagents(src)] at [log_loc(user)].")
			begin_application(M,user=user)
			return 1

		return 0

	proc/begin_application(mob/M as mob, mob/user as mob)
		actions.start(new/datum/action/bar/icon/automender_apply(user,src,M), user)


	proc/apply_to(mob/M as mob, mob/user as mob, var/mult = 1, var/silent = 0)
		//repair_bleeding_damage(M, 66, 1)
		var/use_volume_adjusted = use_volume * mult

		if (reagents && reagents.total_volume)
			var/list/params = list("nopenetrate")
			if (silent)
				params.Add("silent")

			reagents.reaction(M, TOUCH, react_volume = use_volume_adjusted, paramslist = params)
			if (!borg)
				reagents.trans_to(M, use_volume_adjusted/2) // Patches should primarily be for topically drugs (Convair880).
				reagents.remove_any(use_volume_adjusted/2)
			else
				var/datum/reagents/R = new
				reagents.copy_to(R)
				R.trans_to(M, use_volume_adjusted/2)
			logTheThing("combat", user, M, " automends [constructTarget(M,"combat")] [log_reagents(src)] at [log_loc(user)].")

			playsound(get_turf(src), pick(sfx), 50, 1)



/obj/item/reagent_containers/mender/brute
	initial_reagents = "styptic_powder"

	medbot
		name = "brute auto-mender"
		borg = 1

/obj/item/reagent_containers/mender/burn
	initial_reagents = "silver_sulfadiazine"

	medbot
		name = "burn auto-mender"
		borg = 1

/obj/item/reagent_containers/mender/both
	initial_reagents = "synthflesh"

/datum/action/bar/icon/automender_apply
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "automender_apply"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mender-active"
	var/mob/living/user
	var/obj/item/reagent_containers/mender/M
	var/mob/living/target
	var/looped = 0

	var/health_temp = 0

	New(usermob,tool,targetmob, loopcount = 0)
		user = usermob
		M = tool
		target = targetmob
		looped = loopcount
		..()

	onUpdate()
		..()
		if(get_dist(user, target) > 1 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(get_dist(user, target) > 1 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return
		src.loopStart()
		return

	loopStart()
		..()
		if (!M.reagents || M.reagents.total_volume <= 0)
			user.show_text("[M] is empty.", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		health_temp = target.health

		//WEAKEN the first apply or use some sort of ramp-up!
		var/multiply = 1
		if (looped <= 7)
			multiply = min((looped+1)/8, 1)

		M.apply_to(target,user, multiply, silent = (looped >= 1))

	onEnd()
		if(get_dist(user, target) > 1 || user == null || target == null)
			..()
			interrupt(INTERRUPT_ALWAYS)
			return

		//Auto stop healing loop if we are not tampered and the health didnt change at all
		if (!M.tampered)
			target.updatehealth() //I hate this, but we actually need the health on time here.
			if (health_temp == target.health)
				..()
				user.show_text("[M] is finished healing and powers down automatically.", "blue")
				return

		looped++
		src.onRestart()
