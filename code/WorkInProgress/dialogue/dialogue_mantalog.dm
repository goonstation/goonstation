/obj/machinery/mantalog
	name = "computer console"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "randompc"
	density = 1
	anchored = 2
	var/datum/dialogueMaster/dialogue = null

	New()
		dialogue = new/datum/dialogueMaster/mantalog(src)
		..()

	attack_hand(mob/user)
		if(BOUNDS_DIST(user, src) > 0 || user.z != src.z) return
		dialogue.showDialogue(user)
		return

	attack_ai(mob/user as mob)
		return attack_hand(user)

/datum/dialogueMaster/mantalog
	dialogueName = "NSS Manta Bridge Computer"
	start = /datum/dialogueNode/mantalog_start
	visibleDialogue = 0
	maxDistance = 1

/datum/dialogueNode/seeker/mantalog
	linkText = "Return."
	targetNodeType = /datum/dialogueNode/mantalog_start2
	respectCanShow = 1

	getNodeText(var/client/C)
		return "Anything else we can help you with,[C.mob.name]?"

/datum/dialogueNode

	mantalog_start
		nodeImage = "submarine.png"
		linkText = "Return."
		links = list(/datum/dialogueNode/mantalog_start2,/datum/dialogueNode/mantalog_captainslog,/datum/dialogueNode/mantalog_mission)

		getNodeText(var/client/C)
			return "Access to NSS Manta's public bridge computer granted. What can we do for you, [C.mob.name]?"

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_start2
		linkText = "What does this computer do?"
		links = list(/datum/dialogueNode/mantalog_propellers,/datum/dialogueNode/mantalog_junctionboxes,/datum/dialogueNode/mantalog_torpedoes,/datum/dialogueNode/mantalog_comms,/datum/dialogueNode/mantalog_magnets,/datum/dialogueNode/mantalog_captainslog)

		getNodeText(var/client/C)
			return "This computer contains access to NSS Manta's captains logs and a few other helpful documents related to NSS Manta and it's subsystems. What would you like to do, [C.mob.name]?"

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_propellers
		showBackToMain = 0
		nodeImage = "propeller.png"
		linkText = "Tell me more about propellers and movement."
		links = list(/datum/dialogueNode/seeker/mantalog)

		getNodeText(var/client/C)
			return {"<center><h3>Propellers and movement of NSS Manta</h3></center>
	A stationary submarine would be deemed useless in the dangerous waters that Abzu is filled with, so naturally NSS Manta is equipped with eight enormous propellers that allow it to move around freely in the water.
	While NSS Manta is moving, it is ill-advised to exit the ship unless you are going out in a mini-submarine or unless you're equipped with a jetpack that has a magnetic tether attachment on it. (Please, read through the section "Magnetic tether".)
	Caution should also be taken to make sure that the jetpack is fully operational and is turned on.
	<br>
	<br>
	If NSS Manta ever loses control over four or more propellers, the ship will automatically come to a halt until the necessary propellers are repaired. Caution should be used when dealing with propellers as multiple workplace accidents have been reported to
	Nanotrasen due to the propellers."}

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_junctionboxes
		showBackToMain = 0
		nodeImage = "junction.png"
		linkText = "Tell me more about junction boxes."
		links = list(/datum/dialogueNode/seeker/mantalog)

		getNodeText(var/client/C)
			return {"<center><h3>Junction Boxes and electricity onboard NSS Manta</h3></center>
	An extraordinary submarine sadly comes with an extraordinarily large consumption of power. This issue is alleviated by installing multiple high-tech junction boxes all over NSS Manta which help to re-route the power where its needed the most. It is reported
	that these junction boxes have a tendency to malfunction from time to time, but Nanotrasen is unable to confirm this issue at this time. If repairs must be done on the said junction boxes, insulating gloves are recommended.
	<br>
	<br>
	It should be noted that NSS Manta also uses vast amounts of power to stay on the move, to power its shields and to run other normal functions onboard. To help with this task, NSS Manta is equipped with an experimental singularity engine which while unstable, is easily able to
	keep NSS Manta powered for even the longest of voyages."}

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_torpedoes
		showBackToMain = 0
		nodeImage = "torpedo.png"
		linkText = "Tell me more about torpedoes."
		links = list(/datum/dialogueNode/seeker/mantalog)

		getNodeText(var/client/C)
			return {"<center><h3>Torpedoes on NSS Manta</h3></center>
		NSS Manta comes equipped with four different flavors of torpedoes, each of them with a dinstinct functionality. Each of them should be fired off to defeat a specific threat they were designed to neutralize. The following section will cover them more in-depth.<hr>
	<h4>Torpedo variants:</h4>
	<i>Remember, using and blowing up torpedoes aboard NSS Manta is strictly forbidden under Nanotrasen employee contract. Failure to comply this rule may lead to complete bloodline eradication.</i>
	<ul style='list-style-type:disc'>
		<li>Incendiary
			<ul style='list-style-type:circle'>
				<li>Distinguishable by bright red outer shell. Upon contact with the target, two contained liquids inside combine and cause a severe fire to erupt on location. Due to the fire being chemically produced, it may even be used underwater.</li>
			</ul>
		</li>
		<li>Toxic
			<ul style='list-style-type:circle'>
				<li>Distinguishable by a green outer shell. Upon contact with the target, releases the extremely poisonous but yet Space Law sanctioned chemicals in a very nasty gas cloud. Despite certain rumors, it is not recycling the nuclear engine waste.</li>
			</ul>
		</li>
		<li>Explosive
			<ul style='list-style-type:circle'>
				<li>Distinguishable by a blue outer shell. Upon contact with the target, explodes in a violent manner and causes shrapnel to erupt from it's shell.</li>
			</ul>
		</li>
		<li>High-Explosive
			<ul style='list-style-type:circle'>
				<li>Distinguishable by a grey outer shell. Upon contact with target or a hard surface, continues to fly through three, penetrating everything in it's path before exploding in an extremely violently.</li>
			</ul>
		</li>
	<h3>Operating torpedoes</h3><hr>
	<ul style='list-style-type:disc'>
		<li>1) Choose a torpedo that you wish to use. Open the torpedo tube and drag the torpedo onto the tray. Make sure you're not blocking the path of the tray.</li>
		<li>2) Push the tray back in and close the hatch.</li>
		<li>3) Mark your target with the torpedo console. You can exit the console at any time by pressing Q or E.</li>
		<li>4) Await for confirmation orders from the captain,HoP or HoS before you proceed to fire the torpedo by pressing space. </li>
		<li>5) Upon receiving confirmation, destroy your target.</li>
	</ul>"}

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_comms
		showBackToMain = 0
		nodeImage = "comms.png"
		linkText = "Tell me more about the communication systems."
		links = list(/datum/dialogueNode/seeker/mantalog)

		getNodeText(var/client/C)
			return {"<center><h3>Communications aboard NSS Manta</h3></center>
	While NSS Manta can perform almost miraculous dives in the depths of Abzu, those come at the price of communication range. This was offset by Nanotrasen by installing long-range communication dishes that bounce the signal back to the surface and onto the off-planet satellite.
	All of these signals are relayed through the communications tower installed inside the communications office. Should the tower ever become damaged or even destroyed, the dishes will attempt to establish an emergency uplink with Oshan Laboratory, although this will take around eight to ten minutes.
	<br>
	<br>
	Nanotrasen has also hired a communications officer to guard the communication tower and also to keep the crew of NSS Manta informed of on-going affairs that are happening on the ship."}

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_magnets
		showBackToMain = 0
		nodeImage = "magnet.png"
		linkText = "Tell me more about the magnetic tether."
		links = list(/datum/dialogueNode/seeker/mantalog)

		getNodeText(var/client/C)
			return "NSS Manta is equipped with a safety measure for close-by ocean exploration. Jetpacks aboard NSS Manta are directly linked to the Magnetic Tether that can be found in the engineering department. Should the tether ever become damaged, the links will fail and no longer pull anyone towards NSS Manta. Extra caution should be taken to keep the members of the Syndicate away from the Magnetic Tether."

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_mission
		linkText = "Tell me more about NSS Manta's mission."
		links = list()

		getNodeText(var/client/C)
			return {"<center><h3>NSS Manta's Mission</h3></center>
	Not long after Oshan station was built on planet Abzu, Nanotrasen begun the construction of a submarine vessel which would be able to traverse the depths of Abzu with relative ease.
	Equipped with state-of-the-art submarine technology NSS Manta continues to patrol waters around Oshan, keeping it safe from different dangers that lurk in the depths of the planet.
	<br>
	<br>
	Who knows what adventures await NSS Manta?"}

	mantalog_captainslog
		linkText = "I'd like to access the captain's log."
		links = list(/datum/dialogueNode/mantalog_captainslogentry1)

		getNodeText(var/client/C)
			return {"Here you may read through NSS Manta's captain logs that have been made public to the whole crew. These logs represent the past events that have occurred on NSS Manta and there might be hints towards what is still to come. It is often up to the brave crewmembers to push this adventure forward.
			<br>
			<br>
			I wonder where it will take us, [C.mob.name]?"}

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return

	mantalog_captainslogentry1
		linkText = "Entry 1"
		links = list()

		getNodeText(var/client/C)
			return "The NSS Manta has been on ocean floor patrol for approximately four weeks. Crewmen including several heads of staff have mentioned noticing anomalous Green-tinted lights in crevasses, however nothing of substance has been sighted as of yet, It is suspected to be a new kind of fauna or megafauna that feeds off the ocean wildlife. <br> <br> However, our direction changed when on Sept 6th 2053 at exactly 04:59 hours, a distress signal was received from the NSS Polaris, indicating that the ship has run aground in one of Abzu's trenches. However after the initial pass the wreckage of the Polaris could not be found, nor any sign of the Polaris's crew. The Manta is standing by near the beacon and is extending its search radius by sending local deep-sea expedition teams into the deeper recesses via submersible."

		onActivate(var/client/C)
			playsound(C.mob.loc, 'sound/effects/manta_interface.ogg', 50, 1,1)
			return
