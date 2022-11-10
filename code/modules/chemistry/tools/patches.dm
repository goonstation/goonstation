


/mob/living/proc/handle_skin(var/mult = 1)
	if (src.skin_process && length(src.skin_process))
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
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK | EXTRADELAY
	rc_flags = RC_SPECTRO		// only spectroscopic analysis
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
		..()
		src.UpdateIcon()
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

	proc/can_operate_on(atom/A)
		.= (iscarbon(A) || ismobcritter(A))

	proc/clamp_reagents()
		if (src.reagents.total_temperature > src.reagents.temperature_cap)
			src.reagents.total_temperature = src.reagents.temperature_cap
		if (src.reagents.total_temperature < src.reagents.temperature_min)
			src.reagents.total_temperature = src.reagents.temperature_min


	update_icon()

		src.underlays = null
		if (src.reagents && src.reagents.total_volume)
			icon_state = "[src.style]1"
			if (medical == 1)
				icon_state = "[src.style]_med1"
			if (reagents.has_reagent("LSD",1))
				icon_state = "[src.style]_LSD"
			if (reagents.has_reagent("lsd_bee"))
				icon_state = "[src.style]_LSBee"

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
			src.UpdateIcon()
			return 1

	attackby(obj/item/W, mob/user)
		return

	attack_self(mob/user as mob)
		if (ON_COOLDOWN(user, "self-patch", user.combat_click_delay))
			return

		if (src.borg == 1 && !issilicon(user))
			user.show_text("This item is not designed with organic users in mind.", "red")
			return

		if (can_operate_on(user))
			user.visible_message("[user] applies [src] to [himself_or_herself(user)].",\
			"<span class='notice'>You apply [src] to yourself.</span>")
			logTheThing(LOG_CHEMISTRY, user, "applies a patch to themself [log_reagents(src)] at [log_loc(user)].")
			user.Attackby(src, user)
		return

	throw_impact(atom/M, datum/thrown_thing/thr)
		..()
		if (src.medical && !borg && !src.in_use && (can_operate_on(M)))
			if (prob(30) || good_throw && prob(70))
				src.in_use = 1
				M.visible_message("<span class='alert'>[src] lands on [M] sticky side down!</span>")
				logTheThing(LOG_COMBAT, M, "is stuck by a patch [log_reagents(src)] thrown by [constructTarget(usr,"combat")] at [log_loc(M)].")
				apply_to(M,usr)
				attach_sticker_manual(M)

	attack(mob/M, mob/user)
		if (src.in_use)
			//DEBUG_MESSAGE("[src] in use")
			return

		if (src.borg == 1 && !issilicon(user))
			user.show_text("This item is not designed with organic users in mind.", "red")
			return

		// No src.reagents check here because empty patches can be used to counteract bleeding.
		if (can_operate_on(M))
			src.in_use = 1
			if (M == user)
				//M.show_text("You put [src] on your arm.", "blue")
				M.visible_message("[user] applies [src] to [himself_or_herself(user)].",\
				"<span class='notice'>You apply [src] to yourself.</span>")
			else
				if (medical == 0)
					user.visible_message("<span class='alert'><b>[user]</b> is trying to stick [src] to [M]'s arm!</span>",\
					"<span class='alert'>You try to stick [src] to [M]'s arm!</span>")
					logTheThing(LOG_COMBAT, user, "tries to apply a patch [log_reagents(src)] to [constructTarget(M,"combat")] at [log_loc(user)].")

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

			logTheThing(user == M ? LOG_CHEMISTRY : LOG_COMBAT, user, M, "applies a patch to [constructTarget(M,"combat")] [log_reagents(src)] at [log_loc(user)].")

			src.clamp_reagents()

			apply_to(M,user=user)
			return 1

		return 0

	proc/apply_to(mob/M as mob, mob/user as mob)
		repair_bleeding_damage(M, 25, 1)
		active = 1

		if (reagents?.total_volume)
			if (!borg)
				user?.drop_item(src)
				//user.u_equip(src)
				//qdel(src)
				src.set_loc(M)
				if (isliving(M))
					var/mob/living/L = M
					L.skin_process += src
			else
				reagents.reaction(M, TOUCH, paramslist = list("nopenetrate","ignore_chemprot"))

				var/datum/reagents/R = new
				reagents.copy_to(R)
				R.trans_to(M, reagents.total_volume/2)
				src.in_use = 0

			playsound(src, 'sound/items/sticker.ogg', 50, 1)

		else
			if (!borg)
				user.drop_item(src)
				qdel(src)
			else
				src.in_use = 0

	afterattack(var/atom/A as mob|obj|turf, var/mob/user as mob, reach, params)
		.= 0
		if(!can_operate_on(A))
			return
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

	cyborg
		borg = 1

/obj/item/reagent_containers/patch/lsd_bee
	name = "bluzzer"
	desc = "A highly potent hallucinogenic substance. It smells like honey."
	icon_state = "patch_LSBee"
	initial_reagents = list("lsd_bee"=20)

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
			P.Attackby(W, user)

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
				SPAWN(6 SECONDS)
					update_overlay()


//mender
/obj/item/reagent_containers/mender
	name = "auto-mender"
	desc = "A small electronic device designed to topically apply healing chemicals."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mender"
	mats = list("MET-2"=5,"CRY-1"=4, "gold"=5)
	var/image/fluid_image
	var/tampered = 0
	var/borg = 0
	initial_volume = 200
	flags = FPRINT | TABLEPASS | OPENCONTAINER | ONBELT | NOSPLASH | ATTACK_SELF_DELAY
	click_delay = 0.7 SECONDS
	rc_flags = RC_SCALE | RC_VISIBLE | RC_SPECTRO

	var/list/whitelist = list()
	var/use_volume = 8

	var/static/list/sfx = list('sound/items/mender.ogg','sound/items/mender2.ogg')


	New()
		..()
		if (!tampered && islist(chem_whitelist) && length(chem_whitelist))
			src.whitelist = chem_whitelist
		if (src.reagents)
			src.reagents.temperature_cap = 330
			src.reagents.temperature_min = 270
			src.reagents.temperature_reagents(change_min = 0, change_cap = 0)

	on_reagent_change(add)
		..()
		if (src.reagents)
			src.reagents.temperature_cap = 330
			src.reagents.temperature_min = 270
			src.reagents.temperature_reagents(change_min = 0, change_cap = 0)
		if (!tampered && add)
			check_whitelist(src, src.whitelist)
		src.UpdateIcon()


	is_open_container()
		if (borg)
			.= 0
		else
			. = ..()

	proc/can_operate_on(atom/A)
		.= (iscarbon(A) || ismobcritter(A))

	update_icon()
		if (reagents.total_volume)
			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/chemical.dmi', "mender-fluid", -1)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.UpdateOverlays(src.fluid_image, "fluid")
		else
			src.UpdateOverlays(null, "fluid")
		signal_event("icon_updated")

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (user && E)
			user.show_text("You press on [src] with [E]. The anti-tamper lock is broken.", "blue")
		src.tampered = 1
		src.UpdateIcon()
		return 1

	attack_self(mob/user as mob)
		if (can_operate_on(user))
			src.attack(user,user) //do self operation
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/reagent_containers/mender_refill_cartridge))
			var/obj/item/reagent_containers/mender_refill_cartridge/refill = W
			refill.do_refill(src, user)
			return
		..()

	attack(mob/M, mob/user)
		if (src.borg == 1 && !issilicon(user))
			user.show_text("This item is not designed with organic users in mind.", "red")
			return

		if (can_operate_on(M) && !actions.hasAction(user,"automender_apply"))
			if (M == user)
				M.visible_message("[user] begins mending [himself_or_herself(user)] with [src].",\
					"<span class='notice'>You begin mending yourself with [src].</span>")
			else
				user.visible_message("<span class='alert'><b>[user]</b> begins mending [M] with [src].</span>",\
					"<span class='alert'>You begin mending [M] with [src].</span>")
				if (M.health < 90)
					JOB_XP(user, "Medical Doctor", 2)

			logTheThing(user == M ? LOG_CHEMISTRY : LOG_COMBAT, user, M, "begins automending [constructTarget(M,"combat")] [log_reagents(src)] at [log_loc(user)].")
			begin_application(M,user=user)
			return 1

		return 0

	afterattack(obj/target, mob/user, flag)
		if(istype(target, /obj/reagent_dispensers) && target.reagents)
			if (!target.reagents.total_volume)
				boutput(user, "<span class='alert'>[target] is already empty.</span>")
				return
			playsound(src.loc, 'sound/items/mender_refill_juice.ogg', 50, 1)
			target.reagents.trans_to(src, src.reagents.maximum_volume)
			return

	proc/begin_application(mob/M as mob, mob/user as mob)
		actions.start(new/datum/action/bar/icon/automender_apply(user,src,M), user)


	proc/apply_to(mob/M as mob, mob/user as mob, var/mult = 1, var/silent = 0)
		//repair_bleeding_damage(M, 66, 1)
		var/use_volume_adjusted = use_volume * mult

		if (reagents?.total_volume)
			var/list/params = list("nopenetrate","ignore_chemprot")
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

			playsound(src, pick(sfx), 50, 1)


/obj/item/reagent_containers/mender/brute
	initial_reagents = "styptic_powder"

	medbot
		name = "brute auto-mender"
		borg = 1

	high_capacity
		initial_volume = 500

/obj/item/reagent_containers/mender/burn
	initial_reagents = "silver_sulfadiazine"

	medbot
		name = "burn auto-mender"
		borg = 1

	high_capacity
		initial_volume = 500

/obj/item/reagent_containers/mender/both
	initial_reagents = "synthflesh"

/obj/item/reagent_containers/mender/both/mini
	initial_volume = 50
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
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null)
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
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null || !user.find_in_hand(M))
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

	onInterrupt(flag)
		. = ..()
		logTheThing(user == target ? "chemistry" : "combat", user, target, " finishes automending [constructTarget(M,"combat")] [log_reagents(src)] after [looped] applications at [log_loc(user)].")

//basically the same as ecig_refill_cartridge, but there's no point subtyping it...
ABSTRACT_TYPE(/obj/item/reagent_containers/mender_refill_cartridge)
/obj/item/reagent_containers/mender_refill_cartridge
	name = "auto-mender refill cartridge"
	desc = "A container designed to be able to quickly refill medical auto-menders."
	icon = 'icons/obj/chemical.dmi'
	initial_volume = 200
	initial_reagents = "nicotine"
	// item_state = "ecigrefill"
	icon_state = "mender-refill"
	flags = FPRINT | TABLEPASS
	var/image/fluid_image

	New()
		..()
		UpdateIcon()

	update_icon()
		if (reagents.total_volume)
			var/fluid_state = round(clamp((src.reagents.total_volume / src.reagents.maximum_volume * 4), 1, 4))
			if (!src.fluid_image)
				src.fluid_image = image('icons/obj/chemical.dmi', "mender-refill-fluid-4", -1)
			var/datum/color/average = reagents.get_average_color()
			src.fluid_image.color = average.to_rgba()
			src.fluid_image.icon_state = "mender-refill-fluid-[fluid_state]"
			src.UpdateOverlays(src.fluid_image, "fluid")

		else
			src.ClearSpecificOverlays("fluid")

		signal_event("icon_updated")

	proc/do_refill(var/obj/item/reagent_containers/mender, var/mob/user)
		if (src?.reagents.total_volume > 0)
			src.reagents.trans_to(mender, src.reagents.total_volume)
			src.UpdateIcon()
			playsound(src, 'sound/items/mender_refill_juice.ogg', 50, 1)
			if (src.reagents.total_volume == 0)
				boutput(user, "<span class='notice'>You refill [mender] to [mender.reagents.total_volume]u and empty [src]!</span>")
			else
				boutput(user, "<span class='notice'>You refill [mender] to [mender.reagents.total_volume]u!</span>")
		else
			boutput(user, "<span class='alert'>You attempt to refill [mender], but [src] is empty!</span>")

/obj/item/reagent_containers/mender_refill_cartridge/brute
	name = "brute auto-mender refill cartridge"
	initial_reagents = "styptic_powder"
	high_capacity
		initial_volume = 500

/obj/item/reagent_containers/mender_refill_cartridge/burn
	name = "burn auto-mender refill cartridge"
	initial_reagents = "silver_sulfadiazine"
	high_capacity
		initial_volume = 500

/obj/item/reagent_containers/mender_refill_cartridge/both
	name = "synthflesh auto-mender refill cartridge"
	initial_reagents = "synthflesh"
	high_capacity
		initial_volume = 500
