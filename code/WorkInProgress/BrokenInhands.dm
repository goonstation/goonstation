/proc/getbrokeninhands()
	//var/icon/IL = new('items_lefthand.dmi')
	//var/list/Lstates = IL.IconStates()
	//var/icon/IR = new('items_righthand.dmi')
	//var/list/Rstates = IR.IconStates()
	var/icon/I = new('icons/mob/inhand/hand_general.dmi')
	var/list/states = I.IconStates()

	var/text
	for(var/A in typesof(/obj/item))
		var/obj/item/O = new A( locate(1,1,1) )
		if(!O) continue
		var/icon/J = new(O.icon)
		var/list/istates = J.IconStates()
		if(!states.Find(O.icon_state) && !states.Find(O.item_state))
			if(O.icon_state)
				text += "[O.type] WANTS SPRITE CALLED<br>\"[O.icon_state]\".<br>"


		if(O.icon_state)
			if(!istates.Find(O.icon_state))
				text += "[O.type] MISSING NORMAL ICON CALLED<br>\"[O.icon_state]\" IN \"[O.icon]\"<br>"
		if(O.item_state)
			if(!istates.Find(O.item_state))
				text += "[O.type] MISSING NORMAL ICON CALLED<br>\"[O.item_state]\" IN \"[O.icon]\"<br>"
		text+="<br>"
		qdel(O)
	if(text)
		var/F = file("broken_icons.txt")
		fdel(F)
		boutput(F, text)
		boutput(world, "Completely successfully and written to [F]")


