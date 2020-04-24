// handles items
datum/controller/process/items
	var/tmp/list/detailed_count
	var/tmp/tick_counter
	var/tmp/list/processing_items

	setup()
		name = "Item"
		schedule_interval = 29

		for(var/obj/object in world)
			object.initialize()
			LAGCHECK(LAG_HIGH)

		detailed_count = new

		src.processing_items = global.processing_items

	doWork()
		var/c
		for(var/datum/i in global.processing_items)
			i:process()
			if (i.pooled || i.qdeled) //if the object was pooled or qdeled we have to remove it from this list... otherwise the lagchecks cause this loop to hold refs and block GC!!!
				i = null //this might not even be working consistenlty after testing? or somethin else has a lingering ref >:(
			if (!(c++ % 20))
				scheck()

		/*for(var/obj/item/item in processing_items)
			tick_counter = world.timeofday

			item.process()

			tick_counter = world.timeofday - tick_counter
			if (item && tick_counter > 0)
				detailed_count["[item.type]"] += tick_counter

			scheck(currentTick)
*/
	tickDetail()
		if (detailed_count && detailed_count.len)
			var/stats = "<b>[name] ticks:</b><br>"
			var/count
			for (var/thing in detailed_count)
				count = detailed_count[thing]
				if (count > 4)
					stats += "[thing] used [count] ticks.<br>"
			boutput(usr, "<br>[stats]")

/obj/item/proc/handle_parry(mob/target, mob/user)
	if (target != user && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/sword/S = H.find_type_in_hand(/obj/item/sword, "right")
		if (!S)
			S = H.find_type_in_hand(/obj/item/sword, "left")
		var/obj/item/mop/mop = (H.find_type_in_hand(/obj/item/mop, "right")&& H.mind && H.job == "Janitor")
		if (!mop)
			mop = (H.find_type_in_hand(/obj/item/mop, "left")&& H.mind && H.job == "Janitor")
		if (((S && S.active) || (mop)) && !(H.lying || isdead(H) || H.hasStatus("stunned") || H.hasStatus("weakened") || H.hasStatus("paralysis")))
			var/obj/itemspecialeffect/clash/C = unpool(/obj/itemspecialeffect/clash)
			if(target.gender == MALE) playsound(get_turf(target), pick('sound/weapons/male_cswordattack1.ogg','sound/weapons/male_cswordattack2.ogg'), 70, 0, 0, max(0.7, min(1.2, 1.0 + (30 - H.bioHolder.age)/60)))
			else playsound(get_turf(target), pick('sound/weapons/female_cswordattack1.ogg','sound/weapons/female_cswordattack2.ogg'), 70, 0, 0, max(0.7, min(1.4, 1.0 + (30 - H.bioHolder.age)/50)))
			C.setup(H.loc)
			var/matrix/m = matrix()
			m.Turn(rand(0,360))
			C.transform = m
			var/matrix/m1 = C.transform
			m1.Scale(2,2)
			C.pixel_x = 32*(user.x - target.x)*0.5
			C.pixel_y = 32*(user.y - target.y)*0.5
			animate(C,transform=m1,time=8)
			H.remove_stamina(40)
			if (ishuman(user))
				var/mob/living/carbon/human/U = user
				U.remove_stamina(15)

			return 1
	return 0


/obj/item/proc/handle_katanaparry(mob/target, mob/user)
	if (target != user && ishuman(target))
		var/mob/living/carbon/human/H = target
		if ((H.find_type_in_hand(/obj/item/katana, "right") || H.find_type_in_hand(/obj/item/katana, "left"))||(((H.find_type_in_hand(/obj/item/mop,"right")||H.find_type_in_hand(/obj/item/mop,"left"))&& H.mind && H.job == "Janitor")))
			var/obj/itemspecialeffect/clash/C = unpool(/obj/itemspecialeffect/clash)
			playsound(get_turf(target), pick("sound/effects/sword_clash1.ogg","sound/effects/sword_clash2.ogg","sound/effects/sword_clash3.ogg"), 70, 0, 0)
			C.setup(H.loc)
			var/matrix/m = matrix()
			m.Turn(rand(0,360))
			C.transform = m
			var/matrix/m1 = C.transform
			m1.Scale(2,2)
			C.pixel_x = 32*(user.x - target.x)*0.5
			C.pixel_y = 32*(user.y - target.y)*0.5
			animate(C,transform=m1,time=8)
			H.remove_stamina(60)
			if (ishuman(user))
				var/mob/living/carbon/human/U = user
				U.remove_stamina(20)

			return 1
	return 0
