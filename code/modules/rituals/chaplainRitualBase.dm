var/list/globalRitualComponents = list()
var/list/globalRitualAnchors = list() //Global list of ritual anchors used for ritual checks and spells.
var/list/globalRituals = list() //Global list of rituals.

#define RITUAL_BUTTON_SCALE 0.6 //Base size is 32x32px
#define RITUAL_BUTTONS_PER_SIDE 2
#define RITUAL_ANCHOR_RANGE 4

#define RITUAL_FLAG_CORE 1       //Components with this flag implement behaviour that can be used as a core spell.
#define RITUAL_FLAG_CREATE 2     //Components with this flag implement behaviour that can spawn objects.
#define RITUAL_FLAG_MODIFY 4 	   //Components with this flag implement behaviour that modifies objects. Either change stats or throw the object around or whatever.
#define RITUAL_FLAG_ENERGY 8      //Components with this flag implement behaviour that modifies ritual energy.
#define RITUAL_FLAG_SELECT 32 	//Components with this flag implement behaviour that selects targets. (and puts them in the ritual vars)
#define RITUAL_FLAG_PERSIST 64   //If there's a component with this flag, the ritual wont self-destruct on casting.
#define RITUAL_FLAG_STRENGTH 128 //Components with this flag implement behaviour that modifies ritual strength.
#define RITUAL_FLAG_CONSUME 256 //Components with this flag implement behaviour that consumes or destroys things in the ritual. used for sacrifices etc
#define RITUAL_FLAG_RANGE 512   //Implements behaviour that modifies range or AOE range inside ritualvars.
#define RITUAL_FLAG_HOLY 1024 //Reduces corruption level of ritual. Actually modify it inside flag_corruption.
#define RITUAL_FLAG_UNHOLY 2048 //Increases corruption level of ritual. Actually modify it inside flag_corruption.
#define RITUAL_FLAG_SECRET 4096 //Only used to hide flags in the tooltip. for secret components.

#define RITUAL_BASE_RANGE 4 //Base range of ritual targeting etc.

/atom/var/datum/ritualComponent/ritualComponent = null

/proc/checkRituals(var/datum/ritualComponent/anchor/A)
	for(var/datum/ritual/R in globalRituals)
		return R.tryExecute(A)
	return 0

/datum/ritual
	var/persistent = 0 //If 1, does not destroy components at the end of the spell.

	proc/tryExecute(var/datum/ritualComponent/anchor/A) //Return 1 on success.
		return 0

	custom //Custom is core directly above anchor, then add other components to taste.
		tryExecute(var/datum/ritualComponent/anchor/A)
			. = 0
			if(A)
				var/turf/above = locate(A.owner.x, A.owner.y+1, A.owner.z)
				for(var/atom/T in above)
					if(T.ritualComponent && (T.ritualComponent.ritualFlags & RITUAL_FLAG_CORE))
						var/datum/ritualVars/V = newRitualVars()
						V.invoker  = usr
						for(var/mob/M in view(RITUAL_BASE_RANGE, T))
							if (M.job == "Chaplain")
								V.energy += 2
								V.strength += 2
								V.chaplainBoosted++
						V.core = T
						V.coreAdjacent = T.ritualComponent.getAdjacentFlagged(0) //Core adjacent components are reserved for core usage.
						for(var/datum/ritualComponent/C in (A.getFlagged(RITUAL_FLAG_HOLY) + A.getFlagged(RITUAL_FLAG_UNHOLY)) - V.coreAdjacent) //Increase and decrease corruption. Done first to allow the other components to make use of it.
							V = C.flag_corruption(V)
						for(var/datum/ritualComponent/C in A.getFlagged(RITUAL_FLAG_CONSUME) - V.coreAdjacent) //Consume first, then store power/strength in the components themselves. (If applicable)
							C.flag_consume()
							V.used += C
						for(var/datum/ritualComponent/C in A.getFlagged(RITUAL_FLAG_ENERGY) - V.coreAdjacent) //Use power inside components/let components mod power/strength, store changed values in ritualvars datum.
							V = C.flag_power(V,1)
							//V.used += C
						for(var/datum/ritualComponent/C in A.getFlagged(RITUAL_FLAG_STRENGTH) - V.coreAdjacent) //^^
							V = C.flag_strength(V,1)
							//V.used += C
						for(var/datum/ritualComponent/C in A.getFlagged(RITUAL_FLAG_RANGE) - V.coreAdjacent) //Same but for range/AOE.
							V = C.flag_range(V)
							V.used += C

						//Same but for targets. Only use the closest and exclude things that have been used already.
						var/datum/ritualComponent/selector = A.getClosestFlagged(RITUAL_FLAG_SELECT, V.used + V.coreAdjacent)
						if(selector != null)
							V = selector.flag_select(V)
							V.used += selector
						if(V.energy < 1)
							return "The ritual fails due to a lack of energy!"

						//logging
						var/adj_names = ""
						for(var/datum/ritualComponent/C in V.coreAdjacent)
							adj_names += "[C.name],"
						logTheThing(LOG_STATION, V.invoker, "activated ritual (e=[V.energy],s=[V.strength]) at [get_turf(T)] with core [T.name] and adjacent:[adj_names].")

						//Actually do the thing and pass in our ritualvars. ritual vars should be passed into every proc called so components can modify power and strength during their excecution even if they dont have the flag.
						T.ritualComponent.flag_core(V)

						. = 1
						break
			return .

/proc/newRitualVars(var/power=1, var/strength=1)
	var/datum/ritualVars/V = new()
	V.energy = power
	V.strength = strength
	return V

/datum/ritualVars
	var/energy = 1 //Energy is what limits the amount of components a ritual can have. If your ritual uses more energy than it provides, it fizzles
	var/strength = 1 //Strength is what modifies the strength of the actual effects applied. For example, how much damage a thing does.
	var/corrupted = 0 //Ritual is corrupted. Heals do damage everything gets wonky. TBI. Necromancy.

	var/aoe = 0 //Aoe range. Size of the AOE.
	var/range = 0 //Range mod. Range of targeting or other effects in the ritual.
	var/list/targets = list() //List of targets.
	var/list/used = list() //List of used components. Used to prevent double usage of components in some cases.
	var/list/coreAdjacent = list() //List of components directly adjacent to core.

	var/chaplainBoosted = 0
	var/dir = 0			//UNUSED ATM: might want to use for directio, not sure yet.
	var/datum/ritualComponent/core
	var/mob/invoker				//The guy that activated this ritual.

/datum/ritualComponent
	var/id = ""
	var/name = "EMPTY NAME"
	var/icon_symbol = ""
	var/desc = "THIS IS AN EMPTY DESCRIPTION THIS IS AN EMPTY DESCRIPTION THIS IS AN EMPTY"
	var/bg = "bttbg"
	var/atom/owner = null
	var/datum/ritualComponent/anchor/ownerAnchor = null
	var/prototype = 0
	var/selectable = 1 //If 0, is not selectable in chalk by default.
	var/autoActive = 0 //Does not need to be invoked. Always active.
	var/persistent = 0 //If 1, will not be deleted on ritual completion. (Including parent object)

	var/active = 0 //Is this activated? Once all components in a ritual are active, it is cast.
	var/filterList = list()

	var/ritualFlags = 0 //Tells us what a specific instance of component implements. So you set the flag and then actually implement the proc. I wish we had interfaces.

	proc/flag_core(var/datum/ritualVars/V)
		return
	proc/flag_create(var/datum/ritualVars/V, var/atom/loc, var/applyaoe = 1)
		return list()
	proc/flag_power(var/datum/ritualVars/V, var/consume=1)
		return V
	proc/flag_strength(var/datum/ritualVars/V, var/consume=1)
		return V
	proc/flag_select(var/datum/ritualVars/V)
		return list()
	proc/flag_range(var/datum/ritualVars/V)
		return list()
	proc/flag_modify(var/datum/ritualVars/V, var/atom/A, var/applyaoe = 1)
		return A
	proc/flag_consume()
		return
	proc/flag_corruption()
		return

	proc/hasFlags(var/flags)
		if(flags == 0) return 1
		else return (ritualFlags & flags)

	proc/showEffect(var/atom/location, var/datum/ritualVars/ritVars)
		return

	New(atom/A)
		owner = A
		. = ..()
		if(prototype || !owner) return

		owner.ensure_listen_tree()
		owner.listen_tree.AddListenInput(LISTEN_INPUT_OUTLOUD)
		owner.listen_tree.AddListenEffect(LISTEN_EFFECT_RITUAL)

		if(!istype(src, /datum/ritualComponent/anchor))
			findAnchor()

	disposing()
		breakLinks()
		filterList = null
		if(istype(owner))
			owner.listen_tree.RemoveListenInput(LISTEN_INPUT_OUTLOUD)
			owner.listen_tree.RemoveListenEffect(LISTEN_EFFECT_RITUAL)
			owner.ritualComponent = null
			qdel(owner)
			owner = null
		. = ..()

	proc/getFlagged(var/flags = 0, var/list/excludeList = list())
		var/datum/ritualComponent/anchor/A = null
		var/list/retList = list()
		if(istype(src,/datum/ritualComponent/anchor))
			A = src
		else
			if(ownerAnchor)
				A = ownerAnchor
		if(A)
			for(var/datum/ritualComponent/C in A.linkedComponents)
				if(C.hasFlags(flags) && !(C in excludeList))
					retList.Add(C)
		return retList

	proc/getAdjacentFlagged(var/flags = 0, var/list/excludeList = list(src)) //Get components directly adjacent to this one with the given flags
		var/datum/ritualComponent/anchor/A = null
		var/list/retList = list()
		if(istype(src,/datum/ritualComponent/anchor))
			A = src
		else
			if(ownerAnchor)
				A = ownerAnchor
		if(A)
			var/list/eligible = A.getFlagged(flags)
			for(var/datum/ritualComponent/R in eligible)
				if(excludeList.len && (R in excludeList)) continue
				if(BOUNDS_DIST(R.owner, src.owner) == 0 && R != src)
					retList.Add(R)
		return retList

	proc/getClosestFlagged(var/flags = 0, var/list/excludeList = list(src))
		var/datum/ritualComponent/anchor/A = null
		if(istype(src,/datum/ritualComponent/anchor))
			A = src
		else
			if(ownerAnchor)
				A = ownerAnchor
		if(A)
			var/datum/ritualComponent/selected = null
			var/list/eligible = A.getFlagged(flags)
			for(var/datum/ritualComponent/R in eligible)
				if(excludeList.len && (R in excludeList)) continue
				if(R == src) continue
				if(!selected || get_dist(R.owner, src.owner) < get_dist(selected.owner, src.owner))
					selected = R
			if(selected) return selected
		return null

	proc/breakLinks()
		if(ownerAnchor?.linkedComponents)
			ownerAnchor.linkedComponents.Remove(src)
			ownerAnchor = null
		return

	proc/hear(datum/say_message/message)
		if(istype(ownerAnchor) && findtext(lowertext(message.content), lowertext(name)) )// && BOUNDS_DIST(owner, M) == 0)
			if(!active)
				setActive(1)
				ownerAnchor.tryFire(message.speaker)
		return

	proc/setActive(var/val)
		if(active && !val)
			active = 0
			if(owner)
				owner.clear_filters()
		else if(!active && val)
			active = 1
			if(owner)
				owner.clear_filters()
				owner.add_filter("ritual_outline", 0, outline_filter(size=1, color="#FFFFFF"))
				owner.add_filter("ritual_drop_shadow", 0, drop_shadow_filter(x=0, y=0, offset=0, size=1, color="#FFFFFF"))
				animate(owner.get_filter("ritual_drop_shadow"), size = 0, time = 0)
				animate(size = 5, time = 10)
		return

	proc/showConnection()
		if(prototype) return
		if(ownerAnchor && ownerAnchor.owner)
			particleMaster.SpawnSystem(new /datum/particleSystem/ritual(get_turf(owner.loc), get_turf(ownerAnchor.owner)))
		return

	proc/findAnchor() //Finds the closest nearby anchor and assigns itself to it.
		if(prototype) return
		var/datum/ritualComponent/anchor/closest = null
		if(istype(src, /datum/ritualComponent/anchor)) return
		for(var/datum/ritualComponent/anchor/A in globalRitualAnchors)
			if(A.prototype) continue
			if(get_dist(A.owner, src.owner) <= RITUAL_ANCHOR_RANGE)
				if(closest == null || get_dist(A.owner, src.owner) < get_dist(closest.owner, src.owner))
					closest = A
		if(closest)
			setAnchor(closest)
		return

	proc/setAnchor(var/datum/ritualComponent/anchor/A)
		if(prototype) return
		if(istype(src, /datum/ritualComponent/anchor)) return

		if(A)
			ownerAnchor = A
			ownerAnchor.linkedComponents.Add(src)
		else
			ownerAnchor = null
			findAnchor()

		showConnection()
		return

	anchor
		name = "Ritual anchor"
		icon_symbol = "anchor"
		bg = "bttbg2"
		desc = "Every ritual requires an anchor to link the other sigils together."

		var/list/linkedComponents = list()

		New(atom/o)
			. = ..(o)
			if(prototype) return
			globalRitualAnchors.Add(src)
			linkComponents()

		hear()
			return

		breakLinks()
			for(var/datum/ritualComponent/C in linkedComponents)
				C.setAnchor(null)
			return ..()

		disposing()
			globalRitualAnchors.Remove(src)
			breakLinks()
			return ..()

		proc/tryFire(var/mob/M)
			if(checkActive())
				execute()

				if(getClosestFlagged(RITUAL_FLAG_PERSIST) == null)
					destroyNetwork()
				else
					for(var/datum/ritualComponent/C in linkedComponents)
						C.setActive(0)
			return

		proc/checkActive()
			for(var/datum/ritualComponent/C in linkedComponents)
				if(C == src) continue //should never happen.
				if(C.autoActive) continue
				if(!C.active) return 0
			return 1

		proc/execute()
			var/result = checkRituals(src)
			if(result == 1)
				playsound(get_turf(owner), 'sound/effects/ritual.ogg', 100, 0)
				ritualEffect(get_turf(owner), "ritualeffect",  50, 1, PLANE_SELFILLUM)
			else if(istext(result))
				owner.visible_message(SPAN_ALERT("<b>[result]</b>"), SPAN_ALERT("<b>You hear a strange noise!</b>"))
			else
				owner.visible_message(SPAN_ALERT("<b>The ritual fails!</b>"), SPAN_ALERT("<b>You hear a hissing noise!</b>"))
			return

		proc/destroyNetwork()
			var/datum/ritualComponent/anchor/A = src
			src = null //Decouple from src so the spawn doesnt abort
			for(var/datum/ritualComponent/C in A.linkedComponents)
				C.breakLinks()
				if(!C.persistent)
					SPAWN(rand(1,14))
						playsound(get_turf(C.owner), 'sound/effects/poof.ogg', 100, 1)
						ritualEffect(get_turf(C.owner), "poof")
						qdel(C)
			playsound(get_turf(A.owner), 'sound/effects/poof.ogg', 100, 1)
			ritualEffect(get_turf(A.owner), "poof")
			qdel(A)
			return

		proc/linkComponents() //Finds all nearby components and links them to this anchor. Inverse of findAnchor. Does not affect components that already have links.
			if(prototype) return
			if(owner)
				for(var/atom/movable/A in range(RITUAL_ANCHOR_RANGE, owner))
					if(istype(A.ritualComponent, /datum/ritualComponent/anchor)) continue
					if(A.ritualComponent && A.ritualComponent.ownerAnchor == null && !A.ritualComponent.prototype)
						A.ritualComponent.setAnchor(src)
			return

/atom/disposing()
	src.ritualComponent?.dispose()
	src.ritualComponent = null
	..()

/datum/bioEffect/hidden/sacrificed
	name = "Sacrificed"
	desc = "Subject appears to have been emptied of its life essense."
	id = "sacrificed"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0

	OnMobDraw()
		if (..())
			return
		if(ishuman(owner))
			owner:body_standing:overlays += image('icons/mob/human.dmi', "husk")

	OnAdd()
		owner.color = rgb(40, 20, 20)
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H:set_body_icon_dirty()

			qdel(H.organHolder)
			H.organHolder = new(H)
		. = ..()

	OnRemove()
		. = ..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H:set_body_icon_dirty()
