
#define PIPEC_MAIL "#8dc2f4"
#define PIPEC_BRIG "#ff6666"
#define PIPEC_EJECTION "#f2a673"
#define PIPEC_MORGUE "#696969"
#define PIPEC_FOOD "#fbed92"
#define PIPEC_PRODUCE "#b2ff4f"
#define PIPEC_TRANSPORT "#ffbef6"
#define PIPEC_MINERAL "#a5fffc"

// virtual disposal object
// travels through pipes in lieu of actual items
// contents will be items flushed by the disposal
// this allows the gas flushed to be tracked

/obj/disposalholder
	invisibility = 101
	var/datum/gas_mixture/gas = null	// gas used to flush, will appear at exit point
	var/active = 0	// true if the holder is moving, otherwise inactive
	dir = 0
	var/count = 1000	//*** can travel 1000 steps before going inactive (in case of loops)
	var/has_fat_guy = 0	// true if contains a fat person
	var/last_sound = 0

	var/slowed = 0 // when you move, slows you down

	var/mail_tag = null //Switching junctions with the same tag will pass it out the secondary instead of primary

	unpooled()
		..()
		gas = null
		active = 0
		dir = 0
		count = initial(count)
		has_fat_guy = 0
		last_sound = 0
		mail_tag = null

	pooled()
		gas = null
		active = 0
		dir = 0
		has_fat_guy = 0
		last_sound = 0
		mail_tag = null
		..()

	// initialize a holder from the contents of a disposal unit
	proc/init(var/obj/machinery/disposal/D)
		gas = D.air_contents.remove_ratio(1)	// transfer gas resv. into holder object

		// loc = null makes some stuff grumpy, ok?
		if(D.trunk)
			src.set_loc(D.trunk)
		else
			src.set_loc(D)

		// now everything inside the disposal gets put into the holder
		// note AM since can contain mobs or objs
		for(var/atom/movable/AM in D)
			AM.set_loc(src)
			if(ishuman(AM))
				var/mob/living/carbon/human/H = AM
				H.unlock_medal("It'sa me, Mario", 1)
				if(H.bioHolder.HasEffect("fat"))		// is a human and fat?
					has_fat_guy = 1			// set flag on holder



	// start the movement process
	// argument is the disposal unit the holder started in
	proc/start(var/obj/machinery/disposal/D)
		if(!D.trunk || D.trunk.loc != D.loc)
			D.expel(src)	// no trunk connected, so expel immediately
			return

		loc = D.trunk
		active = 1
		dir = DOWN
		SPAWN_DBG(1 DECI SECOND)
			process()		// spawn off the movement process

		return

	// movement process, persists while holder is moving through pipes
	proc/process()
		var/obj/disposalpipe/last
		while(active)
			if(has_fat_guy && prob(2)) // chance of becoming stuck per segment if contains a fat guy
				active = 0
				// find the fat guys
				for(var/mob/living/carbon/human/H in src)
					if(H.bioHolder.HasEffect("fat"))
						H.unlock_medal("Try jiggling the handle",1)

				break
			sleep(0.1 SECONDS)		// was 1
			if(slowed > 0)
				slowed--
				slowed = max(slowed,0)
				sleep(1 SECONDS)
			else
				if (!loc)
					return
				var/obj/disposalpipe/curr = loc
				last = curr
				curr = curr.transfer(src)
				if(!curr)
					last.expel(src, loc, dir)

				if(!(count--))
					active = 0
		return

	// find the turf which should contain the next pipe
	proc/nextloc()
		return get_step(loc,dir)

	// find a matching pipe on a turf
	proc/findpipe(var/turf/T)

		if(!T)
			return null

		var/fdir = turn(dir, 180)	// flip the movement direction
		for(var/obj/disposalpipe/P in T)
			if(fdir & P.dpdir)		// find pipe direction mask that matches flipped dir
				return P
		// if no matching pipe, return null
		return null

	// merge two holder objects
	// used when a a holder meets a stuck holder
	proc/merge(var/obj/disposalholder/other)
		for(var/atom/movable/AM in other)
			AM.set_loc(src)	// move everything in other holder to this one
		if(other.has_fat_guy)
			has_fat_guy = 1
		if(other.mail_tag && !src.mail_tag)
			src.mail_tag = other.mail_tag
		pool(other)


	// called when player tries to move while in a pipe
	relaymove(mob/user as mob)
		if (user.stat)
			return

		// drsingh: attempted fix for Cannot read null.loc
		if (src == null || src.loc == null || src.loc.loc == null)
			return

		for (var/mob/M in hearers(src.loc.loc))
			boutput(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>CLONG, clong!</FONT>")

		if(last_sound + 6 < world.time)
			playsound(src.loc, "sound/impact_sounds/Metal_Clang_1.ogg", 50, 0, 0)
			last_sound = world.time
			damage_pipe()
			if(prob(30))
				slowed++

	mob_flip_inside(var/mob/user)
		var/obj/disposalpipe/P = src.loc
		if(!istype(P))
			return
		user.show_text("<span class='alert'>You leap and slam against the inside of [P]! Ouch!</span>")
		user.changeStatus("paralysis", 40)
		user.changeStatus("weakened", 4 SECONDS)
		src.visible_message("<span class='alert'><b>[P]</b> emits a loud thump and rattles a bit.</span>")

		animate_storage_thump(P)

		user.show_text("<span class='alert'>[P] [pick("cracks","bends","shakes","groans")].</span>")
		damage_pipe(5)
		slowed++

	proc/damage_pipe(var/amount = 3)
		var/obj/disposalpipe/P = src.loc
		if(istype(P))
			P.health -= rand(1,amount)
			P.health = max(P.health,0)
			P.healthcheck()

	// called to vent all gas in holder to a location
	proc/vent_gas(var/atom/location)
		location.assume_air(gas)  // vent all gas to turf
		gas = null
		return

// Disposal pipes

/obj/disposalpipe
	icon = 'icons/obj/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	level = 1			// underfloor only
	var/dpdir = 0		// bitmask of pipe directions
	dir = 0				// dir will contain dominant direction for junction pipes
	var/health = 10 	// health points 0-10
	layer = DISPOSAL_PIPE_LAYER
	var/base_icon_state	// initial icon state on map
	var/list/mail_tag = null // Tag of mail group for switching pipes

	var/image/pipeimg = null

	// new pipe, set the icon_state as on map
	New()
		..()
		base_icon_state = icon_state
		pipeimg = image(src.icon, src.loc, src.icon_state, 3, dir)
		pipeimg.layer = OBJ_LAYER
		pipeimg.dir = dir
		return

	// pipe is deleted
	// ensure if holder is present, it is expelled
	disposing()
		var/obj/disposalholder/H = locate() in src
		if(H)
			// holder was present
			H.active = 0
			var/turf/T = get_turf(src)
			if(T && T.density)
				// deleting pipe is inside a dense turf (wall)
				// this is unlikely, but just dump out everything into the turf in case

				for(var/atom/movable/AM in H)
					AM.set_loc(T)
					AM.pipe_eject(0)
				H.dispose()
				..()
				return

			// otherswise, do normal expel from turf
			expel(H, T, 0)
		..()

	// returns the direction of the next pipe object, given the entrance dir
	// by default, returns the bitmask of remaining directions
	proc/nextdir(var/fromdir)
		return dpdir & (~turn(fromdir, 180))

	// transfer the holder through this pipe segment
	// overriden for special behaviour
	//
	proc/transfer(var/obj/disposalholder/H)
		var/nextdir = nextdir(H.dir)
		H.dir = nextdir
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P


	// update the icon_state to reflect hidden status
	proc/update()
		var/turf/T = src.loc
		if (T) hide(T.intact && !istype(T,/turf/space))	// space never hides pipes

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = intact ? 101: 0	// hide if floor is intact
		updateicon()

	// update actual icon_state depending on visibility
	// if invisible, set alpha to half the norm
	// this will be revealed if a T-scanner is used
	// if visible, use regular icon_state
	proc/updateicon()
		icon_state = base_icon_state
		alpha = invisibility ? 128 : 255
		return

	proc/fix_sprite()
		return

	// expel the held objects into a turf
	// called when there is a break in the pipe
	//

	proc/expel(var/obj/disposalholder/H, var/turf/T, var/direction)
		// oh dear, please stop ruining the machine loop with your invalid loc
		if (!T)
			return

		var/turf/target

		if(T.density)		// dense ouput turf, so stop holder
			H.active = 0
			H.set_loc(src)
			return
		if(T.intact && istype(T,/turf/simulated/floor)) //intact floor, pop the tile
			var/turf/simulated/floor/F = T
			//F.health	= 100
			F.burnt	= 1
			F.intact	= 0
			F.levelupdate()
			new /obj/item/tile/steel(H)	// add to holder so it will be thrown with other stuff
			F.icon_state = "[F.burnt ? "panelscorched" : "plating"]"

		if(direction)		// direction is specified
			if(istype(T, /turf/space)) // if ended in space, then range is unlimited
				target = get_edge_target_turf(T, direction)
			else						// otherwise limit to 10 tiles
				target = get_ranged_target_turf(T, direction, 10)

			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)
			for(var/atom/movable/AM in H)
				AM.set_loc(T)
				AM.pipe_eject(direction)
				SPAWN_DBG(1 DECI SECOND)
					if(AM)
						AM.throw_at(target, 100, 1)
			H.vent_gas(T)
			pool(H)

		else	// no specified direction, so throw in random direction

			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5)-rand(5), rand(5)-rand(5))

				AM.set_loc(T)
				AM.pipe_eject(0)
				SPAWN_DBG(1 DECI SECOND)
					if(AM)
						AM.throw_at(target, 5, 1)

			H.vent_gas(T)	// all gas vent to turf
			pool(H)

		return

	// call to break the pipe
	// will expel any holder inside at the time
	// then delete the pipe
	// remains : set to leave broken pipe pieces in place
	proc/broken(var/remains = 0)
		if(isrestrictedz(z))
			return
		if(remains)
			for(var/D in cardinal)
				if(D & dpdir)
					var/obj/disposalpipe/broken/P = new(src.loc)
					P.dir = D

		src.invisibility = 101	// make invisible (since we won't delete the pipe immediately)
		var/obj/disposalholder/H = locate() in src
		if(H)
			// holder was present
			H.active = 0
			var/turf/T = src.loc
			if(T.density)
				// broken pipe is inside a dense turf (wall)
				// this is unlikely, but just dump out everything into the turf in case

				for(var/atom/movable/AM in H)
					AM.set_loc(T)
					AM.pipe_eject(0)
				pool(H)
				return

			// otherswise, do normal expel from turf
			expel(H, T, 0)

		SPAWN_DBG(0.2 SECONDS)	// delete pipe after 2 ticks to ensure expel proc finished
			qdel(src)


	proc/disconnected_dirs()
		. = list()
		if(!src)
			return

		for(var/d in list(1, 2, 4, 8))
			if(!(d & src.dpdir))
				continue
			var/ok = 1
			for(var/obj/disposalpipe/D in get_step(get_turf(src), d))
				if(D) // already existing connection
					if(D.dpdir & get_dir(D, src)) //pipe points towards us
						ok = 0
						break
			if(ok)
				. += d


	// pipe affected by explosion
	ex_act(severity)

		switch(severity)
			if(1.0)
				broken(0)
				return
			if(2.0)
				health -= rand(5,15)
				healthcheck()
				return
			if(3.0)
				health -= rand(0,15)
				healthcheck()
				return


	// test health for brokenness
	proc/healthcheck()
		if(isrestrictedz(z))
			return
		if(health < -2)
			broken(0)
		else if(health<1)
			broken(1)
		return

	//attack by item
	//weldingtool: unfasten and convert to obj/disposalconstruct

	attackby(var/obj/item/I, var/mob/user)
		if (isrestrictedz(z))
			return
		var/turf/T = src.loc
		if (T.intact)
			return		// prevent interaction with T-scanner revealed pipes

		if (isweldingtool(I))
			if (I:try_weld(user, 3, noisy = 2))
				// check if anything changed over 2 seconds
				var/turf/uloc = user.loc
				var/atom/wloc = I.loc
				boutput(user, "You begin slicing [src].")
				sleep(0.1 SECONDS)
				if (user.loc == uloc && wloc == I.loc)
					welded(user)
				else
					boutput(user, "You must stay still while welding the pipe.")
					return

	// called when pipe is cut with welder
	proc/welded(var/user)

		var/obj/disposalconstruct/C = new (src.loc)
		switch(base_icon_state)
			if("pipe-s")
				C.ptype = 0
			if("pipe-c")
				C.ptype = 1
			if("pipe-j1")
				C.ptype = 2
			if("pipe-j2")
				C.ptype = 3
			if("pipe-y")
				C.ptype = 4
			if("pipe-t")
				C.ptype = 5
			if("pipe-sj1")
				C.ptype = 6
			if("pipe-sj2")
				C.ptype = 7

		if (user)
			boutput(user, "You finish slicing [C].")

		C.dir = dir
		C.mail_tag = src.mail_tag
		C.update()

		qdel(src)

// a straight or bent segment
/obj/disposalpipe/segment
	icon_state = "pipe-s"

	horizontal
		dir = EAST
	vertical
		dir = NORTH
	bent
		icon_state = "pipe-c"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	mail
		name = "mail pipe"
		desc = "An underfloor mail pipe."
		color = PIPEC_MAIL

		horizontal
			dir = EAST
		vertical
			dir = NORTH
		bent
			icon_state = "pipe-c"

			north
				dir = NORTH
			east
				dir = EAST
			south
				dir = SOUTH
			west
				dir = WEST
	brig
		name = "brig pipe"
		desc = "An underfloor brig pipe."
		color = PIPEC_BRIG

	ejection
		name = "ejection pipe"
		desc = "An underfloor ejection pipe."
		color = PIPEC_EJECTION

	morgue
		name = "morgue pipe"
		desc = "An underfloor morgue pipe."
		color = PIPEC_MORGUE

	food
		name = "food pipe"
		desc = "An underfloor food pipe."
		color = PIPEC_FOOD

	produce
		name = "produce pipe"
		desc = "An underfloor produce pipe."
		color = PIPEC_PRODUCE

	transport
		name = "transport pipe"
		desc = "An underfloor transport pipe."
		color = PIPEC_TRANSPORT

	mineral
		name = "mineral pipe"
		desc = "An underfloor mineral pipe."
		color = PIPEC_MINERAL

	New()
		..()
		if(icon_state == "pipe-s")
			dpdir = dir | turn(dir, 180)
		else
			dpdir = dir | turn(dir, -90)

		update()
		return

/obj/disposalpipe/segment/fix_sprite()
	if(turn(dir, 180) & dpdir)
		icon_state = "pipe-s"
	else
		icon_state = "pipe-c"
		for(var/d in list(1, 2, 4, 8))
			if((d | turn(d, -90)) == dpdir)
				dir = d
				break
	base_icon_state = icon_state
	src.update()

//a three-way junction with dir being the dominant direction
/obj/disposalpipe/junction
	icon_state = "pipe-j1"

	left
		name = "pipe junction"
		icon_state = "pipe-j1"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	right
		name = "pipe junction"
		icon_state = "pipe-j2"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	middle
		name = "pipe junction"
		icon_state = "pipe-y"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	New()
		..()
		if(icon_state == "pipe-j1")
			dpdir = dir | turn(dir, -90) | turn(dir,180)
		else if(icon_state == "pipe-j2")
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		else // pipe-y
			dpdir = dir | turn(dir,90) | turn(dir, -90)
		update()
		return

	fix_sprite()
		if(dpdir == (dir | turn(dir, 90) | turn(dir, 180)))
			icon_state = "pipe-j2"
		else if(dpdir == (dir | turn(dir, -90) | turn(dir, 180)))
			icon_state = "pipe-j1"
		else if(dpdir == (dir | turn(dir, -90) | turn(dir, 90)))
			icon_state = "pipe-y"
		base_icon_state = icon_state
		src.update()

	// next direction to move
	// if coming in from secondary dirs, then next is primary dir
	// if coming in from primary dir, then next is equal chance of other dirs

	nextdir(var/fromdir)
		var/flipdir = turn(fromdir, 180)
		if(flipdir != dir)	// came from secondary dir
			return dir		// so exit through primary
		else				// came from primary
							// so need to choose either secondary exit
			var/mask = ..(fromdir)

			// find a bit which is set
			var/setbit = 0
			if(mask & NORTH)
				setbit = NORTH
			else if(mask & SOUTH)
				setbit = SOUTH
			else if(mask & EAST)
				setbit = EAST
			else
				setbit = WEST

			if(prob(50))	// 50% chance to choose the found bit or the other one
				return setbit
			else
				return mask & (~setbit)

//A junction capable of switching output direction
/obj/disposalpipe/switch_junction
	name = "switching pipe"
	icon_state = "pipe-sj1"

	var/redirect_chance = 50
	var/switch_dir = 0 //Direction of secondary port
					//Same-tag holders are sent out this one.

	left
		name = "mail junction"
		icon_state = "pipe-sj1"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	right
		name = "mail junction"
		icon_state = "pipe-sj2"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	New()
		..()
		if(icon_state == "pipe-sj1")
			switch_dir = turn(dir, -90)
			dpdir = dir | switch_dir | turn(dir,180)
		else if(icon_state == "pipe-sj2")
			switch_dir = turn(dir, 90)
			dpdir = dir | turn(dir, 90) | turn(dir,180)
		else
			switch_dir = turn(dir, 90)
			dpdir = dir | turn(dir,90) | turn(dir, -90)
		update()

		if (src.mail_tag)
			if (islist(src.mail_tag))
				src.name = "mail junction (multiple destinations)"
			else
				src.name = "mail junction ([src.mail_tag])"
				src.mail_tag = params2list(src.mail_tag)
		return


	// next direction to move

	transfer(var/obj/disposalholder/H)
		var/same_group = 0
		if(src.mail_tag && (H.mail_tag in src.mail_tag))
			same_group = 1

		var/nextdir = nextdir(H.dir, same_group)
		H.dir = nextdir
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

	nextdir(var/fromdir, var/use_secondary)
		var/flipdir = turn(fromdir, 180)
		if(flipdir != dir)	// came from secondary or tertiary
			var/senddir = dir	//Do we send this out the primary or secondary?
			if(use_secondary && flipdir != switch_dir) //Oh, we're set to sort this out our side secondary
				flick("[base_icon_state]-on", src)
				senddir = switch_dir
			return senddir
		else				// came from primary
							// so need to choose either secondary exit
			var/mask = ..(fromdir)

			// find a bit which is set
			var/setbit = 0
			if(mask & NORTH)
				setbit = NORTH
			else if(mask & SOUTH)
				setbit = SOUTH
			else if(mask & EAST)
				setbit = EAST
			else
				setbit = WEST

			if(prob(redirect_chance))	// Adjustable chance to choose the found bit or the other one
				return setbit
			else
				return mask & (~setbit)

/obj/disposalpipe/switch_junction/biofilter
	name = "biofilter pipe"
	desc = "A pipe junction designed to redirect living organic tissue."
	redirect_chance = 0

	left
		icon_state = "pipe-sj1"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	right
		icon_state = "pipe-sj2"

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	transfer(var/obj/disposalholder/H)
		var/redirect = 0
		for (var/mob/living/carbon/C in H)
			if (!isdead(C))
				redirect = 1
				break

		var/nextdir = nextdir(H.dir, redirect)
		H.dir = nextdir
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

	welded()

		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = (src.icon_state == "pipe-sj1" ? 8 : 9)
		C.dir = dir
		C.mail_tag = src.mail_tag
		C.update()

		qdel(src)

/obj/disposalpipe/loafer
	name = "disciplinary loaf processor"
	desc = "A pipe segment designed to convert detritus into a nutritionally-complete meal for inmates."
	icon_state = "pipe-loaf0"
	var/nugget_mode = 0
	mats = 100
	is_syndicate = 1

	horizontal
		dir = EAST
	vertical
		dir = NORTH

	New()
		..()

		dpdir = dir | turn(dir, 180)
		update()

	was_built_from_frame(mob/user, newly_built)
		. = ..()
		dpdir = dir | turn(dir, 180)
		update()

	transfer(var/obj/disposalholder/H)

		if (H.contents.len)
			playsound(src.loc, "sound/machines/mixer.ogg", 50, 1)
			//src.visible_message("<b>[src] activates!</b>") // Processor + loop = SPAM
			src.icon_state = "pipe-loaf1"

			var/doSuperLoaf = 0
			for (var/atom/movable/O in H)
				if(O.name == "strangelet loaf")
					doSuperLoaf = 1
					break

			if(doSuperLoaf)
				for (var/atom/movable/O2 in H)
					if(ismob(O2))
						var/mob/M = O2
						M.ghostize()
					qdel(O2)
					H.contents -= O2
					O2 = null

				var/obj/item/reagent_containers/food/snacks/einstein_loaf/estein = new /obj/item/reagent_containers/food/snacks/einstein_loaf(src)
				estein.set_loc(H)
				goto StopLoafing

			if (nugget_mode)
				var/obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget/current_nugget
				var/list/new_nuggets = list()
				for (var/atom/movable/newIngredient in H)
					if(istype(newIngredient, /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget))
						continue
					if (!current_nugget)
						current_nugget = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget(src)
						new_nuggets += current_nugget

					current_nugget.name = "[newIngredient] nugget"
					current_nugget.desc = "A breaded wad of [newIngredient.name], far too processed to have a more specific label than 'nugget.'"

					if (isliving(newIngredient))
						playsound(src.loc, pick("sound/impact_sounds/Slimy_Splat_1.ogg","sound/impact_sounds/Liquid_Slosh_1.ogg","sound/impact_sounds/Wood_Hit_1.ogg","sound/impact_sounds/Slimy_Hit_3.ogg","sound/impact_sounds/Slimy_Hit_4.ogg","sound/impact_sounds/Flesh_Stab_1.ogg"), 50, 1)
						var/mob/living/poorSoul = newIngredient
						if (issilicon(poorSoul))
							current_nugget.reagents.add_reagent("oil",10)
							current_nugget.reagents.add_reagent("silicon",10)
							current_nugget.reagents.add_reagent("iron",10)
						else
							current_nugget.reagents.add_reagent("bloodc",10) // heh
							current_nugget.reagents.add_reagent("ectoplasm",10)

						if(!isdead(poorSoul))
							poorSoul:emote("scream")
						sleep(0.5 SECONDS)
						poorSoul.ghostize()

					if (newIngredient.reagents)
						var/anItem = isitem(newIngredient)
						while (newIngredient.reagents.total_volume > 0 || (anItem && newIngredient:w_class--))
							newIngredient.reagents.trans_to(current_nugget, current_nugget.reagents.maximum_volume)
							if (current_nugget.reagents.total_volume >= current_nugget.reagents.maximum_volume)
								current_nugget = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/nugget(src)

								current_nugget.name = "[newIngredient] nugget"
								current_nugget.desc = "A breaded wad of [newIngredient.name], far too processed to have a more specific label than 'nugget.'"

								new_nuggets += current_nugget

					qdel(newIngredient)
					H.contents -= newIngredient
					newIngredient = null
					LAGCHECK(LAG_MED)

				for (var/obj/O in new_nuggets)
					O.set_loc(H)
					LAGCHECK(LAG_MED)

			else
				var/obj/item/reagent_containers/food/snacks/prison_loaf/newLoaf = new /obj/item/reagent_containers/food/snacks/prison_loaf(src)

				for (var/atom/movable/newIngredient in H)

					LAGCHECK(LAG_MED)



					if (newIngredient.reagents)
						newIngredient.reagents.trans_to(newLoaf, 1000)

					if (istype(newIngredient, /obj/item/reagent_containers/food/snacks/prison_loaf))
						var/obj/item/reagent_containers/food/snacks/prison_loaf/otherLoaf = newIngredient
						newLoaf.loaf_factor += otherLoaf.loaf_factor * 1.2
						newLoaf.loaf_recursion = otherLoaf.loaf_recursion + 1
						otherLoaf = null

					else if (isliving(newIngredient))
						playsound(src.loc, pick("sound/impact_sounds/Slimy_Splat_1.ogg","sound/impact_sounds/Liquid_Slosh_1.ogg","sound/impact_sounds/Wood_Hit_1.ogg","sound/impact_sounds/Slimy_Hit_3.ogg","sound/impact_sounds/Slimy_Hit_4.ogg","sound/impact_sounds/Flesh_Stab_1.ogg"), 50, 1)
						var/mob/living/poorSoul = newIngredient
						if (issilicon(poorSoul))
							newLoaf.reagents.add_reagent("oil",10)
							newLoaf.reagents.add_reagent("silicon",10)
							newLoaf.reagents.add_reagent("iron",10)
						else
							newLoaf.reagents.add_reagent("bloodc",10) // heh
							newLoaf.reagents.add_reagent("ectoplasm",10)

						if(ishuman(newIngredient))
							newLoaf.loaf_factor += (newLoaf.loaf_factor / 5) + 50 // good god this is a weird value
						else
							newLoaf.loaf_factor += (newLoaf.loaf_factor / 10) + 50
						if(!isdead(poorSoul))
							poorSoul:emote("scream")
						sleep(0.5 SECONDS)
						poorSoul.death()
						if (poorSoul.mind || poorSoul.client)
							poorSoul.ghostize()
					else if (isitem(newIngredient))
						var/obj/item/I = newIngredient
						newLoaf.loaf_factor += I.w_class * 5
						I = null
					else
						newLoaf.loaf_factor++

					H.contents -= newIngredient
					newIngredient.loc = null
					newIngredient = null

					//LAGCHECK(LAG_MED)
					qdel(newIngredient)

				newLoaf.update()
				newLoaf.set_loc(H)

			StopLoafing:

			sleep(0.3 SECONDS)	//make a bunch of ongoing noise i guess?
			playsound(src.loc, pick("sound/machines/mixer.ogg","sound/machines/mixer.ogg","sound/machines/mixer.ogg","sound/machines/hiss.ogg","sound/machines/ding.ogg","sound/machines/buzz-sigh.ogg","sound/impact_sounds/Machinery_Break_1.ogg","sound/effects/pop.ogg","sound/machines/warning-buzzer.ogg","sound/impact_sounds/Glass_Shatter_1.ogg","sound/impact_sounds/Flesh_Break_2.ogg","sound/effects/spring.ogg","sound/machines/engine_grump1.ogg","sound/machines/engine_grump2.ogg","sound/machines/engine_grump3.ogg","sound/impact_sounds/Glass_Hit_1.ogg","sound/effects/bubbles.ogg","sound/effects/brrp.ogg"), 50, 1)
			sleep(0.3 SECONDS)

			playsound(src.loc, "sound/machines/engine_grump1.ogg", 50, 1)
			sleep(3 SECONDS)
			src.icon_state = "pipe-loaf0"
			//src.visible_message("<b>[src] deactivates!</b>") // Processor + loop = SPAM

		var/nextdir = nextdir(H.dir)
		H.dir = nextdir
		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

	welded()

		/*var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = 10
		C.dir = dir
		C.update()

		qdel(src)*/

		src.visible_message("<span class='alert'>[src] emits a weird noise!</span>")

		src.nugget_mode = !src.nugget_mode
		src.update()
		return

	update()
		..()
		if (nugget_mode)
			src.name = "disciplinary nugget processor"
		else
			src.name = initial(src.name)

#define MAXIMUM_LOAF_STATE_VALUE 10

/obj/item/reagent_containers/food/snacks/einstein_loaf
	name = "einstein-rosen loaf"
	desc = "A hypothetical feature of loaf-spacetime. Maybe this could be used as a material?"
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "eloaf"
	force = 0
	throwforce = 0

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		src.reagents.add_reagent("liquid spacetime",11)
		src.setMaterial(getMaterial("negativematter"), appearance = 0, setname = 0)

/obj/item/reagent_containers/food/snacks/prison_loaf
	name = "prison loaf"
	desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
	icon = 'icons/obj/foodNdrink/food_meals.dmi'
	icon_state = "ploaf0"
	force = 0
	throwforce = 0
	var/loaf_factor = 1
	var/loaf_recursion = 1
	var/processing = 0

	New()
		..()
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		src.reagents.add_reagent("gravy",10)
		src.reagents.add_reagent("refried_beans",10)
		src.reagents.add_reagent("fakecheese",10)
		src.reagents.add_reagent("silicate",10)
		src.reagents.add_reagent("space_fungus",3)
		src.reagents.add_reagent("synthflesh",10)
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	proc/update()
		var/orderOfLoafitude = max( 0, min( round( log(8, loaf_factor)), MAXIMUM_LOAF_STATE_VALUE ) )
		//src.icon_state = "ploaf[orderOfLoafitude]"

		src.w_class = min(orderOfLoafitude+1, 4)

		switch ( orderOfLoafitude )

			if (1)
				src.name = "prison loaf"
				src.desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
				src.icon_state = "ploaf0"
				src.force = 0
				src.throwforce = 0

			if (2)
				src.name = "dense prison loaf"
				src.desc = "The chef must be really packing a lot of junk into these things today."
				src.icon_state = "ploaf0"
				src.force = 3
				src.throwforce = 3
				src.reagents.add_reagent("beff",25)

			if (3)
				src.name = "extra dense prison loaf"
				src.desc = "Good lord, this thing feels almost like a brick. A brick made of kitchen scraps and god knows what else."
				src.icon_state = "ploaf0"
				src.force = 6
				src.throwforce = 6
				src.reagents.add_reagent("porktonium",25)

			if (4)
				src.name = "super-compressed prison loaf"
				src.desc = "Hard enough to scratch a diamond, yet still somehow edible, this loaf seems to be emitting decay heat. Dear god."
				src.icon_state = "ploaf1"
				src.force = 11
				src.throwforce = 11
				src.throw_range = 6
				src.reagents.add_reagent("thalmerite",25)

			if (5)
				src.name = "fissile loaf"
				src.desc = "There's so much junk packed into this loaf, the flavor atoms are starting to go fissile. This might make a decent engine fuel, but it definitely wouldn't be good for you to eat."
				src.icon_state = "ploaf2"
				src.force = 22
				src.throwforce = 22
				src.throw_range = 5
				src.reagents.add_reagent("uranium",25)

			if (6)
				src.name = "fusion loaf"
				src.desc = "Forget fission, the flavor atoms in this loaf are so densely packed now that they are undergoing atomic fusion. What terrifying new flavor atoms might lurk within?"
				src.icon_state = "ploaf3"
				src.force = 44
				src.throwforce = 44
				src.throw_range = 4
				src.reagents.add_reagent("radium",25)

			if (7)
				src.name = "neutron loaf"
				src.desc = "Oh good, the flavor atoms in this prison loaf have collapsed down to a a solid lump of neutrons."
				src.icon_state = "ploaf4"
				src.force = 66
				src.throwforce = 66
				src.throw_range = 3
				src.reagents.add_reagent("polonium",25)

			if (8)
				src.name = "quark loaf"
				src.desc = "This nutritional loaf is collapsing into subatomic flavor particles. It is unfathmomably heavy."
				src.icon_state = "ploaf5"
				src.force = 88
				src.throwforce = 88
				src.throw_range = 2
				src.reagents.add_reagent("george_melonium",25)

			if (9)
				src.name = "degenerate loaf"
				src.desc = "You should probably call a physicist."
				src.icon_state = "ploaf6"
				src.force = 110
				src.throwforce = 110
				src.throw_range = 1
				src.reagents.add_reagent("george_melonium",50)

			if (10)
				src.name = "strangelet loaf"
				src.desc = "You should probably call a priest."
				src.icon_state = "ploaf7"
				src.force = 220
				src.throwforce = 220
				src.throw_range = 0
				src.reagents.add_reagent("george_melonium",100)

				if (!src.processing)
					src.processing = 1

				/*SPAWN_DBG(rand(100,1000))
					if(src)
						src.visible_message("<span class='alert'><b>[src] collapses into a black hole! Holy fuck!</b></span>")
						world << sound("sound/effects/kaboom.ogg")
						new /obj/bhole(get_turf(src.loc))*/


		return

	process()
		if(!src.processing)
			return
		if(src.loc == get_turf(src))
			var/edge = get_edge_target_turf(src, pick(alldirs))
			SPAWN_DBG(0)
				src.throw_at(edge, 100, 1)
		if (istype(src.loc,/obj/))
			if (prob(33))
				var/obj/container = src.loc
				container.visible_message("<span class='alert'><b>[container]</b> emits a loud thump and rattles a bit.</span>")
				if (istype(container, /obj/storage) && prob(33))
					var/obj/storage/C = container
					if (C.can_flip_bust == 1)
						boutput(src, "<span class='alert'>[C] [pick("cracks","bends","shakes","groans")].</span>")
						C.bust_out()


#undef MAXIMUM_LOAF_STATE_VALUE

/obj/disposalpipe/mechanics_switch
	icon_state = "pipe-mech0"
	var/active = 0
	var/switch_dir = 0

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		mechanics = new(src)
		mechanics.master = src
		mechanics.addInput("toggle", "toggleactivation")
		mechanics.addInput("on", "activate")
		mechanics.addInput("off", "deactivate")

		SPAWN_DBG (10)
			switch_dir = turn(dir, 90)
			dpdir = dir | switch_dir | turn(dir,180)

		update()

	nextdir(var/fromdir)
		//var/flipdir = turn(fromdir, 180)
		if(fromdir & turn(switch_dir, 180))	// came in the wrong way
			return dpdir & (prob(50) ? dir : turn(dir, 180))//turn(switch_dir, prob(50) ? -90 : 90)

		else
			if (active)
				return switch_dir

			else
				return fromdir

	updateicon()
		icon_state = "pipe-mech[active]"//[invisibility ? "f" : null]"
		alpha = invisibility ? 128 : 255
		return

	proc/toggleactivation()
		src.active = !src.active
		updateicon()

	proc/activate()
		src.active = 1
		updateicon()

	proc/deactivate()
		src.active = 0
		updateicon()

	welded()
		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = 11
		C.dir = dir
		C.update()

		if (src.mechanics)
			src.mechanics.wipeIncoming()
			src.mechanics.wipeOutgoing()

		qdel(src)

//<Jewel>:
//Tried to rework biofilter to create a new disposalholder and send bio one way and normal objects the other. It doesn't work.
//Check back on the pipe code later. It needs some kinda revamp in the future.

/*/obj/disposalpipe/switch_junction/biofilter
	name = "biofilter pipe"
	desc = "A pipe junction designed to redirect living organic tissue."
	redirect_chance = 0

	var/obj/disposalholder/bioHolder = new()

	transfer(var/obj/disposalholder/origHolder)
		for (var/mob/living/carbon/C in origHolder)
			if (!isdead(C))
				C.set_loc(bioHolder)

		var/otherdir = nextdir(origHolder.dir, 0)
		var/biodir = nextdir(origHolder.dir, 1)

		origHolder.dir = otherdir
		bioHolder.dir = biodir

		var/turf/nonBioTurf = origHolder.nextloc()
		var/turf/bioTurf = bioHolder.nextloc()

		var/obj/disposalpipe/nonBioPipe = origHolder.findpipe(nonBioTurf)
		var/obj/disposalpipe/bioPipe = bioHolder.findpipe(bioTurf)

		if (nonBioPipe)
			var/obj/disposalholder/newHolder = locate() in nonBioPipe
			if(newHolder && !newHolder.active)
				origHolder.merge(newHolder)

			origHolder.set_loc(nonBioPipe)

			boutput(world, "I found a non bio pipe at [nonBioPipe.loc] with [origHolder.loc]")

		if (bioPipe)
			var/obj/disposalholder/newHolderBio = locate() in bioPipe
			if (newHolderBio && !newHolderBio.active)
				bioHolder.merge(newHolderBio)

			bioHolder.set_loc(bioPipe)

			boutput(world, "I found a bio pipe at [bioPipe.loc] with [bioHolder.loc]")

		bioHolder.active = 1
		bioHolder.dir = biodir
		SPAWN_DBG(1 DECI SECOND)
			bioHolder.process()

		return nonBioPipe

	welded()
		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = (src.icon_state == "pipe-sj1" ? 8 : 9)
		C.dir = dir
		C.mail_tag = src.mail_tag
		C.update()

		qdel(src)*/

/obj/disposalpipe/block_sensing_outlet
	name = "smart disposal outlet"
	desc = "A disposal outlet with a little sonar sensor on the front, so it only dumps contents if it is unblocked."
	icon_state = "unblockoutlet"
	anchored = 1
	density = 1
	var/turf/stuff_chucking_target

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		dpdir = dir | turn(dir, 270) | turn(dir, 90)
		SPAWN_DBG (1)
			stuff_chucking_target = get_ranged_target_turf(src, dir, 1)

	welded()
		return

	transfer(var/obj/disposalholder/H)
		var/allowDump = 1

		for (var/atom/movable/blockingJerk in get_step(src, src.dir))
			if (blockingJerk.density)
				allowDump = 0
				break

		if (allowDump)
			flick("unblockoutlet-open", src)
			playsound(src, "sound/machines/warning-buzzer.ogg", 50, 0, 0)

			sleep(2 SECONDS)	//wait until correct animation frame
			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)


			for(var/atom/movable/AM in H)
				AM.set_loc(src.loc)
				AM.pipe_eject(dir)
				SPAWN_DBG(1 DECI SECOND)
					AM.throw_at(stuff_chucking_target, 3, 1)
			H.vent_gas(src.loc)
			pool(H)

			return null

		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

/obj/disposalpipe/type_sensing_outlet
	name = "filter disposal outlet"
	desc = "A disposal outlet with a little sensor in it, to allow it to filter out unwanted things from the system."
	icon_state = "unblockoutlet"
	var/turf/stuff_chucking_target
	var/list/allowed_types = list()

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		dpdir = dir | turn(dir, 270) | turn(dir, 90)
		SPAWN_DBG (1)
			stuff_chucking_target = get_ranged_target_turf(src, dir, 1)

	welded()
		return

	transfer(var/obj/disposalholder/H)
		var/list/things_to_dump = list()

		for (var/atom/movable/A in H)
			var/dump_this = 1
			for (var/thing in src.allowed_types)
				if (ispath(thing) && istype(A, thing))
					dump_this = 0
					break
			if (dump_this)
				things_to_dump += A

		if (things_to_dump.len)
			flick("unblockoutlet-open", src)
			playsound(src, "sound/machines/warning-buzzer.ogg", 50, 0, 0)

			sleep(2 SECONDS)	//wait until correct animation frame
			playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)

			for (var/atom/movable/AM in things_to_dump)
				AM.set_loc(src.loc)
				AM.pipe_eject(dir)
				SPAWN_DBG(1 DECI SECOND)
					AM.throw_at(stuff_chucking_target, 3, 1)
			if (H.contents.len < 1)
				H.vent_gas(src.loc)
				pool(H)
				return null

		var/turf/T = H.nextloc()
		var/obj/disposalpipe/P = H.findpipe(T)

		if(P)
			// find other holder in next loc, if inactive merge it with current
			var/obj/disposalholder/H2 = locate() in P
			if(H2 && !H2.active)
				H.merge(H2)

			H.set_loc(P)
		else			// if wasn't a pipe, then set loc to turf
			H.set_loc(T)
			return null

		return P

/obj/disposalpipe/type_sensing_outlet/drone_factory
	allowed_types = list(/obj/item/ghostdrone_assembly)

#define SENSE_LIVING 1
#define SENSE_OBJECT 2
#define SENSE_TAG 3

/obj/disposalpipe/mechanics_sensor
	name = "Sensor pipe"
	icon_state = "pipe-mechsense"
	var/sense_mode = SENSE_OBJECT
	var/sense_tag_filter = ""

	horizontal
		dir = EAST
	vertical
		dir = NORTH

	New()
		..()

		mechanics = new(src)
		mechanics.master = src

		dpdir = dir | turn(dir, 180)

		update()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return
		else if(ispulsingtool(W))
			. = alert(usr, "What should trigger the sensor?","Disposal Sensor", "Creatures", "Anything", "A mail tag")
			if (.)
				if (get_dist(usr, src) > 1 || usr.stat)
					return

				switch (.)
					if ("Creatures")
						sense_mode = SENSE_LIVING

					if ("Anything")
						sense_mode = SENSE_OBJECT

					if ("A mail tag")
						. = copytext(ckeyEx(input(usr, "What should the tag be?", "What?")), 1, 33)
						if (. && get_dist(usr, src) < 2 && !usr.stat)
							sense_mode = SENSE_TAG
							sense_tag_filter = .

	MouseDrop(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)

		if(!isliving(usr))
			return

		if(istype(O, /obj/item/mechanics) && O.level == 2)
			boutput(usr, "<span class='alert'>[O] needs to be secured into place before it can be connected.</span>")
			return

		if(usr.stat)
			return

		if (!usr.find_tool_in_hand(TOOL_PULSING))
			boutput(usr, "<span class='alert'>[MECHFAILSTRING]</span>")
			return

		mechanics.dropConnect(O, null, src_location, control_orig, control_new, params)
		return ..()

	transfer(var/obj/disposalholder/H)
		if (sense_mode == SENSE_TAG)
			if (cmptext(H.mail_tag, sense_tag_filter))
				mechanics.fireOutgoing(mechanics.newSignal(ckey(H.mail_tag)))
				flick("pipe-mechsense-detect", src)

		else if (sense_mode == SENSE_OBJECT)
			if (H.contents.len)
				mechanics.fireOutgoing(mechanics.newSignal("1"))
				flick("pipe-mechsense-detect", src)

		else
			for (var/atom/aThing in H)
				if (sense_mode == SENSE_LIVING)
					if (istype(aThing, /obj/critter) || isliving(aThing))
						if (isliving(aThing))
							var/mob/living/M = aThing
							if (isdead(M))
								continue

						mechanics.fireOutgoing(mechanics.newSignal("1"))
						flick("pipe-mechsense-detect", src)
						break

		return ..()

	welded()
		var/obj/disposalconstruct/C = new (src.loc)
		C.ptype = 12
		C.dir = dir
		C.update()

		if (src.mechanics)
			src.mechanics.wipeIncoming()
			src.mechanics.wipeOutgoing()

		qdel(src)

#undef SENSE_LIVING
#undef SENSE_OBJECT
#undef SENSE_TAG

//a trunk joining to a disposal bin or outlet on the same turf
/obj/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	// the linked obj/machinery/disposal or obj/disposaloutlet

	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	mail
		name = "mail pipe"
		desc = "An underfloor mail pipe."
		color = PIPEC_MAIL

		north
			dir = NORTH
		east
			dir = EAST
		south
			dir = SOUTH
		west
			dir = WEST

	brig
		name = "brig pipe"
		desc = "An underfloor brig pipe."
		color = PIPEC_BRIG

	ejection
		name = "ejection pipe"
		desc = "An underfloor ejection pipe."
		color = PIPEC_EJECTION

	morgue
		name = "morgue pipe"
		desc = "An underfloor morgue pipe."
		color = PIPEC_MORGUE

	food
		name = "food pipe"
		desc = "An underfloor food pipe."
		color = PIPEC_FOOD

	produce
		name = "produce pipe"
		desc = "An underfloor produce pipe."
		color = PIPEC_PRODUCE

	transport
		name = "transport pipe"
		desc = "An underfloor transport pipe."
		color = PIPEC_TRANSPORT

	mineral
		name = "mineral pipe"
		desc = "An underfloor mineral pipe."
		color = PIPEC_MINERAL

	New()
		..()
		dpdir = dir
		SPAWN_DBG(1 DECI SECOND)
			getlinked()

		update()
		return

	disposing()
		if (linked && istype(linked, /obj/machinery/disposal))
			var/obj/machinery/disposal/D = linked
			D.trunk = null
			D = null
		linked = null
		..()

	proc/getlinked()
		linked = null
		var/obj/machinery/disposal/D = locate() in src.loc
		if(D)
			linked = D

		var/obj/disposaloutlet/O = locate() in src.loc
		if(O)
			linked = O

		update()
		return

	// would transfer to next pipe segment, but we are in a trunk
	// if not entering from disposal bin,
	// transfer to linked object (outlet or bin)

	transfer(var/obj/disposalholder/H)

		if(H.dir == DOWN)		// we just entered from a disposer
			return ..()		// so do base transfer proc
		// otherwise, go to the linked object
		if(linked)
			var/obj/disposaloutlet/O = linked
			if(istype(O))
				O.expel(H)	// expel at outlet
			else
				var/obj/machinery/disposal/D = linked
				D.expel(H)	// expel at disposal
		else
			src.expel(H, src.loc, 0)	// expel at turf
		return null

	// nextdir

	nextdir(var/fromdir)
		if(fromdir == DOWN)
			return dir
		else
			return 0

// a broken pipe
/obj/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0		// broken pipes have dpdir=0 so they're not found as 'real' pipes
					// i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

	New()
		..()
		update()
		return

	// called when welded
	// for broken pipe, remove and turn into scrap

	welded()
		var/obj/item/scrap/S = new(src.loc)
		S.set_components(200,0,0)
		qdel(src)

// the disposal outlet machine

/obj/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	// this will be where the output objects are 'thrown' to.
	mats = 12

	var/message = null
	var/mailgroup = null
	var/mailgroup2 = null
	var/net_id = null
	var/frequency = 1149
	var/datum/radio_frequency/radio_connection

	ex_act(var/severity)
		switch(severity)
			if(1)
				qdel(src)
			if(2)
				if(prob(50))
					qdel(src)
			if(3)
				if(prob(25))
					qdel(src)
	north
		dir = NORTH
	east
		dir = EAST
	south
		dir = SOUTH
	west
		dir = WEST

	New()
		..()

		SPAWN_DBG(1 DECI SECOND)
			target = get_ranged_target_turf(src, dir, 10)
		SPAWN_DBG(0.8 SECONDS)
			if(radio_controller)
				radio_connection = radio_controller.add_object(src, "[frequency]")
			if(!src.net_id)
				src.net_id = generate_net_id(src)

	disposing()
		var/obj/disposalpipe/trunk/trunk = locate() in src.loc
		if (trunk && trunk.linked == src)
			trunk.linked = null
		trunk = null

		radio_controller.remove_object(src, "[frequency]")
		..()

	// expel the contents of the holder object, then delete it
	// called when the holder exits the outlet
	proc/expel(var/obj/disposalholder/H)
		if (message && mailgroup && radio_connection)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CHUTE-MAILBOT"
			newsignal.data["message"] = "[message]"

			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = mailgroup
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

		if (message && mailgroup2 && radio_connection)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CHUTE-MAILBOT"
			newsignal.data["message"] = "[message]"

			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = mailgroup2
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

		flick("outlet-open", src)
		playsound(src, "sound/machines/warning-buzzer.ogg", 50, 0, 0)

		sleep(2 SECONDS)	//wait until correct animation frame
		playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)


		for(var/atom/movable/AM in H)
			AM.set_loc(src.loc)
			AM.pipe_eject(dir)
			SPAWN_DBG(1 DECI SECOND)
				AM.throw_at(target, src.throw_range, 1)
		H.vent_gas(src.loc)
		pool(H)

		return

// called when movable is expelled from a disposal pipe or outlet
// by default does nothing, override for special behaviour

/atom/movable/proc/pipe_eject(var/direction)
	return

// check if mob has client, if so restore client view on eject
/mob/pipe_eject(var/direction)
	src.changeStatus("weakened", 2 SECONDS)
	return

/obj/decal/cleanable/blood/gibs/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)

/obj/decal/cleanable/robot_debris/gib/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	src.streak(dirs)




/obj/disposaloutlet/artifact

	expel(var/obj/disposalholder/H)
		if (message && mailgroup && radio_connection)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CHUTE-MAILBOT"
			newsignal.data["message"] = "[message]"

			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = mailgroup
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

		if (message && mailgroup2 && radio_connection)
			var/datum/signal/newsignal = get_free_signal()
			newsignal.source = src
			newsignal.transmission_method = TRANSMISSION_RADIO
			newsignal.data["command"] = "text_message"
			newsignal.data["sender_name"] = "CHUTE-MAILBOT"
			newsignal.data["message"] = "[message]"

			newsignal.data["address_1"] = "00000000"
			newsignal.data["group"] = mailgroup2
			newsignal.data["sender"] = src.net_id

			radio_connection.post_signal(src, newsignal)

		flick("outlet-open", src)
		playsound(src, "sound/machines/warning-buzzer.ogg", 50, 0, 0)

		sleep(2 SECONDS)	//wait until correct animation frame
		playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)


		for(var/atom/movable/AM in H)
			AM.set_loc(src.loc)
			AM.pipe_eject(dir)
			SPAWN_DBG(1 DECI SECOND)
				AM.throw_at(target, 10, 10) //This is literally the only thing that was changed in this, otherwise it booted them way too close.
		H.vent_gas(src.loc)
		pool(H)

		return
// -------------------- VR --------------------
/obj/disposaloutlet/virtual
	name = "gauntlet outlet"
	desc = "For disposing of pixel junk, one would suppose."
	icon = 'icons/effects/VR.dmi'
// --------------------------------------------

// takes a pipe and changes one of its disconnected directions to new_dir, or makes a junction if all are connected and make_junctions=1
proc/pipe_reconnect_disconnected(var/obj/disposalpipe/pipe, var/new_dir, var/make_junctions=0)
	var/list/avail_dirs = pipe.disconnected_dirs()
	for(var/x in avail_dirs)
	if(!avail_dirs.len && !(new_dir & pipe.dpdir))
		if(!make_junctions)
			return
		if(istype(pipe, /obj/disposalpipe/trunk))
			var/obj/disposalpipe/segment/segment = new(pipe.loc)
			segment.dpdir = pipe.dpdir | new_dir
			segment.dir = new_dir
			qdel(pipe)
			segment.fix_sprite()
		else if(istype(pipe, /obj/disposalpipe/junction))
			var/obj/disposalpipe/segment/horiz = new(pipe.loc)
			horiz.dpdir = 1 | 2
			horiz.dir = 1
			horiz.fix_sprite()
			var/obj/disposalpipe/segment/vert = new(pipe.loc)
			vert.dpdir = 4 | 8
			vert.dir = 4
			vert.fix_sprite()
			qdel(pipe)
		if(istype(pipe, /obj/disposalpipe/segment))
			var/obj/disposalpipe/junction/junction = new(pipe.loc)
			junction.dpdir = pipe.dpdir | new_dir
			junction.dir = new_dir
			qdel(pipe)
			junction.fix_sprite()
		return
	else if(!(new_dir & pipe.dpdir))
		for(var/d in list(new_dir, turn(new_dir, 90), turn(new_dir, 270), turn(new_dir, 180)))
			if(d in avail_dirs)
				pipe.dpdir &= ~d
				pipe.dpdir |= new_dir
				if(!(pipe.dir & pipe.dpdir)) // if we lost our dir
					pipe.dir = new_dir
				break
	pipe.fix_sprite()
