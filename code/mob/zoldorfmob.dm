TYPEINFO(/mob/zoldorf)
	start_listen_modifiers = list(LISTEN_MODIFIER_MOB_MODIFIERS)
	start_listen_inputs = list(LISTEN_INPUT_EARS_GHOST, LISTEN_INPUT_GLOBAL_HEARING_GHOST, LISTEN_INPUT_GLOBAL_HEARING_LOCAL_COUNTERPART_GHOST)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = null
	start_speech_outputs = null

//Zoldorf Player Mob
/mob/zoldorf
	name = "Zoldorf"
	desc = "Spooky light ball!"
	icon = 'icons/obj/zoldorf.dmi'
	icon_state = "zolsoulgrey"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	event_handler_flags = IMMUNE_MANTA_PUSH | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	density = 0
	canmove = 0
	blinded = 0
	anchored = ANCHORED
	alpha = 180
	default_speech_output_channel = null
	can_use_say = FALSE

	var/autofree = 0
	var/firstfortune = 1
	var/free = 0
	var/fortunemessage
	var/obj/machinery/playerzoldorf/homebooth
	var/soulcolor
	var/emoting

	New(var/mob/M)
		..()
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_GHOST)
		src.abilityHolder = new /datum/abilityHolder/zoldorf(src)
		src.sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		src.see_invisible = INVIS_GHOST
		src.see_in_dark = SEE_DARK_FULL
		src.flags |= UNCRUSHABLE

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
		spawn(0)
			src.show_antag_popup("souldorf")

	Login()
		..()
		src.updateButtons()

	is_spacefaring()
		return 1

	Life(parent)
		if (..(parent))
			return 1

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
		if((target in range(0,src))&&(istype(target,/obj/item/reagent_containers/food/snacks/ectoplasm))&&(src.invisibility > INVIS_NONE))
			if(src.emoting)
				return
			src.visible_message(SPAN_NOTICE("<b>[src.name] rolls around in the ectoplasm, making their soul visible!</b>"))
			if (prob(50))
				animate_spin(src, "R", 1, 0)
			else
				animate_spin(src, "L", 1, 0)
			src.UpdateOverlays(image('icons/obj/zoldorf.dmi',"ectooverlay"),"ecto")
			REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
			qdel(target)
		else
			src.examine_verb(target)

	Cross(atom/movable/mover)
		return 1

	Move(NewLoc, direct) //just a copy paste from ghost move // YEAH IT SURE FUCKING IS
		if(!canmove) return

		if (!can_ghost_be_here(src, NewLoc))
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

		. = ..()

	is_active()
		return 0

	can_use_hands()
		return 0

	put_in_hand(obj/item/I, hand)
		return 0

	equipped()
		return 0

	emote(var/act, var/voluntary) //souldorf emotes!
		if(!src.free)
			return
		if(src.emoting)
			return
		..()
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
						APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_GHOST)
						src.ClearAllOverlays()
						var/obj/item/reagent_containers/food/snacks/ectoplasm/e = new /obj/item/reagent_containers/food/snacks/ectoplasm
						e.set_loc(get_turf(src))
			if("fart")
				src.visible_message("<span><b>[src.name]</b> flies in a figure 8!</span>")
				src.emoting = 1
				soulcache = src.icon
				if(!src.invisibility)
					src.visible_message(SPAN_ALERT("<b>The ectoplasm falls off! Oh no!</b>"))
					APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_GHOST)
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
		. = ..()
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
				src.visible_message(SPAN_ALERT("<b>Poof!</b>"))
				src.gib(1)
				return
		var/obj/machinery/playerzoldorf/pz = src.loc
		src.visible_message(SPAN_ALERT("<b>Poof!</b>"))
		src.free()
		src.set_loc(get_turf(src.loc))
		pz.remove_simple_light("zoldorf")

	stopObserving()
		if(src.homebooth)
			src.set_loc(homebooth)
		else
			src.ghostize()
		src.observing = null

/mob/proc/make_zoldorf(var/obj/machinery/playerzoldorf/pz) //ok this is a little weird, but its the other portion of the booth proc that handles the mob-side things and some of the booth things that need to be set before the original player is deleted
	if (src.mind || src.client)
		logTheThing(LOG_COMBAT, src, "was turned into Zoldorf at [log_loc(src)].")
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
			Z.mind.ckey = ckey
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
		logTheThing(LOG_ADMIN, usr, "made [constructTarget(src,"admin")] a zoldorf.")
		return make_zoldorf()
	return null

/client/MouseDrop(var/over_object, var/src_location, var/over_location) //handling click dragging of items within one tile of a zoldorf booth.
	..()
	var/mob/zoldorf/user = usr
	if(!istype(user,/mob/zoldorf))
		return
	var/turf/Tb = get_turf(over_location)
	var/turf/Ta = get_turf(src_location)

	if(!Tb || !Ta || Ta.density || Tb.density)
		return

	if(istype(over_object,/obj/item) && istype(user.loc,/obj/machinery/playerzoldorf))
		var/obj/item/i = over_object
		if(i.anchored)
			return
		var/obj/machinery/playerzoldorf/pz = user.loc
		if((i in range(1,user.loc)) && (Tb in range(1,Ta)))
			if(!pz.GetOverlayImage("fortunetelling"))
				pz.UpdateOverlays(image('icons/obj/zoldorf.dmi',"fortunetelling"),"fortunetelling")
				SPAWN(0.6 SECONDS)
					if(pz)
						pz.ClearSpecificOverlays("fortunetelling")
			if((istype(i,/obj/item/paper/thermal/playerfortune)) && (Ta == get_turf(user.loc)))
				var/obj/item/paper/thermal/playerfortune/fi = i
				fi.icon = 'icons/obj/zoldorf.dmi'
				fi.icon_state = "fortuneburn"
				sleep(0.8 SECONDS)
				qdel(fi)
			else
				i.set_loc(Ta)
