/obj/item/weapon/pipe
	name = "Pipe"
	desc = "a pipe for holding gas"
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "pipe"
	opacity = 0
	density = 0
	anchored = 0.0

	var/storage = 1 //How much gas it can hold (in moles)?

//What dir\s the pipe can connect with
	var/up = 0
	var/down = 0
	var/left = 0
	var/right = 0

	attack_ai(mob/user as mob)
		return

	attack_hand(mob/user as mob)
		..()
		return

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			var/turf/T = get_turf(src.loc)
			if(istype(T,/turf/simulated/floor/plating))
				var/obj/machinery/atmos/pipe/P = new/obj/machinery/atmos/pipe(T)
				P.update_dir(up,down,left,right)
				SPAWN_DBG(1 DECI SECOND)
					qdel(src)//This might need to be changed to have them drop it first
			else
				boutput(user, "<span class='alert'>You are unable to place the pipe there.</span>")
		else
			..()//Add ID swipe

	proc/update_dir(var/u, var/d, var/l, var/r)//For the moment just going to have the pipe machine call this
		up = u
		down = d
		left = l
		right = r
		update_icon()
		return

	proc/update_icon()
		overlays = null
		if(up)
			overlays += "+u"
		if(down)
			overlays += "+d"
		if(left)
			overlays += "+l"
		if(right)
			overlays += "+r"
		return



/obj/machinery/atmos/pipe
	name = "Pipe"
	desc = "a pipe for holding gas, currently attached to the flooring"
	icon = 'icons/obj/atmospherics/pipes.dmi'
	icon_state = "pipe"
	opacity = 0
	density = 0
	layer = PIPE_LAYER//Change this to wires+-1

	m_amt = 50	// metal
	g_amt = 10	// glass
	w_amt = 80	// waster amounts


	var/datum/atmos/pipeline/parent = null

//What dir\s the pipe can connect with
	var/up = 0
	var/down = 0
	var/left = 0
	var/right = 0

	New()
		SPAWN_DBG(0.5 SECONDS)
			build()
		return//Dont need to be on the gameticker so dont add us

	attack_ai(mob/user as mob)
		return

	attack_hand(mob/user as mob)
		return

	attackby(obj/item/W, mob/user)
		if (!iswrenchingtool(W))
			..()//Add ID swipe

	proc/update_dir(var/u, var/d, var/l, var/r)
		up = u
		down = d
		left = l
		right = r
		update_icon()
		return

///Clears the overlays then add newones
	proc/update_icon()
		overlays = null
		if(up)
			overlays += "+u"
		if(down)
			overlays += "+d"
		if(left)
			overlays += "+l"
		if(right)
			overlays += "+r"
		return

///This will check tiles based upon the udlr vars to see if we have pipes/nodes to connect to
	proc/build()
		if(parent)//We have a pipeline, don't need to go looking
			return

		if(up)
			var/turf/T = get_step(get_turf(src.loc), 1)//Take a step
			if(locate(var/obj/machinery/atmos/A) in T)
				if(istype(A, /obj/machinery/atmos/pipe))//Found a pipe
					var/obj/machinery/atmos/pipe/P = A
					if(P.parent)//Do you have a line?
						P.parent.add_pipe(src)

				else if(istype(A, /obj/machinery/atmos/node))//Found a node
					var/obj/machinery/atmos/node/N = A
					if(N.up)
						if(N.up.parent)
							N.up.parent.add_pipe(src)
					if(N.down)
						if(N.down.parent)
							N.down.parent.add_pipe(src)
					if(N.left)
						if(N.left.parent)
							N.left.parent.add_pipe(src)
					if(N.right)
						if(N.right.parent)
							N.right.parent.add_pipe(src)
					N.down = src

		if(down)
			var/turf/T = get_step(get_turf(src.loc), 2)//Take a step
			if(locate(var/obj/machinery/atmos/A) in T)
				if(istype(A, /obj/machinery/atmos/pipe))//Found a pipe
					var/obj/machinery/atmos/pipe/P = A
					if(P.parent)//Do you have a line?
						P.parent.add_pipe(src)

				else if(istype(A, /obj/machinery/atmos/node))//Found a node
					var/obj/machinery/atmos/node/N = A
					if(N.up)
						if(N.up.parent)
							N.up.parent.add_pipe(src)
					if(N.down)
						if(N.down.parent)
							N.down.parent.add_pipe(src)
					if(N.left)
						if(N.left.parent)
							N.left.parent.add_pipe(src)
					if(N.right)
						if(N.right.parent)
							N.right.parent.add_pipe(src)
					N.up = src

		if(left)
			var/turf/T = get_step(get_turf(src.loc), 4)//Take a step
			if(locate(var/obj/machinery/atmos/A) in T)
				if(istype(A, /obj/machinery/atmos/pipe))//Found a pipe
					var/obj/machinery/atmos/pipe/P = A
					if(P.parent)//Do you have a line?
						P.parent.add_pipe(src)

				else if(istype(A, /obj/machinery/atmos/node))//Found a node
					var/obj/machinery/atmos/node/N = A
					if(N.up)
						if(N.up.parent)
							N.up.parent.add_pipe(src)
					if(N.down)
						if(N.down.parent)
							N.down.parent.add_pipe(src)
					if(N.left)
						if(N.left.parent)
							N.left.parent.add_pipe(src)
					if(N.right)
						if(N.right.parent)
							N.right.parent.add_pipe(src)
					N.right = src

		if(right)
			var/turf/T = get_step(get_turf(src.loc), 8)//Take a step
			if(locate(var/obj/machinery/atmos/A) in T)
				if(istype(A, /obj/machinery/atmos/pipe))//Found a pipe
					var/obj/machinery/atmos/pipe/P = A
					if(P.parent)//Do you have a line?
						P.parent.add_pipe(src)

				else if(istype(A, /obj/machinery/atmos/node))//Found a node
					var/obj/machinery/atmos/node/N = A
					if(N.up)
						if(N.up.parent)
							N.up.parent.add_pipe(src)
					if(N.down)
						if(N.down.parent)
							N.down.parent.add_pipe(src)
					if(N.left)
						if(N.left.parent)
							N.left.parent.add_pipe(src)
					if(N.right)
						if(N.right.parent)
							N.right.parent.add_pipe(src)
					N.left = src

		if(!parent)
			parent = new/datum/atmos/pipeline()


