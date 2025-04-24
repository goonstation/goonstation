////Martian Turf stuff//////////////
/turf/simulated/floor/martian
	name = "organic floor"
	icon_state = "floor1"
	name = "martian"
	icon = 'icons/turf/martian.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

/turf/unsimulated/floor/martian
	icon = 'icons/turf/martian.dmi'
	name = "organic floor"
	icon_state = "floor1"

TYPEINFO(/turf/simulated/wall/auto/martian)
	connect_overlay = FALSE
	connect_diagonal = TRUE
TYPEINFO_NEW(/turf/simulated/wall/auto/martian)
	. = ..()
	connects_to = typecacheof(list(
		/obj/machinery/door/unpowered/martian, /turf/simulated/wall/auto/old,
		/obj/indestructible/shuttle_corner, /turf/unsimulated/wall/auto/adventure,
		/obj/machinery/door, /obj/window, /turf/simulated/wall/auto/martian,
		/turf/simulated/wall/auto/reinforced/old
		))

/turf/simulated/wall/auto/martian
	name = "organic wall"
	icon = 'icons/turf/walls/martian.dmi'
	icon_state = "martian-0"
	mod = "martian-"

	exterior
		icon_state = "martout-0"
		mod = "martout-"

	health = 40

	proc/take_damage(var/damage) // Let other walls support this later
		src.health -= damage
		if (src.health <= 0)
			src.gib()

	attackby(obj/item/W, mob/user, params)
		user.lastattacked = get_weakref(src)
		if(istype(W, /obj/item/spray_paint_gang) || istype(W, /obj/item/spray_paint_graffiti) || istype(W, /obj/item/gang_flyer))
			return

		if (istype(W, /obj/item/pen))
			var/obj/item/pen/P = W
			P.write_on_turf(src, user, params)
			return

		else
			src.material_trigger_when_attacked(W, user, 1)
			attack_particle(user, src)
			src.visible_message(SPAN_ALERT("[user ? user : "Someone"] hits [src] with [W]."), SPAN_ALERT("You hit [src] with [W]."))
			src.take_damage(W.force / 2)

	dismantle_wall(devastated=0, keep_material = 1)
		src.gib()

	meteorhit()
		src.gib()

	ex_act(severity)
		switch(severity)
			if(1)
				src.gib()
			if(2)
				src.take_damage(20)
			if(3)
				src.take_damage(5)

	blob_act(var/power)
		src.take_damage(20)

	proc/gib()
		ReplaceWithFloor()
		gibs(src)

