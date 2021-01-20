/datum/matfab_part/variable
	var/required_value = 50
	var/greater_than = 1
	var/required_property = "hard"
	var/proper_name = "hardness"

	New()
		name = "Material [greater_than?">":"<"][required_value] [proper_name]"
		return ..()

	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!I.material) return 0
		if(!I.material.hasProperty(required_property)) return 0
		if(greater_than)
			if(I.material.getProperty(required_property) < required_value) return 0
		else
			if(I.material.getProperty(required_property) > required_value) return 0
		return ..()

/////////////////////////////////////////////////////////////////////////////////////////////

/datum/matfab_part/optionalmat_mining
	name = "Optional Mod"
	optional = 1
	checkMatch(var/obj/item/I)
		if(!istype(I, /obj/item/mining_mod)) return 0
		return ..()

/datum/matfab_part/any_mtool_head
	name = "Mining Tool Head"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/mining_head)) return 0
		return ..()

/datum/matfab_part/radiocative_material
	name = "Radioactive Material"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(I.material.getProperty("radioactive") < 10) return 0
		return ..()

/datum/matfab_part/charge
	name = "Explosive Charge"
	checkMatch(var/obj/item/I)
		if(!istype(I, /obj/item/breaching_charge)) return 0
		return ..()

/datum/matfab_part/rubber
	name = "Rubber"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_RUBBER)) return 0
		return ..()

/datum/matfab_part/energy
	name = "Energy"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!( I.material.material_flags & MATERIAL_ENERGY)) return 0
		return ..()

/datum/matfab_part/cloth
	name = "Cloth"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_CLOTH)) return 0
		return ..()

/datum/matfab_part/metal
	name = "Metal"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_METAL)) return 0
		return ..()

/datum/matfab_part/crystal
	name = "Crystal"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_CRYSTAL)) return 0
		return ..()

/datum/matfab_part/organic
	name = "Organic"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_ORGANIC)) return 0
		return ..()

/datum/matfab_part/metalororganic
	name = "Metal or Organic"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_ORGANIC || I.material.material_flags & MATERIAL_METAL)) return 0
		return ..()

/datum/matfab_part/metalorcrystal
	name = "Metal or Crystal"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_CRYSTAL || I.material.material_flags & MATERIAL_METAL)) return 0
		return ..()

/datum/matfab_part/metalorcrystalororganic
	name = "Metal or Crystal or Organic"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_CRYSTAL || I.material.material_flags & MATERIAL_METAL||I.material.material_flags & MATERIAL_ORGANIC)) return 0
		return ..()

/datum/matfab_part/clothororganic
	name = "Cloth or Organic"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_CLOTH || I.material.material_flags & MATERIAL_ORGANIC)) return 0
		return ..()

/datum/matfab_part/clothorrubber
	name = "Cloth or Rubber"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_CLOTH || I.material.material_flags & MATERIAL_RUBBER)) return 0
		return ..()

/datum/matfab_part/clothororganicorrubber
	name = "Cloth or Organic or Rubber"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!(I.material.material_flags & MATERIAL_CLOTH || I.material.material_flags & MATERIAL_ORGANIC || I.material.material_flags & MATERIAL_RUBBER)) return 0
		return ..()

/datum/matfab_part/anymat
	name = "Material"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		return ..()

/datum/matfab_part/anymat_canmix
	name = "Unprocessed Material"
	checkMatch(var/obj/item/I)
		if(!I.material.canMix) return 0
		if(!istype(I, /obj/item/material_piece) && !istype(I, /obj/item/raw_material)) return 0
		if(!I.material) return 0
		return ..()

/datum/matfab_part/lens
	name = "Lens"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!istype(I, /obj/item/lens) ||  !I.material) return 0
		return ..()

/datum/matfab_part/arrowhead
	name = "Arrowhead"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		if(!I.material || !istype(I, /obj/item/arrowhead)) return 0
		return ..()

/datum/matfab_part/chemical
	name = "Chemical"
	checkMatch(var/obj/item/I)
		if(!I.reagents || !I.reagents.total_volume || !I.reagents.reagent_list.len) return 0
		return ..()

/datum/matfab_part/starstone
	name = "Starstone"
	checkMatch(var/obj/item/I)
		if(!I.material || (I.material.mat_id != "starstone")) return 0
		return ..()

/datum/matfab_part/fissile
	name = "Fissile"
	checkMatch(var/obj/item/I)
		if(!I.material) return 0
		//if(I.material.getProperty("fissile") < 30) return 0
		//if(!I.material.nuke_compat) return 0
		return ..()
//////////////////////////////////////////////BASE CLASS BELOW

/datum/matfab_part
	var/name = "" //Name of the material or component required.
	var/part_name = "" //Name of the part that this will be used for. Set in the recipes New proc.
	var/required_amount = 1 //How much we need of this. also set in the recipe.
	var/obj/item/assigned = null //What is currently assigned to this slot.
	var/optional = 0 //If 1, slot does not have to be filled.

	proc/checkMatch(var/obj/item/I) //Does the object match our conditions?
		if(I.material && I.material.mixOnly) return 0
		if(I.amount >= required_amount)
			return 1
		return -1 //Return -1 if theres not enough of the material. This will show up differently on the fab.

	proc/clear() //Clear all assigned items etc. Used to reset the recipe.
		assigned = null
		return
