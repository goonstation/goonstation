/datum/simsMotive
	var/name = "motive"
	var/desc = "motive description"
	var/icon = 'icons/mob/hud_human_new.dmi'
	var/icon_state
	var/value = 100
	var/last_life_value = 100
	var/datum/simsHolder/holder
	var/warning_cooldown = 10
	var/depletion_rate = 0.2
	var/image/image_meter = null
	var/image/image_change = null

	//Multipliers for how much the motive is drained by certain things and for how much it is gained
	//High drain rate - higher reduction of motive when explicitly modified
	//High gain rate - higher gain of motive when explicitly modified

	//var/affection_rate = 1
	var/gain_rate = 1
	var/drain_rate = 1

	var/obj/screen/hud/hud = new

	New(var/is_control = 0)
		..()
		SPAWN_DBG(0)
			if (src.holder)
				var/icon/hud_style = hud_style_selection[get_hud_style(src.holder.owner)]
				if (isicon(hud_style))
					src.icon = hud_style
					hud.tooltipTheme = hud_style
			hud.name = name
			hud.icon = icon
			hud.icon_state = icon_state
			hud.layer = HUD_LAYER

			updateHud()
			if (!is_control)
				var/datum/simsMotive/M = simsController.motives[type]
				if (M && istype(M))
					depletion_rate = M.depletion_rate
					gain_rate = M.gain_rate
					drain_rate = M.drain_rate

			simsController.register_motive(src)

	disposing()
		if (hud)
			qdel(hud)
			hud = null
		simsController.simsMotives -= src
		..()

	disposing()
		if (hud)
			qdel(hud)
		..()

	proc/updateHud()
		var/change = 0
		if (value > last_life_value)
			change = min(1 + round((value - last_life_value) / 5), 3)
		if (value < last_life_value)
			change = -min(1 + round((last_life_value - value) / 5), 3)
		if (change)
			if (!src.image_change)
				src.image_change = image(src.icon, "change[change]", layer = HUD_LAYER+2)
			else
				src.image_change.icon_state = "change[change]"
			src.hud.UpdateOverlays(src.image_change, "change")
		else
			src.hud.UpdateOverlays(null, "change")
		//var/a_change = value - last_life_value
		var/maptext_color = "#ffffff"
		var/round_value = round(value)
		switch (round_value)
			if (90 to INFINITY)
				maptext_color = "#88ff88"
			if (70 to 89)
				maptext_color = "#41bf41"
			if (50 to 69)
				maptext_color = "#ffff00"
			if (30 to 49)
				maptext_color = "#ff8000"
			if (25 to 48)
				maptext_color = "#ff0000"
			else
				maptext_color = "#b30b0b"
		//hud.name = "[initial(name)] ([value] / 100) \[[a_change > 0 ? "+" : null][a_change]\]"
		hud.name = "[initial(name)] -  Your current total is: <span class='sh vb r ps2p' style='color: [maptext_color];'>[round_value]%</span>"
		hud.desc = "[initial(desc)]"
		var/ratio = value / 100
		if (!src.image_meter)
			src.image_meter = image(src.icon, "[src.icon_state]-o", layer = HUD_LAYER+1)
		src.image_meter.color = rgb((1 - ratio) * 255, ratio * 255, 0)
		src.hud.UpdateOverlays(src.image_meter, "meter")

	proc/updateHudIcon(var/icon/I)
		if (!I || !src.hud)
			return
		src.icon = I
		src.hud.icon = I
		if (src.image_change)
			src.hud.UpdateOverlays(null, "change")
			src.image_change.icon = I
			src.hud.UpdateOverlays(src.image_change, "change")
		if (src.image_meter)
			src.image_meter.icon = I
			src.updateHud()

	proc/showOwner(var/msg)
		boutput(holder.owner, msg)

	proc/modifyValue(var/amt)
		var/prev_value = value
		var/affection_mod = amt < 0 ? drain_rate : gain_rate //Negative change, use drain modifier, positive, use gain modifier

		value = max(min(value + (amt * affection_mod), 100), 0)
		if (prev_value < 100 && value >= 100)
			onFill()
		else if (prev_value > 0 && value <= 0)
			onDeplete()
		if (prev_value != value)
			onChange()
			if (prev_value < value)
				onIncrease()
			else
				onDecrease()

	proc/Life()
		updateHud()
		last_life_value = value
		if (mayStandardDeplete())
			modifyValue(-depletion_rate)
		if (warning_cooldown <= 0)
			var/warning = getWarningMessage()
			if (warning)
				showOwner(warning)
				warning_cooldown = 40
		else
			warning_cooldown--
		onLife()

	proc/mayStandardDeplete()
		if (holder && holder.owner && (holder.owner.nodamage || holder.owner.hibernating))
			value = 100
			return 0
		return 1

	proc/getWarningMessage()
	proc/onLife()
	proc/onDeplete()
	proc/onFill()
	proc/onChange()
	proc/onIncrease()
	proc/onDecrease()

	hunger
		name = "Hunger"
		icon_state = "hunger"
		desc = "Hunger can be raised by eating various edible items, more complex dishes raise your hunger more."
		depletion_rate = 0.078
		var/starve_message = "<span class='alert'>You are starving to death!</span>"

		var/starving = 0

		onDeplete()
			if (!starving)
				showOwner(starve_message)
				starving++

		onFill()
			starving = 0

		getWarningMessage()
			if (value < 25)
				return pick("<span class='alert'>You are [pick("utterly", "absolutely", "positively", "completely", "extremely", "perfectly")] [pick("starving", "unfed", "ravenous", "famished")]!</span>", "<span class='alert'>You feel like you could [pick("die of [pick("hunger", "starvation")] any moment now", "eat a [pick("donkey", "horse", "whale", "moon", "planet", "star", "galaxy", "universe", "multiverse")]")]!</span>")
			else if (value < 50)
				return "<span class='alert'>You feel [pick("hungry", "peckish", "ravenous", "undernourished", "famished", "esurient")]!</span>"
			else if (value < 75)
				return "<span class='alert'>You feel [pick("a bit", "slightly", "somewhat", "a little", "faintly")] [pick("hungry", "peckish", "famished")]!</span>"
			else
				return null

		/*onLife()
			if (starving && value < 25)
				starving++
				if (!(starving % 10))
					showOwner(starve_message)
				if (starving > 30 && prob(10))
					holder.owner.death()
			else if (starving && value > 50)
				starving--*/

		thirst
			name = "Thirst"
			icon_state = "thirst"
			desc = "Thirst can be raised by drinking various liquids. Certain liquids can also lower your thirst."
			starve_message = "<span class='alert'>You are dying of thirst!</span>"
			depletion_rate = 0.0909

			getWarningMessage()
				if (value < 25)
					return pick("<span class='alert'>You are [pick("utterly", "absolutely", "positively", "completely", "extremely", "perfectly")] dry!</span>", "<span class='alert'>You feel [pick("like you could die of thirst any moment now", "as dry as [pick("sand", "the moon", "solid carbon dioxide", "bones")]")]!</span>")
				else if (value < 50)
					return "<span class='alert'>You feel [pick("thirsty", "dry")]!</span>"
				else if (value < 75)
					return "<span class='alert'>You feel [pick("a bit", "slightly", "somewhat", "a little", "faintly")] [pick("thirsty", "dry")]!</span>"
				else
					return null


	social
		name = "social"
		icon_state = "social"
		depletion_rate = 0.18
		var/criminal = -1 //-1 unset, 0 law-abiding citizen, 1 traitor

		mayStandardDeplete()
			if (..())
				if (!ticker || !ticker.mode)
					return 0
				//Let's save the results of this so we're not doing a bunch of thingy in list every life cycle
				if (criminal > 0)
					return 0
				else if(criminal < 0 || prob(5)) //But let's refresh it once / 20 cycles or so
					criminal = (holder.owner.mind in ticker.mode.traitors) || (holder.owner.mind in ticker.mode.Agimmicks)
					return !criminal
				return 1

		getWarningMessage()
			if (value < 25)
				return "<span class='alert'>You really feel like talking to someone, or you might [pick("go crazy", "go insane", "go nuts", "become unhinged", "become a lunatic", "become totally gaga", "go loco", "go bonkers", "go stark mad", "go mad")]!</span>"
			else if (value < 50)
				return "<span class='alert'>You feel [pick("rather ", "quite ", "moderately ", "kind of ", "pretty ", null)]socially deprived!</span>"
			else if (value < 75)
				return "<span class='alert'>You could go for a [pick("good", "nice", "long", "short", "great", "pleasant", "delightful", "friendly")] [pick("conversation", "chat", "discussion", "talk", "social exchange", "banter", "head-to-head", trim("t[ascii2text(234)]te-[ascii2text(224)]-t[ascii2text(234)]te"))] right now.</span>"
			else
				return null

		onDeplete()
			holder.owner.contract_disease(/datum/ailment/disease/space_madness, null, null, 1)
			if (ishuman(holder.owner))
				var/mob/living/carbon/human/H = holder.owner
				if (!H.pathogens.len)
					holder.owner.infected(ez_pathogen(/datum/pathogeneffects/malevolent/serious_paranoia))

		onLife()
			if (value < 10 && prob((10 - value) * 10))
				onDeplete()

	hygiene
		name = "Hygiene"
		icon_state = "hygiene"
		desc = "Hygiene can be raised by either taking a shower or a bath."
		depletion_rate = 0.061

		var/protection = 20

		mayStandardDeplete()
			if (..())
				if (protection > 0)
					protection--
					return 0
				return 1

		onIncrease()
			protection = round(value / 5)

		onLife()
			if (value < 15 && prob(33))
				if (holder.owner.bioHolder && !(holder.owner.bioHolder.HasEffect("sims_stinky")))
					holder.owner.bioHolder.AddEffect("sims_stinky")
			/*
			if (value < 10 && prob((10 - value) * 1.5))
				for (var/mob/living/carbon/human/H in viewers(2, holder.owner))
					if (H != holder.owner && prob(30 - value) * 2)
						//H.stunned = max(holder.owner.stunned, 1) <- Let's not punish others for our poor choices in life - unrealistic but more fun
						H.vomit()
						H.visible_message("<span class='alert'>[H] throws up all over \himself. Gross!</span>")
						boutput(H, "<span class='alert'>You are [pick("disgusted", "revolted", "repelled", "sickened", "nauseated")] by [holder.owner]'s [pick("smell", "odor", "body odor", "scent", "fragrance", "bouquet", "savour", "tang", "whiff")]!</span>")
				holder.owner.changeStatus("stunned", 1 SECOND)
				holder.owner.visible_message("<span class='alert'>[holder.owner] throws up all over \himself. Gross!</span>")
				holder.owner.vomit()
				showOwner("<span class='alert'>You are [pick("disgusted", "revolted", "repelled", "sickened", "nauseated")] by your own [pick("smell", "odor", "body odor", "scent", "fragrance", "bouquet", "savour", "tang", "whiff")]!</span>")
			*/
			#ifdef CREATE_PATHOGENS //PATHOLOGY_REMOVAL
			if (value < 5 && prob(1))
				var/datum/pathogen/P = unpool(/datum/pathogen)
				P.create_weak()
				holder.owner.infected(P)
				showOwner("<span class='alert'>You don't feel well.</span>")
			#endif

		getWarningMessage()
			if (value < 25)
				return pick("<span class='alert'>You [pick("smell", "stink", "reek")]!</span>", "<span class='alert'>You are [pick("absolutely", "utterly", "completely")] [pick("disgusting", "revolting", "repellent", "sickening", "nauseating", "stomach-churning", "gross")]!</span>", "<span class='alert'><b>Take a [pick("shower", "bath")]!</b></span>")
			else if (value < 50)
				return "<span class='alert'>You feel [pick("smelly", "stinky", "unclean", "filthy", "dirty", "a bit disgusting", "grimy", "mucky", "foul", "unwashed", "begrimed", "tainted")]!</span>"
			else if (value < 75)
				return "<span class='alert'>You feel [pick("a bit", "slightly", "somewhat", "a little", "faintly")] [pick("unclean", "dirty", "filthy", "stinky", "smelly")].</span>"
			else
				return null

	bladder
		name = "Bladder"
		icon_state = "bladder"
		desc = "You can raise your bladder by releasing your urges in the toilet. Be sure to stand above a toilet and type '*pee'."
		depletion_rate = 0.067 //53
		gain_rate = 1

		getWarningMessage()
			var/list/urination = list("urinate", "piss", "pee", "answer the call of nature", "wee-wee", "spend a penny", "have a leak", "take a leak", "relieve yourself", "have a Jimmy", "have a whizz", "have a piddle", "pass water", "empty the tank", "flush the buffers", "lower the water level", "pay the water bill", "park your breakfast", "make your bladder gladder", "release the pressure", "put out the fire", "visit the urination station", "drain the tank")
			var/to_urinate = pick(urination)
			if (value < 25)
				return "<span class='alert'>You feel like you could [pick("wet", "piss", "pee", "urinate into", "leak into")] your pants any minute now!</span>"
			else if (value < 50)
				return "<span class='alert'>You feel a [pick("serious", "pressing", "critical", "dire", "burning")] [pick("inclination", "desire", "need", "call", "urge", "motivation")] to [to_urinate]!</span>"
			else if (value < 75)
				return "<span class='alert'>You feel a [pick("slight", "tiny", "faint", "distant", "minimal", "little")] [pick("inclination", "desire", "need", "urge", "call", "motivation")] to [to_urinate].</span>"
			else
				return null

		onDeplete()
			showOwner("<span class='alert'><b>You piss all over yourself!</b></span>")
			modifyValue(100)
			holder.affectMotive("Hygiene", -100)
			holder.owner.changeStatus("stunned", 2 SECONDS)
			if (ishuman(holder.owner))
				var/mob/living/carbon/human/H = holder.owner
				if (H.w_uniform)
					var/obj/item/clothing/U = H.w_uniform
					U.add_stain("piss-soaked")
					//U.name = "piss-soaked [initial(U.name)]"
				else if (H.wear_suit)
					var/obj/item/clothing/U = H.wear_suit
					U.add_stain("piss-soaked")
					//U.name = "piss-soaked [initial(U.name)]"
			make_cleanable(/obj/decal/cleanable/urine,holder.owner.loc)

	comfort
		name = "comfort"
		icon_state = "comfort"
		depletion_rate = 0.25
		gain_rate = 1.5

		mayStandardDeplete()
			if (..())
				if (holder.owner.buckled)
					return 0
				if (locate(/obj/stool/chair) in holder.owner.loc)
					return 0
				if (holder.owner.lying && (locate(/obj/stool/bed) in holder.owner.loc))
					return 0
				return 1

		getWarningMessage()
			if (value < 25)
				return "<span class='alert'>You really [pick("need", "require", "feel the need for", "are in need of")] the [pick("hug", "feeling", "embrace", "comfort")] of a soft [pick("sofa", "bed", "chair", "pillow")]!</span>"
			else if (value < 50)
				return "<span class='alert'>You feel like [pick("sitting down", "lying down", "you need a bit of comfort")]!</span>"
			else if (value < 75)
				return "<span class='alert'>You feel [pick("slightly", "minimally", "a tiny bit", "a little", "just a bit")] uncomfortable.</span>"
			else
				return null

		onLife()
			if (holder.owner.lying && (locate(/obj/stool/bed) in holder.owner.loc))
				modifyValue(5)
				return
			var/obj/stool/chair/the_chair = locate(/obj/stool/chair) in holder.owner.loc
			if (the_chair)
				modifyValue(the_chair.comfort_value)

	fun
		name = "fun"
		icon_state = "fun"
		depletion_rate = 0.25

		mayStandardDeplete()
			if (..())
				if (isrestrictedz(holder.owner.z))
					return 0
				if (!ticker || !ticker.mode)
					return 0
				if ((holder.owner.mind in ticker.mode.traitors) || (holder.owner.mind in ticker.mode.Agimmicks))
					return 0
				return 1

		getWarningMessage()
			if (value < 25)
				return "<span class='alert'>You are [pick("<b>so</b>", "so very", "painfully", "extremely", "excruciatingly", "rather uncomfortably")] bored![prob(25)? " You'd rather die!" : null]</span>"
			else if (value < 50)
				return "<span class='alert'>You're [pick("quite", "rather", "super", "really", "pretty", "moderately", "very")] bored!</span>"
			else if (value < 75)
				return pick("<span class='alert'>You feel like doing something fun.</span>", "<span class='alert'>You feel a bit bored.</span>")
			else
				return null

		onDeplete()
			if (prob(10))
				showOwner("<span class='alert'><b>You can't take being so bored anymore!</b></span>")
				if (ishuman(holder.owner))
					var/mob/living/carbon/human/H = holder.owner
					H.force_suicide()
					modifyValue(50)

		onLife()
			if (value < 10)
				onDeplete()

	room
		name = "room"
		icon_state = "room"
		depletion_rate = 0

		mayStandardDeplete()
			if (..())
				return 0

		getWarningMessage()
			var/a_mess = pick("mess", "clusterfuck", "disorder", "disarray", "clutter", "landfill", "dump")
			if (value < 25)
				return "<span class='alert'>This place is a [pick("fucking", "complete", "total", "downright", "consummate", "veritable", "proper")] [a_mess].</span>"
			else if (value < 50)
				return "<span class='alert'>This place is a [a_mess]!</span>"
			else if (value < 75)
				return "<span class='alert'>This place is a [pick("bit of a mess", "bit messy", "little messy")].</span>"
			else
				return null

		onLife()
			var/area/Ar = get_area(holder.owner)
			if (Ar)
				value = Ar.sims_score
			else
				value = 0

	energy
		name = "Energy"
		icon_state = "energy"
		desc = "You can raise your energy by entering a bed, right-clicking on it and selecting 'sleep in'. Certain other substances may also increase your energy."
		depletion_rate = 0.07

		gain_rate = 1

		var/forced_sleep = 0

		mayStandardDeplete()
			if (..())
				// JFC fuck mobs
				if (holder.owner.getStatusDuration("weakened"))
					return 0
				if (holder.owner.getStatusDuration("paralysis"))
					return 0
				if (holder.owner.lying)
					return 0
				if (holder.owner.sleeping)
					return 0
				if (holder.owner.hasStatus("resting"))
					return 0
				return 1

		onLife()
			var/mob/living/L = holder.owner
			if (forced_sleep)
				if (value < 25)
					if (!L.hasStatus("resting"))
						showOwner("<span class='alert'>You overworked yourself and cannot wake up until you are minimally rested!</span>")
						L.setStatus("resting", INFINITE_STATUS)
					L.sleeping += 1
				else
					forced_sleep = 0
					L.sleeping = 0
			if (L.hasStatus("resting"))
				var/sm = 1
				if (forced_sleep)
					sm *= 0.5
				if (locate(/obj/stool/bed) in holder.owner.loc)
					sm *= 2
				modifyValue(sm)

		onDeplete()
			showOwner("<span class='alert'><b>You cannot stay awake anymore!</b></span>")
			forced_sleep = 1
			modifyValue(5)

		getWarningMessage()
			if (value < 25)
				return "<span class='alert'>You're [pick("extremely", "seriously", "incredibly", "tremendously", "overwhelmingly")] [pick("tired", "exhausted", "weary", "fatigued", "drowsy", "spent", "drained", "jaded")].</span>"
			else if (value < 50)
				return "<span class='alert'>You feel [pick("rather", "quite", "very", "pretty", "really")] [pick("tired", "sleepy", "drowsy")]!</span>"
			else if (value < 75)
				return "<span class='alert'>You feel [pick("somewhat", "a bit", "slightly", "a little", "a little bit", "a tiny bit")] tired.</span>"
			else
				return null


	sanity
		name = "Sanity"
		icon_state = "sanity"
		desc = "Your sanity slowly increases by itself, but you can speed that up with certain substances or by making sure that your mind won't be further afflicted."
		depletion_rate = 0.0

		gain_rate = 0.1

		onLife()

		onDeplete()

		getWarningMessage()

/datum/simsControl
	var/list/motives = list()
	var/list/datum/simsHolder/simsHolders = list()
	var/list/datum/simsMotive/simsMotives = list()

#ifdef RP_MODE
	var/provide_plumbobs = 0
#else
	var/provide_plumbobs = 1
#endif

	New()
		..()
		SPAWN_DBG(1 SECOND) //Give it some time to finish creating the simsController because fak
			for (var/M in childrentypesof(/datum/simsMotive))
				motives[M] = new M(1)
#ifdef RP_MODE
			SPAWN_DBG(0)
				set_multiplier(1)
#endif

	Topic(href, href_list)
		usr_admin_only
		if (href_list["mot"])
			var/datum/simsMotive/M = locate(href_list["mot"])
			if (!istype(M) || M != motives[M.type])
				return
			if (href_list["rate"])
				var/dep = input("Enter new depletion rate.", "Depletion rate", M.depletion_rate) as null|num
				if (isnull(dep))
					return
				set_global_sims_var(M,"depletion_rate", dep)

			else if (href_list["gain"])
				var/gain = input("Enter new gain rate.", "Gain rate", M.gain_rate) as null|num
				if (isnull(gain))
					return
				set_global_sims_var(M, "gain_rate", gain)
			else if (href_list["drain"])
				var/drain = input("Enter new drain rate.", "Drain rate", M.drain_rate) as null|num
				if (isnull(drain))
					return
				set_global_sims_var(M, "drain_rate", drain)

			showControls(usr)
		else if (href_list["profile"])
			var/mod = text2num(href_list["profile"])
			if (!isnum(mod))
				mod = input("Enter custom profile rate.", "Custom rate") as null|num
				if (!isnum(mod))
					return
			set_multiplier(mod)
			showControls(usr)
		else if (href_list["toggle_plum"])
			src.toggle_plumbobs()
			showControls(usr)
		else
			return

	proc/toggle_plumbobs()
		provide_plumbobs = !provide_plumbobs
		for (var/datum/simsHolder/SH in simsHolders)
			if (SH.plumbob)
				qdel(SH.plumbob)

	proc/register_motive(var/datum/simsMotive/SM)
		if(!(SM in src.simsMotives))
			simsMotives += SM

	proc/register_simsHolder(var/datum/simsHolder/SH)
		if(!(SH in src.simsHolders))
			simsHolders += SH

	proc/set_multiplier(var/mult) //Set a profile on all simsMotives
		if(!isnum(mult)) return
		for(var/datum/simsMotive/SM in simsMotives)
			//SM.gain_rate = initial(SM.gain_rate) * mult
			SM.drain_rate = initial(SM.drain_rate) * mult
			SM.depletion_rate = initial(SM.depletion_rate) * mult

	proc/set_global_sims_var(var/datum/simsMotive/M, var/var_name, var/new_value) //Change one value on every simsHolder
		if(!(var_name in M.vars))
			logTheThing("debug", null, null, "<B>SpyGuy/Sims:</B> Tried to set \"[var_name]\" var on simsMotive [M] but could not find it in vars list.")
			return
		for(var/datum/simsMotive/SM in simsMotives)
			if(SM.type == M.type)
				SM.vars[var_name] = new_value

	proc/showControls(var/mob/user)
		var/o = "<html><head><title>Motive Controls</title><style>"
		o += "</style></head><body>"

		o += {"<a href='?src=\ref[src];toggle_plum=1'>Plumbobs: [provide_plumbobs ? "On" : "Off"]</a><br>

				<h3>Profiles</h3>
				<table style='font-size:80%'><tr>
				<td><a href='?src=\ref[src];profile=ham'>Custom</a></td>
				<td><a href='?src=\ref[src];profile=0.6'>RP Default(0.3)</a></td>
				<td><a href='?src=\ref[src];profile=0.2'>V. Low (0.2)</a></td>
				<td><a href='?src=\ref[src];profile=0.4'>Low (0.4)</a></td>
				<td><a href='?src=\ref[src];profile=0.6'>Med-low (0.6)</a></td>
				<td><a href='?src=\ref[src];profile=1'>Standard (1)</a></td>
				<td><a href='?src=\ref[src];profile=1.5'>High (1.5)</a></td>
				<td><a href='?src=\ref[src];profile=2'>Very High (2)</a></td>
				<td><a href='?src=\ref[src];profile=4'>Doom (4)</a></td>
				</tr></table>"}
		o += "<table><tr><td><b>Name</b></td><td><b>Standard depletion rate</b></td><td><b>Gain rate</b></td><td>Drain rate</td></tr>"
		for (var/T in motives)
			var/datum/simsMotive/M = motives[T]
			o += {"<tr>
				<td><b>[M.name]</b></td>
				<td><a href='?src=\ref[src];mot=\ref[M];rate=1'>[M.depletion_rate]</a>% per second</td>
				<td><a href='?src=\ref[src];mot=\ref[M];gain=1'>[M.gain_rate]</a> ([M.gain_rate * 100]%)</td>
				<td><a href='?src=\ref[src];mot=\ref[M];drain=1'>[M.drain_rate]</a> ([M.drain_rate * 100]%)</td>
				</tr>"}

		o += "</table>"
		o += "</body></html>"
		user.Browse(o, "window=sims_controller;size=500x400")


var/global/datum/simsControl/simsController = new()

/datum/simsHolder
	var/list/motives = list()
	var/mob/living/owner
	var/obj/effect/plumbob/plumbob = null
	var/base_mood_value = 1.35
	var/start_y = 3

	human
		start_y = 3
		make_motives()
			addMotive(/datum/simsMotive/hunger)
			addMotive(/datum/simsMotive/hunger/thirst)
			addMotive(/datum/simsMotive/social)
			addMotive(/datum/simsMotive/hygiene)
			addMotive(/datum/simsMotive/bladder)
			addMotive(/datum/simsMotive/comfort)
			addMotive(/datum/simsMotive/fun)
			addMotive(/datum/simsMotive/energy)
			addMotive(/datum/simsMotive/room)

	rp
		start_y = 5
		make_motives()
			addMotive(/datum/simsMotive/hunger)
			addMotive(/datum/simsMotive/hunger/thirst)
			addMotive(/datum/simsMotive/hygiene)
			//addMotive(/datum/simsMotive/bladder)
			//addMotive(/datum/simsMotive/energy)
			//addMotive(/datum/simsMotive/sanity)

	New(var/mob/living/L)
		..()
		owner = L
		simsController.register_simsHolder(src)
		make_motives()
		add_hud()

	proc/make_motives()

	proc/add_hud()
		if (owner && ishuman(owner))
			var/SY = src.start_y
			var/mob/living/carbon/human/H = owner
			for (var/name in motives)
				var/datum/simsMotive/M = motives[name]
				var/obj/screen/hud/hud = M.hud
				hud.screen_loc = "NORTH-[SY],EAST"
				SY++
				H.hud.add_screen(hud)

	proc/cleanup()
		if (owner && ishuman(owner))
			var/mob/living/carbon/human/H = owner
			for (var/name in motives)
				var/datum/simsMotive/M = motives[name]
				var/obj/screen/hud/hud = M.hud
				H.hud.remove_screen(hud)
			if (plumbob && islist(H.attached_objs))
				H.attached_objs -= plumbob
				plumbob.set_loc(null)
		if (plumbob)
			qdel(plumbob)
			plumbob = null
		for (var/name in motives)
			qdel(motives[name])
		motives.len = 0
		simsController.simsHolders -= src

	disposing()
		cleanup()
		..()

	proc/updateHudIcons(var/icon/I)
		if (!I || !src.motives.len)
			return
		for (var/name in motives)
			var/datum/simsMotive/M = motives[name]
			if (M)
				M.updateHudIcon(I)

	proc/getMoodActionMultiplier()
		if (!motives || !motives.len)
			return 1
		if (!base_mood_value)
			base_mood_value = 1
		var/mv = motives.len * 100
		var/cv = 0
		for (var/motive in motives)
			var/datum/simsMotive/M = motives[motive]
			cv += M.value
		return cv / mv * base_mood_value

	proc/addMotive(var/mt)
		var/datum/simsMotive/M = new mt
		if (initial(M.name) in motives)
			return
		motives[initial(M.name)] = M
		M.holder = src

	proc/getValue(var/name)
		if (name in motives)
			var/datum/simsMotive/M = motives[name]
			return M.value

	proc/affectMotive(var/name, var/affection)
		if (owner.nodamage)
			return
		if (name in motives)
			var/datum/simsMotive/M = motives[name]
			M.modifyValue(affection)

	proc/Life()
		if (disposed)
			return

		for (var/name in motives)
			var/datum/simsMotive/M = motives[name]
			M.Life()

		if (!base_mood_value)
			base_mood_value = 1
		var/color_t = getMoodActionMultiplier() / base_mood_value

		if(simsController && simsController.provide_plumbobs)
			if (!plumbob)
				attach_plum(owner)

			plumbob.color = rgb((1 - color_t) * 255, color_t * 255, 0)
			plumbob.light.set_color(1 - color_t, color_t, 0)

/obj/effect/plumbob
	name = "plumbob"
	icon = 'icons/obj/junk.dmi'
	icon_state = "plum-desat"
	mouse_opacity = 0
	anchored = 1.0
	pixel_y = 32
	var/mob/living/owner
	var/datum/light/light

	New()
		..()
		animate_bumble(src, Y1 = 32, Y2 = 30, slightly_random = 0)
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.5)
		light.enable()

	// relay procs
	attackby(obj/item/W as obj, mob/user as mob)
		if (owner)
			owner.attackby(W, user)

	attack_hand(mob/user as mob)
		if (owner)
			owner.attack_hand(user)

	attack_ai(mob/user as mob)
		if (owner)
			owner.attack_ai(user)

/proc/attach_plum(var/mob/M as mob in world)
	if (!M)
		M = input("Please, select a player!", "Attach Plumbob") as null|anything in mobs
	var/obj/effect/plumbob/P = new(get_turf(M))
	if (!islist(M.attached_objs))
		M.attached_objs = list()
	M.attached_objs += P
	P.owner = M
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.sims)
			H.sims.plumbob = P
