//adds object properties to the sword while blocking with it.
datum/component/itemblock/saberblock
	bonus = 1 //bonus is a flag that determines whether or not the item tooltip will include "⛨ Block+: RESIST with this item for more info" when not blocking

//proc that is called when the base item is used to block. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_BEGIN" signal 
datum/component/itemblock/saberblock/on_block_begin(obj/item/I, mob/user)
	. = ..()//Always call your parents
	var/obj/item/sword/S = I
	if(istype(S) && S.active && S.off_w_class == 2 && (S.c_flags & HAS_GRAB_EQUIP)) //this is gross but it makes it so only active, extendable, swords (not d-saber) get defensive bonuses
		for(var/obj/item/grab/block/B in S)
			B.setProperty("rangedprot", 1)
			B.setProperty("disorient_resist", 35)

//proc that is called when the block is ended. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_END" signal
datum/component/itemblock/saberblock/on_block_end(obj/item/I, mob/user)
	. = ..()//always always
	if(I.c_flags & HAS_GRAB_EQUIP)
		for(var/obj/item/grab/block/B in I)
			B.delProperty("rangedprot")
			B.delProperty("disorient_resist")
