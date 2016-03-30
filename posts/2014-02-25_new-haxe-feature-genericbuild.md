[tags]: haxe,macro,json

# New Haxe feature - @:genericBuild

If you follow haxe development, you probably know about this one. The `@:genericBuild` meta is used to specify a build macro that is executed per instance of a generic type. For example:

    @:genericBuild(MyMacro.build())
    class A<T> {}

And then:

    var a:A<Int>, b:A<String>;

Will execute `MyMacro.build()` for each instance, both `A<Int>` and `A<String>`. The macro itself must return a valid `haxe.macro.Type` object representing a type that will be used instead of the given one at the place of usage. In the build macro itself, you can retrieve the type being built and its parameters with a standard `Context.getLocalType()` function.

Now for the real-life usage example. In my company's project we are using JSON structures quite heavily, in fact we have all game data represented with dynamic objects and arrays (so much for javascript ancestry). We type that JSON data using haxe anonymous structures and typedef which is awesome, but we got one problem left - most of the data we are working with should be protected from accidental modification - game configuration, object defs, and even player data that can only be modified with a special database method. The obvious solution that we are still using is to return a copy of the actual object. But the drawback of that that it's quite expensive to do a recursive copy, so here's where `@:genericBuild` comes to rescue.

The basic idea is to provide a `Const<T>` class that is being built into a read-only version of `T` (its type parameter).

    typedef House = {
        itemId:Int,
        typeId:String,
        tenants:Array<{name:String}>,
    }

    class Main
    {
        static function main()
        {
            var a:Const<House> = {itemId: 1, typeId: "house", tenants: []};
            a.tenants[1] = {name: "Dan"}; // COMPILATION ERROR
            a.tenants[1].name = "Dan"; // COMPILATION ERROR
        }
    }

It's easy for ints, floats, bools and strings as those are immutable in haxe and can be returned as is, however there are two more data types in JSON - arrays and objects.

Arrays are actually very easy to make read-only - an abstract with array-access function and a length definition will do the job:

    @:arrayAccess
    abstract ArrayRead<T>(Array<T>) from Array<T>
    {
        @:arrayAccess inline function get(index:Int):T return this[index];
        public var length(get, never):Int;
        inline function get_length():Int return this.length;
    }

For structures we need to create a new type that has read-only version of original fields. Note that both the field itself should be read-only (this is done with `default,never` access specification) and its type should be a read-only version of original type (so we must recurse our build function here).

This is quite elegant, because we can use both original type, for example if we are creating new object, or modifying an explicitly created copy. And the read-only version of it, if we are returning data from a database, or passing to a function and want to be sure that it won't modify it. This kinda reminds me of `const` C++ keyword, hence the name :)

Here's the full example: https://gist.github.com/nadako/9200026 It is pretty basic, but if you read the code, you get the idea. Also it shows another nice pattern-matching feature: extractors (the `=>` syntax).
