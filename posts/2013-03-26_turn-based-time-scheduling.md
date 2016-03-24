# Turn-based time scheduling

I finally came up with a simple yet versatile implementation for scheduling actions in a roguelike game.

It's based on an energy principle: While actor has energy he can perform actions, after he used up all his energy, add some to it and move it to be the last in queue.


## Basic implementation

We define actor as a simple interface:

    interface IActor
    {
        var energy:Int;
        var speed:Int;
        function act():Int;
    }

So, `energy` is his current energy, `speed` is how much energy we add after all energy is used, and the `act` function is obviously the one doing the job. It returns **action energy cost**, which will be substracted from actor's energy. This way we can define actors with different speed and actions that takes different time. This reminds me of classic turn-based games with action points, like UFO and Fallout.

The scheduler class we begin with is very simple:

    class Scheduler
    {
        private var queue:List<IActor>;

        public function new()
        {
            queue = new List();
        }

        public function addActor(actor:IActor):Void
        {
            queue.add(actor);
        }

        public function removeActor(actor:IActor):Void
        {
            queue.remove(actor);
        }

        public function tick():Void
        {
            var actor:IActor = queue.first();
            if (actor == null)
                return;

            while (actor.energy > 0)
            {
                var actionCost:Int = actor.act();
                actor.energy -= actionCost;
            }

            actor.energy += actor.speed;
            queue.add(queue.pop());
        }
    }

So it's a straight-away implementation of what I've described above. Note that a good data structure for actor queue is a linked-list, because it will be rotated very often.

It will however process only one actor per call, so you may want to call a few times in your game update loop:

    var actorsPerUpdate:Int = 1000;

    for (_ in 0...actorsPerUpdate)
        scheduler.tick();

And now we're gonna make it more suitable for a real game. :) 


## Asynchronous input

What our basic implementation doesn't consider is that the actor can be in a situation he can't decide what to right away, like a player actor who waits asynchronous input from a human.

We solve this by returning negative **action cost** from the `act()` function.

We change our `tick` function to return early if **action cost** returned was negative.

    public function tick():Bool
    {
        var actor:IActor = queue.first();
        if (actor == null)
            return false;

        while (actor.energy > 0)
        {
            var actionCost:Int = actor.act();

            if (actionCost < 0)
                return false;

            actor.energy -= actionCost;
        }

        actor.energy += actor.speed;
        queue.add(queue.pop());

        return true;
    }

Simple as that. We just return early from the function without messing with actor energy and position in queue, so next time we'll poll it again and this time he may be ready to do the action.

This actually solves an ambiguity in the code: what to do if act function returned negative number? :)

Also, note that we changed `tick` function return value to Bool. This means that it will return `true` if actor was successfully processed and we're ready to process next one and `false` otherwise. This will help avoid extra processing in our game update function that calls `tick` a number of times:

    for (_ in 0...actorsPerUpdate)
    {
        if (!scheduler.tick())
            break;
    }

This way we will return from the loop early if there's no actors in queue or some actor is not ready to do his job right now.


## Current actor removal

Another thing our implementation should consider is that actor could be removed as a result of processing its actions. We must stop processing this actor and move on to the next one. To do this, we just store the current actor in a variable and check it in `removeActor` function, setting the special flag to true.

Add two property declarations to the `Scheduler` class:

    private var currentActor:IActor;
    private var currentActorRemoved:Bool;

Change `removeActor` function to set the flag if current actor is removed:

    public function removeActor(actor:IActor):Void
    {
        queue.remove(actor);

        if (currentActor == actor)
            currentActorRemoved = true;
    }

Now, in our `tick` method, we set `currentActor` property before calling `actor.act()` and checking if it was removed using `currentActorRemoved` value:

    public function tick():Bool
    {
        var actor:IActor = queue.first();
        if (actor == null)
            return false;

        while (actor.energy > 0)
        {
            currentActor = actor;
            var actionCost:Int = actor.act();
            currentActor = null;

            if (currentActorRemoved)
            {
                currentActorRemoved = false;
                return true;
            }

            if (actionCost < 0)
                return false;

            actor.energy -= actionCost;
        }

        actor.energy += actor.speed;
        queue.add(queue.pop());

        return true;
    }

Note how we reset `currentActor` and `currentActorRemoved` values after change, so there's no ambiguities in `removeActor` and `tick` methods if called after actor removal.


## Scheduler locking

I also found it useful to be able to temporarily lock scheduler. For example for playing animations.

Add a new property to the Scheduler class:

    private var lockCount:Int;

Add functions for locking and unlocking:

    public function lock():Void
    {
       lockCount++;
    }

    public function unlock():Void
    {
        if (lockCount == 0)
            throw "Cannot unlock not locked scheduler";
        lockCount--;
    }

This one I actually borrowed from [rot.js](http://ondras.github.com/rot.js/), a great JS toolkit for roguelikes. Note that instead of using a boolean value, we increment and decrement lock count. This technique allows us to have recursive locks (i.e. some process locks the scheduler, then shows an animation that locks it again and unlocks when finished animating, after the animation, process does something more and releases its lock).

Now we need to check for locks in our `tick` function:

    public function tick():Bool
    {
        if (lockCount > 0)
            return false;

        var actor:IActor = queue.first();
        if (actor == null)
            return false;

        while (actor.energy > 0)
        {
            currentActor = actor;
            var actionCost:Int = actor.act();
            currentActor = null;

            if (currentActorRemoved)
            {
                currentActorRemoved = false;
                return true;
            }

            if (actionCost < 0)
                return false;

            actor.energy -= actionCost;

            if (lockCount > 0)
                return false;
        }

        actor.energy += actor.speed;
        queue.add(queue.pop());

        return true;
    }

We check for lock at the very beginning of the function so we can exit early if locked. Then we do another check after processing successful action, because most locks will be done as a result of some action, be it directly or indirectly (like the "move" action causing animation that locks the scheduler, so other actors aren't moving in parallel).


## Examples

This scheduling system can be used for basically everything: player, monsters, health/mana regeneration, spell effects, etc.


### Time ticker

The most simple example of actor is a time ticker:

    class TimeTicker implements IActor
    {
        public static inline var TICK_ENERGY:Int = 100;

        public var speed:Int;
        public var energy:Int;

        public var ticks(default, null):Int;

        public function new()
        {
            speed = energy = TICK_ENERGY;
            ticks = 0;
        }

        public function act():Int
        {
            ticks++;
            return TICK_ENERGY;
        }
    }

Add it to the scheduler:

    var ticker = new TimeTicker();
    scheduler.addActor(ticker);

And voila! We got our time ticking.

Note that to simplify speed balancing it's advised to base all speed/actionCost values on some generic **tick** value, like a `TimeTicker.TICK_ENERGY` constant in the above example and apply different multipliers to it. For example:

    var basicSpeed = TICK_ENERGY;
    var basicActionCost = TICK_ENERGY;

    var fastSpeed = TICK_ENERGY * 2;
    var slowSpeed = TICK_ENERGY * 0.5;
    var fastActionCost = TICK_ENERGY * 0.5;

This will save you a lot of time balancing speeds using energy-based scheduling system.


### Creatures

Of course, the player and monsters are main actors in the timeline. A player actor could be implemented like this:

    class PlayerActor implements IActor
    {
        public var speed:Int;
        public var energy:Int;

        public function new()
        {
            speed = energy = TICK_ENERGY;
        }

        public function act():Int
        {
            if (Input.pressed(Key.UP))
            {
                moveForward();
                return MOVE_COST; // amount of energy required to move
            }
            else
            {
                return -1; // not ready yet
            }
        }
    }

The monster could be implemented just like player:

    class MonsterActor implements IActor
    {
        public var speed:Int;
        public var energy:Int;

        public function new(fast:Bool)
        {
            speed = energy = fast ? TICK_ENERGY * 2 : TICK_ENERGY;
        }

        public function act():Int
        {
            if (aiDecidedToMoveForward())
            {
                moveForward();
                return MOVE_COST; // amount of energy required to move
            }
            else
            {
                return TICK_ENERGY; // wait a turn
            }
        }
    }


### Health regen

Another actor could be attached to a creature that handles its health regeneration:

    class HealthRegenerator implements IActor
    {
        public var speed:Int;
        public var energy:Int;

        private var regenCost:Int;
        private var creature:Creature;

        public function new(creature:Creature, ticksToRegen:Int)
        {
            this.creature = creature;
            speed = TICK_ENERGY;
            regenCost = TICK_ENERGY * ticksToRegen;
            energy = -regenCost; // delay first action by ticksToRegen
        }

        public function act():Int
        {
            creature.health++;
            return regenCost;
        }
    }

Note that initial `energy` is negative, so this actor won't do anything until it accumulates enough energy for the first time. Also note that **action cost** is more than `energy` so every time it regenerates, the next regeneration is delayed for some time.


## Summary

I like this system alot because it's generic and highly reusable. It doesn't depend on anything at all and can be easily covered with unit-tests and moved to a library.

Note that I didnt actually test the code I wrote in this article, it's written to give you a basic idea of what I mean. Here's an actual code I'm using in my project: https://gist.github.com/nadako/5246390