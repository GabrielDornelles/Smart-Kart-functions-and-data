# Smart-Kart-functions-and-data
Some functions and data from my project using mario kart 64 ann

Those are functions that works as classes in OOP, and some data from mario kart 64 registers in RAM. It's a Lua code and it was
made to work with bizhawk 1.12.2 as a plugin. 
You can also find the mapping system through the game ram for the Neural Network inputs.
This project was inspired by mega ia x and mari/o.
Hopefully you might find that useful.
You can find some videos of it running here:

https://www.youtube.com/watch?v=P1kLbxp8Mhk&list=PLkBF5AWJutYeHXpW44k4mvUM004CPXrGq.

How it looks:

![image](https://user-images.githubusercontent.com/56324869/71424612-ea29f680-2671-11ea-8173-9f5fcc724f1b.png)

As you'll see in the docs, there's some problems with the mapping system
![image](https://user-images.githubusercontent.com/56324869/71424771-35450900-2674-11ea-985d-02bbce4ffa3e.png)

for example this one in Choco mountain, that will map to the neural network input even the track section above the kart, or the track below when the kart reach the high section, it's explained in the docs how to solve it.

todo: some tracks aren't playable because of some sections that uses a type of texture that the load track doesn't work, the texture map can be found at the end of the tweanns functions.lua functions file. Maybe some time I'll take a look on it, I think its because of the type of mainmemoryread function being used at the moment, but couldn't be as well:

![image](https://user-images.githubusercontent.com/56324869/71424888-87d2f500-2675-11ea-9ef3-5d1b638b18aa.png)

FIXED: It can be mapped with 0x0A value on stage.ground_type, so this track is playable (it will map all the dark brown sand) :)

The whole project was only possible by RenaKunisaki and Shygoo reverse engineering Mario Kart 64, RenaKunisaki repository is at my favorites and you should definitely take a look if you want to work with mario kart 64 or even to understand  F3DEX, The RSP microcode program used by this game to render graphics.

The latest version can be found here:
<https://www.youtube.com/watch?v=VQRwFbQZjNg>
Where you can see the snow and the bridge being mapped at the same time. It works on Koopa Troopa Beach as well or any
other texture (Actually the boosters in Dk jungle parkway and Royal Raceway are the only texture I tested and it didnt work).

## Fun Fact: 
I discovered through one neural net that you can use kind of a "cheat" to loss less speed at turns, it turns out that the game calculates the speed slowdown during curves using its current angle (sine and cossine in ram), so it slows exponentially based on kart angle (that should be at very least a bit close to 0 or 180º). If you do your turns really fast and press the oposite direction, vectors cancelate each other and speed is never decreased, and since vectors cancelate, that kart its just at a straigth 90º, do it on every turn and the normal way of playing will never be able to reach you. I sent the neural net ghost to the speedrunner that holds Mario Kart 64 world record and he said 

"The key is straightening out though. You go slower when the kart is turned, so you want to do little adjustments and turn back the opposite direction to straighten out the kart as much as possible.".

Then I just confirmed neural net just found a more effective way to play it by having no learning with humans, pretty cool isnt?
You can watch Abney racing the neural net here: 
https://youtu.be/hPZJbxEbKfQ?t=63

At Luigi Raceway Smart Kart time was 1'55"64, Abney did 1'53"60.



