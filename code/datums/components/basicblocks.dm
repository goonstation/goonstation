datum/component/itemblock/basic_block
	var/list/blocktypes = list()
	bonus = 1

datum/component/itemblock/basic_block/on_block_begin(datum/source, mob/user)
	. = ..()
	var/obj/item/I = src.parent
	for (var/blocktype in blocktypes)
		I.setProperty(blocktype, 1)
datum/component/itemblock/basic_block/on_block_end(datum/source, mob/user)
	. = ..()
	var/obj/item/I = src.parent
	for (var/blocktype in blocktypes)
		I.delProperty(blocktype, 1)


datum/component/itemblock/basic_block/all
	blocktypes = list("block_blunt", "block_cut", "block_stab", "block_burn")
datum/component/itemblock/basic_block/large
	blocktypes = list("block_blunt", "block_cut", "block_stab")
datum/component/itemblock/basic_block/rod
	blocktypes = list("block_blunt", "block_cut")
datum/component/itemblock/basic_block/tank
	blocktypes = list("block_blunt", "block_cut", "block_burn")
datum/component/itemblock/basic_block/soft
	blocktypes = list("block_stab", "block_burn")
datum/component/itemblock/basic_block/knife
	blocktypes = list("block_cut", "block_stab")
datum/component/itemblock/basic_block/book
	blocktypes = list("block_stab")

