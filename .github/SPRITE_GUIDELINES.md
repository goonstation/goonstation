# Goonstation Spriting Guidelines

{%hackmd @ZeWaka/dark-theme %}

## Basic Style :sunglasses: 

* New large object sprites should be in ¾ perspective. Example [here](https://i.imgur.com/tU8mmeR.png).
    * Normally, items shouldn't be in ¾, but drawn in a flat projection.
    * Large handheld item sprites should be shown side on, see tool and gun sprites for examples of this. 
* Keep colour palettes simple, and where possible sample existing colour palettes to create consistency within departments.
* Hue shift your shadows and highlights. Tutorial [here](https://i.imgur.com/fsTkpWQ.gif). Example:
    ![](http://i.imgur.com/9iGrBo9.png) <-- Bad
    ![](http://i.imgur.com/gB8u1zp.png) <-- Good
* Do not use straight black for outlining. Instead, use a darkened version of the colour at the edge of the sprite. Example:

![](https://i.imgur.com/eUL0qTx.png)
* If you just shrink a jpeg and submit that, you're fired. ![](https://wiki.ss13.co/images/a/af/FoodPancakes.png)
* Unique in hand sprites are encouraged for every new item, this is especially true for items that need to be visually identified in combat. :lower_left_paintbrush: 
* Referencing popular culture is allowed, but try to be subtle about it. Commonly available content should be original. :cake: 
* Icon states should generally be centered on the middle of the canvas. 
* Keep the use of your sprite in-game in mind, it’s difficult and frustrating to click tiny sprites or sprites with 1px holes in them
    * To fix this, add a transparency 1 pixel in the hole. 
* Try to keep scale in mind in general. Things don’t need to be actually proportional, they just need to “feel” right in the game.  :arrow_up_down: 
* It’s good (but not mandated) to distinguish different objects by more than just color if possible, to accommodate the colorblind. :traffic_light: 


## Implementation :wrench:

* Keep the names of your icon_states simple but descriptive.
* Use already existing .dmi files that fit your purpose if possible.
* Use the `widthXheight` files (ex: 120x120) for larger-than-normal sprites.


## Meta :left_speech_bubble: 
* Do not be precious about your work. Be open to criticism and change both from other developers and players. 
* Most untrained people can visually identify when something looks wrong or bad, it's your responsibility as the artist to parse that criticism and find a solution. 