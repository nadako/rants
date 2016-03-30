[tags]: haxe

# Haxe: working with dynamic anonymous structures in a typed way

Often people ask about how or what's the best way to work with anonymous structures that don't have a predefined set of fields (and hence can't be typed with haxe structure type). Basically, objects like that are string-keyed dictionaries. They can be used instead of haxe's `Map` type for example when working with JSON collections or extern JavaScript data.

Haxe provides no specific type representing this concept out-of-the-box and one has to work with these objects using `Dynamic` type and `Reflect` methods. It is no good, because of the loss of strict typing, but fortunately it is possible to wrap all dynamic affairs in a properly-typed `abstract` type that is easy-to work with and has no run-time overhead over `Dynamic`+`Reflect` option.

In my code, I use the following `abstract` type that provides `Map`-like API over dynamic structures by wrapping `Reflect` calls:

    abstract DynamicObject<T>(Dynamic<T>) from Dynamic<T> {

        public inline function new() {
            this = {};
        }

        @:arrayAccess
        public inline function set(key:String, value:T):Void {
            Reflect.setField(this, key, value);
        }

        @:arrayAccess
        public inline function get(key:String):Null<T> {
            #if js
            return untyped this[key];
            #else
            return Reflect.field(this, key);
            #end
        }

        public inline function exists(key:String):Bool {
            return Reflect.hasField(this, key);
        }

        public inline function remove(key:String):Bool {
            return Reflect.deleteField(this, key);
        }

        public inline function keys():Array<String> {
            return Reflect.fields(this);
        }
    }
	
Let's see how its usage looks like and what it generates:

    class Main {
        static function main() {
            var a:DynamicObject<Int> = {field1: 1, field2: 2}; // implicit cast supported by "from Dynamic<T>"

            var f = "field3";
            if (!a.exists(f))
                a[f] = 3;

            for (key in a.keys()) {
                trace(a[key]);
                a.remove(key);
            }
        }
    }

Here's what generated JS looks like for the `main` function:

	Main.main = function() {
		var a = { field1 : 1, field2 : 2};
		var f = "field3";
		if(!Object.prototype.hasOwnProperty.call(a,f)) a[f] = 3;
		var _g = 0;
		var _g1 = Reflect.fields(a);
		while(_g < _g1.length) {
			var key = _g1[_g];
			++_g;
			console.log(a[key]);
			Reflect.deleteField(a,key);
		}
	};

As you can see it's pretty the same as if you've worked with `Dynamic` and `Reflect` by hand, but it's much easier and strictly typed.

Now I only hope Google will give this post for an answer on working with dynamic structures in Haxe :-P
