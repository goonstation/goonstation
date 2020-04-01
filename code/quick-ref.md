# Attack procs

## attackby
*Syntax:*
```attackby(obj/item/W as obj, mob/user as mob)```
Called when the owning atom is attacked with W by user.
*Parent:* /atom

## attack_self
*Syntax:*
```attack_self(mob/user as mob)```
Called when a mob uses the item in active hand.
*Parent:* /obj/item

## attack_hand
*Syntax:*
```attack_hand(mob/user as mob)```
Called when a mob clicks the owning atom with an empty hand.
*Parent:* /atom

## attack
*Syntax:*
```attack(mob/M as mob, mob/user as mob, def_zone)```
Called when a mob attacks another mob with the owning item in hand. Only called when user can reach M. Only called for mob targets.
*Parent:* /obj/item

## afterattack
*Syntax:*
```afterattack(atom/target as obj|mob|turf, mob/user as mob, flag)```
Called when a mob attacks a target with the owning item in hand. Called even if the target is out of reach.
*Parent:* /obj/item