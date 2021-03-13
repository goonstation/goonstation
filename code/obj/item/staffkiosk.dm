/obj/submachine/staffkiosk
	name = "Staff Recruitment Kiosk"
	icon = 'icons/obj/vending.dmi'
	icon_state = "staffkiosk"
	desc = "An automated quartermaster service to equip staff assistants for departmental work. It appears to accept tokens and an ID."
	density = 1
	opacity = 0
	anchored = 1
	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/obj/item/card/id/ID_card = null

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/assistant_token))
			var/obj/item/assistant_token/AT = I
			if(src.ID_card)
				if(AT.authed)
					user.drop_item(AT)
					qdel(AT)
					accepted_token(AT, user)
				else
					boutput(user, "The kiosk won't accept the token. It has to be authorized by a department staff member first.")
			else
				boutput(user, "The token slot is closed. It looks like an identification card has to be inserted.")
		else if(istype(I, /obj/item/card/id))
			var/obj/item/card/id/ID = I
			if (src.ID_card)
				boutput(user, "<span class='notice'>The kiosk already has an ID inside it.</span>")
				return
			else if (!src.ID_card)
				if(ID.assignment == "Staff Assistant")
					src.insert_id_card(ID, user)
					boutput(user, "<span class='notice'>You insert [ID] into [src]. The token slot opens up.</span>")
				else
					boutput(user, "<span class='notice'>The kiosk refuses to accept the identification card. It appears to only accept staff assistant IDs.</span>")
					return
		else
			..()

	attack_hand(var/mob/user as mob)
		if (src.ID_card)
			boutput(user, "<span class='notice'>You eject [ID_card] from [src]. The token slot closes.</span>")
			src.eject_id_card(user)
		else
			boutput(user, "<span class='notice'>The kiosk doesn't have an identification card inserted.</span>")

	proc/eject_id_card(var/mob/user as mob)
		if (src.ID_card)
			if (istype(user))
				user.put_in_hand_or_drop(src.ID_card)
			else
				var/turf/T = get_turf(src)
				src.ID_card.set_loc(T)
			src.ID_card = null

	proc/insert_id_card(var/obj/item/card/id/ID as obj, var/mob/user as mob)
		if (!istype(ID))
			return
		if (src.ID_card)
			src.eject_id_card(istype(user) ? user : null)
		src.ID_card = ID
		if (user)
			user.u_equip(ID)
		ID.set_loc(src)

	accepted_token()
		src.updateUsrDialog()
		playsound(src.loc, sound_token, 80, 1)
		boutput(user, "<span class='notice'>You insert the recruitment token into [src]. It dispenses a box and a small chip.</span>")

//assignment protocol

//give user an identification change to the role set on the token, and a corresponding box

//boxes will contain:
//an alternate jumpsuit with departmental stripe
//a departmental headset
//a set of supplementary items roughly appropriate for the tasks at hand



/obj/item/assistant_token
	name = "recruitment token"
	desc = "A token issued to assistants that faciliates recruitment into departments. It has a small ID reader and selection wheel."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "req-token-sec"
	//icon_state = "req-token-staff"
	w_class = 1.0
	var/authed = null









//ok I'm doing it this way for some reason I hope the performance isn't terrible

ABSTRACT_TYPE(/datum/recruitment_role)
/datum/recruitment_role
	var/name = "Clown Assistant" //title as it will appear on assistant's card
	var/accessParent = "Clown" //job whose access this mimics
	var/canAuthorize = list("Clown") //who is allowed to give out this job
	var/cardIcon = "id_clown" //what icon state the card should receive
	var/dispensedKit = /obj/item/storage/box/staffkit/civ //what kit should be dispensed (lo and behold)

/datum/recruitment_role/medical
	name = "Medical Assistant"
	accessParent = "Medical Doctor"
  canAuthorize = list("Medical Doctor","Geneticist","Roboticist","Medical Director","Head of Personnel","Captain")
	cardIcon = "id_res"
	dispensedKit = /obj/item/storage/box/staffkit/med

/datum/recruitment_role/robo
	name = "Robotics Assistant"
	accessParent = "Roboticist"
  canAuthorize = list("Roboticist","Medical Director","Head of Personnel","Captain")
	cardIcon = "id_res"
	dispensedKit = /obj/item/storage/box/staffkit/robo

/datum/recruitment_role/engineer
	name = "Engineering Assistant"
	accessParent = "Engineer"
  canAuthorize = list("Engineer","Chief Engineer","Head of Personnel","Captain")
	cardIcon = "id_eng"
	dispensedKit = /obj/item/storage/box/staffkit/eng

/datum/recruitment_role/mechanic
	name = "Mechanics Assistant"
	accessParent = "Mechanic"
  canAuthorize = list("Mechanic","Chief Engineer","Head of Personnel","Captain")
	cardIcon = "id_eng"
	dispensedKit = /obj/item/storage/box/staffkit/mech

/datum/recruitment_role/mining
	name = "Mining Assistant"
	accessParent = "Miner"
  canAuthorize = list("Miner","Chief Engineer","Head of Personnel","Captain")
	cardIcon = "id_eng"
	dispensedKit = /obj/item/storage/box/staffkit/miner

/datum/recruitment_role/sci
	name = "Research Assistant"
	accessParent = "Scientist"
  canAuthorize = list("Scientist","Research Director","Head of Personnel","Captain")
	cardIcon = "id_res"
	dispensedKit = /obj/item/storage/box/staffkit/res

/datum/recruitment_role/chef
	name = "Culinary Assistant"
	accessParent = "Chef"
  canAuthorize = list("Chef","Head of Personnel","Captain")
	cardIcon = "id_civ"
	dispensedKit = /obj/item/storage/box/staffkit/chef

/datum/recruitment_role/bar
	name = "Bar Assistant"
	accessParent = "Bartender"
  canAuthorize = list("Bartender","Head of Personnel","Captain")
	cardIcon = "id_civ"
	dispensedKit = /obj/item/storage/box/staffkit/bar

/datum/recruitment_role/botany
	name = "Bar Assistant"
	accessParent = "Bartender"
  canAuthorize = list("Bartender","Head of Personnel","Captain")
	cardIcon = "id_civ"
	dispensedKit = /obj/item/storage/box/staffkit/botany


//equipment kits

/obj/item/storage/box/staffkit/med
	name = "medical assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffmed,
		/obj/item/device/radio/headset/medical,
		/obj/item/disk/data/cartridge/medical,
		/obj/item/reagent_containers/emergency_injector/epinephrine,
		/obj/item/reagent_containers/mender/brute,
		/obj/item/reagent_containers/mender/burn,
		/obj/item/bandage)

/obj/item/storage/box/staffkit/robo
	name = "robotics assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffmed,
		/obj/item/device/radio/headset/medical,
		/obj/item/disk/data/cartridge/medical,
		/obj/item/screwdriver,
		/obj/item/cable_coil,
		/obj/item/body_bag)

/obj/item/storage/box/staffkit/eng
	name = "engineering assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffeng,
		/obj/item/device/radio/headset/engineer,
		/obj/item/disk/data/cartridge/engineer,
		/obj/item/clothing/head/helmet/hardhat,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/device/multitool)

/obj/item/storage/box/staffkit/mech
	name = "mechanics assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffeng,
		/obj/item/device/radio/headset/engineer,
		/obj/item/disk/data/cartridge/mechanic,
		/obj/item/electronics/soldering,
		/obj/item/device/t_scanner,
		/obj/item/screwdriver,
		/obj/item/device/multitool)

/obj/item/storage/box/staffkit/miner
	name = "mining assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffeng,
		/obj/item/device/radio/headset/engineer,
		/obj/item/clothing/head/emerg,
		/obj/item/clothing/suit/space/emerg,
		/obj/item/crowbar,
		/obj/item/mining_tool/power_pick,
		/obj/item/satchel/mining)

/obj/item/storage/box/staffkit/res
	name = "research assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffres,
		/obj/item/device/radio/headset/research,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/device/reagentscanner)

/obj/item/storage/box/staffkit/chef
	name = "culinary assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffciv,
		/obj/item/device/radio/headset/civilian,
		/obj/item/clothing/head/souschefhat,
		/obj/item/clothing/gloves/latex,
		/obj/item/satchel/hydro,
		/obj/item/reagent_containers/food/drinks/drinkingglass/icing,
		/obj/item/spraybottle/cleaner)

/obj/item/storage/box/staffkit/bar
	name = "bar assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffciv,
		/obj/item/device/radio/headset/civilian,
		/obj/item/clothing/suit/wcoat,
		/obj/item/clothing/gloves/black,
		/obj/item/device/reagentscanner,
		/obj/item/reagent_containers/food/drinks/cocktailshaker,
		/obj/item/spraybottle/cleaner)

/obj/item/storage/box/staffkit/botany
	name = "botanical assistant kit"
	desc = "A slightly stale-smelling set of equipment."
	spawn_contents = list(/obj/item/clothing/under/rank/staffciv,
		/obj/item/device/radio/headset/civilian,
		/obj/item/disk/data/cartridge/botanist,
		/obj/item/clothing/gloves/black,
		/obj/item/satchel/hydro,
		/obj/item/device/reagentscanner)
