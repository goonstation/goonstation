/* CONTAINS:
- Injector belt
- Vapo-Matic mask
- Associated condition datums

There's A LOT of duplicate code here, which isn't ideal to say the least. Should really be overhauled at some point.
*/

/obj/item/injector_belt
	name = "injector belt"
	desc = "Automated injection system attached to a belt."
	icon = 'icons/obj/items/belts.dmi'
	icon_state = "injectorbelt_atm"
	item_state = "injector"
	flags = FPRINT | TABLEPASS | ONBELT | NOSPLASH
	mats = 10

	var/can_trigger = 1
	var/mob/owner = null
	var/active = 0
	var/obj/item/reagent_containers/glass/container = null
	var/datum/injector_belt_condition/condition = null
	var/min_time = 10
	var/inj_amount = -1

	equipped(var/mob/user, var/slot)
		..()
		if(slot == SLOT_BELT)
			owner = user
			if (container?.reagents.total_volume && condition)
				active = 1
				check()
				user.show_text("[src]: Injector system initialized.", "blue")
			else
				var/error_message = ""
				if (!container)
					error_message += " no beaker,"
				if (container && !container.reagents.total_volume)
					error_message += " beaker is empty,"
				if (!condition)
					error_message += " no condition selected,"
				var/output = copytext(error_message, 1, -1)
				user.show_text("Injector system not set up properly:[output].", "red")
		return

	unequipped(mob/user as mob)
		..()
		owner = null
		active = 0
		return

	attack_self(mob/user as mob)
		src.add_dialog(user)
		var/dat = ""
		dat += container ? "Container: <A href='?src=\ref[src];remove_cont=1'>[container.name]</A> - [container.reagents.total_volume] / [container.reagents.maximum_volume] Units<BR><BR>" : "Please attach a beaker<BR><BR>"
		dat += condition ? "[condition.name] - [condition.desc] <A href='?src=\ref[src];remove_cond=1'>(Remove)</A><BR><BR>" : "<A href='?src=\ref[src];sel_cond=1'>(Select Condition)</A><BR><BR>"
		dat += "Injection amount: <A href='?src=\ref[src];change_amt=1'>[inj_amount == -1 ? "ALL" : inj_amount]</A><BR><BR>"
		dat += "Min. time between activations: <A href='?src=\ref[src];change_mintime=1'>[min_time] seconds</A><BR><BR>"

		user.Browse("<TITLE>Injector Belt</TITLE>Injector Belt:<BR><BR>[dat]", "window=inj_belt;size=575x250")
		onclose(user, "inj_belt")
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/reagent_containers/glass))
			if (container)
				boutput(user, "<span class='alert'>There is already a container attached to the belt.</span>")
				return
			if (!W.reagents.total_volume)
				user.show_text("[W] is empty.", "red")
				return
			container =  W
			user.drop_item()
			W.set_loc(src)
			if (src.is_equipped() && src.owner == user && src.condition)
				src.active = 1
				src.check()
				user.show_text("You attach the [W] to the [src.name]! The injector system is now operational.", "blue")
			else
				user.show_text("You attach the [W] to the [src.name]! Please select a condition and re-equip [src] to initialize injector system.", "blue")

	Topic(href, href_list)
		..()
		if(usr != src.loc)
			return
		if (href_list["remove_cont"])
			container.set_loc(get_turf(src))
			container = null

		if (href_list["remove_cond"])
			condition = null

		if (href_list["sel_cond"])
			var/list/cond_types = childrentypesof(/datum/injector_belt_condition)
			var/list/filtered = new/list()

			for(var/A in cond_types)
				var/datum/injector_belt_condition/C = new A()
				filtered += C.name
				filtered[C.name] = A

			var/selected = input(usr,"Select:","Condition") in filtered
			var/selected_type = filtered[selected]

			condition = new selected_type()
			condition.setup(usr)

		if (href_list["change_amt"])
			var/amt = input(usr,"Select:","Amount", inj_amount) in list("ALL",1,5,10,20,30,40,50,75,100)
			if(amt == "ALL")
				inj_amount = -1
			else
				inj_amount = amt

		if (href_list["change_mintime"])
			var/amt = input(usr,"Select:","Min time in seconds", min_time) in list(3,4,5,6,7,8,9,10,20,30,40,50,60,120,180,300)
			min_time = amt

		updateUsrDialog()
		attack_self(usr)

	proc/check()
		if(!is_equipped()) return
		if(!active) return

		if(condition && container?.reagents.total_volume)
			if(condition.check_trigger(owner) && can_trigger)

				can_trigger = 0
				SPAWN_DBG(min_time*10) can_trigger = 1

				playsound(get_turf(src),"sound/items/injectorbelt_active.ogg", 33, 0, -5)
				boutput(owner, "<span class='notice'>Your Injector belt activates.</span>")

				container.reagents.reaction(owner, INGEST)
				SPAWN_DBG(1.5 SECONDS)
					if(inj_amount == -1)
						container.reagents.trans_to(owner, container.reagents.total_volume)
					else
						container.reagents.trans_to(owner, inj_amount)

		SPAWN_DBG(2.5 SECONDS)
			if (src) check()

	proc/is_equipped()
		if(!owner) return 0
		if(hasvar(owner, "belt"))
			if(owner:belt == src)
				return 1
			else
				return 0
		else
			return 0

//////////////////////////////////////

/obj/item/clothing/mask/gas/injector_mask
	name = "Vapo-Matic"
	desc = "Automated chemical vaporizer system built into an old industrial respirator. Doesn't look very safe at all!"
	flags = FPRINT | TABLEPASS  | NOSPLASH
	c_flags = SPACEWEAR | COVERSMOUTH | MASKINTERNALS
	mats = 10
	icon_state = "gas_injector"
	item_state = "gas_injector"

	var/can_trigger = 1
	var/mob/owner = null
	var/active = 0
	var/obj/item/reagent_containers/glass/container = null
	var/datum/injector_belt_condition/condition = null
	var/min_time = 10
	var/inj_amount = -1

	equipped(var/mob/user, var/slot)
		..()
		if(slot == SLOT_WEAR_MASK)
			owner = user
			if (container?.reagents.total_volume && condition)
				active = 1
				check()
				user.show_text("[src]: Injector system initialized.", "blue")
			else
				var/error_message = ""
				if (!container)
					error_message += " no beaker,"
				if (container && !container.reagents.total_volume)
					error_message += " beaker is empty,"
				if (!condition)
					error_message += " no condition selected,"
				var/output = copytext(error_message, 1, -1)
				user.show_text("Injector system not set up properly:[output].", "red")
		return

	unequipped(mob/user as mob)
		..()
		owner = null
		active = 0
		return

	attack_self(mob/user as mob)
		src.add_dialog(user)
		var/dat = ""
		dat += container ? "Container: <A href='?src=\ref[src];remove_cont=1'>[container.name]</A> - [container.reagents.total_volume] / [container.reagents.maximum_volume] Units<BR><BR>" : "Please attach a beaker<BR><BR>"
		dat += condition ? "[condition.name] - [condition.desc] <A href='?src=\ref[src];remove_cond=1'>(Remove)</A><BR><BR>" : "<A href='?src=\ref[src];sel_cond=1'>(Select Condition)</A><BR><BR>"
		dat += "Injection amount: <A href='?src=\ref[src];change_amt=1'>[inj_amount == -1 ? "ALL" : inj_amount]</A><BR><BR>"
		dat += "Min. time between activations: <A href='?src=\ref[src];change_mintime=1'>[min_time] seconds</A><BR><BR>"

		user.Browse("<TITLE>Vapo-Matic</TITLE>Vapo-Matic:<BR><BR>[dat]", "window=inj_belt;size=575x250")
		onclose(user, "inj_belt")
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/reagent_containers/glass))
			if (container)
				boutput(user, "<span class='alert'>There is already a container attached to the mask.</span>")
				return
			if (!W.reagents.total_volume)
				user.show_text("[W] is empty.", "red")
				return
			container =  W
			user.drop_item()
			W.set_loc(src)
			if (src.is_equipped() && src.owner == user && src.condition)
				src.active = 1
				src.check()
				user.show_text("You attach the [W] to the [src.name]! The injector system is now operational.", "blue")
			else
				user.show_text("You attach the [W] to the [src.name]! Please select a condition and re-equip [src] to initialize injector system.", "blue")
		else
			return ..()

	Topic(href, href_list)
		..()

		if(usr != src.loc)
			return

		if (href_list["remove_cont"])
			container.set_loc(get_turf(src))
			container = null

		if (href_list["remove_cond"])
			condition = null

		if (href_list["sel_cond"])
			var/list/cond_types = childrentypesof(/datum/injector_belt_condition)
			var/list/filtered = new/list()

			for(var/A in cond_types)
				var/datum/injector_belt_condition/C = new A()
				filtered += C.name
				filtered[C.name] = A

			var/selected = input(usr,"Select:","Condition") in filtered
			var/selected_type = filtered[selected]

			condition = new selected_type()
			condition.setup(usr)

		if (href_list["change_amt"])
			var/amt = input(usr,"Select:","Amount", inj_amount) in list("ALL",1,5,10,20,30,40,50,75,100)
			if(amt == "ALL")
				inj_amount = -1
			else
				inj_amount = amt

		if (href_list["change_mintime"])
			var/amt = input(usr,"Select:","Min time in seconds", min_time) in list(3,4,5,6,7,8,9,10,20,30,40,50,60,120,180,300)
			min_time = amt

		updateUsrDialog()
		attack_self(usr)

	proc/check()
		if(!is_equipped()) return
		if(!active) return

		if(condition && container?.reagents.total_volume)
			if(condition.check_trigger(owner) && can_trigger)

				can_trigger = 0
				SPAWN_DBG(min_time*10) can_trigger = 1
				var/turf/T = get_turf(src)
				if(T)
					playsound(T,"sound/items/injectorbelt_active.ogg", 33, 0, -5)
					SPAWN_DBG(0.5 SECONDS)
						playsound(T,"sound/machines/hiss.ogg", 40, 1, -5)

				boutput(owner, "<span class='notice'>Your [src] activates.</span>")

				container.reagents.reaction(owner, INGEST)
				SPAWN_DBG(1.5 SECONDS)
					if(inj_amount == -1)
						container.reagents.trans_to(owner, container.reagents.total_volume)
					else
						container.reagents.trans_to(owner, inj_amount)

		SPAWN_DBG(2.5 SECONDS)
			if (src) check()

	proc/is_equipped()
		if(!owner) return 0
		if(hasvar(owner, "wear_mask"))
			if(owner:wear_mask == src)
				return 1
			else
				return 0
		else
			return 0

//////////////////////////////////////

/datum/injector_belt_condition
	var/name = ""
	var/desc = ""

	proc/setup(mob/M)
		return

	proc/check_trigger(mob/M)
		return 0

/datum/injector_belt_condition/health
	name = "Condition: Health"
	desc = "Triggers when health falls below a certain threshold."
	var/threshold = 0

	setup(mob/M)
		var/th = input(M,"Select:","Health",threshold) in list(100,90,75,50,33,25,10,0)
		threshold = th
		desc = "Triggers when health falls below [threshold]."
		return 1

	check_trigger(mob/M)
		if(M.health < threshold) return 1
		else return 0

/datum/injector_belt_condition/damage
	name = "Condition: Damage"
	desc = "Triggers when a certain damage type exceeds a threshold."
	var/threshold = 0
	var/damagetype = "brute"

	setup(mob/M)
		var/dt = input(M,"Select:","Damage Type",damagetype) in list("brute","burn","toxin","oxygen")
		damagetype = dt
		var/th = input(M,"Select:","Threshold",threshold) in list(5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100)
		threshold = th
		desc = "Triggers when [damagetype] damage exceeds [threshold]."
		return 1

	check_trigger(mob/M)
		switch(damagetype)
			if("brute")
				if(M.get_brute_damage() > threshold) return 1
			if("burn")
				if(M.get_burn_damage() > threshold) return 1
			if("toxin")
				if(M.get_toxin_damage() > threshold) return 1
			if("oxygen")
				if(M.get_oxygen_deprivation() > threshold) return 1
		return 0

/datum/injector_belt_condition/tempdiff
	name = "Condition: Temperature !="
	desc = "Triggers when temperature reaches abnormal levels."
	var/threshold = 307

	setup(mob/M)
		return 1

	check_trigger(mob/M)
		if(M.bodytemperature > threshold)
			if((M.bodytemperature - threshold) > 20) return 1
		else
			if((threshold - M.bodytemperature) > 20) return 1
		return 0

/datum/injector_belt_condition/tempover
	name = "Condition: Temperature >"
	desc = "Triggers when temperature rises above a certain threshold."
	var/threshold = 315

	setup(mob/M)
		var/th = input(M,"Select:","Temperature",threshold) in list(315,375,400,450,500,550,600)
		threshold = th
		desc = "Triggers when temperature rises above [threshold]."
		return 1

	check_trigger(mob/M)
		if(M.bodytemperature > threshold) return 1
		else return 0

/datum/injector_belt_condition/tempunder
	name = "Condition: Temperature <"
	desc = "Triggers when temperature falls below a certain threshold."
	var/threshold = 300

	setup(mob/M)
		var/th = input(M,"Select:","Temperature",threshold) in list(300,250,200,150,100,50,25)
		threshold = th
		desc = "Triggers when temperature falls below [threshold]."
		return 1

	check_trigger(mob/M)
		if(M.bodytemperature < threshold) return 1
		else return 0

/datum/injector_belt_condition/incapacitated
	name = "Condition: Incapacitated"
	desc = "Triggers when incapacitated."

	setup(mob/M)
		return 1

	check_trigger(mob/M)
		if(M.getStatusDuration("stunned") || M.getStatusDuration("paralysis") || M.getStatusDuration("weakened") || isunconscious(M)) return 1
		else return 0

/datum/injector_belt_condition/life
	name = "Condition: Death"
	desc = "Triggers on Death."

	setup(mob/M)
		return 1

	check_trigger(mob/M)
		if(isdead(M)) return 1
		else return 0
