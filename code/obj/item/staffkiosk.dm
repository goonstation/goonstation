/obj/submachine/staffkiosk
	name = "Staff Recruitment Kiosk"
	icon = 'icons/obj/vending.dmi'
	icon_state = "staffkiosk"
	desc = "An automated quartermaster service to equip staff assistants for departmental work."
	density = 1
	opacity = 0
	anchored = 1
	var/sound_token = 'sound/machines/capsulebuy.ogg'

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/assistant_token))
			var/obj/item/assistant_token/AT = I
			if(AT.authed)
				user.drop_item(AT)
				qdel(AT)
				accepted_token(AT, user)
			else
				boutput(user, "The kiosk won't accept the token. It has to be authorized by a department staff member first.")
		else
			..()

	attack_hand(var/mob/user as mob)
		if(..())
			return
		boutput(user, "The kiosk doesn't seem to have any buttons, only a token slot labeled 'REQUISITION TOKENS HERE'.")

	accepted_token()
		src.updateUsrDialog()
		playsound(src.loc, sound_token, 80, 1)
		boutput(user, "<span class='notice'>You insert the recruitment token into [src]. It dispenses a box and a small chip.</span>")



//kits

//boxes will contain:
//an alternate jumpsuit with departmental stripe
//a departmental headset
//a set of supplementary items appropriate for the task


/datum/materiel/loadout/assist_civ
	name = "Catering"
	path = /obj/item/storage/box/staffkit/civ
	category = "Loadout"

/datum/materiel/loadout/assist_eng
	name = "Engineering"
	path = /obj/item/storage/box/staffkit/eng
	category = "Loadout"

/datum/materiel/loadout/assist_med
	name = "Medical"
	path = /obj/item/storage/box/staffkit/med

/datum/materiel/loadout/assist_res
	name = "Research"
	path = /obj/item/storage/box/staffkit/res
	category = "Loadout"




/obj/item/assistant_token
	name = "recruitment token"
	desc = "A token issued to assistants that faciliates recruitment into departments. It has a small ID recognition chip inside."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "req-token"
	w_class = 1.0
	var/authed = null
