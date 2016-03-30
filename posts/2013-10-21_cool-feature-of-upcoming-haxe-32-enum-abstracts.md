[tags]: haxe

# Cool feature of upcoming Haxe 3.2: enum abstracts.

**UPDATE**: As of commit 9f1a25b1d64ce8fa5ddd6942bea35ce322f3416a, @:fakeEnum was renamed to @:enum. I have updated the article for newer terms.

I just discovered a handy feature in Haxe's git: enum abstracts. Unlike real haxe `enums`, they are not fancy algebraic data types, but merely `abstracts` over any type that define a limited set of constant values.

This is very useful in many cases where you want to define a finite set of values and make sure noone makes a mistake by assigning something different. In Haxe it is done with elegancy and checked in compile-time, as usual :)

So, for example you want to define a set of string constants. You define an `abstract` over `String` and mark it with `@:enum` metadata. Inside that abstract, you can define values with simple var syntax:

    @:enum
    abstract State(String)
    {
        var Idle = "idle";
        var Move = "move";
        var Attack = "attack";
    }

As you may know, `abstracts` are compile-time types that don't really exist in runtime, so in runtime, our real type will be a simple string, as we defined, but in compile-time, we can define variables with type `State` and compiler will check that only values of that type is assigned to the variable. And guess what? That `vars` we defined in the abstract are actually of `State` type thanks to `@:enum`.

We use it like that:

    var state = State.Idle;

We can't assign some casual string to this variable:

    state = "other"; // ERROR: String should be State

Also, haxe compiler will show error when trying to switch over a `enum abstract` if we don't specify all cases, just like with normal enums:

    switch (state)
    {
        case Idle:
        // ERROR: Unmatched patterns: Move | Attack
    }

Inside the code, this stuff is done with a `build macro` and very little compiler magic (basically @:enum becomes a @:build meta, and in `switch` handling there's a special case for `enum abstracts`, that's all).

How cool is that? :)
