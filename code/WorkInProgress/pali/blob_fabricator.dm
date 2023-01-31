
/datum/manufacture/mechanics/blob
	name = "blob"
	item_paths = list("ORG|RUB")
	item_amounts = list(3)
	time = 10 SECONDS
	create = 1
	frame_path = /obj/blob
	apply_material = 1

	base
		name = "blob"
		frame_path = /obj/blob
		item_amounts = list(1)

	nucleus
		name = "nucleus blob"
		time = 1 MINUTE
		item_amounts = list(30)
		frame_path = /obj/blob/nucleus

	launcher
		name = "slime launcher blob"
		frame_path = /obj/blob/launcher

	mitochondria
		name = "mitochondria blob"
		frame_path = /obj/blob/mitochondria

	reflective
		name = "reflective blob"
		frame_path = /obj/blob/reflective

	ectothermid
		name = "ectothermid blob"
		frame_path = /obj/blob/ectothermid

	plasmaphyll
		name = "plasmaphyll blob"
		frame_path = /obj/blob/plasmaphyll

	lipid
		name = "lipid blob"
		frame_path = /obj/blob/lipid

	ribosome
		name = "ribosome blob"
		frame_path = /obj/blob/ribosome

	wall
		name = "thick blob"
		frame_path = /obj/blob/wall

	firewall
		name = "fire-resistant blob"
		frame_path = /obj/blob/firewall

/datum/manufacture/mechanics/blob_overmind
	name = "blob overmind"
	item_paths = list("blob", "ectoplasm")
	item_amounts = list(10, 10)
	time = 1 MINUTE
	create = 1
	frame_path = /mob/living/intangible/blob_overmind/ai/start_here

/obj/machinery/manufacturer/blob
	name = "blob fabricator"
	supplemental_desc = "This one is for producing blobs. What?"
	icon_state = "fab-hangar"
	icon_base = "hangar"
	available = list(
		/datum/manufacture/mechanics/blob/base,
		/datum/manufacture/mechanics/blob/wall,
		/datum/manufacture/mechanics/blob/firewall,
		/datum/manufacture/mechanics/blob/launcher,
		/datum/manufacture/mechanics/blob/mitochondria,
		/datum/manufacture/mechanics/blob/reflective,
		/datum/manufacture/mechanics/blob/ectothermid,
		/datum/manufacture/mechanics/blob/plasmaphyll,
		/datum/manufacture/mechanics/blob/lipid,
		/datum/manufacture/mechanics/blob/ribosome,
		/datum/manufacture/mechanics/blob/nucleus
		)

	hidden = list(
		/datum/manufacture/mechanics/blob_overmind
	)

	New()
		..()
		src.setMaterial(getMaterial("blob"), setname=FALSE)

/obj/machinery/manufacturer/blob/filled
	free_resource_amt = 10
	free_resources = list(/obj/item/material_piece/wad/blob)
