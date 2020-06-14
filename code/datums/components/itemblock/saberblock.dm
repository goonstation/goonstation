//adds object properties to the sword while blocking with it.
datum/component/itemblock/saberblock
	bonus = 1 //bonus is a flag that determines whether or not the item tooltip will include "⛨ Block+: RESIST with this item for more info" when not blocking

//proc that is called when the base item is used to block. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_BEGIN" signal
datum/component/itemblock/saberblock/on_block_begin(obj/item/I, var/obj/item/grab/block/B)
	. = ..()//Always call your parents
	var/obj/item/sword/S = I
	if(istype(S) && S.active && S.off_w_class == 2) //this is gross but it makes it so only active, extendable, swords (not d-saber) get defensive bonuses
		B.setProperty("reflection", 1)
		B.setProperty("disorient_resist", 90)

		var/blockplus = DEFAULT_BLOCK_PROTECTION_BONUS + 4 //a bit of bonus protection. 1 point bonus per 3 items in the bag
		for (var/obj/item/grab/block/block in S.contents)
			if(S.c_flags & BLOCK_CUT) //only increase the types we're actually blocking
				block.setProperty("I_block_cut", blockplus)
			if(S.c_flags & BLOCK_STAB)
				block.setProperty("I_block_stab", blockplus)
			if(S.c_flags & BLOCK_BURN)
				block.setProperty("I_block_burn", blockplus)
			if(S.c_flags & BLOCK_BLUNT)
				block.setProperty("I_block_blunt", blockplus)

//proc that is called when the block is ended. The parent itemblock component has already registered this proc for the "COMSIG_ITEM_BLOCK_END" signal
datum/component/itemblock/saberblock/on_block_end(obj/item/I, var/obj/item/grab/block/B)
	. = ..()//always always
	B.delProperty("reflection")
	B.delProperty("disorient_resist")
