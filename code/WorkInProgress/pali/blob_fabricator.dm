
/datum/manufacture/mechanics/blob
	name = "blob"
	item_requirements = list("organic_or_rubber" = 3)
	create = 1
	time = 10 SECONDS
	apply_material = TRUE
	frame_path = /obj/blob

/datum/manufacture/mechanics/blob/base
	name = "blob"
	item_requirements = list("organic_or_rubber" = 1)
	frame_path = /obj/blob

/datum/manufacture/mechanics/blob/nucleus
	name = "nucleus blob"
	item_requirements = list("organic_or_rubber" = 30)
	time = 1 MINUTE
	frame_path = /obj/blob/nucleus

/datum/manufacture/mechanics/blob/launcher
	name = "slime launcher blob"
	frame_path = /obj/blob/launcher

/datum/manufacture/mechanics/blob/mitochondria
	name = "mitochondria blob"
	frame_path = /obj/blob/mitochondria

/datum/manufacture/mechanics/blob/reflective
	name = "reflective blob"
	frame_path = /obj/blob/reflective

/datum/manufacture/mechanics/blob/ectothermid
	name = "ectothermid blob"
	frame_path = /obj/blob/ectothermid

/datum/manufacture/mechanics/blob/plasmaphyll
	name = "plasmaphyll blob"
	frame_path = /obj/blob/plasmaphyll

/datum/manufacture/mechanics/blob/lipid
	name = "lipid blob"
	frame_path = /obj/blob/lipid

/datum/manufacture/mechanics/blob/ribosome
	name = "ribosome blob"
	frame_path = /obj/blob/ribosome

/datum/manufacture/mechanics/blob/wall
	name = "thick blob"
	frame_path = /obj/blob/wall

/datum/manufacture/mechanics/blob/firewall
	name = "fire-resistant blob"
	frame_path = /obj/blob/firewall

/datum/manufacture/mechanics/blob_overmind
	name = "blob overmind"
	item_requirements = list("blob" = 10,
							 "ectoplasm" = 10)
	create = 1
	time = 1 MINUTE
	frame_path = /mob/living/intangible/blob_overmind/ai/start_here

/obj/machinery/manufacturer/blob
	name = "blob fabricator"
	supplemental_desc = "This one is for producing blobs. What?"
	icon_state = "fab-hangar"
	icon_base = "hangar"
	default_material = "blob"
	uses_default_material_appearance = TRUE
	mat_changename = FALSE
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

/obj/machinery/manufacturer/blob/filled
	free_resources = list(/obj/item/material_piece/wad/blob = 10)
