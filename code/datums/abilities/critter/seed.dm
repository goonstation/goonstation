// a temporary ability for the sappers
// generate a seed which can grow a random structure

/datum/targetable/critter/seed
  name = "Summon Seed"
  desc = "Don't think about why it just arrives. It just does."
  cooldown = 3000
  start_on_cooldown = 0

/datum/targetable/critter/seed/cast(atom/target)
  if (..())
    return 1

  var/turf/T = get_turf(holder.owner)

  playsound(T, 'sound/effects/ghost2.ogg', 100, 1)
  holder.owner.visible_message("<span class='notice'><b>[holder.owner]</b> summons a biotech seed from... somewhere, probably.</span>", "<span class='notice'>You get a biotech seed.[prob(10) ? " Somehow." : ""]</span>")

  new /obj/item/martianSeed(holder.owner.loc)

  holder.owner.say("SUMMON SEED!", 1)
