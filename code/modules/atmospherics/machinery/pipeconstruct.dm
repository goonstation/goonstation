/obj/item/pipeconstruct
	name = "Pipe Construct"
	desc = "Some item you place down for making pipes"

	var/obj/machinery/atmospherics/typetoplace
	var/pipedir

/obj/item/pipeconstruct/New(var/loc, var/obj/machinery/atmospherics/parentobj)
	..()
	src.name = 	"[parentobj.name] construct"
	src.typetoplace = parentobj.type
	src.icon = parentobj.icon
	src.icon_state = initial(parentobj.icon_state)
	src.pipedir = parentobj.dir
	src.dir = parentobj.dir
	src.color = parentobj.color


/obj/item/pipeconstruct/attack_self(mob/user)
	pipedir = turn(pipedir, 90)
	dir = pipedir

/obj/item/pipeconstruct/attackby(obj/item/W, mob/user, params)
	if(isweldingtool(W))
		var/obj/machinery/atmospherics/thingtoplace = new typetoplace(src.loc, src.pipedir)
		for(var/obj/machinery/atmospherics/target in thingtoplace.loc)
			if(target == thingtoplace)
				continue
			if(target.initialize_directions & thingtoplace.initialize_directions)
				boutput(user, "<b><span class='alert'>Something is hogging that direction!</span></b>")
				qdel(thingtoplace)
				return
		if(!W:try_weld(user, 2, noisy=2))
			return
		thingtoplace.color = src.color
		thingtoplace.initialize()
		thingtoplace.mergewithedges()
		thingtoplace.UpdateIcon()

		qdel(src)

/obj/item/pipeconstruct/dropped(mob/user)
	..()
	dir = pipedir //i like my pipes looking correct

