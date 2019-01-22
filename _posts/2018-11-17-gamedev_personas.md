---
layout: post
title: Personas in game design
date: 2019-01-22
---

### The premise: personas and user stories in general and in game design

Recently reading the amazing [The Long Way to a Small Angry Planet by Becky Chambers](https://www.goodreads.com/book/show/22733729-the-long-way-to-a-small-angry-planet) made me drag up an old game idea, which is based on the same sci-fi trope that is underlying this book, and other stories like Firefly or The Expanse: What I call a 'space family', stories focusing on one space ship's small crew and their interactions. 

The idea I had a while ago was to start of with a simple premise: a space ship, the need for crew members to keep it running, and the need to earn money and to keep crew members happy. 

Thinking about that idea again, I quickly started sketching what I need to do, which technologies and techniques I want to use and had a small backlog of tasks of the form of _get a main window running with [SMFL](https://www.sfml-dev.org/)_, _make planet map_, _create action planning NPC AI_ etc. . 

Setting that initial set of ideas down for a day, I got to thinking about a topic that currently occupies me a lot professionally - requirements, user stories and personas in an Agile setting. 

So I started reading up on the state of using personas in game development. 

Many blog posts and research papers detail the usual ideas of knowing your user, and some go especially in depth about using metrics on player interaction to form detailed representations of users. 

Tommy Thompson of AI & Games also has a very interesting post on player analytics of that form [here](https://aiandgames.com/tomb-raider/)

That however was not what I was looking for, and I was about to scrap the idea of persona driven design in a medium that seems to be largely either _creative_ - as in someone's idea or narrative is turned into something that hopefully people will want to play- or focuses on hard data on existing users to be able to design things they will enjoy/buy - which seems to be largely a concern of the large industry players. 

But then I stumbled on an interesting notion in [this blogpost](http://blog.agilegamedevelopment.com/2016/04/user-story-mapping-for-games-example.html) on agilegamedevelopment.com, in which the author details the use of user story maps, but in this utilizes user stories not from the point of view of users of the finished product, but from a narrative or character point of view. 

One of his example epics is `As a fugitive I want to drive a car fast to evade the police.` 

Using personas and user stories as a narrative tool seems somewhat obvious, as fleshing out a character's background, motivations and goals is exactly what makes good literary characters seem like believable individuals instead of mere archetypes. 
However before stumbling upon the casual inclusion of a character focused user story in that post, it had not occurred to me at all.  

Interested in how well one could define a game using personas and user stories, I scrapped my existing plan and started fresh. 

### Two types of personas

I decided I'd use two types of personas to inform the design of my game. In-Game personas to inform the basic narrative and game mechanics, as well as actual user personas to further refine what one should be able to do in the game, as well as how to interact with it. 

What I want to capture in narrative and mechanics, is the feeling of being the captain of your own ship, just doing the best to keep your ship and crew afloat. 

#### In game personas 

So the main in-game persona will be the captain the player will embody. 

| _Mal_ | Details | Goals | 
| --- | --- | --- | 
| ![Nathan Fillion as Capt. Malcolm Reynolds, in a promotion picture for the series Firefly. Copyright © 2002 Twentieth Century Fox Film Corporation. All Rights Reserved. ](https://upload.wikimedia.org/wikipedia/en/1/13/MalReynoldsFirefly.JPG)| Owns a space ship. <br/> Sees violence as a last measure. <br/> Likes people. | Keep his space ship running. <br/> Increase and retain his crew so that his ship stays in operation. <br/> Earn money to improve ship and crew. | 

From this and the initial game idea I ended up with the following user stories: 

```
As the captain you can upgrade and extend your ship.

As the captain you can hire crew members. 

As the captain can earn money.

  As the captain of a cargo ship you can transport things between different planets.

As the captain you need to ensure that the needs to keep you ship flying are met.
```

This leaves out one of the original ideas as well as leaving on of the captain's goal ambiguous: how do you retain your crew? How do you keep them happy and stay with your ship over another? 

To answer this question with user stories and to further inform the design of game mechanics later on, I needed a sample crew member. 

| _IX_ | Details | Goals | 
| --- | --- | --- | 
| ![randomuser.me](https://randomuser.me/api/portraits/women/20.jpg)| Technician for space ship engines. <br/> Likes to travel. <br/> Likes to have a well equip space to work in. <br/> Likes food. | Wants all her basic needs fulfilled |

Which adds the following mechanics focused user stories: 

```
As the captain you need to ensure that the basic needs of your crew members are met. 

  As crew member Ix I don't want the ship to stay in the same place too long. 

  As crew member Ix I want the engineering deck to be well equip. 

  As crew member Ix I want the kitchen to be well equip. 
```

These obviously already define some key game mechanics: 

The ship is made up of certain areas, that can be individually upgraded. 
Crew members can be hired, but need other things than only money to stay with the ship. Depending on the level of certain areas, certain crew members are more or less satisfied with the ship. 

#### User Personas

Additionally I came up with three traditional user personas, which not only lead to further game play user stories, but also the expected user experience user stories, which my initial game idea plan left our entirely. 

| _brayden vasquez_ | Details | Goals | 
| --- | --- | --- | 
| ![randomuser.me](https://randomuser.me/api/portraits/men/55.jpg)| Is a fan of Firefly and similar stories about small groups of people having sci-fi adventures. <br/> Hasn't played many computer games.  | Wants to have the happiest crew. |

```
Brayden: I want to be able to build my crew out of interesting characters.
Brayden: I want to know what my crew members need, so I can make them happy about working on my ship.
Brayden: I want to be easily able to play the game, without having to figure out too many details.
Brayden: I want the game to have a nice tutorial showing me the ropes. 
```

| _tamara davidson_ | Details | Goals | 
| --- | --- | --- | 
| ![randomuser.me](https://randomuser.me/api/portraits/women/51.jpg)| Likes economy simulation games. <br/> Has played a lot of computer games. <br/> Has played a lot of demanding strategy games.  | Wants to be the ship captain with the nicest ship and the most money. |

```
Tamara: I want to be able to upgrade and design my ship, with better and better parts. 
Tamara: I want to compare my achievements with others, so that I can be better than them.
Tamara: I want the game to provide me with as much data as possible to make decisions. 
Tamara: I want to be able to make choices important to how the game plays out. If I can buy and sell everything at the same prices everywhere all the time, the game will get boring. 
Tamara: I want to be able to skip a tutorial.
```

| _warren hicks_ | Details | Goals | 
| --- | --- | --- | 
| ![randomuser.me](https://randomuser.me/api/portraits/men/44.jpg)| Likes adventure games. <br/> Has played mainly mobile games. | Wants to experience adventures and compete against other captains in interesting missions. |

```
Warren: I want to be able to start playing the game without reading any manual. 
Warren: I want to the UI to be easy to use, and self-explanatory. 
Warren: I don’t want to be shown number all the time, and just see what's currently important. 
Warren: I want to experience some story. Only buying and selling things on my own will make me bored soon. 
```

### Conclusions
Defining the main character of a game as a persona, who's user stories define the main game mechanics and narrative, seems obvious in retrospect, and works well for the pretty much narrative-less game I intend on creating. In a more narrative focused game, classic writing wisdom will have the main character as a fully fleshed out character with background and needs/goals anyways, so it might also lend itself to define parts of the experience via in-game user stories. 

The addition of _normal_ user personas and their stories, allowed me to think of different kinds of interactions and expectations, which is what I generally knew to user personas for. 

As a next step in 'agile experiments in game design' I intend to come up with a minimal viable product using the user stories of these personas. 
But as this first experiment took me from November to January, being interrupted by other things like compulsively refactoring a large old project of mine, which is still ongoing, I don't expect to get around to that all too soon. 

#### Image credits
Mal Persona : [Nathan Fillion as Capt. Malcolm Reynolds, in a promotion picture for the series Firefly. Copyright © 2002 Twentieth Century Fox Film Corporation. All Rights Reserved. From wikimedia](https://en.wikipedia.org/wiki/File:MalReynoldsFirefly.JPG)

All other persona portraits (as well as their names) from [randomuser.me](https://randomuser.me/)
