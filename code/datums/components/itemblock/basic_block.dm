//sets up the basic bonuses to blocking certain damage types
datum/component/itemblock/basic_block
	var/list/blocktypes = list()
	bonus = 1 //Give a tooltip when not blocking

datum/component/itemblock/basic_block/Initialize(list/blocktypes) //we get passed a list of types that we want to block
	. = ..()
	src.blocktypes = blocktypes

datum/component/itemblock/basic_block/on_block_begin(obj/item/I, mob/user)
	. = ..()
	if(I.c_flags & HAS_GRAB_EQUIP)
		for(var/obj/item/grab/block/B in I)
			for (var/blocktype in blocktypes)
				B.setProperty(blocktype, 1) //for each thing in our list of types to block, add the thing
datum/component/itemblock/basic_block/on_block_end(obj/item/I, mob/user)
	. = ..()
	if(I.c_flags & HAS_GRAB_EQUIP)
		for(var/obj/item/grab/block/B in I)
			for (var/blocktype in blocktypes)
				B.delProperty(blocktype, 1) //block is ended, get rid of the blocking properties




