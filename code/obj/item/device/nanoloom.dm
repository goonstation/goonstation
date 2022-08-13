/obj/item/device/nanoloom
	name = "nanoloom"
	desc = "A small device capable of rapidly repairing degradation in equipment using material from an attached spool cartridge."
	icon_state = "nanoloom"
	flags = ONBELT
	click_delay = 0.7 SECONDS
	rand_pos = 0

	var/obj/item/nanoloom_cartridge/loom_cart = new

	var/static/sewnoise = 'sound/items/putback_defib.ogg'

	attack_self(mob/user as mob)
		if (loom_cart)
			boutput(user, "<span class='notice'>You remove the [loom_cart.thread ? null : "spent "]cartridge from the nanoloom.</span>")
			loom_cart.UpdateIcon()
			user.put_in_hand_or_drop(loom_cart)
			src.loom_cart = null
			src.icon_state = "nanoloom-empty"
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/nanoloom_cartridge))
			if(!loom_cart)
				boutput(user, "<span class='notice'>You load the cartridge into the nanoloom.</span>")
				W.loc = src
				user.u_equip(W)
				src.loom_cart = W
				src.icon_state = "nanoloom"
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
		if (!I.GetComponent(/datum/component/gear_corrosion))
			boutput(user, "<span class='alert'>The item isn't damaged.</span>")
			return

		begin_application(I,user=user)

	proc/begin_application(obj/item/I as obj, mob/user as mob)
		actions.start(new/datum/action/bar/icon/nanoloom_mend(user,src,I), user)

/datum/action/bar/icon/nanoloom_mend
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ATTACKED
	id = "nanoloom_mend"
	icon = 'icons/obj/items/device.dmi'
	icon_state = "nanoloom-active"
	var/mob/living/user
	var/obj/item/device/nanoloom/N
	var/obj/item/target
	var/datum/component/gear_corrosion/gear_dam

	New(usermob,tool,targetitem)
		user = usermob
		N = tool
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
		return

	loopStart()
		..()
		if (!N.loom_cart || N.loom_cart.thread <= 0)
			user.show_text("[N]'s spool cartridge [N.loom_cart ? "was removed" : "is empty"].", "red")
			interrupt(INTERRUPT_ALWAYS)
			return

		playsound(N, N.sewnoise, 30, 1)
		boutput(user,"[gear_dam.time_to_corrode]")
		if(gear_dam.apply_mend())
			N.loom_cart.thread--

	onEnd()
		if(BOUNDS_DIST(user, target) > 0 || user == null || target == null || !user.find_in_hand(N))
			..()
			interrupt(INTERRUPT_ALWAYS)
			return

		if(gear_dam.time_to_corrode >= gear_dam.max_ttc) //shouldn't ever exceed, but just in case.
			user.show_text("[N] finishes repairing [target].", "blue")
			gear_dam.RemoveComponent(/datum/component/gear_corrosion)
			gear_dam = null
			..()
			return

		src.onRestart()


/obj/item/nanoloom_cartridge
	name = "spool cartridge"
	desc = "A small cartridge of fine, densely-spun thread for use in a handheld nanoloom."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "nanoloom-cart"
	var/thread = 60
	inventory_counter_enabled = 1

	New()
		..()
		UpdateIcon()

	update_icon()
		..()
		inventory_counter?.update_number(src.thread)
