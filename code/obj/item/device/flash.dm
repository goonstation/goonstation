/obj/item/device/flash
	name = "flash"
	desc = "A device that emits an extremely bright light when used. Useful for briefly stunning people or starting a dance party."
	uses_multiple_icon_states = 1
	icon_state = "flash"
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	item_state = "electronic"
	mats = 2
	module_research = list("energy" = 1, "devices" = 3)

	var/status = 1 // Bulb still functional?
	var/secure = 1 // Access panel still secured?
	var/use = 0 // Times the flash has been used.
	var/l_time = 0 // Anti-spam cooldown (in relation to world time).
	var/emagged = 0 // Booby Trapped?

	var/eye_damage_mod = 0
	var/range_mod = 0
	var/burn_mod = 0 // De-/increases probability of bulb burning out, so not related to BURN damage.
	var/stun_mod = 0

	var/animation_type = "flash2"

	var/turboflash = 0 // Turbo flash-specific vars.
	var/obj/item/cell/cell = null
	var/max_flash_power = 0
	var/min_flash_power = 0

	cyborg
		process_burnout(mob/user)
			return

		attack(mob/living/M as mob, mob/user as mob)
			..()
			var/mob/living/silicon/robot/R = user
			if (istype(R))
				R.cell.use(300)

		attack_self(mob/user as mob, flag)
			..()
			var/mob/living/silicon/robot/R = user
			if (istype(R))
				R.cell.use(150)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				user.show_text("You use the card to poke a hole in the back of the [src]. That may not have been a very good idea.", "blue")
			src.emagged = 1
			src.desc += " There seems to be a tiny hole drilled into the back of it."
			return 1
		else
			if (user)
				user.show_text("There already seems to be some modifications done to the device.", "red")

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You fill the strange hole in the back of the [src].", "blue")
		src.emagged = 0
		src.desc = "A device that emits an extremely bright light when used. Useful for briefly stunning people or starting a dance party."
		return 1



//I split attack and flash_mob into seperate procs so the rev_flash code is cleaner
/obj/item/device/flash/attack(mob/living/M as mob, mob/user as mob)
	if(isghostcritter(user)) return
	src.flash_mob(M, user)

// Tweaked attack and attack_self to reduce the amount of duplicate code. Turboflashes to be precise (Convair880).
/obj/item/device/flash/proc/flash_mob(mob/living/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	var/turf/t = get_turf(user)
	if (t.loc:sanctuary)
		user.visible_message("<span class='alert'><b>[user]</b> tries to use [src], cannot quite comprehend the forces at play!</span>")
		return
	if (user.bioHolder && user.bioHolder.HasEffect("clumsy") && prob(50))
		user.visible_message("<span class='alert'><b>[user]</b> tries to use [src], but slips and drops it!</span>")
		user.drop_item()
		return
	if (src.status == 0)
		boutput(user, "<span class='alert'>The bulb has been burnt out!</span>")
		return

	// Handle turboflash power cell.
	var/flash_power = 0
	if (src.turboflash)
		if (!src.cell)
			user.show_text("[src] doesn't seem to be connected to a power cell.", "red")
			return
		if (src.cell && istype(src.cell,/obj/item/cell/erebite))
			user.visible_message("<span class='alert'>[user]'s flash/cell assembly violently explodes!</span>")
			logTheThing("combat", user, M, "tries to blind [constructTarget(M,"combat")] with [src] (erebite power cell) at [log_loc(user)].")
			var/turf/T = get_turf(src.loc)
			explosion(src, T, 0, 1, 2, 2)
			SPAWN_DBG(0.1 SECONDS)
				if (src) qdel(src)
			return
		if (src.cell)
			if (src.cell.charge < min_flash_power)
				user.show_text("[src] seems to be out of power.", "red")
				return
			else
				flash_power = src.cell.charge / max_flash_power
				if (flash_power > 1)
					flash_power = 1
				flash_power++
	else
		flash_power = 1

	// Play animations.
	if (isrobot(user))
		SPAWN_DBG(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(0.5 SECONDS)
			qdel(animation)

	playsound(get_turf(src), "sound/weapons/flash.ogg", 100, 1)
	flick(src.animation_type, src)
	src.l_time = world.time
	if (!src.turboflash)
		src.use++

	// Calculate target damage.
	var/animation_duration
	var/weakened
	var/eye_blurry
	var/eye_damage
	var/burning

	if (src.turboflash)
		animation_duration = 60
		weakened = (10 + src.stun_mod) * flash_power
		eye_blurry = src.eye_damage_mod + rand(2, (4 * flash_power))
		eye_damage = src.eye_damage_mod + rand(5, (10 * flash_power))
		burning = 15 * flash_power
	else
		animation_duration = 30
		weakened = (8 + src.stun_mod) * flash_power
		eye_damage = src.eye_damage_mod + rand(0, (1 * flash_power))

	// We're flashing somebody directly, hence the 100% chance to disrupt cloaking device at the end.
	M.apply_flash(animation_duration, weakened, 0, 0, eye_blurry, eye_damage, 0, burning, 100, stamina_damage = 70 * flash_power, disorient_time = 30)
	if (src.emagged)
		user.apply_flash(animation_duration, weakened, 0, 0, eye_blurry, eye_damage, 0, burning, 100, stamina_damage = 70 * flash_power, disorient_time = 30)

	convert(M,user)

	// Log entry.
	M.visible_message("<span class='alert'>[user] blinds [M] with the [src.name]!</span>")
	logTheThing("combat", user, M, "blinds [constructTarget(M,"combat")] with [src] at [log_loc(user)].")
	if (src.emagged)
		logTheThing("combat", user, user, "blinds themself with [src] at [log_loc(user)].")

	// Handle bulb wear.
	if (src.turboflash)
		status = 0
		src.cell.use(min(src.cell.charge, max_flash_power))
		boutput(user, "<span class='alert'><b>The bulb has burnt out!</b></span>")
		set_icon_state("turboflash3")
		src.name = "depleted flash/cell assembly"

	else
		src.process_burnout(user)

	// Some after attack stuff.
	user.lastattacked = M
	M.lastattacker = user
	M.lastattackertime = world.time

	return

/obj/item/device/flash/attack_self(mob/user as mob)
	if(isghostcritter(user)) return
	src.add_fingerprint(user)

	if (src.l_time && world.time < src.l_time + 10)
		return

	if (user?.bioHolder?.HasEffect("clumsy") && prob(50))
		user.visible_message("<span class='alert'><b>[user]</b> tries to use [src], but slips and drops it!</span>")
		user.drop_item()
		JOB_XP(user, "Clown", 1)
		return
	if (status == 0)
		boutput(user, "<span class='alert'>The bulb has been burnt out!</span>")
		return

	// Handle turboflash power cell.
	if (src.turboflash)
		if (!src.cell)
			user.show_text("[src] doesn't seem to be connected to a power cell.", "red")
			return
		if (src.cell && src.cell.charge < min_flash_power)
			user.show_text("[src] seems to be out of power.", "red")
			return
		if (src.cell && istype(src.cell,/obj/item/cell/erebite))
			user.visible_message("<span class='alert'>[user]'s flash/cell assembly violently explodes!</span>")
			logTheThing("combat", user, null, "tries to area-flash with [src] (erebite power cell) at [log_loc(user)].")
			var/turf/T = get_turf(src.loc)
			explosion(src, T, 0, 1, 2, 2)
			SPAWN_DBG(0.1 SECONDS)
				if (src) qdel(src)
			return

	// Play animations.
	playsound(get_turf(src), "sound/weapons/flash.ogg", 100, 1)
	flick(src.animation_type, src)
	src.l_time = world.time

	if (isrobot(user))
		SPAWN_DBG(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(0.5 SECONDS)
			qdel(animation)

	// Flash target mobs.
	for (var/mob/living/M in oviewers((3 + src.range_mod), get_turf(src)))
		if (src.turboflash)
			M.apply_flash(35, 0, 0, 25)
		else
			var/dist = get_dist(get_turf(src),M)
			dist = min(dist,4)
			dist = max(dist,1)
			M.apply_flash(20, weak = 2, uncloak_prob = 100, stamina_damage = (35 / dist), disorient_time = 3)


	// Handle bulb wear.
	if (src.turboflash)
		status = 0
		src.cell.use(min(src.cell.charge, max_flash_power))
		boutput(user, "<span class='alert'><b>The bulb has burnt out!</b></span>")
		set_icon_state("turboflash3")
		src.name = "depleted flash/cell assembly"
	else
		src.use++
		src.process_burnout(user)

	return

/obj/item/device/flash/proc/convert(mob/living/M as mob, mob/user as mob)
	.= 0
	if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
		var/datum/game_mode/revolution/R = ticker.mode
		if (ishuman(M))
			//playsound(get_turf(src), "sound/weapons/rev_flash_startup.ogg", 40, 1 , 0, 0.6) //moved to rev flash only

			var/mob/living/carbon/human/H = M
			var/safety = 0
			if (H.eyes_protected_from_light())
				safety = 1

			if (safety == 0 && user.mind && (user.mind in R.head_revolutionaries) && !isghostcritter(user))
				var/nostun = 0
				var/list/U = R.get_unconvertables()
				if (!H.client || !H.mind)
					user.show_text("[H] is braindead and cannot be converted.", "red")
				else if (locate(/obj/item/implant/antirev) in H.implant)
					user.show_text("There seems to be something preventing [H] from revolting.", "red")
					.= 0.5
					nostun = 1
				else if (H.mind in U)
					user.show_text("[H] seems unwilling to revolt.", "red")
					nostun = 1
				else if (H.mind in R.head_revolutionaries)
					user.show_text("[H] is already a member of the revolution.", "red")
				else
					.= 1
					if (!(H.mind in R.revolutionaries))
						R.add_revolutionary(H.mind)
					else
						user.show_text("[H] is already a member of the revolution.", "red")
				if (!nostun)
					M.apply_flash(1, 2, 0, 0, 0, 0, 0, burning, 100, stamina_damage = 210, disorient_time = 40)


/obj/item/device/flash/proc/process_burnout(mob/user as mob)
	if (use > 1 && prob(max(0,(use*1.2) + burn_mod)))
		status = 0
		boutput(user, "<span class='alert'><b>The bulb has burnt out!</b></span>")
		set_icon_state("flash3")
		name = "depleted flash"

	return


/obj/item/device/flash/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/cell) && !src.secure)
		boutput(user, "<span class='notice'>You combine [W] and [src]...</span>")
		var/obj/item/device/flash/turbo/T = new /obj/item/device/flash/turbo(user.loc)
		T.cell = W
		user.drop_item()
		W.set_loc(T)

		if(!src.status)
			T.set_icon_state("turboflash3")
			T.status = 0

		qdel(src)
		return
	else if (isscrewingtool(W))
		boutput(user, "<span class='notice'>You [src.secure ? "unscrew" : "secure"] the access panel.</span>")
		secure = !secure
	else if (ispulsingtool(W))
		if (src.status == 0)
			boutput(user, "<span class='alert'>The bulb has been burnt out.</span>")
		else
			if (src.use <= 0)
				boutput(user, "<span class='notice'>The bulb is in perfect condition.</span>")
			else if (src.use>0 && src.use<5)
				boutput(user, "<span class='notice'>The bulb is in good condition.</span>")
			else if (src.use>5 && src.use<10)
				boutput(user, "<span class='notice'>The bulb is in decent condition.</span>")
			else if (src.use>10 && src.use<15)
				boutput(user, "<span class='notice'>The bulb is in bad condition.</span>")
			else
				boutput(user, "<span class='notice'>The bulb is in terrible condition.</span>")
	else
		return ..()

/obj/item/device/flash/is_detonator_attachment()
	return 1

/obj/item/device/flash/detonator_act(event, var/obj/item/assembly/detonator/det)
	switch (event)
		if ("pulse")
			det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src] discharges.</span>")
			for (var/mob/living/M in viewers(4, det.attachedTo))
				M.apply_flash(30, 20)
		if ("cut")
			det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src] goes black.</span>")
			det.attachments.Remove(src)
		if ("process")
			if (prob(5))
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>\The [src] discharges.</span>")
				for (var/mob/living/M in viewers(2, det.attachedTo))
					M.apply_flash(30, 8)

/obj/item/device/flash/emp_act()
	if(iscarbon(src.loc))
		src.attack_self()
	return

// The Turboflash - A flash combined with a charged energy cell to make a bigger, meaner flash (That dies after one use).
/obj/item/device/flash/turbo
	name = "flash/cell assembly"
	desc = "A common stun weapon with a power cell hastily wired into it. Looks dangerous."
	icon_state = "turboflash"
	mats = 0
	animation_type = "turboflash2"
	turboflash = 1
	max_flash_power = 5000
	min_flash_power = 500

	New()
		..()
		SPAWN_DBG(1 SECOND)
			if(!src.cell)
				src.cell = new /obj/item/cell(src)
				src.cell.maxcharge = max_flash_power
				src.cell.charge = src.cell.maxcharge
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (!W)
			return
		if (iswrenchingtool(W) && !(src.secure))
			boutput(user, "You disassemble [src]!")
			src.cell.set_loc(get_turf(src))
			var/obj/item/device/flash/F = new /obj/item/device/flash( get_turf(src) )
			if(!src.status)
				F.status = 0
				F.set_icon_state("flash3")
			qdel(src)
		else if (isscrewingtool(W))
			boutput(user, "<span class='notice'>You [src.secure ? "unscrew" : "secure"] the access panel.</span>")
			secure = !secure
		return

/obj/item/storage/box/turbo_flash_kit
	name = "\improper Box of flash/cell assemblies."
	desc = "A box filled with five dangerous looking flash/cell assemblies."
	icon_state = "flashbang"
	spawn_contents = list(/obj/item/device/flash/turbo = 5)

/obj/item/device/flash/revolution
	name = "revolutionary flash"
	desc = "A device that emits an extremely bright light when used. Something about this device forces people to revolt, when flashed by a revolution leader."
	icon_state = "rev_flash"

	process_burnout(mob/user as mob)
		return

	emp_act()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		return

	attack(mob/living/M as mob, mob/user as mob)
		flash_mob(M, user, 0)
		flash_mob(M, user, 1)


	flash_mob(mob/living/M as mob, mob/user as mob, var/convert = 1)
		if (!convert)
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
				var/datum/game_mode/revolution/R = ticker.mode
				if (M.mind && (M.mind in R.head_revolutionaries))
					user.show_text("[src] refuses to flash!", "red") //lol
					return
		else if (ticker?.mode && istype(ticker.mode, /datum/game_mode/revolution))
			playsound(get_turf(src), "sound/weapons/rev_flash_startup.ogg", 60, 1 , 0, 0.6)
			var/convert_result = convert(M,user)
			if (convert_result == 0.5)
				user.show_text("Hold still to override . . . ", "red")
				actions.start(new/datum/action/bar/icon/rev_flash(src,M), user)
			if (convert_result)
				..()
