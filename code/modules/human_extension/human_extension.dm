/* mutantrace refactor current goals:
* rename mutantrace to be more descriptive of what it does
* make it so that the default mutantrace for humans is a "human" mutantrace
* since humans now have a mutantrace, take this opportunity to clean up human appearance building by moving all human appearance building instructions to an appearanceholder held in the mutantrace
* take this opportunity to investigate how to make appearance building easier to maintain (documenting code, rewriting segments to be less jank?? idk)
* potential complication: human has a bioholder which holds mutantrace and appearanceholder. this is like a deeply ingrained code hierarchy so messing with it may cause issues.
*/

/** Human Extension Datum
 * This datum has several hooks to existing human procedures and allows you to override/extend existing human behaviour.
 * This datum also holds a reference to an appearanceHolder, which provides mob appearance rendering information.
 */
/datum/human_extension
