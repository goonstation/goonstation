TYPEINFO(/obj/machinery/gibber)
	mats = 15

/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/mob/occupant // Mob who has been put inside
	var/atom/movable/proxy // a proxy object containing the occupant in its vis_contents for easier manipulation
	var/output_direction = WEST // Spray gibs and meat in that direction.
	var/list/meat_grinding_sounds = list('sound/impact_sounds/Flesh_Crush_1.ogg', 'sound/impact_sounds/Flesh_Tear_1.ogg', 'sound/impact_sounds/Flesh_Tear_2.ogg', 'sound/impact_sounds/Flesh_Tear_3.ogg')
	var/machine_startup_sound = 'sound/machines/tractorrev.ogg'
	var/machine_shutdown_sound = 'sound/machines/tractor_running3.ogg'
	var/rotor_sound = 'sound/machines/lavamoon_rotors_fast_short.ogg'
	deconstruct_flags =  DECON_WRENCH | DECON_WELDER

	output_north
		output_direction = NORTH
	output_east
		output_direction = EAST
	output_west
		output_direction = WEST
	output_south
		output_direction = SOUTH

/obj/machinery/gibber/New()
	..()
	UnsubscribeProcess()

/obj/machinery/gibber/disposing()
	if(proxy)
		src.vis_contents -= proxy
		qdel(proxy)
		src.proxy = null
	if(src.occupant)
		src.occupant.set_loc(get_turf(src))
		src.occupant = null
	. = ..()

/obj/machinery/gibber/custom_suicide = 1
/obj/machinery/gibber/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if(src.occupant)
		user.visible_message("<span class='alert'><b>[user] tries to climb on top of the gibber but someone's already there!</b></span>")
		return 0
	if (user.client)
		user.visible_message("<span class='alert'><b>[user] climbs on top of the gibber!</b></span>")
		enter_gibber(user)
		src.startgibbing(user)
		return 1

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user)
	if(operating)
		boutput(user, "<span class='alert'>It's locked and running</span>")
		return
	else
		src.startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/grab/G, mob/user)
	if(src.occupant)
		boutput(user, "<span class='alert'>The gibber is full, empty it first!</span>")
		return
	if (!(istype(G, /obj/item/grab)) || !ishuman(G.affecting))
		boutput(user, "<span class='alert'>This item is not suitable for the gibber!</span>")
		return
	if (!isdead(G.affecting))
		boutput(user, "<span class='alert'>[G.affecting.name] needs to be dead first!</span>")
		return
	user.visible_message("<span class='alert'>[user] starts to put [G.affecting] onto the gibber!</span>")
	src.add_fingerprint(user)
	SETUP_GENERIC_ACTIONBAR(user, src, 3 SECONDS, /obj/machinery/gibber/proc/gibber_action, list(G, user), 'icons/mob/screen1.dmi', "grabbed", null, null)

/obj/machinery/gibber/proc/gibber_action(obj/item/grab/G as obj, mob/user as mob)
	if(G?.affecting && (BOUNDS_DIST(user, src) == 0))
		user.visible_message("<span class='alert'>[user] shoves [G.affecting] on top of the gibber!</span>")
		logTheThing(LOG_COMBAT, user, "forced [constructTarget(G.affecting,"combat")] into a gibber at [log_loc(src)].")
		var/mob/M = G.affecting
		enter_gibber(M)
		qdel(G)

/obj/machinery/gibber/proc/enter_gibber(var/mob/entering_mob)
	entering_mob.set_loc(src)
	src.occupant = entering_mob
	entering_mob.set_dir(SOUTH)
	var/atom/movable/proxy = new
	proxy.mouse_opacity = FALSE
	src.proxy = proxy
	proxy.appearance = entering_mob.appearance
	proxy.transform = null
	src.proxy.pixel_x = 0
	src.proxy.pixel_y = 24
	proxy.add_filter("grinder_mask", 1, alpha_mask_filter(x=0, y=-16, icon=icon('icons/obj/kitchen_grinder_mask.dmi', "grinder-mask")))
	src.vis_contents += proxy

/obj/machinery/gibber/verb/eject()
	set src in oview(1)
	set category = "Local"

	if (!isalive(usr) || iswraith(usr)) return
	if (src.operating) return
	src.vis_contents -= proxy
	qdel(proxy)
	src.proxy = null
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	if (!src.occupant)
		return
	if(src.proxy)
		src.vis_contents -= src.proxy
		qdel(src.proxy)
		src.proxy = null
	for(var/obj/O in src)
		O.set_loc(src.loc)
	src.occupant.set_loc(src.loc)
	src.occupant = null
	return


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		boutput(user, "<span class='alert'>Nothing is loaded inside.</span>")
		return
	else
		var/bdna = null // For forensics (Convair880).
		var/btype = null

		user.visible_message("<span class='alert'>[user] presses a button on the [src]. Its engines begin to rev up!</span>",
				"<span class='alert'>You press the button on the [src]. The engines rev up.</span>")
		src.operating = 1
		src.icon_state = "grinder-on"

		var/decomp = 0
		if(ishuman(src.occupant))
			decomp = src.occupant:decomp_stage

			bdna = src.occupant.bioHolder.Uid // Ditto (Convair880).
			btype = src.occupant.bioHolder.bloodType

		if(user != src.occupant) //for suiciding with gibber
			logTheThing(LOG_COMBAT, user, "grinds [constructTarget(src.occupant,"combat")] in a gibber at [log_loc(src)].")
			if(src.occupant.client)
				message_admins("[key_name(src.occupant, 1)] is ground up in a gibber by [key_name(user)] at [log_loc(src)].")
		src.occupant.death(TRUE)

		if (src.occupant.mind)
			src.occupant.ghostize()

		var/dispense_direction = get_edge_target_turf(src, output_direction)

		src.dirty += 1

		animate(proxy, pixel_y = -8, time = 70)
		animate(proxy.get_filter("grinder_mask"), y = 32, time = 105, flags=ANIMATION_PARALLEL)

		playsound(src.loc, machine_startup_sound, 80, 1)
		sleep(1.5 SECONDS)
		if(src.disposed)
			return
		playsound(src.loc, rotor_sound, 80, 1)
		for(var/i = 1, i < 10; i++)
			if(src.disposed)
				return
			if(i % 3 == 0) // alternate between dispensing meat or gibs
				var/atom/movable/generated_meat = generate_meat(src.occupant, decomp, get_turf(src))
				generated_meat.throw_at(dispense_direction, rand(1,4), 3, throw_type = THROW_NORMAL)
			else
				var/obj/decal/cleanable/blood/gibs/mess = new /obj/decal/cleanable/blood/gibs(get_turf(src))
				if (bdna && btype)
					mess.blood_DNA = bdna
					mess.blood_type = btype
				mess.throw_at(dispense_direction, rand(1,3), 3, throw_type = THROW_NORMAL)

			playsound(src.loc, pick(meat_grinding_sounds), 80, 1)
			if(i % 2 == 0)
				playsound(src.loc, rotor_sound, 80, 1)
			sleep(0.8 SECONDS)
		if(src.disposed)
			return
		icon_state = "grinder"
		playsound(src.loc, machine_shutdown_sound, 80, 1)
		src.vis_contents -= src.proxy
		qdel(src.occupant)
		qdel(src.proxy)
		src.occupant = null
		src.proxy = null

		if (src.dirty == 1)
			src.overlays += image('icons/obj/kitchen.dmi', "grbloody")

		src.operating = 0

/obj/machinery/gibber/proc/generate_meat(var/mob/meat_source, var/decomposed_level, var/spawn_location)
	var/obj/item/reagent_containers/food/snacks/ingredient/meat/generated_meat
	if (ischangeling(meat_source))
		generated_meat = new /obj/item/reagent_containers/food/snacks/ingredient/meat/mysterymeat/changeling(spawn_location)
	else
		if(decomposed_level < 3) // fresh or fresh enough
			generated_meat = new /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat(spawn_location, meat_source)
		else // rotten yucky mess
			generated_meat = new /obj/item/reagent_containers/food/snacks/yuck(spawn_location)
			generated_meat.name = (meat_source.disfigured ? meat_source.real_name : "Unknown") + " meat-related substance"

	return generated_meat
