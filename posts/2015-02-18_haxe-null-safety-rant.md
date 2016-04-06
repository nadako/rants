[tags]: haxe
[disqus]: 111320874485

# Please Haxe, give null safety!

As you may know, I like Haxe so much that I'm using it everywhere and joined its dev team to make it even better. But there are a couple of things that are constantly bugging me and don't seem to be justified by the need to compile to multiple targets. One of them is that there's basically no *null safety* in Haxe.

I hate `null` very much. The main reason is because one can never be sure if a given variable is `null` or not at any level in the code, and there's no way to explicitly separate `null`-able variables from non-`null`-able ones. So one have to either check function arguments and return values for `null` in run-time or just document it hope that noone will pass `null` where it's unexpected (which will most likely happen at some moment anyways).

In languages like OCaml, there is simply no such concept as null, and any variable/constant/whatever does always have a value. If one needs to express the absence of a value, an `Option<T>` type is used, which can have two possible values: `None` and `Some(value:T)`. This makes away a whole category of run-time errors from a program and makes the code much more explicit, and compile-time checked.

What I would like to see in Haxe 4 very much is strict separation between `T` and `Null<T>`, which means that one CANNOT assign or compare `T` with `null`, AND one cannot implicitly unify `Null<T>` with `T`, i.e.:

    var a:Int = null; // ERROR on every platform, including dynamic ones
    var a:Null<Int> = null; // OK
    var b:Int = a; // ERROR: Null<Int> should be Int
    var b = a.get(); // OK, b is typed as Int, an exception is thrown if a is null
    var c:Null<Int> = b; // OK
    
    var a = "hello";
    if (a == null) {} // ERROR: a is String, but should be Null<String> to be compared with null

God, I'd even fork Haxe to have that.

What would also be very nice, but not cruicial is to have syntax sugar for working with nullable types, similar to how it's done in Apple Swift's optionals.

There are *some* ways to make this happen in current Haxe using [abstracts](https://bitbucket.org/waneck/taurine-core/src/e7063b660655522b362359e283cdd0d9609ec59e/src/taurine/Option.hx?at=master) and/or macros, but it still doesn't protect you enough from having null errors. In my opinion, this MUST be a core language feature.
