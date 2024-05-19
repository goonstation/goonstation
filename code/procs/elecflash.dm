

var/global/mutable_appearance/elecflash_ma = null

/proc/elecflash(var/atom/center, var/radius = 0, var/power=1, var/exclude_center = 1)//power 1 to 6
	if (!center || center.qdeled || center.disposed)
		return

	var/turf/center_turf = get_turf(center)
	if (!elecflash_ma)
		elecflash_ma = new
		elecflash_ma.name = "electricity"
		elecflash_ma.icon = 'icons/effects/electile.dmi'
		elecflash_ma.alpha = 255
		elecflash_ma.invisibility = INVIS_NONE
		elecflash_ma.layer = TURF_LAYER
		elecflash_ma.plane = PLANE_ABOVE_LIGHTING
		elecflash_ma.mouse_opacity = 0

	elecflash_ma.icon_state = "[power][pick("a","b","c")]"

	var/sound = null
	switch(power)
		if (1)
			sound = "sparks"
		if (2)
			sound = 'sound/effects/electric_shock_short.ogg'
		if (3,4)
			sound = 'sound/effects/electric_shock.ogg'
		else
			sound = 'sound/effects/elec_bzzz.ogg'
	var/atom/E = null

	var/list/chain_to = list()
	var/list/fluid_groups_touched = list()

	if (exclude_center) // copy paste its a little faster ok!
		for (var/turf/T in oview(radius,center_turf))
			if (T.active_liquid && T.active_liquid.group && radius + power > 1)
				if (!(T.active_liquid.group in fluid_groups_touched))
					fluid_groups_touched += T.active_liquid.group
					chain_to |= T.active_liquid.get_connected_fluid_members(power * 9.5 * (1-(T.active_liquid.group.avg_viscosity/T.active_liquid.group.max_viscosity)))
					playsound(T, sound, 50, TRUE)
			else
				chain_to += T
	else	// copy paste also!
		for (var/turf/T in view(radius,center_turf))
			if (T.active_liquid && T.active_liquid.group && radius + power > 1)
				if (!(T.active_liquid.group in fluid_groups_touched))
					fluid_groups_touched += T.active_liquid.group
					chain_to |= T.active_liquid.get_connected_fluid_members(power * 9.5 * (1-(T.active_liquid.group.avg_viscosity/T.active_liquid.group.max_viscosity)))
					playsound(T, sound, 50, TRUE)
			else
				chain_to += T

	if (radius <= 0)
		for (var/turf/T in oview(1,center_turf))
			if (prob(25))
				//copy paste
				if (T.active_liquid && T.active_liquid.group && radius + power > 1)
					if (!(T.active_liquid.group in fluid_groups_touched))
						fluid_groups_touched += T.active_liquid.group
						chain_to |= T.active_liquid.get_connected_fluid_members(power * 9.5 * (1-(T.active_liquid.group.avg_viscosity/T.active_liquid.group.max_viscosity)))
						playsound(T, sound, 50, TRUE)
				else
					chain_to += T
		if (length(chain_to) < 2)
			chain_to += get_step(center_turf,pick(alldirs)) //consider this an extra layer of randomness for when we dont jump to fluid


	var/turf/T = null


	var/matrix/M = matrix()
	M.Scale(0,0)

	var/list/elecs = list()
	for (var/x in chain_to)
		if(!x)
			continue
		T = x
		E = new/obj/overlay/tile_effect(T)
		E.appearance = elecflash_ma
		T.hotspot_expose(1000,100,usr, electric = power)
		elecs += E
		if (radius <= 0 && length(chain_to) < 8 && center_turf)
			E.pixel_x = (center_turf.x - E.x) * 32
			E.pixel_y = (center_turf.y - E.y) * 32
			animate(E, transform = M, pixel_x = rand(-32,32), pixel_y = rand(-32,32), time = (0.66 SECONDS) + (power * (0.12 SECONDS)), easing = CUBIC_EASING | EASE_OUT)
		else
			animate(E, alpha = 0, time = (0.6 SECONDS) + (power * (0.12 SECONDS)), easing = BOUNCE_EASING | EASE_IN)



	playsound(center_turf, sound, 50, TRUE)

	SPAWN(3 SECONDS)
		for(var/atom in elecs)
			var/atom/A = atom
			qdel(A)
		elecs.Cut()
		elecs = null
	chain_to = null
	fluid_groups_touched = null
//disorient + LIGHT burn

/atom/proc/electric_expose(var/power = 1)

/mob/living/electric_expose(var/power = 1)
	if (isintangible(src) || check_target_immunity(src))
		return
	if (power > 1) // pretty light damage and stam damage :)
		if (src.bioHolder?.HasEffect("resist_electric"))
			boutput(src, SPAN_NOTICE("You feel electricity spark across you harmlessly!"))
			return 0
		if (src.hasStatus("knockdown"))
			src.do_disorient(stamina_damage = 15 + power * 8, knockdown = 0, stunned = 0, unconscious = 0, disorient = (power * (0.5 SECONDS)), remove_stamina_below_zero = 0, target_type = DISORIENT_BODY)
		else
			src.do_disorient(stamina_damage = 15 + power * 8, knockdown = 1 SECONDS + (power * (0.1 SECONDS)), stunned = 0, unconscious = 0, disorient = (power * (0.5 SECONDS)), remove_stamina_below_zero = 0, target_type = DISORIENT_BODY)
		src.TakeDamage("chest", 0, rand(0,1) * power * 0.2, damage_type=DAMAGE_BURN)
		src.setStatus("defibbed", sqrt(power) SECONDS)
