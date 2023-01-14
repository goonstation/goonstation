TYPEINFO(/obj/machinery/robotic_fabricator)
	mats = 20

/obj/machinery/robotic_fabricator
	name = "Robotic Fabricator"
	desc = "A machine that produces various objects for robotics from raw material."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fab-idle"
	density = 1
	anchored = 1
	var/metal_amount = 0
	var/operating = 0
	var/obj/item/parts/robot_parts/being_built = null

/obj/machinery/robotic_fabricator/attackby(var/obj/item/O, var/mob/user)
	if (istype(O, /obj/item/sheet/metal))
		if (src.metal_amount < 150000.0)
			var/count = 0
			SPAWN(1.5 SECONDS)
				while(metal_amount < 150000 && O:amount)

					if(!O:amount)
						return

					src.metal_amount += O:height * O:width * O:length * 100000
					O:amount--
					count++

				if (O:amount < 1)
					qdel(O)

				boutput(user, "You insert [count] metal sheet\s into the fabricator.")
				updateDialog()
		else
			boutput(user, "The robot part maker is full. Please remove metal from the robot part maker in order to insert more.")

/obj/machinery/robotic_fabricator/power_change()
	if (powered())
		status &= ~NOPOWER
	else
		status |= NOPOWER

/obj/machinery/robotic_fabricator/process()
	if (status & (NOPOWER | BROKEN))
		return

	use_power(1000)

/obj/machinery/robotic_fabricator/attack_hand(user)
	var/dat
	if (..())
		return

	if (src.operating)
		dat = {"
<TT>Building [src.being_built.name].<BR>
Please wait until completion...</TT><BR>
<BR>
"}
	else
		dat = {"
<B>Metal Amount:</B> [min(150000, src.metal_amount)] cm<sup>3</sup> (MAX: 150,000)<BR><HR>
<BR>
<A href='?src=\ref[src];make=1'>Left Arm (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=2'>Right Arm (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=3'>Left Leg (25,000 cc metal.)<BR>
<A href='?src=\ref[src];make=4'>Right Leg (25,000 cc metal).<BR>
<A href='?src=\ref[src];make=5'>Chest (50,000 cc metal).<BR>
<A href='?src=\ref[src];make=6'>Head (50,000 cc metal).<BR>
<A href='?src=\ref[src];make=7'>Robot Frame (75,000 cc metal).<BR>
"}

	user << browse("<HEAD><TITLE>Robotic Fabricator Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=robot_fabricator")
	onclose(user, "robot_fabricator")
	return

/obj/machinery/robotic_fabricator/Topic(href, href_list)
	if (..())
		return

	src.add_dialog(usr)
	src.add_fingerprint(usr)

	if (href_list["make"])
		if (!src.operating)
			var/part_type = text2num_safe(href_list["make"])

			var/build_type = ""
			var/build_time = 200
			var/build_cost = 25000

			switch (part_type)
				if (1)
					build_type = "/obj/item/parts/robot_parts/l_arm"
					build_time = 200
					build_cost = 25000

				if (2)
					build_type = "/obj/item/parts/robot_parts/r_arm"
					build_time = 200
					build_cost = 25000

				if (3)
					build_type = "/obj/item/parts/robot_parts/l_leg"
					build_time = 200
					build_cost = 25000

				if (4)
					build_type = "/obj/item/parts/robot_parts/r_leg"
					build_time = 200
					build_cost = 25000

				if (5)
					build_type = "/obj/item/parts/robot_parts/chest"
					build_time = 350
					build_cost = 50000

				if (6)
					build_type = "/obj/item/parts/robot_parts/head"
					build_time = 350
					build_cost = 50000

				if (7)
					build_type = "/obj/item/parts/robot_parts/robot_frame"
					build_time = 600
					build_cost = 75000

			var/building = text2path(build_type)
			if (!isnull(building))
				if (src.metal_amount >= build_cost)
					src.operating = 1

					src.metal_amount = max(0, src.metal_amount - build_cost)

					src.being_built = new building(src)

					src.icon_state = "fab-active"
					src.updateUsrDialog()

					use_power(5000)

					SPAWN(build_time)
						if (!isnull(src.being_built))
							src.being_built.set_loc(get_turf(src))
							src.being_built = null

						src.operating = 0
						src.icon_state = "fab-idle"
		return

	for (var/mob/M in viewers(1, src))
		if (M.client && M.machine == src)
			src.Attackhand(M)
