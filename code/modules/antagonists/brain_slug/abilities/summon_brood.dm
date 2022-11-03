/datum/targetable/brain_slug/summon_brood
	name = "Summon brood"
	desc = "Break down the last useful parts of this failing body and summon your brood. The body is unlikely to survive."
	icon_state = "slimeshot"
	cooldown = 1 SECONDS
	targeted = 0
	var/max_points = 200

	cast()
		if (holder.points > src.max_points)
			boutput(holder.owner, "<span class='alert'>This body hasnt degraded enough yet! You need [src.max_points] stability or lower to do this!</span>")
			return TRUE
		if (holder.points == 0)
			boutput(holder.owner, "<span class='alert'>This body's ressources are spent!</span>")
			return TRUE
		if (holder.points > 100)
			new/mob/living/critter/small_animal/broodling(holder.owner.loc, holder.owner, 2 MINUTES)
			new/mob/living/critter/small_animal/broodling(holder.owner.loc, holder.owner, 2 MINUTES)
		new/mob/living/critter/small_animal/broodling(holder.owner.loc, holder.owner, 2 MINUTES)
		new/mob/living/critter/small_animal/broodling(holder.owner.loc, holder.owner, 2 MINUTES)
		holder.points = 0
		holder.owner.visible_message("<span class='alert'>[holder.owner] suddenly bends forward and spews out several glob of goo that- OH GOD IT'S ALIVE!!</span>", "<span class='notice'>You turn most of this body's remaining lifeforce into your brood.</span>")
		gibs(holder.owner.loc, headbits = FALSE)
		random_brute_damage(holder.owner, 80)
		return FALSE
