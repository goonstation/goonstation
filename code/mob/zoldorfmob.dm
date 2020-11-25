//Zoldorf Player Mob
/mob/zoldorf
	name = "Zoldorf"
	desc = "Spooky light ball!"
	icon = 'icons/obj/zoldorf.dmi'
	icon_state = "zolsoulgrey"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	event_handler_flags = IMMUNE_MANTA_PUSH
	density = 0
	canmove = 0
	blinded = 0
	anchored = 1
	alpha = 180
	stat = 0
	suicide_can_succumb = 0
	var/autofree = 0
	var/firstfortune = 1
	var/free = 0
	var/fortunemessage
	var/obj/machinery/playerzoldorf/homebooth
	var/soulcolor
	var/emoting

	New(var/mob/M)
		..()
		src.invisibility = 10
		src.abilityHolder = new /datum/abilityHolder/zoldorf(src)
		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.see_invisible = 16
		src.see_in_dark = SEE_DARK_FULL

	proc/addAbility(var/abilityType)
		abilityHolder.addAbility(abilityType)

	proc/addAllAbilities()
		src.addAbility(/datum/targetable/zoldorfAbility/fortune)
		src.addAbility(/datum/targetable/zoldorfAbility/omen)
		src.addAbility(/datum/targetable/zoldorfAbility/medium)
		src.addAbility(/datum/targetable/zoldorfAbility/brand)
		src.addAbility(/datum/targetable/zoldorfAbility/astral)
		src.addAbility(/datum/targetable/zoldorfAbility/notes)
		src.addAbility(/datum/targetable/zoldorfAbility/manifest)
		src.addAbility(/datum/targetable/zoldorfAbility/seance)
		src.addAbility(/datum/targetable/zoldorfAbility/jar)

		//debug stuffs
		//src.addAbility(/datum/targetable/zoldorfAbility/addsoul)
		//src.addAbility(/datum/targetable/zoldorfAbility/removesoul)

	proc/removeAbility(var/abilityType)
		abilityHolder.removeAbility(abilityType)

	proc/removeAllAbilities()
		src.removeAbility(/datum/targetable/zoldorfAbility/fortune)
		src.removeAbility(/datum/targetable/zoldorfAbility/omen)
		src.removeAbility(/datum/targetable/zoldorfAbility/medium)
		src.removeAbility(/datum/targetable/zoldorfAbility/brand)
		src.removeAbility(/datum/targetable/zoldorfAbility/astral)
		src.removeAbility(/datum/targetable/zoldorfAbility/notes)
		src.removeAbility(/datum/targetable/zoldorfAbility/manifest)
		src.removeAbility(/datum/targetable/zoldorfAbility/seance)
		src.removeAbility(/datum/targetable/zoldorfAbility/jar)

		//debug stuffs
		//src.removeAbility(/datum/targetable/zoldorfAbility/addsoul)
		//src.removeAbility(/datum/targetable/zoldorfAbility/removesoul)

	proc/updateButtons()
		abilityHolder.updateButtons()

	proc/getAbility(var/abilityType)
		return abilityHolder.getAbility(abilityType)

	proc/free() //since making two mobs would be pretty redundant. zoldorf mobs have two states. free and unfree. freed = souldorf, unfree = zoldorf
		src.free = 1 //this proc handles the transforming of a zoldorf into a souldorf
		src.canmove = 1
		setdead(src)

		if(src.homebooth) //this mainly prepares the booth for a new zoldorf and sets up the souldorf stuffs
			if(src.homebooth.initialsoul != 0)
				src.homebooth.partialsouls -= src.homebooth.initialsoul
			else
				src.homebooth.storedsouls-- //players add their soul to the booth when becoming a zoldorf and remove it from the booth when theyre ejected (flavor!)
			if(src.homebooth.storedsouls < 0)
				src.homebooth.storedsouls = 0
			if(src.homebooth.partialsouls < 0)
				src.homebooth.partialsouls = 0
			src.abilityHolder.points = 0
			src.abilityHolder.locked = 0
			src.homebooth.occupied = 0
			src.homebooth.UpdateOverlays(null,"player",1)
			if(!src.homebooth.usurping)
				src.homebooth.name = "Vacant Booth"
			src.homebooth.brandlist.Add(src)

			src.homebooth = null
		src.set_loc(get_turf(src.loc))

		src.removeAllAbilities()
		src.addAbility(/datum/targetable/zoldorfAbility/color)

		the_zoldorf = list()

		src << browse(grabResource("html/traitorTips/souldorfTips.htm"),"window=antagTips;titlebar=1;size=600x400;can_minimize=0;can_resize=0")

	Login()
		..()
		src.updateButtons()

	is_spacefaring()
		return 1

	Life(parent)
		if (..(parent))
			return 1

		if (src.client)
			src.antagonist_overlay_refresh(0, 0)

		if (!src.abilityHolder)
			src.abilityHolder = new /datum/abilityHolder/zoldorf(src)

		else if (src.health < src.max_health)
			src.health++

	ex_act(severity) //exploding. is. illegal.
		return

	meteorhit()
		return

	set_loc(var/a) //this pretty much covers any situation in which a zoldorf would need to be emergency free'd or teleported back to their booth (i.e. player is gibbed while being observed through astral projection)
		if((!src.free) && (!istype(a,/mob) && !istype(a,/obj/machinery/playerzoldorf)))
			if(src.autofree == 0)
				return
			if(src.homebooth)
				src.set_loc(homebooth)
				return
			else
				src.free()
				return
		else
			..()

	click(atom/target) //handles ectoplasm coating and examine clicks
		. = ..()
		if (. == 100)
			return 100
		if((target in range(0,src))&&(istype(target,/obj/item/reagent_containers/food/snacks/ectoplasm))&&(src.invisibility > 0))
			if(src.emoting)
				return
			src.visible_message("<span class='notice'><b>[src.name] rolls around in the ectoplasm, making their soul visible!</b></span>")
			if (prob(50))
				animate_spin(src, "R", 1, 0)
			else
				animate_spin(src, "L", 1, 0)
			src.UpdateOverlays(image('icons/obj/zoldorf.dmi',"ectooverlay"),"ecto")
			src.invisibility = 0
			qdel(target)
		else
			src.examine_verb(target)

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		return 1

	say_understands(var/other)

		if (isAI(other))
			return 1

		if (ishuman(other))
			var/mob/living/carbon/human/H = other
			if (!H.mutantrace || !H.mutantrace.exclusive_language)
				return 1
			else
				return 0

		if (isrobot(other) || isshell(other))
			return 1
		return ..()

	Move(NewLoc, direct) //just a copy paste from ghost move
		if(!canmove) return

		if (NewLoc && isrestrictedz(src.z) && !restricted_z_allowed(src, NewLoc) && !(src.client && src.client.holder))
			var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (OS)
				src.set_loc(OS)
			else
				src.z = 1
			return

		if (!isturf(src.loc))
			src.set_loc(get_turf(src))
		if (NewLoc)
			src.set_dir(get_dir(loc, NewLoc))
			src.set_loc(NewLoc)
			return

		src.set_dir(direct)
		if((direct & NORTH) && src.y < world.maxy)
			src.y++
		if((direct & SOUTH) && src.y > 1)
			src.y--
		if((direct & EAST) && src.x < world.maxx)
			src.x++
		if((direct & WEST) && src.x > 1)
			src.x--

	is_active()
		return 0

	can_use_hands()
		return 0

	put_in_hand(obj/item/I, hand)
		return 0

	equipped()
		return 0

	say(var/message)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		if(free)
			if (dd_hasprefix(message, "*"))
				return src.emote(copytext(message, 2),1)

			logTheThing("diary", src, null, "[src.name] - [src.real_name]: [message]", "say")

			if (src.client && src.client.ismuted())
				boutput(src, "You are currently muted and may not speak.")
				return

			. = src.say_dead(message, 1)
		else if(message)
			return

	emote(var/act, var/voluntary) //souldorf emotes!
		if(!src.free)
			return
		if(src.emoting)
			return
		var/icon/soulcache
		var/icon/blendic
		switch (lowertext(act))
			if("flip")
				if(invisibility)
					if(src.emote_check(voluntary, 100, 1, 0))
						src.visible_message("<span><b>[src.name]</b> spins in place!</span>")
						if (prob(50))
							animate_spin(src, "R", 1, 0)
						else
							animate_spin(src, "L", 1, 0)
				else
					if(src.emote_check(voluntary, 100, 1, 0))

						src.visible_message("<span><b>[src.name]</b> shakes off the ectoplasm!</span>")
						var/wiggle = 6
						while(wiggle > 0)
							wiggle--
							src.pixel_x = rand(-3,3)
							src.pixel_y = rand(-3,3)
							sleep(0.1 SECONDS)
						src.pixel_x = 0
						src.pixel_y = 0
						src.invisibility = 10
						src.ClearAllOverlays()
						var/obj/item/reagent_containers/food/snacks/ectoplasm/e = new /obj/item/reagent_containers/food/snacks/ectoplasm
						e.set_loc(get_turf(src))
			if("fart")
				src.visible_message("<span><b>[src.name]</b> flies in a figure 8!</span>")
				src.emoting = 1
				soulcache = src.icon
				if(!src.invisibility)
					src.visible_message("<span class='alert'><b>The ectoplasm falls off! Oh no!</b></span>")
					src.invisibility = 10
					src.ClearAllOverlays()
					var/obj/item/reagent_containers/food/snacks/ectoplasm/e = new /obj/item/reagent_containers/food/snacks/ectoplasm
					e.set_loc(get_turf(src))
				blendic = new /icon('icons/obj/zoldorf.dmi',"figure8")
				if(src.soulcolor)
					blendic.Blend("[soulcolor]",ICON_MULTIPLY)
				src.icon = blendic
				sleep(22.5)
				src.icon = soulcache
				src.emoting = 0
			if("scream")
				if(src.emote_check(voluntary, 100, 1, 0))
					src.visible_message("<span><b>[src.name]</b> vibrates mid-air...</span>")
					var/wiggle = 6
					while(wiggle > 0)
						wiggle--
						src.pixel_x = rand(-2,2)
						src.pixel_y = rand(-2,2)
						sleep(0.1 SECONDS)
					src.pixel_x = 0
					src.pixel_y = 0

	death(gibbed)
		var/mob/dead/observer/o = src.ghostize()

		if(o.client)
			o.apply_looks_of(o.client)
		qdel(src)

	do_suicide() //Poof!
		if(!src.free)
			the_zoldorf = list()
		if(!istype(src.loc,(/obj/machinery/playerzoldorf)))
			if(src.homebooth)
				src.set_loc(homebooth)
			else
				src.visible_message("<span class='alert'><b>Poof!</b></span>")
				src.gib(1)
				return
		var/obj/machinery/playerzoldorf/pz = src.loc
		src.visible_message("<span class='alert'><b>Poof!</b></span>")
		src.free()
		src.set_loc(get_turf(src.loc))
		pz.remove_simple_light("zoldorf")

/mob/proc/make_zoldorf(var/obj/machinery/playerzoldorf/pz) //ok this is a little weird, but its the other portion of the booth proc that handles the mob-side things and some of the booth things that need to be set before the original player is deleted
	if (src.mind || src.client)
		var/mob/zoldorf/Z = new/mob/zoldorf(get_turf(src))

		var/turf/T = get_turf(src)
		if (!(T && isturf(T)) || ((isrestrictedz(T.z) || T.z != 1) && !(src.client && src.client.holder)))
			var/OS = pick_landmark(LANDMARK_OBSERVER, locate(1, 1, 1))
			if (OS)
				Z.set_loc(OS)
			else
				Z.z = 1
		else
			Z.set_loc(T)

		if (src.mind)
			src.mind.transfer_to(Z)
		else
			var/key = src.client.key
			if (src.client)
				src.client.mob = Z
			Z.mind = new /datum/mind()
			Z.mind.key = key
			Z.mind.current = Z
			ticker.minds += Z.mind

		var/namestring
		var/lastchar
		var/period

		for(var/i=1, i<=length(src.real_name), i++)
			if(src.real_name[i] != " ")
				lastchar = src.real_name[i]
				namestring += src.real_name[i]
			else
				if((lastchar == "d") || (lastchar == "D"))
					i--
					namestring = copytext(namestring,1,length(namestring))
				else if(lastchar == ".")
					period = 1
				break
		if(period)
			namestring += " Dorf"
		else
			namestring +="dorf"
		Z.real_name = src.real_name

		qdel(src)

		pz.name = namestring
		Z.name = namestring
		if(Z.mind && Z.mind.soul)
			if(Z.mind.soul >= 100)
				Z.abilityHolder.points = pz.storedsouls+1
				pz.storedsouls += 1
			else if(Z.mind.soul < 100)
				pz.partialsouls += Z.mind.soul
				pz.initialsoul = Z.mind.soul
		Z.addAllAbilities()
		return Z
	return null

/mob/proc/zoldize()
	if (src.mind || src.client)
		message_admins("[key_name(usr)] made [key_name(src)] a zoldorf.")
		logTheThing("admin", usr, src, "made [constructTarget(src,"admin")] a zoldorf.")
		return make_zoldorf()
	return null

/client/MouseDrop(var/over_object, var/src_location, var/over_location, mob/user as mob) //handling click dragging of items within one tile of a zoldorf booth.
	..()
	if(!istype(usr,/mob/zoldorf))
		return
	var/turf/Tb = get_turf(over_location)
	var/turf/Ta = get_turf(src_location)

	if(!Tb || !Ta || Ta.density || Tb.density)
		return

	if(istype(over_object,/obj/item) && istype(usr.loc,/obj/machinery/playerzoldorf))
		var/obj/item/i = over_object
		var/obj/machinery/playerzoldorf/pz = usr.loc
		if((i in range(1,usr.loc)) && (Tb in range(1,Ta)))
			if(!pz.GetOverlayImage("fortunetelling"))
				pz.UpdateOverlays(image('icons/obj/zoldorf.dmi',"fortunetelling"),"fortunetelling")
				spawn(6)
					if(pz)
						pz.ClearSpecificOverlays("fortunetelling")
			if((istype(i,/obj/item/paper/thermal/playerfortune)) && (Ta == get_turf(usr.loc)))
				var/obj/item/paper/thermal/playerfortune/fi = i
				fi.icon = 'icons/obj/zoldorf.dmi'
				fi.icon_state = "fortuneburn"
				sleep(0.8 SECONDS)
				qdel(fi)
			else
				i.set_loc(Ta)
