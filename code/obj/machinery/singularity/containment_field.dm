
/obj/machinery/containment_field
	name = "containment field"
	desc = "An energy field."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "Contain_F"
	pass_unstable = TRUE
	anchored = ANCHORED
	density = 1
	event_handler_flags = USE_FLUID_ENTER | IMMUNE_SINGULARITY | IMMUNE_TRENCH_WARP
	var/active = 1
	var/power = 10
	var/delay = 5
	var/last_active
	var/mob/U
	var/obj/machinery/field_generator/gen_primary
	var/obj/machinery/field_generator/gen_secondary
	var/datum/light/light

/obj/machinery/containment_field/New(var/obj/machinery/field_generator/A, var/obj/machinery/field_generator/B)
	src.gen_primary = A
	src.gen_secondary = B
	light = new /datum/light/point
	light.set_brightness(0.7)
	light.set_color(0, 0.1, 0.8)
	light.attach(src)
	light.enable()

	..()

/obj/machinery/containment_field/disposing()
	src.gen_primary = null
	src.gen_secondary = null
	..()

/obj/machinery/containment_field/ex_act(severity)
	return

/obj/machinery/containment_field/attack_hand(mob/user)
	return

/obj/machinery/containment_field/process()
	if(isnull(gen_primary)||isnull(gen_secondary))
		qdel(src)
		return

	if(!(gen_primary.active)||!(gen_secondary.active))
		qdel(src)
		return

/obj/machinery/containment_field/proc/shock(mob/user as mob)
	if(isnull(gen_primary) || isnull(gen_secondary))
		qdel(src)
		return

	elecflash(user)

	src.power = max(gen_primary.power,gen_secondary.power)

	var/prot = 1
	var/shock_damage = 0
	if(src.power > 200)
		shock_damage = min(rand(40,80),rand(40,100))*prot
	else if(src.power > 120)
		shock_damage = min(rand(30,60),rand(30,90))*prot
	else if(src.power > 80)
		shock_damage = min(rand(20,40),rand(20,40))*prot
	else if(src.power > 60)
		shock_damage = min(rand(20,30),rand(20,30))*prot
	else
		shock_damage = min(rand(10,20),rand(10,20))*prot

	// Added (Convair880).
	logTheThing(LOG_COMBAT, user, "was shocked by a containment field at [log_loc(src)] and received [shock_damage] damage.")

	if (user?.bioHolder)
		if (user.bioHolder.HasEffect("resist_electric_heal"))
			var/healing = 0
			if (shock_damage)
				healing = shock_damage / 3
			user.HealDamage("All", shock_damage, shock_damage)
			user.take_toxin_damage(0 - healing)
			boutput(user, SPAN_NOTICE("You absorb the electrical shock, healing your body!"))
			return
		else if (user.bioHolder.HasEffect("resist_electric"))
			boutput(user, SPAN_NOTICE("You feel electricity course through you harmlessly!"))
			return

	user.TakeDamage(user.hand == LEFT_HAND ? "l_arm" : "r_arm", 0, shock_damage)
	boutput(user, SPAN_ALERT("<B>You feel a powerful shock course through your body!</B>"))
	user.unlock_medal("HIGH VOLTAGE", 1)
	if (isliving(user))
		var/mob/living/L = user
		L.Virus_ShockCure(100)
		L.shock_cyberheart(100)
	if(user.getStatusDuration("stunned") < shock_damage * 10)	user.changeStatus("stunned", shock_damage/4 SECONDS)
	if(user.getStatusDuration("knockdown") < shock_damage * 10)	user.changeStatus("knockdown", shock_damage/4 SECONDS)

	if(user.get_burn_damage() >= 500) //This person has way too much BURN, they've probably been shocked a lot! Let's destroy them!
		user.visible_message(SPAN_ALERT("<b>[user.name] was disintegrated by the [src.name]!</b>"))
		logTheThing(LOG_COMBAT, user, "was elecgibbed by [src] ([src.type]) at [log_loc(user)].")
		user.elecgib()
		return
	else
		src.field_throw(user)

	src.gen_primary.power -= 3
	src.gen_secondary.power -= 3
	return

/obj/machinery/containment_field/proc/field_throw(mob/user)
	var/throwdir = get_dir(src, get_step_away(user, src))
	if (get_turf(user) == get_turf(src))
		if (prob(50))
			throwdir = turn(throwdir,90)
		else
			throwdir = turn(throwdir,-90)
	var/atom/target = get_edge_target_turf(user, throwdir)
	user.throw_at(target, 200, 4)
	playsound(src, 'sound/effects/elec_bzzz.ogg', 25, 1, -1)
	user.visible_message(SPAN_ALERT("[user.name] is repelled by \the [src]!"), SPAN_ALERT("You're repelled by \the [src]!"), SPAN_ALERT("You hear a heavy electrical crack!"))

/obj/machinery/containment_field/Bumped(atom/O)
	. = ..()
	if(iscarbon(O))
		shock(O)
	else if (issilicon(O))
		src.field_throw(O)

/obj/machinery/containment_field/Cross(atom/movable/mover)
	. = ..()
	if(prob(10))
		. = TRUE

/obj/machinery/containment_field/Crossed(atom/movable/AM)
	. = ..()
	if(iscarbon(AM))
		shock(AM)
	else if (issilicon(AM))
		src.field_throw(AM)
