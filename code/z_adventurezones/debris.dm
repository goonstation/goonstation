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
	icon = 'icons/turf/walls_martian.dmi'
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
		user.lastattacked = src
		if(istype(W, /obj/item/spray_paint) || istype(W, /obj/item/gang_flyer))
			return

		if (istype(W, /obj/item/pen))
			var/obj/item/pen/P = W
			P.write_on_turf(src, user, params)
			return

		else if (istype(W, /obj/item/light_parts))
			src.attach_light_fixture_parts(user, W) // Made this a proc to avoid duplicate code (Convair880).
			return

		else
			if(src.material)
				src.material.triggerOnHit(src, W, user, 1)
			attack_particle(user, src)
			src.visible_message("<span class='alert'>[user ? user : "Someone"] hits [src] with [W].</span>", "<span class='alert'>You hit [src] with [W].</span>")
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

