/obj/item/device/nanoloom
	name = "nanoloom"
	desc = "A small device capable of rapidly repairing degradation in equipment using material from an attached spool cartridge."
	icon_state = "nanoloom"
	flags = FPRINT | SUPPRESSATTACK
	c_flags = ONBELT
	click_delay = 0.7 SECONDS
	rand_pos = FALSE

	var/obj/item/nanoloom_cartridge/loom_cart = new

	New()
		..()
		UpdateIcon()

	attack_self(mob/user as mob)
		if (loom_cart)
			boutput(user, "<span class='notice'>You remove the [loom_cart.thread ? null : "spent "]cartridge from the nanoloom.</span>")
			playsound(src, 'sound/machines/click.ogg', 40, 1)
			loom_cart.UpdateIcon()
			user.put_in_hand_or_drop(loom_cart)
			src.loom_cart = null
			UpdateIcon()

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/nanoloom_cartridge))
			if(!loom_cart)
				boutput(user, "<span class='notice'>You load the cartridge into the nanoloom.</span>")
				playsound(src, 'sound/machines/click.ogg', 40, 1)
				W.set_loc(src)
				user.u_equip(W)
				src.loom_cart = W
				UpdateIcon()
			else
				boutput(user, "<span class='alert'>There's already a cartridge in the nanoloom.</span>")
			return
		..()

	afterattack(obj/item/I, mob/user as mob)
		if (!istype(I))
			boutput(user, "<span class='alert'>You can't mend that.</span>")
			return
		if (!src.loom_cart)
			boutput(user, "<span class='alert'>The nanoloom has no cartridge attached.</span>")
			return
		if (!loom_cart.thread)
			boutput(user, "<span class='alert'>The nanoloom's attached cartridge is empty.</span>")
			return
		var/turf/repairing_at = get_turf(user) //anti cheese mechanic while fluid touch loop doesn't exist
		if (istype(repairing_at,/turf/space/fluid) || repairing_at.active_liquid)
			boutput(user, "<span class='alert'>The nanoloom can't operate in the presence of fluid.</span>")
			return
		var/datum/component/gear_corrosion/corr = I.GetComponent(/datum/component/gear_corrosion)
		if (!corr)
			boutput(user, "<span class='alert'>The item isn't damaged.</span>")
			return
		var/damage_cooldown = (corr.last_decay_time + 30 SECONDS) - TIME
		if(damage_cooldown > 0)
			var/factor = ceil(damage_cooldown * 0.1)
			boutput(user, "<span class='alert'>The item has taken damage too recently to repair - [factor] second(s) remaining.</span>")
			return

		begin_application(I,user=user)

	update_icon()
		if(loom_cart)
			src.icon_state = "nanoloom"
			var/threadlevel = ceil(loom_cart.thread/8)
			UpdateOverlays(image('icons/obj/items/device.dmi', "nloom-[threadlevel]"), "thread")
		else
			src.icon_state = "nanoloom-empty"
			UpdateOverlays(image('icons/obj/items/device.dmi', "nloom-0"), "thread")
		..()

	proc/begin_application(obj/item/I as obj, mob/user as mob)
		actions.start(new/datum/action/bar/icon/nanoloom_mend(user,src,I), user)

/datum/action/bar/icon/nanoloom_mend
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "nanoloom_mend"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "nanoloom-active"
	var/mob/living/user
	var/obj/item/device/nanoloom/loom
	var/obj/item/target
	var/datum/component/gear_corrosion/gear_dam

	New(usermob,tool,targetitem)
		user = usermob
		loom = tool
		target = targetitem
		gear_dam = target.GetComponent(/datum/component/gear_corrosion)
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


	loopStart()
		..()
		if (!loom.loom_cart || loom.loom_cart.thread <= 0)
			user.show_text("[loom]'s spool cartridge [loom.loom_cart ? "was removed" : "is empty"].", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		var/turf/repairing_at = get_turf(user) //anti cheese mechanic while fluid touch loop doesn't exist
		if (istype(repairing_at,/turf/space/fluid) || repairing_at.active_liquid)
			user.show_text("The nanoloom can't operate in the presence of fluid.", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(loom, 'sound/items/putback_defib.ogg', 30, 1)
		if(gear_dam.apply_mend())
			loom.loom_cart.thread--
			loom.UpdateIcon()

	onEnd()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null || !user.find_in_hand(loom))
			..()
			interrupt(INTERRUPT_ALWAYS)
			return

		if(gear_dam.time_to_corrode >= gear_dam.max_ttc) //shouldn't ever exceed, but just in case.
			user.show_text("[loom] finishes repairing [target].", "blue")
			gear_dam.RemoveComponent(/datum/component/gear_corrosion)
			gear_dam = null
			..()
			return

		src.onRestart()


/obj/item/nanoloom_cartridge
	name = "nanoloom spool cartridge"
	desc = "A small cartridge of fine, densely-spun thread for use in a handheld nanoloom."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "nanoloom-cart"
	w_class = W_CLASS_SMALL
	inventory_counter_enabled = TRUE
	rand_pos = TRUE
	var/thread = 40

	New()
		..()
		UpdateIcon()

	update_icon()
		..()
		inventory_counter?.update_number(src.thread)
