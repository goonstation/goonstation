/obj/item/robot_chemaster
	name = "mini-CheMaster"
	desc = "A cybernetic tool designed for chemistry cyborgs to do their work with. Use a beaker on it to begin."
	icon = 'icons/obj/items/device.dmi'
	icon_state = "minichem"
	flags = NOSPLASH
	var/working = 0

	attackby(obj/item/W, mob/user)
		if (!istype(W,/obj/item/reagent_containers/glass/)) return
		var/obj/item/reagent_containers/glass/B = W

		if(!B.reagents.reagent_list.len || B.reagents.total_volume < 1)
			boutput(user, SPAN_ALERT("That beaker is empty! There are no reagents for the [src.name] to process!"))
			return
		if (working)
			boutput(user, SPAN_ALERT("CheMaster is working, be patient"))
			return

		working = 1
		var/holder = src.loc
		var/the_reagent = input("Which reagent do you want to manipulate?","Mini-CheMaster",null,null) in B.reagents.reagent_list
		if (src.loc != holder || !the_reagent)
			return
		var/action = input("What do you want to do with the [the_reagent]?","Mini-CheMaster",null,null) in list("Isolate","Purge","Remove One Unit","Remove Five Units","Create Pill","Create Pill Bottle","Create Bottle","Create Patch","Create Ampoule","Do Nothing")
		if (src.loc != holder || !action || action == "Do Nothing")
			working = 0
			return

		switch(action)
			if("Isolate") B.reagents.isolate_reagent(the_reagent)
			if("Purge") B.reagents.del_reagent(the_reagent)
			if("Remove One Unit") B.reagents.remove_reagent(the_reagent, 1)
			if("Remove Five Units") B.reagents.remove_reagent(the_reagent, 5)
			if("Create Pill")
				var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(user.loc)
				var/default = B.reagents.get_master_reagent_name()
				var/name = copytext(html_encode(input(user,"Name:","Name your pill!",default)), 1, 32)
				if(!name || name == " ") name = default
				if(name && name != default)
					phrase_log.log_phrase("pill", name, no_duplicates=TRUE)
				P.name = "[name] pill"
				B.reagents.trans_to(P,B.reagents.total_volume)
			if("Create Pill Bottle")
				// copied from chem_master because fuck fixing everything at once jeez
				var/default = B.reagents.get_master_reagent_name()
				var/pillname = copytext( html_encode( input( user, "Name:", "Name the pill!", default ) ), 1, 32)
				if(!pillname || pillname == " ")
					pillname = default
				if(pillname && pillname != default)
					phrase_log.log_phrase("pill", pillname, no_duplicates=TRUE)

				var/pillvol = input( user, "Volume:", "Volume of chemical per pill!", "5" ) as num
				if( !pillvol || !isnum(pillvol) || pillvol < 5 )
					pillvol = 5

				var/pillcount = round( B.reagents.total_volume / pillvol ) // round with a single parameter is actually floor because byond
				if(!pillcount)
					boutput(user, "[src] makes a weird grinding noise. That can't be good.")
				else
					var/obj/item/chem_pill_bottle/pillbottle = new /obj/item/chem_pill_bottle(user.loc)
					pillbottle.create_from_reagents(B.reagents, pillname, pillvol, pillcount)
			if("Create Bottle")
				var/obj/item/reagent_containers/glass/bottle/P = new/obj/item/reagent_containers/glass/bottle(user.loc)
				var/default = B.reagents.get_master_reagent_name()
				var/name = copytext(html_encode(input(user,"Name:","Name your bottle!",default)), 1, 32)
				if(!name || name == " ") name = default
				if(name && name != default)
					phrase_log.log_phrase("bottle", name, no_duplicates=TRUE)
				P.name = "[name] bottle"
				B.reagents.trans_to(P,30)
			if("Create Patch")
				var/datum/reagents/R = B.reagents
				var/input_name = input(user, "Name the patch:", "Name", R.get_master_reagent_name()) as null|text
				var/patchname = copytext(html_encode(input_name), 1, 32)
				if (isnull(patchname) || !length(patchname) || patchname == " ")
					working = 0
					return
				var/all_safe = 1
				for (var/reagent_id in R.reagent_list)
					if (!global.chem_whitelist.Find(reagent_id))
						all_safe = 0
				var/obj/item/reagent_containers/patch/P
				if (R.total_volume <= 15)
					P = new /obj/item/reagent_containers/patch/mini(user.loc)
					P.name = "[patchname] mini-patch"
					R.trans_to(P, P.initial_volume)
				else
					P = new /obj/item/reagent_containers/patch(user.loc)
					P.name = "[patchname] patch"
					R.trans_to(P, P.initial_volume)
				P.medical = all_safe
				P.on_reagent_change()
				logTheThing(LOG_CHEMISTRY, user, "created a [patchname] patch containing [log_reagents(P)].")
			if("Create Ampoule")
				var/datum/reagents/R = B.reagents
				var/input_name = input(user, "Name the ampoule:", "Name", R.get_master_reagent_name()) as null|text
				var/ampoulename = copytext(html_encode(input_name), 1, 32)
				if(!ampoulename)
					working = 0
					return
				if(ampoulename == " ")
					ampoulename = R.get_master_reagent_name()
				var/obj/item/reagent_containers/ampoule/A
				A = new /obj/item/reagent_containers/ampoule(user.loc)
				A.name = "ampoule ([ampoulename])"
				R.trans_to(A, 5)
				logTheThing(LOG_CHEMISTRY, user, "created a [ampoulename] ampoule containing [log_reagents(A)].")

		working = 0


/obj/item/robot_chemaster/prototype
	name = "prototype ChemiTool"
	desc = "A prototype of a compact CheMaster/Reagent Extractor device."
	icon_state = "minichem_proto"
	flags = NOSPLASH
	var/obj/submachine/chem_extractor/reagent_extractor
	var/obj/machinery/chem_master/che_master
	var/list/allowed = list(/obj/item/reagent_containers/food/snacks/,/obj/item/plant/,/obj/item/seashell)

	New()
		..()
		//Loc needs to be this item itself otherwise we get "nopower"
		reagent_extractor = new(src, src)
		che_master = new(src, src)
		AddComponent(/datum/component/transfer_input/quickloading, allowed, "tryLoading")

	//We don't want anything to do with /obj/item/robot_chemaster's attackby(...)
	attackby(var/obj/item/W, var/mob/user)
		return

	attack_self(mob/user as mob)
		reagent_extractor.ui_interact(user)
		che_master.ui_interact(user)

	attack_ai(var/mob/user as mob)
		return

	proc/tryLoading(atom/movable/incoming)
		reagent_extractor.tryLoading(incoming)
