datum/component/itemblock/saberblock
	bonus = 1

datum/component/itemblock/saberblock/on_block_begin(datum/source, mob/user)
	. = ..()
	var/obj/item/sword/S = src.parent
	if(S.active)
		if(S.off_w_class == 2) //this is gross but it makes it so only extendable swords (not d-saber) get defensive bonuses
			S.setProperty("rangedprot", 1)
			S.setProperty("disorient_resist", 35)
datum/component/itemblock/saberblock/on_block_end(datum/source, mob/user)
	. = ..()
	var/obj/item/sword/S = src.parent
	S.delProperty("rangedprot")
	S.delProperty("disorient_resist")



