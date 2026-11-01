ABSTRACT_TYPE(/datum/stain)
/datum/stain
	var/name = "stained"

/datum/stain/proc/add_to_clothing(obj/item/clothing/worn)
	return

/datum/stain/proc/remove_from_clothing(obj/item/clothing/worn)
	return

/datum/stain/blood
	name = "blood-stained"

/datum/stain/sparkly
	name = "sparkly"

/datum/stain/damp
	name = "damp"

/datum/stain/puke
	name = "puke-coated"

/datum/stain/puke/green
	name = "green-puke-coated"

/datum/stain/dirt
	name = "dirty"

/datum/stain/slime
	name = "slimy"

/datum/stain/oil
	name = "oily"

/datum/stain/paint
	name = "painted"

/datum/stain/flock
	name = "teal-stained"

#define LAUNDERED_COLDPROT_AMOUNT 2 //!Amount of coldprot(%) given to each item of wearable clothing

/datum/stain/laundered
	name = "freshly-laundred"

/datum/stain/laundered/add_to_clothing(obj/item/clothing/worn)
	. = ..()
	worn.setProperty("coldprot", worn.getProperty("coldprot") + LAUNDERED_COLDPROT_AMOUNT)

/datum/stain/laundered/remove_from_clothing(obj/item/clothing/worn)
	. = ..()
	worn.setProperty("coldprot", worn.getProperty("coldprot") - LAUNDERED_COLDPROT_AMOUNT)

#undef LAUNDERED_COLDPROT_AMOUNT

/datum/stain/singed
	name = "singed"
