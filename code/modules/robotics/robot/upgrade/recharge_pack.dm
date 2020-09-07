/obj/item/roboupgrade/rechargepack
	name = "cyborg recharge pack"
	desc = "A single-use reserve battery that can recharge a cyborg's cell to full capacity."
	icon_state = "up-recharge"
	active = 1
	charges = 1

/obj/item/roboupgrade/rechargepack/upgrade_activate(var/mob/living/silicon/robot/user as mob)
	if (!user)
		return
	if (user.cell)
		var/obj/item/cell/C = user.cell
		C.charge = C.maxcharge
		boutput(user, "<span class='notice'>Cell has been recharged to [user.cell.charge]!</span>")
	else
		boutput(user, "<span class='alert'>You don't have a cell to recharge!</span>")
		src.charges++
