/////Handles oxygen and heating
/obj/item/shipcomponent/life_support
	name = "Nanotrasen Life-Support System"
	desc = "An advanced life-support system"
	power_used=20
	var/tempreg = 310
	system = "Life Support"
	icon_state = "life_support"

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(pre_attackby), override=TRUE)

	proc/pre_attackby(source, atom/target, mob/user)
		if (!isobj(target))
			return
		if(istype(target, /obj/machinery/vehicle))
			var/obj/machinery/vehicle/vehicle = target
			vehicle.install_part(user, src, POD_PART_LIFE_SUPPORT)
			return ATTACK_PRE_DONT_ATTACK
