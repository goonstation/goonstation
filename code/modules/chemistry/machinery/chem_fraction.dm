/obj/machinery/chem_fractioning_still/ //a huge column boiler for separating chems by boiling point
	name = "fractional still"
	desc = "A towering piece of industrial equipment. It reeks of hydrocarbons."
	density = 1
	anchored = ANCHORED
	power_usage = 500
	var/active = 0
	var/overall_temp = T20C
	var/target_temp = T20C
	var/heating = 0
	var/distilling = 0
	var/cracking = 0
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/thick/bottoms = null
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/tops = null
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/feed = null
	var/obj/item/reagent_containers/glass/beaker/extractor_tank/overflow = null
	var/obj/item/reagent_containers/user_beaker = null

	New()
		..()
		src.bottoms = new
		src.tops = new
		src.feed = new
		src.overflow = new

	disposing()
		if (src.bottoms)
			qdel(src.bottoms)
			src.bottoms = null
		if (src.tops)
			qdel(src.tops)
			src.tops = null
		if (src.feed)
			qdel(src.feed)
			src.feed = null
		if (src.overflow)
			qdel(src.overflow)
			src.overflow = null
		if (src.user_beaker)
			qdel(src.user_beaker)
			src.user_beaker = null
		UnsubscribeProcess()
		..()

	process(var/mult)
		if(!active)
			UnsubscribeProcess()
		if(heating)
			heat_up()
		else
			src.power_usage = initial(src.power_usage)
		if(distilling)
			distill(mult)
		if(cracking)
			do_cracking(bottoms,mult)
		bottoms.reagents.temperature_reagents(T20C, 1)
		..()

	proc/check_tank(var/obj/item/reagent_containers/tank,var/headroom)
		if(tank.reagents.total_volume >= tank.reagents.maximum_volume - headroom)
			tank.reagents.trans_to(overflow,(headroom*0.1))
		if(overflow.reagents.total_volume >= overflow.reagents.maximum_volume - headroom)
			src.visible_message(SPAN_ALERT("The internal overflow safety dumps its contents all over the floor!."),SPAN_ALERT("You hear a tremendous gushing sound."))
			var/turf/T = get_turf(src)
			overflow.reagents.reaction(T)

	proc/do_cracking(var/obj/item/reagent_containers/R, var/amount)
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.can_crack)
					reggie.crack(amount)

	proc/distill(var/amount)
		var/vapour_list = get_vapours(bottoms)
		if(vapour_list)
			heating = 0
			for(var/datum/reagent/R in vapour_list)
				bottoms.reagents.remove_reagent(R.id,amount)
				tops.reagents.add_reagent(R.id,amount)
				check_tank(tops,50)
				feed.reagents.trans_to(bottoms,amount)
				check_tank(bottoms,100)
		else
			if(bottoms.reagents && length(bottoms.reagents.reagent_list))
				heating = 1

	proc/heat_up()
		var/vapor_temp = min(get_lowest_temp(bottoms),target_temp)
		bottoms.reagents.temperature_reagents(vapor_temp, 10)
		src.power_usage = 1000

	proc/get_vapours(var/obj/item/reagent_containers/R)
		var/datum/reagent/reg = list()
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.boiling_point <= overall_temp)
					reg += reggie
			return reg
		else return null

	proc/get_lowest_temp(var/obj/item/reagent_containers/R)
		var/top_temp = INFINITY
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.boiling_point<top_temp)
					top_temp=reggie.boiling_point
			return top_temp
		else return T0C

	proc/get_lowest_temp_chem(var/obj/item/reagent_containers/R)
		var/top_temp = INFINITY
		if(R && R.reagents)
			for(var/datum/reagent/reggie in R)
				if(reggie.boiling_point<top_temp)
					top_temp=reggie.boiling_point
					. = reggie
			return
		else return null
