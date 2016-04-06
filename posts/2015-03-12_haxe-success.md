[tags]: haxe,javascript,node,flash,actionscript,ocaml,gamedev,successtory
[disqus]: 113390739725

# A success story for Haxe

**NOTE: Я выложил [русский перевод](http://nadako.tumblr.com/post/114624037180/haxe-success-russian) этой статьи.**

As some may know, I'm a big fan of [Haxe](http://haxe.org/) and I'm actively trying to contribute to its development. But how I got here is (I think) quite an interesting story which may be even called "success story" for Haxe, so let me tell it. :-)

## A little background

To keep it short, I studied C/C++ when I was a student, then I fell in love with Python when Ubuntu started promoting it (I was a linux fan back then), so I found a job with Python and did some web programming for a while. But I always wanted to make games, so I constantly searched for a game vacancy that I was good enough for and finally ended up writing python-based server backends and admin panels for social games in Flash. Then I learned AS3 to help my colleagues with Flash front-ends and eventually became a client-side programmer in Flash/AS3 (I also coded servers for those games in Python).

## Sharing code

When I was doing AS3+Python there was literally NO shared code, there was a Flash "thin client" and a Python server that calculated stuff and changed the game state. One can imagine how it was inefficient and annoying to develop/support, but I didn't knew better ways those days.

Then I joined a team, who also developed Flash games in AS3, but there was this very smart guy (hi, Denis!) that actually had some knowledge and realized that AS3 is a superset of ECMAScript (JavaScript), so one could code game logic in pure javascript and then compile it with AS3 compiler for Flash client and interpret somehow on server (we used Ruby+TheRubyRacer first, then node.js).

## Writing JavaScript

The idea seemed brilliant and it worked very well at first, but (midly speaking) JavaScript is not particularily good language for supporting large code bases such as ours, mostly due to its dynamic nature. It requires a lot of attention, discipline and testing to maintain a code base and keep it stable. It also required to write quite a lot of run-time checking code to make sure things won't break because of some small programmer mistake (that actually become a performance problem for us at some point).

## Typing JavaScript

That's when a friend of mine told me about Haxe (2.11 at a time) and how awesome is it together with NME and can be compiled to Flash, JS and C++, etc, so I decided to take a look. After some research I was impressed by the possiblilty of generation both JS and SWF from a language syntatically similar but greatly superior to ActionScript 3.

So we (with a colleague) developed a prototype build system that allowed us to gradually, bit by bit port our JS codebase to Haxe and compile it first with AS3 compiler as JS (together with not-yet-ported pieces) and when porting is complete - directly to SWF from Haxe.

But that prototype was rejected by our team leader who decided to go with TypeScript which had an advantage of being a syntax superset of JavaScript and thus (theoretically) allowed to port our code much easier and also had a fancy website featuring Microsoft logo. :-)

However that porting was never done and the project was terminated. I was transferred to work on a Unity-based project in the same company.

## Unity

I joined an in-development Unity-based mobile game project. Its team was tasked to reuse the server and shared-logic architecture from that Flash+JS game I described above, so they came up wiring JavaScriptCore engine into an Unity game and writing game logic in JavaScript. It felt unnatural for them (hardcore unity devs/C# fans), but it worked.

I received a task to make things work in Unity Web Player so we could publish on Facebook and surprisingly it was nearly impossible to do, because of JavaScript for few reasons:
  
 * Unity Web Player doesn't allow native plugins such as JavaScriptCore
 * .NET implementations of JavaScript didn't work because of run-time code emit that was also forbidden by Unity Web Player
 * Re-using browser's JS engine is nearly impossible for such complex things because of async nature of `Unity<->Browser` interop which conflicted with our synchronous game logic architecture. Also we certainly didn't want to deal with differences between various browsers and plugins installed by thousands of users all around the world.

## Pushing Haxe

I was already a (novice) Haxe fan and was trying to convince colleagues to check out its potential, however I wasn't taken seriously until that moment. I honestly searched for some ways to make that JS codebase work on Unity Web Player, but with no success.

So I developed a small proof-of-concept in Haxe that basically copied our JavaScript architecture. I compiled it to C# and JavaScript to show that it could work identically in Unity Web Player, JavaScriptCore native plugin and node.js server. The results were surprising even for me - it just worked!

When I showed the prototype to the lead programmer, he was quite impressed by this solution and finally decided to take a look at Haxe technology. After consulting with CTO, they decided to give it a try.

## Porting from JavaScript to Haxe

Thankfully, the architecture of our JavaScript codebase wasn't insane like some of JS projects we see nowadays. It was quite simple, more Java-style, so we didn't have to think too much about how to port code to Haxe.

However, the codebase was quite large already and it took time to port it. So what we did is inject haxe-generated into hand-written javascript code and make it work together, so we can port the code base bit by bit.

We took a .js file, ported it to Haxe, removed the .js file and committed, so other people working on the project won't accidentally edit obsolete code. That way after two weeks of hard work we (me and my like-minded colleague, hi Misha!) had our code ported from JS to Haxe without interrupting the development of actual game by the rest of the team!

At that time we didn't think much about proper typing or macro code-generation, because our main concern was to make generated code behave exactly the same as JS code, so we don't introduce bugs by porting. We reviewed generated code after each porting session and compared it to original js code. We did add types in places where it was obvious and easy to do so, but mostly the code stayed dynamic.

## Fine-tuning ported code

After we finished porting JS code to Haxe, we had to make it actually compile to C# and .NET dll for use in Unity Web Player. After some minor fixes, it did compile and work fine. It was VERY satisfying, promising and it proved Haxe well, but the generated code was very ugly and inefficient, because... well, it was basically C# written in a hardcore dynamic JS-inspired style.

Reviewing and profiling C# code allowed us find out that most of problems were caused by two main reasons:

 - unnecessary casts and dynamic access
 - a lot of runtime dynamic value checks and data copying to prevent programmer's mistake

The first reason was eliminated by specifying proper types in the ported code and reducing usage of reflection. Haxe type system allowed to express everything we had in JS in a typed manner. As an AWESOME BONUS, adding proper types surfaced a number of bugs that were present in JS code but were caught by the compiler now, so we fixed them before QA (or users, what's even worse) found them.

The second reason made me learn Haxe macros, I wrote several macros that allowed us to get rid of large part of runtime code, such as:

 - compile-time validation of game configuration files (so that JSON files edited by game designers contain proper fields with proper types without typos and mistakes)
 - entry-point argument validation generation (so when one writes a new "command" in game logic, he can be sure that arguments, passed to the command are present and properly typed without need to write additional checking code)
 - [compile-time-checked read-only access](https://gist.github.com/nadako/9200026) (so we don't need to copy objects to prevent accidental modification)
 
Maybe there are more, I don't even remember now, but that's how I learned how very powerful Haxe is and how much smaller and at the same time more error-proof AND efficient can Haxe code be, compared to JavaScript and even C#.

Not to mention how FUN it was to automate things. This should be satisfying for every programmer.

## Developing in Haxe

While that Unity-based client is still in C#, a large part of game code is written in Haxe and they play very well together. The same story on the server - the server itself is written in JavaScript (node.js), but is using Haxe-compiled JS module with game logic. And it's working fine for two years or so now.

The team was very happy to move from JavaScript (they hated it because they are mostly C# fans) to something well-typed and structured, and thanks to the compile-time checking, further development become much more stable and fast (less bugs -> less time spent on researching and fixing). Overall there are only benefits.

## Spreading Haxe

Since then I changed my job, but I'm still doing games in Unity using Haxe and C#. I'm in a team, partly assembled from the same guys I worked with before, so it wasn't hard to convince them to stay with Haxe. We've developed a new version of our shared-game-logic architecture involving even more macro code generation, strict typing and compile-time validation, further reducing size of the code base and making things error-proof.

So far, it's working so well that we're sharing our Haxe-based architecture with two more teams/projects within our company, so people are learning Haxe and its awesome features. That could be called "mission accomplished" for a hardcore haxe lover like myself. :-)

## Professional evolution

During porting and futher development, we discovered a bunch of bugs and bottlenecks in Haxe standard library and compiler itself. First I reported them on GitHub and thought of workarounds, but at some point I thought to myself: "I'm a fairly good programmer and Haxe is an open-source project, so why should I wait for someone to come and fix things? Couldn't I just fix them myself?"

It wasn't easy for me, as I found out that Haxe is written in OCaml and I had little to no experience with it or functional programming in general. Also I had very little idea how a compiler works, so I just started reading parts of Haxe source code at evenings, keeping OCaml manual open in a separate browser tab, I joined #haxe IRC channel to meet haxe developers who were welcoming and VERY helpful in my quest to understanding OCaml code and how haxe works (thanks, Simon and Caue!).

I discovered so many awesome techniques that are unusual in JS/AS3/C# world, such as null safety, algebraic data types, pattern matching and immutability, type inference, structural typing. What's even more satisfying is that these things are either already present and ready-to-use in Haxe or could be implemented fairly easy with macros.

I learned what's REAL strict typing, new programming paradigms, how to better structure your code, how compilers work, how awesome could compile-time checking be, not to mention new programming language. This really made me a better programmer, unlike working with Unity (hehe).

Also I'm an active contributor to an open-source project now and am pretty proud of myself!
