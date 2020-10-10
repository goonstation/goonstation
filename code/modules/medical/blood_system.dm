/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-ISSUES=-=-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
/*
 - healing spells for lings/etc should stop bleeding
 - iron and sugar have effects on blood: sugar reduces low blood_volume effects, research it & iron
 - Bleeding rework: if you have open surgical wounds your bleeding shouldn't drop to 0
 - Processor still needs to be finished.
 - Blood donation is better now with IVs, but the processor still could be useful
 - With how cheap sutures are to make, they need more drawbacks/bandages need less, so people actually have a reason to use bandages.
 - Vampires??  ??????
 - Open wounds, limb loss, etc need to bleed more/be more obvious that they're bleeding.
 - Maybe a rewrite to the limb system so it doesn't SUCK re: bugs and interaction with other systems. (medborgs not being able to remove limbs and crap like that - ???)
*/
/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-BLOOD-STUFF-=-=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

#define BLOOD_DEBUG(x) if (haine_blood_debug) message_coders("<span class='alert'><b>BLOOD DEBUG:</b></span> " + x)

var/global/haine_blood_debug = 0

/client/proc/haine_blood_debug()
	set desc = "Toggle blood debug messages."
	set name = "Haine Blood Debug"
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set hidden = 1
	haine_blood_debug = !( haine_blood_debug )
	logTheThing("admin", usr, null, "toggled blood debug messages [haine_blood_debug ? "on" : "off"].")
	logTheThing("diary", usr, null, "toggled blood debug messages [haine_blood_debug ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled blood debug messages [haine_blood_debug ? "on" : "off"]")

// for logging purposes
/proc/dam_num2name(var/damtype)
	if (isnull(damtype))
		return "error"
	switch (damtype)
		if (DAMAGE_STAB)
			return "damage_stab"
		if (DAMAGE_CUT)
			return "damage_cut"
		if (DAMAGE_BLUNT)
			return "damage_blunt"
		if (DAMAGE_BURN)
			return "damage_burn"
		if (DAMAGE_CRUSH)
			return "damage_crush"
	return "error"

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-=-=PROCS=-=-=-=-=-=-=-=-==-=-=-=-=-=*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */
/*
 ---------- WHAT'S HERE ----------

take_bleeding_damage(mob/some_idiot, mob/some_jerk, damage, damage_type, bloodsplatter = 1, turf/T)

some_idiot is your target who takes the damage, some_jerk is the guy what did it to some_idiot
for things that would cause bloodsplatter and increase bleeding
- damage determines how much blood is lost
- damage_types: DAMAGE_STAB, DAMAGE_CUT, DAMAGE_BLUNT, DAMAGE_BURN - these will affect the chance of increasing bleeding and how much bleeding rate increases by
- bloodsplatter var just in case that needs to be taken care of elsewhere???
	if it's 0 it'll just remove [damage] from some_idiot's blood_volume without the decal appearing
- T will pass a turf to bleed() in case you need the blood to appear in more places than just where some_idiot is
	if you don't give it T it defaults to some_idiot's turf
- if the damage_type is DAMAGE_BURN and a bleeding increase doesn't occur, there's a chance that repair_bleeding_damage() will be triggered

 ----------

repair_bleeding_damage(mob/some_idiot, repair_chance, repair_amount)

for things that'll fix bleeding: sutures, bandages, etc
- repair_chance will be affected by how much some_idiot is bleeding already: higher levels of bleeding have a better chance of repair
- repair_amount should be 1-10, and will be subtracted from some_idiot's bleeding

 ----------

bleed(mob/some_idiot, num_amount, vis_amount, turf/T)

creates bloodsplatter on T, or if it isn't passed T, some_idiot's turf
- num_amount is how much blood to lose
- vis_amount is how much blood to spawn visually, 1-5 (see the dynamic blood decal in decal.dm for more info)
I keep having to make this same thing over and over so this is just a timesaver for me
you should probably use take_bleeding_damage() instead of this unless you have some need to make someone bleed without making their bleeding increase

 ----------

transfer_blood(mob/living/some_idiot, atom/A, amount)

take [amount] total blood and reagents (combined) out of some_idiot and transfer it into A
currently used by syringes and IVs
it removes blood from some_idiot's blood_volume and reagents from their reagent holder

 ----------

blood_slash(mob/some_idiot, bleed_amount, atom/A, direction, splatters = 4)

creates a trail of blood in either the direction provided, or, failing that, some_idiot's direction
- bleed_amount is how much blood to lose FOR EACH BLOODSPLATTER + THE INITIAL ONE, this defaults to bleed_amount * 5
- direction and A are optional in case you want to create the slash in a place/direction other than some_idiot's (ie some_idiot is inside something)
- splatters is how many decals to spawn
made for suicides where you cut your throat, but maybe you can find some other use for it

 ----------

animate_blood_damage(mob/some_idiot, mob/some_jerk)

WIP, doesn't work yet.  you can ignore this.

 ----------

staunch_bleeding(mob/some_idiot)

a proc under /mob/living/ for putting pressure on wounds to stop bleeding.
this is already used where it needs to be used, you can probably ignore it.

 ---------- END ---------- */

/* ============================================ */
/* ---------- take_bleeding_damage() ---------- */
/* ============================================ */

/proc/take_bleeding_damage(var/mob/some_idiot as mob, var/mob/some_jerk as mob, var/damage as num, var/damage_type = DAMAGE_CUT, var/bloodsplatter = 1, var/turf/T as turf)
	if (!T) // I forget why I set T as a variable OH WELL
		T = get_turf(some_idiot)

	if (!blood_system)
		if (bloodsplatter) // we at least wanna create the decal anyway
			bleed(some_idiot, 0, 5, T)
			//animate_blood_damage(some_idiot, some_jerk)
		return

	//BLOOD_DEBUG("[some_idiot] begins bleed damage proc")

	if (!isliving(some_idiot))
		return

	var/mob/living/H = some_idiot

	if (H.stat ==  2 || H.nodamage || !H.can_bleed)
		if (H.bleeding)
			H.bleeding = 0
			H.bleeding_internal = 0
		//BLOOD_DEBUG("[H] is dead or immortal or otherwise not supposed to bleed, so their bleeding has been set to 0 and bleed damage was canceled")
		return

	if ((!isvampire(H) && H.blood_volume > 0) || (isvampire(H) && H.get_vampire_blood() > 0)) // make sure we have blood to bleed
		if (bloodsplatter) // make sure we want to make bloodsplatter
			bleed(H, damage, 5, T) // actually bleed
			//animate_blood_damage(some_idiot, some_jerk)
		if (isvampire(H)) // we can go now, we don't need to do anything else for vamps
			return
		//BLOOD_DEBUG("[H]'s blood level is [H.blood_volume]")

	else
		H.bleeding = 0 // if we don't have any blood to bleed, just stop okay, just stop.
		H.bleeding_internal = 0
		//BLOOD_DEBUG("[H] has no blood and their bleeding has been set to 0 and bleed damage was canceled")
		return

	if (H.bleeding >= 10) // don't bleed more if you're already at bleeding 10 tia
		//BLOOD_DEBUG("[H]'s bleeding was [H.bleeding] and has been set to 10 and bleed damage was canceled")
		H.bleeding = 10
		return

	var/increase_chance = rand(10, 30)
	var/increase_amount = 1
	//BLOOD_DEBUG("[H]'s initial increase chance is [increase_chance]")

	switch (damage)
		if (-INFINITY to 1)
			increase_amount -= rand(0,2)
		if (1 to 10)
			increase_amount -= rand(0,1)
		if (10 to 30)
			increase_amount += rand(0,1)
		if (30 to INFINITY)
			increase_amount += rand(0,2)
	//BLOOD_DEBUG("[H] processes damage ([damage]): increase_amount now [increase_amount]")

	switch (damage_type)
		if (DAMAGE_STAB)
			increase_chance += rand(0, 10)
			increase_amount += rand(0,1)
		if (DAMAGE_CUT)
			increase_chance += rand(5, 20)
			increase_amount += rand(0,1)
		if (DAMAGE_BLUNT)
			increase_chance -= rand(10, 30)
		if (DAMAGE_BURN)
			if (!H.is_heat_resistant())
				increase_chance -= rand(30, 50)
				increase_amount -= rand(1,2)
	//BLOOD_DEBUG("[H] processes damage_type ([dam_num2name(damage_type)]): increase_chance now [increase_chance], increase_amount now [increase_amount]")

	//BLOOD_DEBUG("[H]'s initial bleeding is [H.bleeding]")
	switch (H.bleeding)
		if (-INFINITY to 0)
			increase_chance += rand(0, 30)
		if (2)
			increase_chance -= rand(0, 10)
			increase_amount -= rand(0,1)
		if (3)
			increase_chance -= rand(0, 30)
			increase_amount -= rand(0,1)
		if (4)
			increase_chance -= rand(10, 30)
			increase_amount -= rand(0,1)
			// increase_amount = 1 // we only have 1 point more of bleeding we can have!
			// commented out above line because what if Increase_amount was below 1? it's clamped later on anyway. so this made getting from 4 -> 5 easier than 3 -> 4
/*	switch (H.bleeding)
		if (-INFINITY to 0)
			increase_chance += rand(30, 50)
		if (1 to 3)
			increase_chance += rand(20, 30)
		if (4 to 6)
			increase_chance += rand(5, 20)
			increase_amount -= rand(0,1)
		if (7 to 8)
			increase_chance += rand(0, 5)
			increase_amount = 1 // it's already pretty high so just set it back to 1
*/
	//BLOOD_DEBUG("[H] processes bleeding: increase_chance now [increase_chance], increase_amount now [increase_amount]")

	if (H.lying)
		increase_chance -= rand(0,15)

	if (H.reagents)
		var/anticoag_amt = H.reagents.get_reagent_amount("heparin")
		if (anticoag_amt)
			increase_chance += clamp(anticoag_amt, 0, 50)
			increase_amount += rand(1, round(clamp((anticoag_amt / 10), 0, 3), 1))
			//BLOOD_DEBUG("[H] processes heparin: increase_chance now [increase_chance], increase_amount now [increase_amount]")

		var/coag_amt = H.reagents.get_reagent_amount("proconvertin")
		if (coag_amt)
			increase_chance -= clamp(coag_amt, 0, 50)
			increase_amount -= rand(1, round(clamp((coag_amt / 10), 0, 3), 1))
			//BLOOD_DEBUG("[H] processes proconvertin: increase_chance now [increase_chance], increase_amount now [increase_amount]")

	if (ischangeling(H))
		increase_chance -= rand(10, 20)
		increase_amount -= rand(0,1)
		//BLOOD_DEBUG("[H] is a changeling - [H]'s increase chance decreased to [increase_chance]")

	if (H.traitHolder && H.traitHolder.hasTrait("hemophilia"))
		increase_chance *= 3
		increase_amount += rand(0,1)

	var/final_increase_chance = round(clamp(increase_chance, 0, 100), 1)
	var/final_increase_amount = round(clamp(increase_amount, 0, 5), 1)
	//var/final_increase_amount = round(clamp(increase_amount, 0, 10), 1)
	//BLOOD_DEBUG("[H]'s final_increase_chance: [final_increase_chance], final_increase_amount: [final_increase_amount]")

	if (final_increase_amount > 0 && prob(final_increase_chance))
		var/old_bleeding = H.bleeding
		H.bleeding += final_increase_amount
		H.bleeding = clamp(H.bleeding, 0, 5)
		//H.bleeding = clamp(H.bleeding, 0, 10)
		if (H.bleeding > old_bleeding) // I'm not sure how it wouldn't be, but, uh, yeah
			if (old_bleeding <= 0)
				H.visible_message("<span class='alert'>[H] starts bleeding!</span>",\
				"<span class='alert'><b>You start bleeding!</b></span>")
			else if (old_bleeding >= 1)
				H.show_text("<b>You[pick(" start bleeding even worse", " start bleeding even more", " start bleeding more", "r bleeding worsens", "r bleeding gets worse")]!</b>", "red")
			else if (old_bleeding >= 4)//9)
				H.show_text("<b>You can't go on very long with blood pouring out of you like this!</b>", "red")

		//BLOOD_DEBUG("[H] rolls bleeding increase, bleeding is now [H.bleeding]</b>")
	else
		//BLOOD_DEBUG("[H]'s bleeding does not increase</b>")
		if (damage_type == DAMAGE_BURN && !H.is_heat_resistant() && H.bleeding > 0)
			if (prob(rand(30,50)))
				repair_bleeding_damage(H, rand(30,50), rand(1,3))
				//BLOOD_DEBUG("[H] rolls bleeding repair due to DAMAGE_BURN</b>")

/* ============================================== */
/* ---------- repair_bleeding_damage() ---------- */
/* ============================================== */

/proc/repair_bleeding_damage(var/mob/some_idiot as mob, var/repair_chance as num, var/repair_amount as num)
	if (!blood_system)
		return

	//BLOOD_DEBUG("[some_idiot] begins bleeding repair")
	if (!isliving(some_idiot))
		return

	var/mob/living/H = some_idiot

	if (H.stat ==  2)
		//BLOOD_DEBUG("[H] is dead and their bleeding has been set to 0 and repair was canceled")
		H.bleeding = 0 // no just stop bleeding entirely okay, you're dead, stop it
		H.bleeding_internal = 0
		return

	if (isvampire(H))
		//BLOOD_DEBUG("[H] is a vampire and their bleeding has been set to 0 and repair was canceled")
		H.bleeding = 0 // bleh im a vampar
		H.bleeding_internal = 0
		return

	if (H.blood_volume <= 0)
		//BLOOD_DEBUG("[H] has no blood and their bleeding has been set to 0 and repair was canceled")
		H.bleeding = 0 // you have no blood so stop trying to bleed
		H.bleeding_internal = 0
		return

	if (repair_amount <= 0)
		//BLOOD_DEBUG("[H]'s repair_amount was set as [repair_amount] so repair was canceled")
		return // you wouldn't have done anything anyway

	if (repair_chance < 100) // if it's already 100 we don't need to go through all the crap down here
		if (H.reagents)
			var/anticoag_amt = H.reagents.get_reagent_amount("heparin")
			if (anticoag_amt)
				repair_chance -= clamp(anticoag_amt, 0, 10)

			var/coag_amt = H.reagents.get_reagent_amount("proconvertin")
			if (coag_amt)
				repair_chance += clamp(coag_amt, 0, 10)

		switch (H.bleeding)
			if (-INFINITY to 0)
				return // there's nothing to fix here, go home
			if (2)
				repair_chance += rand(0, 5)
			if (3)
				repair_chance += rand(5, 10)
			if (4)
				repair_chance += rand(10, 20)
			if (5 to INFINITY)
				repair_chance += rand(20, 30)
		//BLOOD_DEBUG("[H]'s repair chance is now [repair_chance]")
/*		switch (H.bleeding)
			if (-INFINITY to 0)
				BLOOD_DEBUG("[H] isn't bleeding and repair has been stopped")
				return // there's nothing to fix here, go home
			if (1 to 2)
			if (3 to 4)
				repair_chance += rand(0, 5)
			if (5 to 7)
				repair_chance += rand(5, 20)
			if (8 to 9)
				repair_chance += rand(20, 30)
			if (10 to INFINITY)
				repair_chance += rand(30, 50)
		BLOOD_DEBUG("[H]'s repair chance is now [repair_chance]")
*/
	var/final_repair_chance = min(repair_chance, 100)
	//BLOOD_DEBUG("[H]'s final repair chance is [final_repair_chance]")

	if (prob(final_repair_chance))
		H.bleeding -= repair_amount
		//BLOOD_DEBUG("[H]'s bleeding repaired by [repair_amount], now [H.bleeding]")
		if (H.bleeding < 0)
			H.bleeding = 0
			//BLOOD_DEBUG("[H]'s bleeding dropped below 0 and was reset to 0")
		if (H.bleeding && H.get_surgery_status())
			H.bleeding ++
		switch (H.bleeding)
			if (-INFINITY to 0)
				H.visible_message("<span class='notice'>[H]'s bleeding stops!</span>",\
				"<span class='notice'><b>Your bleeding stops!</b></span>")
			if (1 to 3)
				H.show_text("<b>Your bleeding slows down!</b>", "blue")
			if (4 to INFINITY)
				H.show_text("<b>You can't go on very long with blood pouring out of you like this!</b>", "red")
/*		switch (H.bleeding)
			if (-INFINITY to 0)
				H.show_text("<b>Your bleeding stops!</b>", "red")
			if (1 to 8)
				switch (repair_amount)
					if (1 to 3)
						H.show_text("<b>Your bleeding [pick("slows", "slows down", "slightly slows", "slows a little", "gets slightly slower", "barely slows")]!</b>", "red")
					if (4 to 6)
						H.show_text("<b>Your bleeding [pick("slows", "slows down", "slows a lot", "slows down a lot", "really slows down")]!</b>", "red")
					if (7 to 10)
						H.show_text("<b>Your bleeding [pick("slows", "slows down", "slows a lot", "slows down a lot", "really slows down", "slows way down", "nearly stops", "has almost stopped", "is barely a trickle now")]!</b>", "red")
			if (9 to INFINITY)
				H.show_text("<b>You can't go on very long with blood pouring out of you like this!</b>", "red")
*/

	//else
		//BLOOD_DEBUG("[H] rolled no repair")

/* ============================= */
/* ---------- bleed() ---------- */
/* ============================= */

/proc/bleed(var/mob/living/some_idiot, var/num_amount, var/vis_amount, var/turf/T as turf)

	if (!T)
		T = get_turf(some_idiot)

	var/mob/living/H = some_idiot

	if (!blood_system) // we're here because we want to create a decal, so create it anyway


		var/obj/decal/cleanable/blood/dynamic/B = null
		if (T.messy > 0)
			B = locate(/obj/decal/cleanable/blood/dynamic) in T
		var/blood_color_to_pass = DEFAULT_BLOOD_COLOR

		if (some_idiot.blood_id && (some_idiot.blood_id != "blood" && some_idiot.blood_id != "bloodc"))
			var/datum/reagent/current_reagent= reagents_cache[some_idiot.blood_id]
			blood_color_to_pass = rgb(current_reagent.fluid_r, current_reagent.fluid_g, current_reagent.fluid_b, max(current_reagent.transparency,255))

		if (istype(H))
			blood_color_to_pass = H.blood_color

		if (!B) // look for an existing dynamic blood decal and add to it if you find one
			B = make_cleanable( /obj/decal/cleanable/blood/dynamic,T)
			B.color = blood_color_to_pass

		if (ischangeling(H))
			B.ling_blood = 1

		if (some_idiot.bioHolder)
			B.blood_DNA = some_idiot.bioHolder.Uid
			B.blood_type = some_idiot.bioHolder.bloodType

		else
			B.blood_DNA = "--unidentified substance--"
			B.blood_type = "--unidentified substance--"

		B.add_volume(blood_color_to_pass, some_idiot.blood_id, num_amount, vis_amount)
		return

	BLOOD_DEBUG("[some_idiot] begins bleed")

	if (!isliving(some_idiot))
		return

	if (isdead(H) || H.nodamage || !H.can_bleed)
		if (H.bleeding)
			H.bleeding = 0 // stop that
		//BLOOD_DEBUG("[some_idiot] is either dead, immortal, or has can_bleed disabled, so bleed was canceled")
		return

	if (isvampire(H)) // vampires should be special
		if (H.bleeding)
			H.bleeding = 0 // we don't need this to be anything above 0 for vamps
			//BLOOD_DEBUG("[some_idiot] is a vampire with a bleeding above 0, so it was reset to 0")

	if ((!isvampire(H) && H.blood_volume > 0) || (isvampire(H) && H.get_vampire_blood() > 0)) // you shouldn't bleed unless you have blood okay
		//BLOOD_DEBUG("[H] blood level [H.blood_volume]")
		var/obj/decal/cleanable/blood/dynamic/B = null
		if (T.messy > 0)
			B = locate(/obj/decal/cleanable/blood/dynamic) in T

		if (!B) // look for an existing dynamic blood decal and add to it if you find one
			B = make_cleanable( /obj/decal/cleanable/blood/dynamic,T)
			if (H.blood_id)
				B.set_sample_reagent_custom(H.blood_id,0)
			if (H.blood_color)
				B.color = H.blood_color

		if (ischangeling(H))
			B.ling_blood = 1

		B.blood_DNA = some_idiot.bioHolder.Uid
		B.blood_type = some_idiot.bioHolder.bloodType

		if (isvampire(H))
			H.change_vampire_blood(-5) //num_amount // gunna go with a set number as a test
			//BLOOD_DEBUG("[H] bleeds -5 from vamp_blood_remaining and their vamp_blood_remaining becomes [H.get_vampire_blood()]")
		else
			H.blood_volume -= num_amount // time to bleed
			//BLOOD_DEBUG("[H] bleeds [num_amount] and their blood level becomes [H.blood_volume]")

			if (H.blood_volume < 0) // you shouldn't have negative blood okay
				H.blood_volume = 0
				//BLOOD_DEBUG("[H]'s blood volume dropped below 0 and was reset to 0")

		B.add_volume(H.blood_color, H.blood_id, num_amount, vis_amount)
		//BLOOD_DEBUG("[H] adds volume to existing blood decal")

		if (B && B.reagents && H.reagents && H.reagents.total_volume)
			//BLOOD_DEBUG("[H] transfers reagents to blood decal [log_reagents(H)]")
			H.reagents.trans_to(B, min(round(num_amount / 2, 1), 5))
	else
		return

/* ====================================== */
/* ---------- transfer_blood() ---------- */
/* ====================================== */

/proc/transfer_blood(var/mob/living/some_idiot as mob, var/atom/A as obj|mob, var/amount = 5)
	if (!some_idiot || !A || !istype(some_idiot))
		return 0

	var/mob/living/carbon/human/some_human_idiot = null
	if (ishuman(some_idiot))
		some_human_idiot = some_idiot

	if (!A.reagents || (!istype(some_idiot) && !some_idiot.reagents))
		return 0

	if (isvampire(some_idiot) && (some_idiot.get_vampire_blood() <= 0) || (!isvampire(some_idiot) && !some_idiot.reagents && !some_idiot.blood_volume))
		return 0

	var/reagents_to_transfer = (amount / 5) * 2
	var/blood_to_transfer = (amount - min(reagents_to_transfer, some_idiot.reagents.total_volume))

	var/datum/bioHolder/bloodHolder = null

	if (isvampire(some_idiot) && (some_idiot.get_vampire_blood() < blood_to_transfer))
		blood_to_transfer = some_idiot.get_vampire_blood()

	// Ignore that second container of blood entirely if it's a vampire (Convair880).
	if (!isvampire(some_idiot) && (some_idiot.blood_volume < blood_to_transfer))
		blood_to_transfer = some_idiot.blood_volume

	if (!A.reagents.get_reagent("bloodc") && !A.reagents.get_reagent("blood")) // if it doesn't have blood with blood bioholder data already, only then create this
		bloodHolder = new/datum/bioHolder(null)
		bloodHolder.CopyOther(some_idiot.bioHolder)
		bloodHolder.ownerName = some_idiot.real_name

	var/datum/reagent/R = null

	if (ischangeling(some_idiot))
		A.reagents.add_reagent("bloodc", blood_to_transfer, bloodHolder)
		R = A.reagents.get_reagent("bloodc")
	else
		A.reagents.add_reagent(some_idiot.blood_id, blood_to_transfer, bloodHolder)
		R = A.reagents.get_reagent(some_idiot.blood_id)

	if (R && (R.id == "blood" || R.id == "bloodc") && some_human_idiot)
		var/datum/reagent/blood/B = R
		var/list/SP = A.reagents.aggregate_pathogens()
		for (var/uid in some_human_idiot.pathogens)
			if (!(uid in SP))
				var/datum/pathogen/P = unpool(/datum/pathogen)
				P.setup(0, some_human_idiot.pathogens[uid], 0)
				B.pathogens[uid] = P

	// Vampires can't use this trick to inflate their blood count, because they can't get more than ~30% of it back (Convair880).
	if (blood_system && (isvampire(some_idiot) && (some_idiot.get_vampire_blood() >= blood_to_transfer)))
		some_idiot.change_vampire_blood(-blood_to_transfer)

	// Ignore that second container of blood entirely if it's a vampire (Convair880).
	if (blood_system && !isvampire(some_idiot) && (some_idiot.blood_volume >= blood_to_transfer))
		some_idiot.blood_volume -= blood_to_transfer

	if (blood_to_transfer < amount)
		some_idiot.reagents.trans_to(A, (amount - blood_to_transfer))
	return 1

/* =================================== */
/* ---------- blood_slash() ---------- */
/* =================================== */

/proc/blood_slash(var/mob/some_idiot as mob, var/bleed_amount as num, var/atom/A as mob|obj|turf, var/direction, var/splatters = 4)

	var/turf/target
	var/turf/end_target

	if (!some_idiot) // what do you want and also what are you doing here?!
		//BLOOD_DEBUG("blood_slash: not passed a mob, exiting")
		return

	if (!isliving(some_idiot)) // no stop trying to bleed you aren't human
		//BLOOD_DEBUG("blood_slash: passed non-human mob [some_idiot], exiting")
		return

	if (!A) // if we aren't provided with a separate target, use some_idiot
		target = some_idiot.loc
		//BLOOD_DEBUG("blood_slash: no origin point specified, using [some_idiot]'s location")
	else
		target = A.loc
		//BLOOD_DEBUG("blood_slash: origin point set to [A]")

	take_bleeding_damage(some_idiot, null, bleed_amount, DAMAGE_CUT, 1, target)
	//BLOOD_DEBUG("[some_idiot] enters take_bleeding_damage from blood_slash")

	if (!direction) // if we aren't provided with a direction, use some_idiot again
		direction = some_idiot.dir
		//BLOOD_DEBUG("blood_slash: no direction specified, using [some_idiot]'s dir")

	for (var/i = 0, i < splatters, i++)
		switch (direction)
			if (NORTH)
				end_target = locate(target.x, target.y+i, target.z)
			if (SOUTH)
				end_target = locate(target.x, target.y-i, target.z)
			if (EAST)
				end_target = locate(target.x+i, target.y, target.z)
			if (WEST)
				end_target = locate(target.x-i, target.y, target.z)
		bleed(some_idiot, bleed_amount, 5, end_target)
		//BLOOD_DEBUG("[some_idiot] enters bleed from blood_slash")

/* ============================================ */
/* ---------- animate_blood_damage() ---------- */
/* ============================================ */
/*
/proc/animate_blood_damage(var/mob/some_idiot as mob, var/mob/some_jerk as mob)
	DEBUG_MESSAGE("made it into proc")
	if (!ishuman(some_idiot)) // what're we gunna do here?
		return 0

	var/mob/living/carbon/human/H = some_idiot
	var/bcolor = H.blood_color ? H.blood_color : DEFAULT_BLOOD_COLOR // default is #990000 atm, a dark-ish red.

	var/anim_offset_y = 0 // vertical offset
	var/anim_offset_x = 0 // horizontal offset

	if (H.lying) // are we laying around on the floor like some kinda bum?
		DEBUG_MESSAGE("some_idiot [some_idiot] is lying down")
		if (some_jerk) // our attacker, if we've got one
			switch (some_jerk.zone_sel.selecting) // where're they aiming?
				if ("head")
					DEBUG_MESSAGE("some_jerk [some_jerk] is aiming at the head")
					anim_offset_y = rand(-2,-10)
					anim_offset_x = rand(6,12)
				if ("chest" || "l_arm" || "r_arm")
					DEBUG_MESSAGE("some_jerk [some_jerk] is aiming at the chest/arms")
					anim_offset_y = rand(-2,-12)
					anim_offset_x = rand(8,15)
				if ("l_leg" || "r_leg")
					DEBUG_MESSAGE("some_jerk [some_jerk] is aiming at the legs")
					anim_offset_y = rand(0,-12)
					anim_offset_x = rand(-7,-15)
		else // otherwise...
			DEBUG_MESSAGE("some_jerk not passed")
			anim_offset_y = rand(7,-12)
			anim_offset_x = rand(8,-15)
	else // if we aren't on the ground
		DEBUG_MESSAGE("some_idiot [some_idiot] is standing")
		if (some_jerk)
			switch (some_jerk.zone_sel.selecting)
				if ("head")
					DEBUG_MESSAGE("some_jerk [some_jerk] is aiming at the head")
					anim_offset_y = rand(8,14)
					anim_offset_x = rand(-5,3)
				if ("chest" || "l_arm" || "r_arm")
					DEBUG_MESSAGE("some_jerk [some_jerk] is aiming at the chest/arms")
					anim_offset_y = rand(-5,6)
					anim_offset_x = rand(-9,7)
				if ("l_leg" || "r_leg")
					DEBUG_MESSAGE("some_jerk [some_jerk] is aiming at the legs")
					anim_offset_y = rand(-5,-15)
					anim_offset_x = rand(-7,-5)
		else
			DEBUG_MESSAGE("some_jerk not passed")
			anim_offset_y = rand(-15,14)
			anim_offset_x = rand(-9,-7)
/*
	if (!H.blood_damage_image)
		H.blood_damage_image = image('icons/effects/blood.dmi', "bloodhit", FLY_LAYER)
	H.blood_damage_image.icon_state = "bloodhit"
	H.blood_damage_image.pixel_y = anim_offset_y
	H.blood_damage_image.pixel_x = anim_offset_x
	H.blood_damage_image.color = bcolor
	//H.blood_damage_image.transform = turn(H.blood_damage_image.transform, rand(0, 359))
	DEBUG_MESSAGE("anim y [anim_offset_y], anim x [anim_offset_x], blood color [bcolor]")
	DEBUG_MESSAGE("adding overlay [bicon(H.blood_damage_image)]")
	H.UpdateOverlays(H.blood_damage_image, "bdamage_img")
*/
*/
/* ======================================== */
/* ---------- staunch_bleeding() ---------- */
/* ======================================== */

/mob/proc/staunch_bleeding(var/mob/some_idiot) // stolen from ISN's shake_awake() proc
	if (!src || !some_idiot)
		return 0

	if (isliving(some_idiot))
		var/mob/living/H = some_idiot
		var/his_her = "[H.gender == "male" ? "his" : "her"]"

		if (H.being_staunched)
			src.show_text("[H == src ? "You're" : "Someone's"] already putting pressure on [H == src ? "your" : "[H]'s"] wounds!", "red")
			return

		if (H)
			H.add_fingerprint(src) // Just put 'em on the mob itself, like pulling does. Simplifies forensic analysis a bit (Convair880).

//		if (H.w_uniform)
//			H.w_uniform.add_fingerprint(src)

		H.being_staunched = 1

		src.tri_message("<span class='notice'><b>[src]</b> puts pressure on [src == H ? "[his_her]" : "[H]'s"] wounds, trying to stop the bleeding!</span>",\
		src, "<span class='notice'>You put pressure on [src == H ? "your" : "[H]'s"] wounds, trying to stop the bleeding!</span>",\
		H, "<span class='notice'>[H == src ? "You put" : "<b>[src]</b> puts"] pressure on your wounds, trying to stop the bleeding!</span>")

		if (do_mob(src, H, 100))
			var/original_bleed = H.bleeding
			repair_bleeding_damage(H, 20, rand(1,2))

			if (original_bleed > H.bleeding)
				switch (H.bleeding)
					if (-INFINITY to 0)
						src.show_text("The bleeding stops!", "blue")
					if (1 to 3)
						src.show_text("The bleeding slows!", "blue")
					if (4 to INFINITY)
						src.show_text("It barely helps!", "red")
/*					if (-INFINITY to 0)
						src.show_text("The bleeding stops!", "blue")
					if (1 to 8)
						src.show_text("The bleeding slows!", "blue")
					if (9 to INFINITY)
						src.show_text("It barely helps!", "red")
*/
			else if (original_bleed == H.bleeding)
				src.show_text("The bleeding doesn't slow at all!", "red")

			else if (original_bleed < H.bleeding) // what
				src.show_text("Oh fuck somehow the bleeding got WORSE!", "red")

			H.being_staunched = 0
			return 1

		else
			src.show_text("You were interrupted!", "red")
			H.being_staunched = 0
			return 0
	else
		return 0

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=INTERNAL-BLEEDING=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/proc/internal_bleeding_damage(var/mob/some_idiot as mob, var/mob/some_jerk as mob, var/damage as num)
	if (!blood_system)
		return

	if (haine_blood_debug) logTheThing("debug", some_idiot, null, "<b>HAINE BLOOD DEBUG: [some_idiot] begins internal bleed damage proc</b>")

	if (!isliving(some_idiot))
		if (haine_blood_debug) logTheThing("debug", some_idiot, null, "<b>HAINE BLOOD DEBUG: [some_idiot] is not living so internal bleed damage was canceled</b>")
		return

	var/mob/living/H = some_idiot

	if (H.stat ==  2 || H.nodamage || !H.can_bleed || isvampire(H))
		if (H.bleeding)
			H.bleeding = 0
			H.bleeding_internal = 0
		if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG: [H] is dead/immortal/a vampire/otherwise not supposed to bleed, so their bleeding has been set to 0 and internal bleed damage was canceled</b>")
		return

	if (!(H.blood_volume > 0)) // make sure we have blood to bleed
		H.bleeding = 0 // if we don't have any blood to bleed, just stop okay, just stop.
		H.bleeding_internal = 0
		if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG: [H] has no blood and their bleeding has been set to 0 and internal bleed damage was canceled</b>")
		return

	if (H.bleeding_internal >= 10) // don't bleed more if you're already at bleeding 10 tia
		if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG: [H]'s internal bleeding was [H.bleeding_internal] and has been set to 10 and internal bleed damage was canceled</b>")
		H.bleeding_internal = 10
		return

	var/increase_chance = rand(30, 50)
	if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s initial increase chance is [increase_chance]")

	if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s initial internal bleeding is [H.bleeding_internal]")
	switch (H.bleeding_internal)
		if (-INFINITY to 1)
			increase_chance += rand(30, 50)
			if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s increase chance increased to [increase_chance]")
		if (2)
			increase_chance += rand(20, 30)
			if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s increase chance increased to [increase_chance]")
		if (3)
			increase_chance += rand(5, 20)
			if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s increase chance increased to [increase_chance]")
		if (4)
			increase_chance += rand(0, 5)
			if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s increase chance increased to [increase_chance]")
		if (5 to INFINITY)
			if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s internal bleeding was already high and chance was not increased")

	if (some_jerk && some_jerk.zone_sel && some_jerk.zone_sel.selecting)
		if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [some_jerk]'s target zone is [some_jerk.zone_sel.selecting]")
		switch (some_jerk.zone_sel.selecting)
			if ("head")
				increase_chance += rand(0, 10)
				if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s increase chance increased to [increase_chance]")

	if (ischangeling(H))
		increase_chance -= rand(10, 20)
		if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H] is a changeling - [H]'s increase chance decreased to [increase_chance]")

	var/final_increase_chance = min(increase_chance, 100)
	if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG:</b> [H]'s final increase chance is [final_increase_chance]")
	if (prob(final_increase_chance))
		H.bleeding_internal ++
		if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG: [H] rolls internal bleeding increase, internal bleeding is now [H.bleeding_internal]</b>")
	else
		if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG: [H]'s internal bleeding does not increase</b>")
	H.bleeding_internal = clamp(H.bleeding_internal, 0, 5)
	if (haine_blood_debug) logTheThing("debug", H, null, "<b>HAINE BLOOD DEBUG: [H]'s internal bleeding is [H.bleeding_internal] after clamp</b>")

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=MEDICAL-EQUIPMENT=-=-=-=-=-=-=-=-=-=-=-*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/* ---------- BLOOD PROCESSOR ---------- */

/* ._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._. */
/*-=-=-=-=-=-=-=-=-=-=-=-=-TEST=-ITEMS=-=-=-=-=-=-=-=-=-=-=-=-=*/
/* '~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~'-._.-'~' */

/obj/item/test_toilet
	name = "test toilet"
	desc = "this is for testing bleeding stuff"
	w_class = 1.0
	icon = 'icons/obj/objects.dmi'
	icon_state = "toilet"
	flags = FPRINT | CONDUCT | TABLEPASS
	var/damage_type = DAMAGE_CUT

	attack_self(mob/user as mob)
		var/selection = input("Select damage type", "Damage Type", "CUT") as() in list("STAB", "CUT", "BLUNT", "BURN")
		if (!selection)
			return
		switch (selection)
			if ("STAB")
				src.damage_type = DAMAGE_STAB
			if ("CUT")
				src.damage_type = DAMAGE_CUT
			if ("BLUNT")
				src.damage_type = DAMAGE_BLUNT
			if ("BURN")
				src.damage_type = DAMAGE_BURN

	attack(mob/M as mob, mob/user as mob)
		user.visible_message("<span class='combat'><b>[user]</b> attacks [M] with [src], set to <b>[dam_num2name(src.damage_type)]</b>!</span>",\
		"<span class='combat'>You attack [M] with [src], set to <b>[dam_num2name(src.damage_type)]</b>!</span>")
		switch(src.damage_type)
			if (DAMAGE_STAB)
				playsound(M, 'sound/impact_sounds/Flesh_Stab_1.ogg', 30, 1)
			if (DAMAGE_CUT)
				playsound(M, 'sound/impact_sounds/Flesh_Cut_1.ogg', 30, 1)
			if (DAMAGE_BLUNT)
				playsound(M, 'sound/impact_sounds/Metal_Hit_1.ogg', 30, 1)
			if (DAMAGE_BURN)
				playsound(M, 'sound/effects/mag_fireballlaunch.ogg', 30, 1)
		take_bleeding_damage(M, user, 1, src.damage_type)

/obj/item/test_dagger
	name = "test dagger"
	desc = "this is for testing bleeding stuff"
	w_class = 1.0
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "dagger"
	inhand_image_icon = 'icons/mob/inhand/hand_food.dmi'
	item_state = "knife"
	force = 0.0
	throwforce = 0.0
	throw_range = 16
	flags = FPRINT | TABLEPASS | NOSHIELD
	burn_type = 1

	New()
		..()
		BLOCK_SETUP(BLOCK_KNIFE)

	throw_impact(atom/A, datum/thrown_thing/thr)
		if(iscarbon(A))
			if (ismob(usr))
				A:lastattacker = usr
				A:lastattackertime = world.time
			playsound(A, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)
			take_bleeding_damage(A, null, rand(2,3), DAMAGE_STAB)

	attack(target as mob, mob/user as mob)
		..()
		playsound(target, 'sound/impact_sounds/Flesh_Stab_1.ogg', 60, 1)
		take_bleeding_damage(target, user, rand(2,3), DAMAGE_STAB)

/* -------------------- Notes -------------------- */
/*
- cardiac failure should be tweaked to take longer
- add pulses: initro causes extreme tachycardia, cap causes extreme bradycardia
- "Although atropine treats bradycardia (slow heart rate) in emergency settings, it can cause paradoxical heart rate slowing when given at very low doses (i.e. <0.5 mg),[18] presumably as a result of central action in the CNS."
- heart_rate = 80, read as rand((heart_rate-5),(heart_rate+5)) ?
- <SpyGuy> Idea: when stamina regenerates it slightly increases the heart rate.
- <Dions> what about healthy people, like they havent done any of those drugs in like 20 mins since the start of the round
- <Dions> and they get maybe a minor resistance to cardiac failure
- <Dions> maybe a stealth never mentioned ever thing with an apple so that it makes the check the first time you eat an apple instead of the 20 mins mark
*/
/mob/living/proc/ensure_bp_list()
	if (!islist(src.blood_pressure))
		src.blood_pressure = list("systolic"=120,"diastolic"=80,"rendered"="[rand(115,125)]/[rand(78,82)]","total"=500,"status"="NORMAL")
