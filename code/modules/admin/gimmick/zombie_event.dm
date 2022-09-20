/client/proc/spawn_survival_shit()
	set name = "spawn_survival_shit"
	set desc = "spawn_survival_shit."
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set popup_menu = 0
	ADMIN_ONLY
	var/list/spawn_metal_normal = list(/obj/item/material_piece/cloth, /obj/item/material_piece/mauxite, /obj/item/material_piece/pharosium)
	var/list/spawn_metal_valuable = list(/obj/item/material_piece/cerenkite, /obj/item/material_piece/claretine, /obj/item/material_piece/bohrum, /obj/item/material_piece/uqill)
	var/list/spawn_item = list(/obj/item/bat, /obj/item/storage/firstaid/brute, /obj/item/gun/kinetic/riotgun, /obj/item/gun/kinetic/clock_188, /obj/item/clothing/suit/armor/vest, /obj/item/gun/kinetic/single_action/colt_saa)
	var/list/spawn_ammo = list(/obj/item/ammo/bullets/nine_mm_NATO, /obj/item/ammo/bullets/nine_mm_NATO, /obj/item/gun/kinetic/riotgun, /obj/item/ammo/bullets/buckshot_burst,/obj/item/ammo/bullets/abg, /obj/item/ammo/bullets/c_45)

	for (var/obj/machinery/disposal/mail/MB in world)
		var/turf/spawn_turf = get_turf(MB)
		if (prob(40))
			var/pth = pick(spawn_metal_normal)
			var/obj/item/material_piece/P = new pth(spawn_turf)
			P?.amount = 4
		if (prob(10))
			var/pth = pick(spawn_metal_valuable)
			var/obj/item/material_piece/P = new pth(spawn_turf)
			P?.amount = 3
		if (prob(25))
			var/pth = pick(spawn_item)
			new pth(spawn_turf)
		if (prob(40))
			var/pth = pick(spawn_ammo)
			new pth(spawn_turf)
		if (prob(60))
			new /obj/item/plank/anti_zombie(spawn_turf)

