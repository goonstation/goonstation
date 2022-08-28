// a temporary ability for the martian leader
// needs reworking

/datum/targetable/critter/summon
  name = "Summon Martian"
  desc = "Pull a fellow member of the collective through space to you."
  cooldown = 300
  start_on_cooldown = 0

/datum/targetable/critter/summon/cast(atom/target)
  if (..())
    return 1

  // first get a valid turf to move them to
  var/turf/T = get_turf(holder.owner)
  var/list/adjacentTurfs = T.AdjacentTurfs()
  if(length(adjacentTurfs) < 1)
    boutput(holder.owner, "<span class='alert'>There's no space to summon anyone! Get to a more open area first.</span>")
    return 1
  else
    T = pick(adjacentTurfs)

  // now pick the lucky bastard who gets a free ride through space and time like a cosmic yo-yo
  var/list/otherMartians = list()
  var/list/martianNames = list()
  for(var/mob/living/M in mobs)
    if(M == holder.owner)
      continue // what would be the point of teleporting us to ourselves. WHAT WOULD BE THE POINT
    if (ismartian(M))
      var/category = "UNKNOWN"
      if (ishuman(M))
        category = "DIPLOMAT" // martian diplomat
      else if (istype(M, /mob/living/critter/martian))
        var/mob/living/critter/martian/C = M
        category = uppertext(C.martian_type)
      var/name = "[category]: [M.real_name]"
      otherMartians[name] = M
      martianNames |= name

  if(length(otherMartians) < 1)
    boutput(holder.owner, "<span class='alert'>There are no other martians to summon. You're on your own!</span>")
    return 1

  sortList(martianNames, /proc/cmp_text_asc)

  var/chosenName = input("Who should be summoned?", "Summon", martianNames[1]) in martianNames
  var/mob/living/critter/martian/martian = otherMartians[chosenName]

  if(martian)
    martian.set_loc(T)
    elecflash(T,power = 3)

    playsound(T, 'sound/effects/ghost2.ogg', 100, 1)
    holder.owner.visible_message("<span class='notice'><b>[holder.owner]</b> summons [martian.name]!</span>", "<span class='notice'>You pull [martian.real_name] through space to you!</span>")
    holder.owner.say("SUMMON!", 1)
