[tags]: haxe
[disqus]: 0e662d5c-7b97-4da1-b6a6-5735b3f504e6

# Is Haxe for you?

In this article I'll try to write about some potential reasons to use Haxe from the perspectives of people coming from different areas. Since Haxe's scope is so large, it can be quite hard to understand what it actually is and how it can be useful for you.

I can't say I know everything about every area of programming, but I have some experience in web server and game development, I do my best to stay on the edge of current tech and know Haxe and some of its target platforms fairly good.

I'm gonna split this post into sections about different platforms you may come from and in the end will add some general facts about Haxe that is common for everyone.

## Flash

Historically, Haxe has an image of a "replacement for Flash", so a lot of Flash developers evaluate Haxe when they are thinking of moving away from Flash. The first thing you should know about this is that Haxe is NOT a replacement for Flash, and that rumor is coming from uninformed people. Haxe is a general-purpose programming language that cross-compiles to a number of different languages and bytecodes (including AVM2 that powers Flash). The thing is, there are the [OpenFL](http://www.openfl.org/) and [NME](https://github.com/haxenme/nme) frameworks that basically implement Flash API in Haxe in a cross-platform way, and Haxe's syntax is similar to ActionScript 3, so porting code from it is easy (there is even a [conversion tool](https://github.com/HaxeFoundation/as3hx) that does the boring stuff for you).

But Haxe has much more to offer. If your project is well-written, it doesn't depend on the Flash API too heavily (since that's just a view-level stuff), so you have more options than NME and OpenFL. Here are a couple of notable game/multimedia frameworks that have nothing to do with Flash, but are still awesome: [Kha](http://kha.tech/), [Luxe](http://luxeengine.com/), [Haxe-Pixi](https://github.com/pixijs/pixi-haxe), [Flambe](https://github.com/aduros/flambe), or even basic HTML5 API, included in the Haxe standard library.

If you're still with Flash, but want to be future-proof, it may still make sense to port your code to Haxe using the good old Flash API and compile to Flash for now and have much more freedom in the future.

Also, please note that even though Haxe's syntax is quite similar to AS3 at first sight, it's a much more powerful language and its programming idioms differ a bit from AS3 ones. Haxe focuses on full static typing and provides features to avoid run-time reflection, boilerplate code, and generally to have more compile-time safety.

## JavaScript

Nowadays, JavaScript is probably the most popular language in the world, and thanks to node.js and NPM it has a huge collection of libraries almost for everything. However, even though current ES6 version brings some very nice and modern features to it, it still has a legacy full of quirks and bad design decisions, which, together with its dynamic nature makes developing large applications painful and requiring too much discipline.

That's why we have a number of languages that cross-compile to JavaScript, like CoffeeScript or Microsoft's TypeScript. Obivously, Haxe can be also used as a language to target JavaScript-based platforms, such as browsers or node.js. And in my opinion it's the best option since it not only provides syntax sugar, like CoffeeScript, or static typing, like TypeScript. It provides both AND it fixes a lot of JavaScript issues (e.g. variable scoping, method binding) and it has a much much more powerful type system that allows writing very safe and concise code that compiles to very efficient JavaScript (thanks for powerful static analysis and inlining features). With all that it can also easily use the whole existing JS awesomeness provided by NPM in a type-safe way through the simple extern definition mechanism. And don't forget that JS is just one of many Haxe compilation targets, so if for any reason, JS isn't enough for you, you can compile your Haxe code to other mainstream targets with minimal to no changes.

More on topic, I recommend you to also read these two great articles:

 - [The Benefits of Transpiling to JavaScript](https://pellucidanalytics.github.io/blog/the-benefits-of-transpiling-to-javascript/) by Franco Ponticelli
 - [TypeScript vs Haxe](http://blog.onthewings.net/2015/08/05/typescript-vs-haxe/) by Andy Li

## Lua

Lua is known for its runtime that is very minimalistic, fast and easy to embed. Because of that it's often used for scripting in game engines (e.g. CryEngine, Defold, World of Warcraft), as well as other applications (nginx, awesome wm, etc). However, as a language, Lua suffers from mostly the same issues as JavaScript - it's too dynamic and loosely structured for maintaining a large code base (and any project that is being developed grow large at some point).

Since version 3.3, Haxe has a new shiny Lua target that allows compiling Haxe to Lua code (with LuaJIT support). This provides the same benefits as described in the JavaScript section earlier in this post and enables users to write (and maintain!) more complex projects targeting Lua runtime with more compile-time safety and less headache.

I gave Lua target a try and implemented an extern library for the KING's [Defold](http://www.defold.com/) game engine and I must say it works great, especially considering how new it is. Here's my library to give you an idea: <https://github.com/hxdefold/hxdefold>.

If you're writing a game or an engine or any scriptable app from scratch, I'd say it's worth considering using the Haxe language + Lua(JIT) runtime combo as an ultimate scripting solution.

For more info, look at this year's WWX talk by Lua target author Justin Donaldson:

 * [Video](https://youtu.be/4z18ry0HKBc?list=PLyIetEt7wxr6yo_ARVaQv9UpeGbAYp_Z2&t=1446)
 * [Slides](http://wwx.silexlabs.org/2016/assets/presentations/justin-donaldson.pdf)

## C++

C++ remains the most popular choice in areas that require low level memory management and fine-grained control of what's happening. Game engines are the obvious example of that. However, the other side of the coin is that with C++ it's getting harder to program at higher level (in case of games that would be the actual game logic). Yes, C++14 has a lot to mitigate that, but still, it can be hard to find the manpower to develop and maintain the C++ codebase.

Haxe is a simplier to learn garbage-collected language that integrates quite well into C++ infrastructure by compiling directly to C++ and providing methods to work with C++ side without adding run-time overhead or losing type-safety. C++ target is what powers Haxe cross-platform native compilation. It's battle-proven and used in almost all native Haxe applications and games. The target is constantly improving in aspects of performance and memory efficiency and since Haxe 3.2 it also provides a way to quickly develop your project through compiling to a CPPIA bytecode that allows live code reloading without using a separate script engine. The benefit of CPPIA is that you still write code in Haxe for C++ target and you can compile your final product to C++ without using bytecode.

Since the C++ target is used by Haxe game frameworks, the community developed a number of ready-to-use libraries for accessing popular C/C++ stuff, such as SDL, OpenGL, GLEW, OpenAL, ENet and so on.

It's also worth noting that Proletariat Inc. is successfully using Haxe/C++ and CPPIA combo with the Unreal Engine by Epic Games for their new Streamline game. They even received a [$15000 grant from Epic Games](https://www.unrealengine.com/blog/epic-games-awards-seventy-five-thousand-in-unreal-dev-grants) for their [Unreal.hx](https://github.com/proletariatgames/unreal.hx) project. Check out the presentation by Cauê Waneck ([slides](http://slides.com/cauewaneck/unreal-hx), and [video](https://www.youtube.com/watch?v=WOK5m_D1gOc&list=PLyIetEt7wxr6yo_ARVaQv9UpeGbAYp_Z2&index=9)).

## C# #

C# is actually a very solid and well-designed programming language. In my opinion C# does _some_ things more correctly than Haxe, but on the other hand it lacks features found in Haxe that make code safer and life easier, such as algebraic data types, pattern matching, abstract types or easy-to-use compile-time meta-programming features (aka macros).

Haxe integrates quite well into .NET by compiling to C# and supporting using types from .NET assemblies (the DLLs) automatically, without writing any extern definitions, so you can basically use Haxe instead of C# or any other .NET language. Whether or not to do that comes down to personal preference though, but one thing which makes Haxe worth consideration is its cross-target compilation abilities. For example I personally have the experience of developing two big game projects with Haxe using its C# target for the Unity3D-based client and its JavaScript target for the node.js based server. We wrote game logic once and successfully ran it on both client and server.

## Java

Unfortunately, I can't say much about Java, because I have no experience with it. I know Java 8 brought some nice features to the language (e.g. short functions), but it's still kind of meh. I like to separate the language and its runtime though, because nowadays runtimes are reusable, and for the JVM (which is very good, as I heard) we have a number of different languages besides Java (e.g. Scala, Clojure, Groovy).

Regarding Haxe, I would say the situation is similar to one with C# - Haxe can be a good choice as a JVM language, thanks for its powerful features. It also integrates well by supporting loading types from JAR files automatically and its performance is great. And of course it's always a great choice if you need to target multiple different runtime platforms.

I have a very minimal example of Haxe/Java usage with the LibGDX framework here: <https://github.com/nadako/libgdx-haxe-example>

## Python

I used Python a lot a long time ago and still kind of love it. I think it's one of the few dynamic languages done right. Haxe compiles to pretty good python code, and thanks to static typing and optimization features it can actually generate potentially more efficient code. I'm not sure that I'd use Haxe-to-Python instead of plain Python where it's used, but still there are some very interesting possibilities to target some Python environment among others.

A cool example of using Haxe's Python target is this project by Lubos Lenco: he integrates Kha (a cross-platform multimedia framework written in Haxe) into the Blender 3D editor,
which uses Python as the scripting language, making it possible to develop a project in Blender and then compile it to a lot of different target platforms thanks to Kha and Haxe.
More info here: <http://luboslenco.com/notes/>.

## PHP

I avoided PHP my whole life, so I have literally nothing to say here, sorry :) Feel free to share knowledge about the Haxe + PHP tandem in the comments.

## Everyone

I repeated and paraphrased this point a lot here, but my vision is that Haxe is not solution you are using INSTEAD of something, but rather a tool that you're using WITH something. You still need to know the platform you're targeting, but you can add Haxe into the mix to save quite a bit of time and headache with writing, maintaining and porting the actual code you write for the platform of your choice. It's a programming toolkit that can really adapt to the changing world: platforms, engines, VMs come and go, and it would be nice to be able to keep your existing codebase and people when you switch from one to another, and Haxe provides just that.
