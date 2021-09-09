/obj/item/organ/augmentation
	name = "surgical augmentation parent"
	organ_name = "augmentation"
	//organ_holder_name = "augmentation_nerve"
	organ_holder_location = "chest"
	organ_holder_required_op_stage = 0.0
	icon_state = "augmentation"
	robotic = 1
	desc = "A thin, metal oval with some wires sticking out. It seems like it'd do well attached to the nervous system."

/obj/item/organ/augmentation/head //second abstract parent incase other augmentation types get added
	name = "surgical augmentation parent"
	organ_name = "augmentation_nerve"
	organ_holder_name = "augmentation_nerve"
	organ_holder_location = "head"
	organ_holder_required_op_stage = 4.0
	icon_state = "augmentation"

/obj/item/organ/augmentation/head/wireless_interact //you can interact with mechanical things at range at the cost of flash vulnerability
	name = "wireless interactor"
	organ_name = "wireless interactor"
	icon_state = "augmentation_wire"
	desc = "An augmentation that allows for ranged interaction with various electronic devices."
	var/flashed = FALSE

	proc/ranged_click(atom/target, params, location, control)
		var/mob/M = src.donor
		var/inrange = in_interact_range(target, M)
		var/obj/item/equipped = M.equipped()
		if(!istype(params, /obj) || istype(params, /obj/item) || istype(params, /obj/artifact/borgifier )|| src.flashed == TRUE)
			return
		if (M.client.check_any_key(KEY_EXAMINE | KEY_POINT) || (equipped && (inrange || (equipped.flags & EXTRADELAY))) || ishelpermouse(target)) // slightly hacky, oh well, tries to check whether we want to click normally or use attack_ai
			return
		else
			if (get_dist(M, target) > 0)
				set_dir(get_dir(M, target))

			target.attack_ai(M, params, location, control)

	proc/flash_check(atom/A, obj/item/I, mob/user)
		if(istype(I, /obj/item/device/flash))
			src.flashed = TRUE
			src.take_damage(5, 5, 0) //owie
			src.donor.remove_stamina(25)
			SPAWN_DBG(15 SECONDS)
				src.flashed = FALSE
		if(src.broken)
			src.donor.remove_stamina(15)

	on_transplant(var/mob/M as mob)
		..()
		if(!broken)
			RegisterSignal(src.donor, COMSIG_CLICK, .proc/ranged_click)
			RegisterSignal(src.donor, COMSIG_ATTACKBY, .proc/flash_check)
			M.mob_flags |= USR_DIALOG_UPDATES_RANGE

	on_removal()
		..()
		var/mob/M = src.donor
		if(!broken)
			UnregisterSignal(src.donor, COMSIG_CLICK)
			M.mob_flags &= ~USR_DIALOG_UPDATES_RANGE
		UnregisterSignal(src.donor, COMSIG_ATTACKBY)

	on_broken(var/mult = 1)
		var/mob/M = src.donor
		if (!..())
			return
		src.donor.reagents.add_reagent("nanites", 0.5 * mult) //you want borg powers? Well, come and get 'em!
		UnregisterSignal(src.donor, COMSIG_CLICK)
		M.mob_flags &= ~USR_DIALOG_UPDATES_RANGE
