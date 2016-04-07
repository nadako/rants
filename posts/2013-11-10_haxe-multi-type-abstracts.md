[tags]: haxe
[disqus]: 66530395263

# Multi-type abstracts in haxe

If you ever wondered how `Map` creation works in Haxe, here's how: it's a special kind of `abstract` - the `multi-type abstract`. It differs from normal `abstract` in that it is constructed via special `@:to` functions, so when you call `new Map()`, it actually selects one of these functions depending on given type.

Now, on the syntax. To create your own multi-type abstract, first you define its underlying type to be some base type with type parameters. Anything will do: interface, class, typedef.

Then you add `@:multiType` meta-data to your `abstract`. Then you declare the `new` function so you can create this abstract with `new` keyword, but don't write its body, so it becomes quite like an interface function declaration.

Finally, you define @:to functions that create concrete classes. These functions differ from the `@:to` functions used to convert an instance of abstract to some type. They are **static** and must have one argument of an underlying type with type parameter you want. This argument is not used (actually it's always `null`), but needed for the type system to choose correct @:to function for a given type.

Well, example is worth a thousand words, so here you are:

```haxe
interface IA<T>
{
}

class StringA implements IA<String>
{
    public function new() {}
}

@:multiType
abstract A<T>(IA<T>)
{
    public function new();

    @:to static inline function toStringA(t:IA<String>):StringA
    {
        return new StringA();
    }
}

class Sample
{
    static function main()
    {
        var a = new A<String>();
    }
}
```

The `main` function will be compiled to this (javascript):


```js
Sample.main = function() {
	var a = new StringA();
}
```

This feature is quite useful when you want to abstract multiple implementations depending on type (like it's done with Map), but it wasn't really documented, so I had to read some sources and experiment.

Actually, it may be not documented on purpose because the syntax is subject to change in future versions? I don't know, gotta find out :-)
