/obj/item/roboupgrade/rechargepack
	name = "cyborg recharge pack"
	desc = "A single-use reserve battery that can recharge a cyborg's cell to full capacity."
	icon_state = "up-recharge"
	active = TRUE
	charges = 1

/obj/item/roboupgrade/rechargepack/upgrade_activate(var/mob/living/silicon/robot/user)
	if(user.hasStatus("quick_charged"))
		boutput(user, "<span class='alert'>The battery has been quick charged too recently!</span>")
		return
	if (..())
		return
	var/obj/item/cell/C = user.cell
	C.charge = min(C.maxcharge, C.charge + 15000)
	boutput(user, "<span class='notice'>Cell has been recharged to [user.cell.charge]!</span>")
	user.changeStatus("quick_charged", 7 MINUTES, optional=null)
