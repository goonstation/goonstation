///////////////////////////////////////////////
// FERMID LIMBS (basically tweaked bee limbs)
///////////////////////////////////////////////

/datum/limb/small_critter/fermid // can hold slightly larger things than base small critter
  max_wclass = W_CLASS_NORMAL
  actions = list("jabs", "prods", "pokes", "taps")
  sound_attack = 'sound/impact_sounds/Flesh_Stab_1.ogg'

/datum/limb/mouth/small/fermid
  dam_low = 1
  dam_high = 4
  var/list/bite_adjectives = list("vicious","vengeful","violent")

  harm(mob/target, var/mob/user)
    if (!user || !target)
      return 0
    if (!target.melee_attack_test(user))
      return
    src.custom_msg = "<b><span class='combat'>[user] bites [target] with [his_or_her(user)] [pick(src.bite_adjectives)] mandibles!</span></b>"
    ..()

///////////////////////////////////////////////
// FERMID
///////////////////////////////////////////////

/mob/living/critter/fermid
  name = "fermid"
  desc = "Extremely hostile asteroid-dwelling bugs. Best to avoid them wherever possible."
  icon_state = "fermid"
  icon_state_dead = "fermid-dead"
  speechverb_say = "clicks"
  speechverb_exclaim = "clacks"
  speechverb_ask = "chitters"
  speechverb_gasp = "rattles"
  speechverb_stammer = "click-clacks"
  density = 1
  can_throw = 1
  can_grab = 1
  can_disarm = 1
  hand_count = 3
  reagent_capacity = 100
  add_abilities = list(/datum/targetable/critter/bite/fermid_bite,
	                  	/datum/targetable/critter/sting/fermid,
											/datum/targetable/critter/slam_polymorph)
  var/unified_health = 25
  var/firevuln = 0.1
  var/brutevuln = 1
  var/limb_path = /datum/limb/small_critter/fermid
  var/mouth_path = /datum/limb/mouth/small/fermid

/mob/living/critter/fermid/setup_hands()
  ..()
  var/datum/handHolder/HH = hands[1]
  HH.limb = new src.limb_path
  HH.icon = 'icons/mob/hud_human.dmi'
  HH.icon_state = "handl"
  HH.name = "left feet"
  HH.limb_name = "foot"

  HH = hands[2]
  HH.limb = new src.limb_path
  HH.icon = 'icons/mob/hud_human.dmi'
  HH.icon_state = "handr"
  HH.name = "right feet"
  HH.limb_name = "foot"

  HH = hands[3]
  HH.limb = new src.mouth_path
  HH.icon = 'icons/mob/critter_ui.dmi'
  HH.icon_state = "mouth"
  HH.name = "mouth"
  HH.limb_name = "mandibles"
  HH.can_hold_items = 0

/mob/living/critter/fermid/setup_healths()
  add_hh_flesh(unified_health, brutevuln)
  add_hh_flesh_burn(unified_health, firevuln)
  add_health_holder(/datum/healthHolder/toxin)
  add_health_holder(/datum/healthHolder/brain)

/mob/living/critter/fermid/specific_emotes(var/act, var/param = null, var/voluntary = 0)
  switch (act)
    if ("scream","hiss","chitter")
      if (src.emote_check(voluntary, 50))
        playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
        return "<b>[src]</b> chitters!"
    if ("snap","clack","click","clak")
      if (src.emote_check(voluntary, 50))
        playsound(src, 'sound/items/Scissor.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
        return "<span class='alert'><b>[src]</b> claks!</span>"
  return null

/mob/living/critter/fermid/specific_emote_type(var/act)
  switch (act)
    if ("scream","hiss","chitter")
      return 2
    if ("scream","hiss","chitter")
      return 3
  return ..()

/mob/living/critter/fermid_polymorph
  name = "fermid"
  desc = "Extremely hostile asteroid-dwelling bugs. This one looks particularly annoyed about something."
  icon_state = "fermid"
  icon_state_dead = "fermid-dead"
  speechverb_say = "clicks"
  speechverb_exclaim = "clacks"
  speechverb_ask = "chitters"
  speechverb_gasp = "rattles"
  speechverb_stammer = "click-clacks"
  density = 1
  can_throw = 1
  can_grab = 1
  can_disarm = 1
  hand_count = 3
  reagent_capacity = 100
  add_abilities = list(/datum/targetable/critter/bite/fermid_bite, /datum/targetable/critter/sting/fermid_polymorph, /datum/targetable/critter/slam_polymorph)
  var/unified_health = 50
  var/firevuln = 0.1
  var/brutevuln = 1
  var/limb_path = /datum/limb/small_critter/fermid
  var/mouth_path = /datum/limb/mouth/small/fermid

/mob/living/critter/fermid_polymorph/setup_hands()
  ..()
  var/datum/handHolder/HH = hands[1]
  HH.limb = new src.limb_path
  HH.icon = 'icons/mob/hud_human.dmi'
  HH.icon_state = "handl"
  HH.name = "left feet"
  HH.limb_name = "foot"

  HH = hands[2]
  HH.limb = new src.limb_path
  HH.icon = 'icons/mob/hud_human.dmi'
  HH.icon_state = "handr"
  HH.name = "right feet"
  HH.limb_name = "foot"

  HH = hands[3]
  HH.limb = new src.mouth_path
  HH.icon = 'icons/mob/critter_ui.dmi'
  HH.icon_state = "mouth"
  HH.name = "mouth"
  HH.limb_name = "mandibles"
  HH.can_hold_items = 0

/mob/living/critter/fermid_polymorph/setup_healths()
  add_hh_flesh(unified_health, brutevuln)
  add_hh_flesh_burn(unified_health, firevuln)
  add_health_holder(/datum/healthHolder/toxin)
  add_health_holder(/datum/healthHolder/brain)

/mob/living/critter/fermid_polymorph/specific_emotes(var/act, var/param = null, var/voluntary = 0)
  switch (act)
    if ("scream","hiss","chitter")
      if (src.emote_check(voluntary, 50))
        playsound(src, 'sound/voice/animal/bugchitter.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
        return "<b>[src]</b> chitters!"
    if ("snap","clack","click","clak")
      if (src.emote_check(voluntary, 50))
        playsound(src, 'sound/items/Scissor.ogg', 80, 1, channel=VOLUME_CHANNEL_EMOTE)
        return "<span class='alert'><b>[src]</b> claks!</span>"
  return null

/mob/living/critter/fermid_polymorph/specific_emote_type(var/act)
  switch (act)
    if ("scream","hiss","chitter")
      return 2
    if ("scream","hiss","chitter")
      return 3
  return ..()


///////////////////////////////////////////////
///////////////////////////////////////////////
// STUPID GIMMICKRY BY CIRR BELOW HERE
///////////////////////////////////////////////
///////////////////////////////////////////////

///////////////////////////////////////////////
// FERMID WORKER
///////////////////////////////////////////////
// /mob/living/critter/fermid/worker

///////////////////////////////////////////////
// FERMID QUEEN
///////////////////////////////////////////////
// /mob/living/critter/fermid/queen

///////////////////////////////////////////////
// FERMID GRUB
///////////////////////////////////////////////
// /mob/living/critter/fermid/grub

///////////////////////////////////////////////
// FERMID EGG
///////////////////////////////////////////////
