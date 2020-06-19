client/verb/help()
	set name = "Help"
	src.Browse( {"<ul style='list-style-type:disc'>
		<h3>Overview</h3>
			<p>Space Station 13 was written for BYOND. Like many BYOND games, it is two
			dimensional with a top down view and runs somewhat terribly. It uses tile-based
			movement. Space Station 13 (or SS13 for short) starts you on a space station
			orbiting a very peculiar gaseous planet in a binary star system. Each round
			type is centred around a specific type of disaster, ranging from a crazy wizard
			to a traitor within the crew. The game is constantly being developed,
			so new and exciting features are added all the time!</p>
		<h3>Objectives</h3>
			<p>The primary objective in most modes of Space Station 13 is survival. You must
			try to stay alive long enough to escape on the evacuation shuttle. This
			does not mean you should immediately rush to the escape dock and wall yourself
			in; half the fun is in trying to keep the station running for as long as
			possible. Exactly how you do this is up to you and your assigned job.</p>
		<h3>Getting Started</h3>
			<p>The interface for Space Station 13 is largely click driven. To use something,
			you will almost always click or double click.</p>
		<h3>Movement</h3><p>
			Movement on SS13 normally goes in the 4 cardinal directions. You can also move diagonally by holding two of the respective movement keys.
			If you move into a dense movable object you will try to push it.
			You can right click on an object and select 'pull' to drag it behind you. You can also Control+Click it.
			To stop pulling click the PULL button on your interface, it will lose the highlight.<p>
			To drop to the ground hit the STAND button on the UI. You will lie on the ground and drop items in your hands.
			To return upright hit the REST button.</p>
		<h3>Equipping</h3>
			<p>Items are equipped by placing in either hand or in the proper inventory slot.
			Your backpack gives you more space, and you can carry various toolboxes or use toolbelts to expand your storage.
			The active hand is highlighted in brown in the UI, you can switch hands by clicking on the inactive UI hand-slot or using the middle mouse-button.</p>
		<h3>Talking</h3>
			<p>Type say in the command line and hit enter to bring up a window where to type what you want to say.
			You can also write sentences in the command line by typing say, then space. You can also use the hotkey T in WASD mode.
			These will be heard by all those in hearing range. To speak in your headset use a semicolon after type "say ; phrase".
			Some headset have a department channel, you can speak there using "say :h phrase".
			To see all the channels available to you, examine your headset.</p>
			<p>Say is also used for emotes, they are performed by preceding their name with an asterisk "say *emote".
			Two lists of available emotes are displayed with "say *listbasic" and "say *listtarget".
			Custom emotes can be written by using "say *custom", and typing the actions you want to display in the pop-up window.</p>
		<h3>Taking Items / Giving Items</h3>
		 <p>You can take items from people by dragging from their character sprite onto yours. A screen
			will pop up. From this screen you can select an object to remove from them.
			If you select a 'Nothing' slot then you will attempt to equip that slot with
			the object you are holding.
			To give an object, just use the emote 'give' like "say *give".</p>
		<h3>Death</h3>
			<p>If you are dead then you can use the ghost verb to separate from your dead body and move around.
			Or the observe verb to look through the eyes of another character.</p>
		<h3>Modes</h3>
			<h4>Traitor</h4>
				<p>Several traitors are aboard the space station. Each traitor is
				assigned random objectives, they will steal, murder and sabotage.
				The objective of everyone else is to stop the traitor and survive!</p>
			<h4>Changeling</h4>
				<p>Shapeshifting aliens are mixed with the crew. They will try to kill and absorb crewmembers and finally escape on the shuttle.
				Changelings can assume the identity of anyone they absorbed, do not let them get too close.</p>
			<h4>Wizard</h4>
				<p>The Space Federation of Wizards has scores to settle.
				Magical humans have been dispatched to the station to sow the panic amongst the crew.
				As a crewmember, you must defeat the wizards, or cower in fear until the evacuation shuttle comes.</p>
			<h4>Blob</h4>
				<p>There has been an outbreak of a violent organism that intens to eat the station.
				The blob starts in an area and then grows thanks to the abilities that it can use.
				Regular crewmembers must stop the blob from spreading and taking over the station, normally through the use of fire.</p>
			<h4>Mixed</h4>
				<p>All of the above enemies at once. As well as vampires, wraiths, and more! Undead lords thirsty for blood.
				Vampires increase in strength and powers the more blood the gather. Will you be up to the challenge?</p>
			<h4>Nuclear Emergency</h4>
				<p>A crack team of Syndicate operatives have assaulted the station in order to
				plant a NUCLEAR BOMB. If they get to their target area and you wait enough, the station gets blown to smithereens!
				The crewmembers must destroy or disarm the nuclear bomb or kill the syndicate operatives.</p>
				<p><b>PROTIP: IF YOU KILL A MEMBER OF THE SYNDICATE STEAL HIS STUFF.</b></p>
		<h3>External Links</h3>
			<ul><a target="_blank" href="http://wiki.ss13.co">Goonstation Wiki</a> (The wiki. Beginner and advanced guides.)<br>
			<a target="_blank" href="https://forum.ss13.co">Goonstation Forums</a> (The goonstation forums for discussion and ban appeals)</ul>
	</ul>"}, "window=help;title=Help" )

	//src.Browse('browserassets/html/admin/help.html', "window=help")
	//boutput(src, "<span class='notice'>Please visit the goonstation wiki at <b>http://wiki.ss13.co</b> for more indepth help.</span>")
	return
