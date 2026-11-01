TYPEINFO(/obj/barricade/sandbags)
	var/list/connects_to_turf = list()
	var/list/connects_to_obj = list()
TYPEINFO_NEW(/obj/barricade/sandbags)
	. = ..()
	src.connects_to_obj = typecacheof(list(
		/obj/barricade/sandbags,
	))
/obj/barricade/sandbags
	name = "sandbags"
	desc = "Some sandbags. It looks like you can shoot over them and beat them down, but not walk over them. Devious."
	icon = 'icons/obj/sandbags.dmi'
	icon_state = "sandbags"
	icon_damaged = "sandbags"

/obj/barricade/sandbags/New()
	. = ..()
	for (var/obj/barricade/sandbags/sandbags in orange(1, src))
		sandbags.UpdateIcon()
	SPAWN(0)
		src.UpdateIcon()

/obj/barricade/sandbags/disposing()
	var/list/obj/barricade/sandbags/neighbours = list()
	for (var/obj/barricade/sandbags/neighbour in orange(1, src))
		neighbours += neighbour
	. = ..()
	for (var/obj/barricade/sandbags/neighbour as anything in neighbours)
		neighbour.UpdateIcon()

/obj/barricade/sandbags/update_icon(...)
	var/typeinfo/obj/barricade/sandbags/typeinfo = src.get_typeinfo()
	var/connect_bitflag = get_connected_directions_bitflag(typeinfo.connects_to_turf | typeinfo.connects_to_obj, connect_diagonal = FALSE)
	src.icon_state = "[initial(src.icon_state)]-[connect_bitflag || 0]"

/obj/barricade/sandbags/take_damage(damage)
	src.health -= damage
	if (src.health <= 0)
		qdel(src)

/obj/item/deployer/barricade/sandbags
	name = "sandbags"
	desc = "Loose bags of sand that can be propped up into a makeshift barricade."
	icon = 'icons/obj/items/sandbags.dmi'
	icon_state = "sandbags"
	object_type = /obj/barricade/sandbags

	HELP_MESSAGE_OVERRIDE("Use in-hand to deploy the sandbags on solid ground. Cannot be picked back up once deployed.")

/obj/item/deployer/barricade/sandbags/large
	amount = 12
	inventory_counter_enabled = TRUE
