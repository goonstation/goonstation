/*

Basic flow / Layout:
	Any object may have a /datum/ritualComponent inside it's ritualComponent var. This enables the object to be part of rituals in some way, defined by the datum.
	All the sigils are ritualComponent datums.
	If you want to make a fridge a potential ritual component just give it a ritualComponent and it will link up and behave like any sigil. See /obj/item/ritualskull.
	autoActive on ritualComponent datums let's them be an active part of rituals without you having to say or do anything, they will always be "active" in their linked network.

	The basic flow is that an object hears something and, if it has a ritual component, this is forwarded to that component datum. (proc/hear_talk)
	The normal process is then to activate that component if what was said matches the component. After that we try to activate the ritual on our anchor.
	This will check if all component in the network have been activated. If they are all active, we go through a list of all /datum/ritual and see if we find any matches.
	If you want to add fixed rituals with special conditions, this is where you do it. Add a new subclass of /datum/ritual and do your checks in (tryExecute).
	Currently only custom rituals are implemented, see below.

Custom rituals:
	ritualVars hold variables that are passed and modified between the ritual components as the rituals "unfolds". They hold things like AOE size, energy, strength etc.
	custom rituals need a RITUAL_FLAG_CORE component above the anchor. RITUAL_FLAG_CORE Components implement the actual logic for custom rituals.
	A core would do things like spawn objects or modify them. Core logic is place in the flag_core proc.
	You'll probably want to add a define and a flag proc for new core components.
	For evoco, which spawns things, that would be RITUAL_FLAG_CREATE and flag_create, for example. That way you can easily tie different components together.

	The current order of execution in custom rituals exists out of neccesity. We want to consume before we use stuff from consume for energy etc.
	and we want to have energy sorted out by the time we get to the actual effects. yadda yadda.

	Core components will only use components directly next to them to determine their effects. Evoco will only use a bee component to summon bees if it is right next to the evoco component.
	Components used this way are excluded from the secondary effects, like targeting. If you want to summon a human on a human you need a human component next to the evoco
	and another one at least 2 tiles away from the evoco.

	datum/ritual/custom's current behaviour begins by calling flag_consume on all components marked with a RITUAL_FLAG_CONSUME.
	Components flagged with this implement behaviour that destroys things to achieve something.
	However, flag_consume is mainly responsible for destroying said things and then setting some values for later use inside the component.
	Sacrificum for example, consumes things on it and then stores the power inside a var on the component, inside flag_consume.
	Later that power is used in flag_power in the same component to provide power.

	The next steps are RITUAL_FLAG_ENERGY / flag_power and RITUAL_FLAG_STRENGTH / flag_strength.
	these are responsible for modifying the energy and strength vars inside the ritualvars.
	It's here that sacrificum would turn the previous stored values into actual energy inside the ritualvars.
	All these mean however is that the component modifies these values in some way, so if you want to add an energy cost for your component etc, this is the place.

	After these we move on to RITUAL_FLAG_RANGE / flag_range.
	This one will modify either range or AOE values inside the ritualvars in some way.
	Please note that you'll have to implement your own handling for AOE and range inside new core components etc.
	Currently evoco, for example, will call flag_create which is set up to check if we have AOE and spawn weaker versions of the single target thing if we do.

	After that comes RITUAL_FLAG_SELECT / flag_select.
	These select (a) target(s) and place them inside the ritualvars.
	It's important to note that this specific step will only only the closest valid selection component, not including ones that were already used for some other previous step.
	It only uses the closest component because we don't want people to target literally everything by adding all selection components to a ritual.
	The reason for excluding pre-used components is to prevent some funky interactions in components with both flag_range and flag_select. etc.

	To add new capabilities you'll have to add a flag proc and and appropriate flag for it.
	After that tie them into the logic of /datum/ritual/custom where appropriate.
	If it's something that modifies values inside the ritualvars, make sure it comes before flag_core, otherwise you'll modify the value after the effect is already done.
	The flags and corresponding procs exists to let you find component that have certain capabilities and then execute those.
	This can be done by calling proc/getFlagged or proc/getClosestFlagged in any /datum/ritualComponent.
	This will return a components matching the flags and may include the component that called the proc. (This can be avoided with the exclusion list that can be passed into these procs)
	All components in the current network are considered - nearby components belonging to a different network, or anchor, will not be found.

	After all of that we check if we still have at least 1 energy in the ritualvars. If not, the ritual fails due to a lack of energy.
	Otherwise we finally call flag_core on our core component above the anchor. This actually does the stuff using the values inside our ritualvars.

	They way most component are set up right now is that we take our targets and then apply our effects to them and anything inside the aoe centered on them.
	So if you have 3 targets and 1 AOE radius each of the targets plus everything around them (within 1 range) will be affected.

Ritual vars:
	The ritualvars datum is passed around the different components in the ritual which modify or use the values.
	It just serves as a package that contains all relevant variables that might be used during a ritual's execution.
	Currently it contains these variables:

	Energy is the energy of the ritual - do we have enough energy for this thing to fire at all? do we have excess? etc.

	Strength describes the actual strength of the effects themselves, how much healing something does ... how powerful of a thing is created.
	For reference, currently 1-3 strength is considered very low and 30-infinity is considered very high powered.

	AOE is the range around each target that is also affected. This needs to be handled appropriately in new core components or new flag_create / flag_modify to take into account that AOE should be weaker.

	Range is the range modifier used for targeting (flag_select) or other effects.

	Targets is the list of targets provided by our selection component.

	Used is a list of components that have already been used in the ritual up to that point.

	Corrupted tells us if a ritual has been corrupted one way or another. You can use this in whatever way you want. Could increase it to more than one and have different stages of corruption.
	In terms of gameplay effects corruption should either invert the effects of components or corrupt them in some way, turn em evil, whatever - go wild.

	Feel free to add more variables to the ritualvars as required for new gameplay/components.

Various notes:
	- Make sure that you give components the appropriate flags. flag_create on a component will not be considered unless it has RITUAL_FLAG_CREATE in it's flags, etc.
	- If you add new flags / procs make sure to tie them into the custom ritual code or they won't do a thing.
	- I would recommend that you add appropriate tooltips flags in the /atom/movable/screen/chalkButton if you add new flags.
	- Try to keep things as modular as possible to allow people to combine things. On their own these components are boring - strange combinations is where the emergent gameplay comes from.

*/
