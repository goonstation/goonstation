# Goonstation Mapping Guide

Goonstation doesn't have any specific mapping guide for our version of the game,
however there is another highly detailed pair of guides made by san7890 of /tg/station.

*Some elements of these may not apply to Goonstation code or practices. They also might not explain things necessary for our code.*

[The first](https://hackmd.io/@tgstation/SyVma0dS5) is a comprehensive quick-start guide for anyone wishing to get their toes started in mapping but have absolutely zero idea where to start.

[The second](https://hackmd.io/@tgstation/ry4-gbKH5) is more of a reference for those who already know how to map.


If you are creating a new map for Goonstation, we have the following mapping guidelines that must be adhered to:

## Goonstation Mapping Guidelines

{%hackmd @ZeWaka/dark-theme %}

## :heavy_exclamation_mark:Required:heavy_exclamation_mark: 

###### These are fundamental map features that need to be checked to be working prior to submission.

If these features do not work in the current codebase then your map PR will be **rejected** and ineligible for resubmission for a full calendar month.

- Crates should be able to be ordered from cargo, and arrive where expected **without player intervention**. Sitting in a few-tile conveyor "airlock"  is fine (see Destiny), sitting outside because the door did not open at all is not; missing the conveyor entirely is definitely not fine.
- Crates should be able to be sold from cargo from the expected conveyor belt **without player intervention**. Having to open a few-tile conveyor "airlock" is fine (see Destiny).
- **Access levels** (for both doors and machinery, e.g. NanoMeds, AI turrets) should be correct. Missing a small handful is acceptable, but if excess access levels are incorrect (at the coders' discretion) the map will be rejected. Using the new access_spawn objects is required. :door: 
- Wiring and pipes (disposals, mail, brig, and morgue/crematorium, if present) should be **complete and error-free** for the most part. Obviously, it is okay if you are missing a single wire or something.
    - Note to above: SpyGuy and Haine made a wonderful tool to test disposal networks, it is included in the maps/ folder.
- The disposals crusher blast door should be **closed** at round start (i.e. anything put down disposals at round start should not be crushed without someone opening the door).
- **All areas** on station should be powered. APCs should be able to be charging if the appropriate SMES are set to output. :control_knobs:
- Networked equipment should be **functional**. Specifically: telescience teleporter, communications consoles/dishes.
- A tested and **functioning engine**, either thermo-electric or singularity. Please provide a screenshot of the engine output if thermo-electric (not necessarily at hellburn levels, but enough to meet the station/ship's power needs)
- A **tested and functioning** toxins, if there is a toxins on the map. :biohazard_sign: 
- **Working** shuttles, for the escape shuttle, mining and visiting traders. Some maps can have different facing traders which are not present in the release. If so, please let the coders know when you are submitting your map.
- **Correctly placed spawn points** for all present jobs, late-joiners, observers and so on. Failing to place these will result in players being dropped in to 1,1, which is a Bad Thing.
- A **correctly linked** up syndicate listening post (i.e. nuclear operatives should be able to teleport there), and the airlocks should absolutely be correctly configured.
- A **Correctly placed** landmark for the Map at 1,1.
- **Windows** should be placed using the `obj/wingrille_spawn` spawners.
    - Non-full-tile windows ('thindows') should not be used, as they are being phased out.
- **Firedoors** should be placed using the `obj/firedoor_spawn` spawners.
- **Drains** scattered around, the path is `/obj/machinery/drainage`.

## Recommended
###### These are generally recommended map features that should probably be present in your map. If they are present, please ensure they work as intended.
- An owlery or aviary.
- Monkeys spawn landmarks (including a place for Stirstir in the brig)
- Functioning buddy-paths. Including a tour guide written for Murray/Tour Buddy.
- If you are using perspective walls, try to minimize placing objects on the south side of rooms.
- Blobstart, peststart, and halloweenspawn landmarks.
- Medbay and Security should be well-thought out, daresay more so than other departments.
- Arrivals should have more than one exit, to prevent people from being unable to join the game.
- Cloning should follow the style of modern maps and be mostly public access.
- Feel free to take inspiration from other maps, but please don't copy paste large parts of them.
- If you use random item spawners, try using the types of them that create specific numbers of items. This way you don't risk accidentally overloading rooms with items because RNG decided it to be so.
- Spacemas ornaments are now automatically generated as appropriate. You must only manually add the tree somewhere, specifically the ephemeral subtype.

## Tips and Tricks
###### These aren't one hundred percent necessary to make maps, but they might make your life a bit easier
- **Place Directions!** They make new maps a lot easier to navigate, not just for players, but for you as well during the process. Use the donut 2/nadir floor decals, or the wall signs like cogmap 1, or even both. The amount of directions you should place should be proportional to map size, hallway size, and mazelikeness.
- **Make departments easily recognisable!** Use unique floor designs, colored tiles, lines, and "doormats" to highlight to players where they are. Try to avoid big plain floors: spice things up with some checkered patterns or symbols. Different departments have different colours that they generally go by, so try to stick to those (blue for medbay (with black accents in robotics, and purple in pharmacy), purple for science and research, yellow for engineering, mining and mechanics and so on). Inside departments, use unique floor designs, coloured tiles, lines, and "doormats" (little spots of a department's colour outside their door). It just makes everything look nicer and more organised.
- **Cable spawners** `/obj/cablespawner` exist, they autoconnect to neighbouring cables and other cablespawners. It has reinforced and coloured variants and if you want to make it create nodes for terminal connections and whatnot, you can varedit `var/override_centre_connection` to `TRUE` (`1`). When needing something pretty and/or handcrafted probably use regular cables placed manually, cablespawners are for convenience in places where you don't care.
- **Palettes** are small rooms with assortments of walls, floors and such in different arrangements, available for you to copy over to your projects. Palettes are available at https://cdn.discordapp.com/attachments/469379618168897538/1024529074317701211/Palette.dmm 
- In StrongDMM, "ctrl+1,2,3 to toggle layers, shift click to highlight thing, ctrl shift click to delete thing, 1 2 3 to switch between placing a singular thing, placing multiple things in the area via clickdrag and selecting an area without placing things" ~ Caro, in the #immapper pins
- At the moment, admins are not really accepting maps unless they offer a big gameplay change (like Nadir). It's good habit to start out by making smaller rooms in order to get used to wiring, APC placement, pipe placement, door permissions and such before tackling a larger project. A lot goes into even small rooms: let's not start out challenging ozymandias, yeah?
