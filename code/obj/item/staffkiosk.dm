/obj/submachine/staffkiosk
	name = "Staff Recruitment Kiosk"
	icon = 'icons/obj/vending.dmi'
	icon_state = "staffkiosk"
	desc = "An automated quartermaster service to equip staff assistants for departmental work. It appears to accept tokens and an ID."
	density = 1
	opacity = 0
	anchored = 1
	var/sound_token = 'sound/machines/capsulebuy.ogg'
	var/sound_dispense = 'sound/machines/chime.ogg'
	var/sound_cardslot = 'sound/items/Deconstruct.ogg'
	var/obj/item/card/id/ID_card = null

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/assistant_token))
			var/obj/item/assistant_token/AT = I
			if(src.ID_card)
				if(AT.authed && AT.role_datum)
					user.drop_item(AT)
					var/ATINFO = AT.role_datum
					qdel(AT)
					accepted_token(ATINFO, user)
				else
					boutput(user, "<span class='alert'>The kiosk won't accept the token. It has to be authorized by a department staff member first.</span>")
			else
				boutput(user, "<span class='alert'>The token slot is closed. It looks like an identification card has to be inserted.</span>")
		else if(istype(I, /obj/item/card/id))
			var/obj/item/card/id/ID = I
			if (src.ID_card)
				boutput(user, "<span class='alert'>The kiosk already has an ID inside it.</span>")
				return
			else if (!src.ID_card)
				if(ID.assignment == "Staff Assistant")
					src.insert_id_card(ID, user)
					playsound(src.loc, sound_cardslot, 60, 1)
					boutput(user, "<span class='notice'>You insert [ID] into [src]. The token slot opens up.</span>")
				else
					boutput(user, "<span class='alert'>The kiosk refuses to accept the identification card. It appears to only accept staff assistant IDs.</span>")
					return
		else
			..()

	attack_hand(var/mob/user as mob)
		if (src.ID_card)
			boutput(user, "<span class='notice'>You eject [ID_card] from [src]. The token slot closes.</span>")
			playsound(src.loc, sound_cardslot, 60, 1)
			src.eject_id_card(user)
		else
			boutput(user, "<span class='alert'>The kiosk doesn't have an identification card inserted.</span>")

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

	proc/accepted_token(var/datum/recruitment_role/TD, var/mob/user)
		playsound(src.loc, sound_token, 80, 1)
		boutput(user, "<span class='notice'>You insert the recruitment token into [src]. The ID slot whirs softly, then the machine dispenses a box.</span>")

		src.ID_card.assignment = TD.name
		src.ID_card.access = get_access(TD.accessParent)
		src.ID_card.icon_state = TD.cardIcon
		src.ID_card.name = "[ID_card.registered]'s ID Card ([ID_card.assignment])"

		SPAWN_DBG(10)
			playsound(src.loc, sound_dispense, 80, 1)
			new TD.dispensedKit(src.loc)

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
	icon_state = "assist-token"
	w_class = 1.0
	var/authed = 0
	var/role_name = null
	var/role_datum = null

	attackby(var/obj/item/I, var/mob/user)
		if(istype(I, /obj/item/card/id))
			var/obj/item/card/id/ID = I
			var/pickableRoles = list()
			var/frontEndList = list()

			for(var/datum/recruitment_role/ROL in recruitment_roles)
				if(ID.assignment in ROL.canAuthorize)
					pickableRoles[ROL.name] = ROL
					frontEndList += ROL.name

			if (!length(frontEndList))
				boutput(user, "<span class='alert'>This card can't authorize any available token roles.</span>")
				return

			var/choice = input(user, "Which role to authorize on token?", "Selection") as null|anything in frontEndList
			if (!choice)
				return

			src.authed = 1
			src.role_name = choice
			src.role_datum = pickableRoles[choice]
			src.icon_state = pickableRoles[choice].tokenIcon
			src.desc = "An activated recruitment token, ready for use in the recruitment kiosk. It's configured for the [role_name] role."

			boutput(user, "<span class='notice'>You authorize the token for the [choice] role.</span>")
			return
		else
			..()


//datum? I hardly know em

/proc/build_recruitment_role_cache()
	recruitment_roles.Cut()
	for(var/S in concrete_typesof(/datum/recruitment_role))
		recruitment_roles += new S()

ABSTRACT_TYPE(/datum/recruitment_role)
/datum/recruitment_role
	var/name = "Clown Assistant" //title as it will appear on assistant's card
	var/accessParent = "Clown" //job whose access this mimics
	var/canAuthorize = list("Clown") //who is allowed to give out this job
	var/cardIcon = "id_clown" //what icon state the card should receive
	var/tokenIcon = "assist-token"
	var/dispensedKit = /obj/item/storage/box/staffkit/med //what kit should be dispensed (lo and behold)

/datum/recruitment_role/medical
	name = "Medical Assistant"
	accessParent = "Medical Doctor"
	canAuthorize = list("Medical Doctor","Geneticist","Roboticist","Medical Director","Head of Personnel","Captain")
	cardIcon = "id_res"
	tokenIcon = "assist-token-med"
	dispensedKit = /obj/item/storage/box/staffkit/med

/datum/recruitment_role/robo
	name = "Robotics Assistant"
	accessParent = "Roboticist"
	canAuthorize = list("Roboticist","Medical Director","Head of Personnel","Captain")
	cardIcon = "id_res"
	tokenIcon = "assist-token-robo"
	dispensedKit = /obj/item/storage/box/staffkit/robo

/datum/recruitment_role/engineer
	name = "Engineering Assistant"
	accessParent = "Engineer"
	canAuthorize = list("Engineer","Chief Engineer","Head of Personnel","Captain")
	cardIcon = "id_eng"
	tokenIcon = "assist-token-eng"
	dispensedKit = /obj/item/storage/box/staffkit/eng

/datum/recruitment_role/mechanic
	name = "Mechanics Assistant"
	accessParent = "Mechanic"
	canAuthorize = list("Mechanic","Chief Engineer","Head of Personnel","Captain")
	cardIcon = "id_eng"
	tokenIcon = "assist-token-mech"
	dispensedKit = /obj/item/storage/box/staffkit/mech

/datum/recruitment_role/mining
	name = "Mining Assistant"
	accessParent = "Miner"
	canAuthorize = list("Miner","Chief Engineer","Head of Personnel","Captain")
	cardIcon = "id_eng"
	tokenIcon = "assist-token-mine"
	dispensedKit = /obj/item/storage/box/staffkit/miner

/datum/recruitment_role/sci
	name = "Research Assistant"
	accessParent = "Scientist"
	canAuthorize = list("Scientist","Research Director","Head of Personnel","Captain")
	cardIcon = "id_res"
	tokenIcon = "assist-token-sci"
	dispensedKit = /obj/item/storage/box/staffkit/res

/datum/recruitment_role/chef
	name = "Culinary Assistant"
	accessParent = "Chef"
	canAuthorize = list("Chef","Head of Personnel","Captain")
	cardIcon = "id_civ"
	tokenIcon = "assist-token-chef"
	dispensedKit = /obj/item/storage/box/staffkit/chef

/datum/recruitment_role/bar
	name = "Bar Assistant"
	accessParent = "Bartender"
	canAuthorize = list("Bartender","Head of Personnel","Captain")
	cardIcon = "id_civ"
	tokenIcon = "assist-token-bar"
	dispensedKit = /obj/item/storage/box/staffkit/bar

/datum/recruitment_role/botany
	name = "Botanical Assistant"
	accessParent = "Botanist"
	canAuthorize = list("Botanist","Head of Personnel","Captain")
	cardIcon = "id_civ"
	tokenIcon = "assist-token-hyd"
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
