/obj/item/roboupgrade/rechargepack
	name = "cyborg recharge pack"
	desc = "A single-use reserve battery that can recharge a cyborg's cell to full capacity."
	icon_state = "up-recharge"
	active = TRUE
	charges = 1

/obj/item/roboupgrade/rechargepack/upgrade_activate(var/mob/living/silicon/robot/user)
	if(user.hasStatus("quick_charged"))
		boutput(user, SPAN_ALERT("The battery has been quick charged too recently!"))
		return
	switch(..())
		if(ROBOT_UPGRADE_FAIL_DISABLED)
			return
		if(ROBOT_UPGRADE_FAIL_LOW_POWER)
			// we're still going to use up the recharge pack here
			// this could be avoided by separating a pre-check and use proc for each upgrade
			// snowflake for now, change if it becomes more common
			if (src.charges > 0)
				src.charges--
				if (src.charges == 0)
					boutput(user, "[src] has been activated. It has been used up.")
					user.upgrades.Remove(src)
					qdel(src)
				else
					if (src.charges < 0)
						boutput(user, "[src] has been activated.")
					else
						boutput(user, "[src] has been activated. [src.charges] uses left.")
	var/obj/item/cell/C = user.cell
	C.charge = min(C.maxcharge, C.charge + 15000)
	boutput(user, SPAN_NOTICE("Cell has been recharged to [user.cell.charge]!"))
	user.changeStatus("quick_charged", 7 MINUTES, optional=null)
