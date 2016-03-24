# On my haxe coding style

# Haxe

Here's some conventions that I use for my Haxe code, with reasoning behind them, based on both writing and reading a big chunk of Haxe code. I wouldn't dare to call these "best practices", but I think the reasoning makes sense, and I'd like to see more "haxeish" code. I probably write more posts on that topic if I remember or find out something more.


## public/private modifiers

I see no reason to explicitly add `private` modifier to class fields and functions, because unlike C# and AS3, in Haxe, `private` is always the default modifier (unless you change it with a `@:build`-macro of course). That said, a reader who knows this simple thing about Haxe will always expect field to be private unless it's explicitly public, so the `private` modifier becomes redundant.

There's not much to say about `public`. It should be added for the fields and methods that are part of public API of your class or abstract. However I see no reason to explicitly add the `public` modifier in an interface or `extern` class declaration, as those are always public by default. I'm not even sure why private/public modifiers are allowed there, but I think there are some reasons behind that.

One more thing on `public` is that if you have a class that is supposed to have mostly public fields (for example, some value-object implementation or static method collection), adding the `public` modifier can become tedious and Haxe provides a solution for that: add the `@:publicFields` meta to your class declaration and you have all your fields/methods public by default. Here you can get some use of the `private` modifier that forces a field to be private.


## Explicit typing

### ...in variables

It seems to me that many people coming mostly from AS3 have little idea about [type inference](http://en.wikipedia.org/wiki/Type_inference) and always explicitly write the type of a variable. That is not necessarily a bad thing, however at some moment I came to understand that in 90% of time, the type of a variable is quite obvious from its name (if you stick to sane naming of course) and initialization expression. So, in those cases, skipping explicit type declaration actually increases code readability, especially if the type declaration is complex.

For example, I find these type declarations redundant:

    var count:Int = 1;
    var isValid:Bool = false;
    var itemIds:Array<Int> = [1, 2, 3];
    var usersByName:Map<String, Array<{id:String}>> = getUsersByName();

However, in some cases, I find type declarations useful for both code correctness and ease of understanding, for example when you create an empty collection to fill later:

    var users:Array<{id:Int, name:String}> = [];
    
    for (i in 0...10) users.push({id: i, name: 'User $i'});

### ...in class fields

For class fields that have initializers I mostly follow the convention above, especially if I have something like this:

    @:publicFields
    class CommandNames
    {
        static inline var START_GAME = "startGame";
        static inline var ATTACK = "attack";
        static inline var BUY_ITEM = "buyItem";
    }

I see absolutely no reason to repeat `:String` type declaration for every var here, like `static inline` isn't enough. :-) Also see below on how to do the above in a "Haxe way", using abstracts.

### ...in methods

I prefer to always explicitly specify types for function arguments and return value (even if it's `Void`). I find it good for both self-documentation and ensuring proper type checking and code generation. I have two exceptions for that tho: 1) if a function argument has a default value, the variable rule applies to it. 2) I don't specify `Void` as a return type for class constructors, because those are always `Void`.


## Braces

### ...on the next line

I place the opening brace on the next line, mostly because of the code-style used in last two project I have participated in. But at some point I gave it some thought and decided that I actually like that style because it gives my code some space to breath. I like separating code with empty lines for ease of reading and the new-line-braces add some additional sense to those newlines. :-)

    class A
    {
        static function main()
        {
            for (item in items)
            {
                trace(item);
            }
        }
    }

If course it's less compact, but I would have added a few empty lines in that code anyways.


I don't place braces on new lines in object declarations tho, as it's not real code and should be read as a continuous data flow. This may differ for larger object declarations but those are probably should not be in code in the first place.

    var obj = {
        some: {
            a: 10,
            b: false,
        }
    };

### ...skip unneeded

I tend to omit braces for simple expressions for the sake of less ASCII-graphics in the code and I don't believe nonsense about people forgetting to add braces to loop/condition expressions when they add something there - every programmer should check their code several times after writing it and before compiling.

    if (someFlag)
        doSomeGood(values);

However, I always add braces in if-for/for-if cases:

    for (item in items)
    {
        if (item.isValid)
            trace(item);
    }

Another thing that is not obvious for someone new to Haxe is that you can even omit braces for function declaration, as long as it is simple. That is particularly useful when defining anonymous lambda functions: 

	var validItems = items.filter(function(item) return item.isValid);


## Dynamic and Reflect

I always try to avoid these. I mean ALWAYS. With Haxe, almost everytime there is a way to do things in a properly typed manner. Type safety and compile-time checking really helps alot. However I can understand that it may not be always obvious for a newcomer how to implement things in a type-safe manner, so an advice to you guys: just ask about it on the IRC or Google Group. There are many friendly folks there that will help you for sure.

More on that topic, I often see people asking about a "proper haxe way" to work with JS object, which is not very easy in Haxe since it has no type for that and actually requires to use `Reflect`. But there is a way! :-) For my project, I wrote this very simple wrapper type exactly for that purpose: https://github.com/nadako/haxe-thingies/blob/master/src/DynamicObject.hx


## Abstracts

More on type safety. Often there are cases when drastically different values are represented by the same run-time. And passing one those values to wrong functions can lead to scary things. Fortunately, Haxe has a solution for that as well: the concept of `abstract`. Basically, it's a compile-time type that is represented in run-time by a different type. That means you can define two types that are strings in run-time but are different types in compile-time and cannot be used in place of each other unless you explicitly want that.

One of the uses for that are `enum abstracts`, [described](http://nadako.tumblr.com/post/64707798715/cool-feature-of-upcoming-haxe-3-2-enum-abstracts) in one of my previous posts.

One can think of more uses for abstracts, for example: a millisecond time stamp may be represented by Float because of a large number it can contain, however you don't want to have non-integer operations for it and don't want to confuse it with some ratio value, also represented by Float.

More on abstracts are here: http://haxe.org/manual/types-abstract.html

> Tags: haxe, codestyle