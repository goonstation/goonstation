/obj/machinery/ore_cloud_storage_container
	name = "Rockbox&trade; Ore Cloud Storage Container"
	desc = "This thing stores ore in \"the cloud\" for the station to use. Best not to think about it too hard."
	icon = 'icons/obj/mining_cloud_storage.dmi'
	icon_state = "ore_storage_unit"
	density = 1
	anchored = 1
	var/list/sell_price = list()
	var/list/for_sale = list()
	var/list/ores = list()
	var/list/sellable_ores = list()

	var/health = 100
	var/broken = 0
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)

		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, "<span class='alert'>Only living mobs are able to use the storage container's quick-load feature.</span>")
			return

		if (!isobj(O))
			boutput(user, "<span class='alert'>You can't quick-load that.</span>")
			return

		if(!DIST_CHECK(O, user, 1))
			boutput(user, "<span class='alert'>You are too far away!</span>")
			return

		if(!src.accept_loading(user,1))
			boutput(user,"<span class='alert'>The storage container's quick-load system rejects you!</span>")
			return

		else if (istype(O, /obj/storage/crate/)  || istype(O, /obj/storage/cart/))
			if (O:welded || O:locked)
				boutput(user, "<span class='alert'>You cannot load from a crate that cannot open!</span>")
				return

			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [O]!</span>", "<span class='notice'>You use [src]'s automatic loader on [O].</span>")
			var/amtload = 0
			for (var/obj/item/M in O.contents)
				if (!istype(M,/obj/item/raw_material/))
					continue
				src.load_item(M)
				amtload++
			if (amtload)
				boutput(user, "<span class='notice'>[amtload] materials loaded from [O]!</span>")
				src.update_ores()
			else boutput(user, "<span class='alert'>No material loaded!</span>")

		else if (isitem(O))
			quickload(user,O)
			src.update_ores()

		else
			..()

		src.updateUsrDialog()

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O)
			return
		user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
		var/staystill = user.loc
		for(var/obj/item/M in view(1,user))
			if (!M)
				continue
			if (M.type != O.type)
				continue
			if (!istype(M,/obj/item/raw_material/))
				continue
			if (O.loc == user)
				continue
			if (O in user.contents)
				continue
			src.load_item(M)
			M.set_loc(src)
			playsound(get_turf(src), sound_load, 40, 1)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/raw_material/) && src.accept_loading(user))
			user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
			src.load_item(W,user)
			src.update_ores()

		else
			src.health = max(src.health-W.force,0)
			src.check_health()
			..()

	proc/check_health()
		if(!src.health)
			src.broken = 1
			src.visible_message("<span class='alert'>[src] breaks!</span>")
			src.icon_state = "ore_storage_unit-broken"
			src.update_sellable()

	proc/load_item(var/obj/item/raw_material/R,var/mob/living/user)
		if (!R)
			return
		if(R.amount == 1)
			R.set_loc(src)
			if (user && R)
				user.u_equip(R)
				R.dropped()
		else if(R.amount>1)
			R.set_loc(src)
			for(R.amount,R.amount > 0, R.amount--)
				var/obj/item/raw_material/new_mat = unpool(R.type)
				new_mat.loc = src
			if (user && R)
				user.u_equip(R)
				R.dropped()
			pool(R)


	proc/accept_loading(var/mob/user,var/allow_silicon = 0)
		if (!user)
			return 0
		if (src.status & BROKEN || src.status & NOPOWER)
			return 0
		if (!istype(user, /mob/living/))
			return 0
		if (istype(user, /mob/living/silicon) && !allow_silicon)
			return 0
		var/mob/living/L = user
		if (!isalive(L) || L.transforming)
			return 0
		return 1

	proc/update_ores()
		src.ores.len = 0
		for(var/obj/item/raw_material/R in src.contents)
			if(!ores[R.material_name]) //Using material_name to group materials is dangerous in general. However, since we are only accepting raw_materials, this should be fine.
				ores += R.material_name
				ores[R.material_name] = 1

			else
				ores[R.material_name]++
		src.update_sellable()
		return

	proc/update_sellable()
		src.sellable_ores.len = 0
		if(src.broken)
			return
		for(var/ore in src.ores)
			if(ore in src.for_sale)
				if(for_sale[ore])
					if(!(ore in sellable_ores))
						sellable_ores += ore
						sellable_ores[ore] = ores[ore]
					else
						continue
				else
					continue

	attack_hand(var/mob/user as mob)

		var/list/ores = src.ores

		src.add_dialog(user)
		var/dat = "<B>[src.name]</B>"

		dat += "<br><HR>"

		if (status & BROKEN || status & NOPOWER)
			dat = "The screen is blank."
			user << browse(dat, "window=mining_dropbox;size=400x500")
			onclose(user, "mining_dropbox")
			return

		if(ores.len)
			for(var/ore in ores)
				var/sellable = 0
				var/price = 0
				if(src.sell_price[ore] != null)
					price = sell_price[ore]
				if(src.for_sale[ore] != null)
					sellable = src.for_sale[ore]
				dat += "<B>[ore]:</B> [ores[ore]] (<A href='?src=\ref[src];sellable=[ore]'>[sellable ? "For Sale" : "Not For Sale"]</A>) (<A href='?src=\ref[src];price=[ore]'>$[price] per ore</A>) (<A href='?src=\ref[src];eject=[ore]'>Eject</A>)<br>"
		else
			dat += "No ores currently loaded.<br>"

		user << browse(dat, "window=mining_dropbox;size=450x500")
		onclose(user, "mining_dropbox")



	Topic(href, href_list)

		if(status & BROKEN || status & NOPOWER)
			return

		if(usr.stat || usr.restrained())
			return

		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
			src.add_dialog(usr)

			if (href_list["eject"])
				var/ore = href_list["eject"]
				var/turf/ejectturf = get_turf(usr)

				src.eject_ores(ore,ejectturf,0,0,usr)

			if (href_list["price"])
				var/ore = href_list["price"]
				var/new_price = null
				new_price = input(usr,"What price would you like to set? (Min 0)","Set Sale Price",null) as num
				new_price = max(0,new_price)
				if(src.sell_price[ore])
					sell_price[ore] = new_price
				else
					sell_price += ore
					sell_price[ore] = new_price

			if (href_list["sellable"])
				var/ore = href_list["sellable"]
				if(src.for_sale[ore])
					for_sale[ore] = !for_sale[ore]
				else
					for_sale += ore
					for_sale[ore] = 1
				update_sellable()

			src.updateUsrDialog()
		return

	proc/eject_ores(var/ore, var/turf/ejectturf, var/ejectamt, var/transmit = 0, var/user as mob)
		for(var/obj/item/raw_material/R in src.contents)
			if (R.material_name == ore)
				if (!ejectamt)
					ejectamt = input(usr,"How many ores do you want to eject?","Eject Ores") as num
				if ((ejectamt <= 0 || get_dist(src, user) > 1) && !transmit)
					break
				if (!ejectturf)
					break
				R.set_loc(ejectturf)
				ejectamt--
				if (ejectamt <= 0)
					break
		if(transmit)
			flick("ore_storage_unit-transmit",src)
			showswirl(ejectturf)
			leaveresidual(ejectturf)

		src.update_ores()