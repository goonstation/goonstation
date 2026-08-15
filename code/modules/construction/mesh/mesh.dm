ABSTRACT_TYPE(/obj/mesh)
TYPEINFO(/obj/mesh)
	///Turfs this mesh will try to automatically connect to
	var/list/connects_to_turf = null
	///Objects this mesh will try to automatically connect to
	var/list/connects_to_obj = null
/obj/mesh
	provides_grip = TRUE
	anchored = ANCHORED
	flags = CONDUCT | USEDELAY
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = GRILLE_LAYER
	event_handler_flags = USE_FLUID_ENTER
	material_amt = 0.1

	var/health = 30
	var/health_max = 30
	///Has this mesh already been ruined?
	var/ruined = FALSE //Stop, stop, he's already dead!
	var/blunt_resist = 0
	var/cut_resist = 0
	var/corrode_resist = 0
	var/amount_of_rods_when_destroyed = 2
	///Prefix for icon state generation
	var/icon_state_prefix = ""
	///Automatically adjust sprite to connect with `connects_to_*` atoms
	var/auto_connect = TRUE

/obj/mesh/New()
	. = ..()
	START_TRACKING
	if(src.auto_connect)
		SPAWN(0) //fix for sometimes not joining on map load
			if (map_setting && ticker)
				src.update_neighbors()
			src.UpdateIcon()

/obj/mesh/disposing()
	STOP_TRACKING
	var/list/neighbors = null
	if (src.auto_connect && src.anchored && global.map_setting)
		neighbors = list()
		for(var/obj/mesh/neighbor in orange(1, src))
			neighbors += neighbor
	. = ..()
	for (var/obj/mesh/neighbor as anything in neighbors)
		neighbor?.UpdateIcon()

/obj/mesh/onMaterialChanged()
	. = ..()
	if (istype(src.material))
		health_max = material.getProperty("density") * 10
		health = health_max

		cut_resist = material.getProperty("hard") * 10
		blunt_resist = material.getProperty("density") * 5
		corrode_resist = material.getProperty("chemical") * 10

/obj/mesh/damage_blunt(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		if (amount >= health_max / 2)
			qdel(src)
		return

	amount = get_damage_after_percentage_based_armor_reduction(src.blunt_resist, amount)

	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("cut")
		src.set_density(FALSE)
		src.ruined = TRUE
	else
		src.UpdateIcon()

/obj/mesh/damage_slashing(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		src.drop_rods()
		qdel(src)
		return

	amount = get_damage_after_percentage_based_armor_reduction(src.cut_resist, amount)

	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("cut")
		src.set_density(0)
		src.ruined = 1
	else
		UpdateIcon()

/obj/mesh/damage_corrosive(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		qdel(src)
		return

	amount = get_damage_after_percentage_based_armor_reduction(src.corrode_resist, amount)
	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("corroded")
		src.set_density(FALSE)
		src.ruined = TRUE
	else
		UpdateIcon()

/obj/mesh/damage_heat(amount)
	if (!isnum(amount) || amount <= 0)
		return

	if (src.ruined)
		qdel(src)
		return

	src.health = clamp(src.health - amount, 0, src.health_max)
	if (src.health == 0)
		src.special_update_icon("melted")
		src.set_density(FALSE)
		src.ruined = TRUE
	else
		UpdateIcon()

/obj/mesh/meteorhit(var/obj/M)
	if (istype(M, /obj/newmeteor/massive))
		qdel(src)
		return

	src.damage_blunt(5)

/obj/mesh/blob_act(var/power)
	src.damage_blunt(3 * power / 20)

/obj/mesh/ex_act(severity)
	switch(severity)
		if(1)
			src.damage_blunt(40)
			src.damage_heat(40)

		if(2)
			src.damage_blunt(15)
			src.damage_heat(15)

		if(3)
			src.damage_blunt(7)
			src.damage_heat(7)

/obj/mesh/bullet_act(obj/projectile/P)
	..()
	var/damage_unscaled = P.power * P.proj_data.ks_ratio //stam component does nothing- can't tase a grille
	switch(P.proj_data.damage_type)
		if (D_PIERCING)
			src.damage_blunt(damage_unscaled)
			playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 50, 1)
		if (D_BURNING)
			src.damage_heat(damage_unscaled / 2)
		if (D_KINETIC)
			src.damage_blunt(damage_unscaled / 2)
			if (damage_unscaled > 10)
				var/datum/effects/system/spark_spread/sparks = new /datum/effects/system/spark_spread
				sparks.set_up(2, null, src) //sparks fly!
				playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 40, 1)
		if (D_ENERGY)
			src.damage_heat(damage_unscaled / 4)
		if (D_SPECIAL) //random guessing
			src.damage_blunt(damage_unscaled / 4)
			src.damage_heat(damage_unscaled / 8)
		//nothing for radioactive (useless) or slashing (unimplemented)

/obj/mesh/reagent_act(reagent_id, volume, datum/reagentsholder_reagents)
	if(..())
		return
	switch(reagent_id)
		//todo: other acids?
		if("acid")
			src.damage_corrosive(volume / 2)
		if("pacid")
			src.damage_corrosive(volume)
		//todo: thermite, kerosene?
		if("phlogiston")
			src.damage_heat(volume)
		if("infernite")
			src.damage_heat(volume * 2)
		if("foof")
			src.damage_heat(volume * 3)

/obj/mesh/update_icon()
	if (src.ruined)
		return
	src.icon_state = "[src.icon_state_prefix][src.get_icon_direction()][src.get_damage_icon_suffix()]"

/obj/mesh/attackby(obj/item/I, mob/user)
	user.lastattacked = get_weakref(src)
	attack_particle(user, src)
	src.visible_message(SPAN_ALERT("<b>[user]</b> attacks [src] with [I]."))
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 80, 1)

	switch(I.hit_type)
		if(DAMAGE_BURN)
			damage_heat(I.force)
		else
			damage_blunt(I.force * 0.5)

///Get the directional icon state piece.
/obj/mesh/proc/get_icon_direction()
	return ""

/// Get the direct turf connection directions from neighbors. Uses typeinfo connects_to lists.
/obj/mesh/proc/get_icon_connectdir()
	var/connectdir = 0
	if (src.auto_connect)
		var/typeinfo/obj/mesh/typinfo = get_typeinfo()
		var/connects_to_turf = typinfo.connects_to_turf
		var/connects_to_obj = typinfo.connects_to_obj
		for (var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			var/connectable_turf = FALSE
			if(connects_to_turf?[T.type])
				connectdir |= dir
				connectable_turf = TRUE
			if (!connectable_turf) //no turfs to connect to, check for obj's
				for (var/atom/movable/AM as anything in T)
					if (!AM.anchored)
						continue
					if (connects_to_obj?[AM.type])
						connectdir |= dir
						break
	return connectdir

///Check our damage percentage and return the appropriate suffix
/obj/mesh/proc/get_damage_icon_suffix()
	var/diff = get_fraction_of_percentage_and_whole(health,health_max)
	switch(diff)
		if(-INFINITY to 25)
			return "-3"
		if(25 to 50)
			return "-2"
		if(50 to 75)
			return "-1"
		if(75 to INFINITY)
			return "-0"

///Handle special icon states for cut/corroded/melted meshes
/obj/mesh/proc/special_update_icon(special_icon_state)
	if (istext(special_icon_state))
		src.icon_state = "[src.icon_state_prefix]-[special_icon_state]"

///Trigger updates in the icons of our neighbors
/obj/mesh/proc/update_neighbors()
	for(var/obj/mesh/neighbor in orange(1, src))
		neighbor.UpdateIcon()

///Drop rods of our material when deconstructing
/obj/mesh/proc/drop_rods()
	var/obj/item/rods/R = new /obj/item/rods(get_turf(src))
	R.amount = src.amount_of_rods_when_destroyed
	if(src.material)
		R.setMaterial(src.material)
	else
		var/datum/material/M = getMaterial("steel")
		R.setMaterial(M)
