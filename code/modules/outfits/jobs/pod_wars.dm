ABSTRACT_TYPE(/datum/outfit/pod_wars)
/datum/outfit/pod_wars/nanotrasen
	outfit_name = "NanoTrasen Pod Pilot"

	slot_back = list(/obj/item/storage/backpack/NT)
	slot_belt = list(/obj/item/gun/energy/blaster_pod_wars/nanotrasen)
	slot_under = list(/obj/item/clothing/under/misc/turds)
	slot_head = list(/obj/item/clothing/head/helmet/space/nanotrasen/pilot)
	slot_outer = list(/obj/item/clothing/suit/space/nanotrasen/pilot)
	slot_shoes = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen)
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_gloves = list(/obj/item/clothing/gloves/swat/NT)
	left_pocket = list(/obj/item/tank/emergency_oxygen/extended)
	right_pocket = list(/obj/item/device/pda2/pod_wars/nanotrasen)
	backpack_items = list(/obj/item/survival_machete, /obj/item/currency/spacecash/hundred)

/datum/outfit/pod_wars/nanotrasen/commander
	outfit_name = "NanoTrasen Commander"

	slot_head = list(/obj/item/clothing/head/NTberet/commander)
	slot_outer = list(/obj/item/clothing/suit/space/nanotrasen/pilot/commander)
	slot_ears = list(/obj/item/device/radio/headset/pod_wars/nanotrasen/commander)

/datum/outfit/pod_wars/syndicate
	outfit_name = "Syndicate Pod Pilot"

	slot_back = list(/obj/item/storage/backpack/syndie)
	slot_belt = list(/obj/item/gun/energy/blaster_pod_wars/syndicate)
	slot_under = list(/obj/item/clothing/under/misc/syndicate)
	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/specialist)
	slot_outer = list(/obj/item/clothing/suit/space/syndicate)
	slot_shoes = list(/obj/item/clothing/shoes/swat)
	slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate)
	slot_mask = list(/obj/item/clothing/mask/breath)
	slot_gloves = list(/obj/item/clothing/gloves/swat)
	left_pocket = list(/obj/item/tank/emergency_oxygen/extended)
	right_pocket = list(/obj/item/device/pda2/pod_wars/syndicate)
	backpack_items = list(/obj/item/survival_machete/syndicate, /obj/item/currency/spacecash/hundred)

/datum/outfit/pod_wars/syndicate/commander
	outfit_name = "Syndicate Commander"

	slot_head = list(/obj/item/clothing/head/helmet/space/syndicate/commissar_cap)
	slot_outer = list(/obj/item/clothing/suit/space/syndicate/commissar_greatcoat)
	slot_ears = list(/obj/item/device/radio/headset/pod_wars/syndicate/commander)
