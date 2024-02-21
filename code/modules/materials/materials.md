The system has gotten a bit convoluted so im gonna write down some notes here to help people.

### How do i add new Material trigger procs?
- Add a new datum for it in the [Mat_MaterialProcs.dm] file
- Make sure the signature for the execute proc matches what will be passed in. See the [Mat_Materials.dm] file and the calling procs therein - for example "triggerOnLife" - to find the signatures.
- In the New proc of the material datum, do something like addTrigger(triggersOnAdd, new /datum/materialProc/erebite_flash())

### How do i add a new Trigger?
- Add a list and a calling proc for it in the base material definition
- Add the name of the list to triggerVars in Mat_ProcsDefines.dm
- Add the required handling for the new trigger in the getFusedMaterial proc in Mat_ProcsDefines.dm - See the existing ones for an example.
- Make sure the calling proc you created in step one is called from somewhere in the game.
- If possible, make sure that the call for your new trigger has the object owning the material or a relevant entity as its first argument.

### How do i add a new material flag?
- Add it in [material_properties.dm]
- Add the handling for it in the getFusedMaterial proc in [Mat_ProcsDefines.dm]
- Give it a name in getMatFlagString in [Mat_ProcsDefines.dm]

## MATERIAL PROPERTIES:
  Tensile Strength: How much a material can be stretched before it snaps

  Compressive Strength: How much a material can resist being crushed

  Shear Strength: Essentially resistance to being cut or abrased

  Ductility: How much it can be fucked with until it is permanently deformed
	
  Toughness: How much force it can absorb without fracturing
