[tags]: haxe
[disqus]: 167ca93c-badd-4836-9a98-d09626a35ebc

# Project-local Haxe installation (how I did it)

In my WWX 2016 presentation on how we used Haxe with Unity I talked about that we
integrated Haxe in right in our repository so there is no need to install Haxe on
developers' machines and we can easily update Haxe version.

After that I received an email asking how to do it, so I'll describe what's needed
in this short post. It's not really tied to Unity and is just about how to run
local Haxe installation.

So what we basically did is put haxe executables (for Windows and macOS)
and needed haxelibs (e.g. hxcs) into our project and wrote a simple build
script that runs Haxe executable with required environment variables, here they are:

 * **HAXEPATH** - path to the directory where Haxe executable is located. I'm not sure
   this is actually needed, but it was present in my system haxe installation.
   As far as I know it's only used in Windows for determining default haxelib repository
   path (`$HAXEPATH/lib`). There's also some code in Haxe's Neko generator that uses the
   same convention for loading .ndll files. I didn't look further and I just used the
   `lib` subdirectory for haxelibs as well.

 * **HAXELIB_PATH** - path to the haxelib repository. This is where we put haxelibs needed
   for our project, such as `hxcs`, required to build for C#. As mentioned above we put it
   next to haxe executables named as `lib`.

 * **HAXE_STD_PATH** - path to the Haxe standard library (the `std` folder, which we put
   in the same directory as Haxe executables). This one is important because if it's not
   present, Haxe will look for standard library in a set of hard-coded locations which
   will be invalid in our case of local haxe installation.

 * **NEKOPATH** - path to the neko installation. I believe it's needed for loading standard
   .ndll files. We have it in separate folders for different platforms and set the env var
   dependeing on whether we're on Windows or macOS.

 * **DYLD_FALLBACK_LIBRARY_PATH** - also path to the neko installation. This is only needed
   on macOS for loading dynamic libraries. I don't remember exactly, but I think this was needed
   for Haxe macros to work properly, since they load neko libraries for some functionality, like
   regexp.

Finally, we add `HAXEPATH` and `NEKOPATH` to the `PATH` env variable so `neko` and `haxe` can be
called from further scripts without specifying the full path. Note that under macOS the separator
between those should be `:` while on Windows it's `;`.

So here's what our directory hierarchy looks like:

```
  * project
    * haxe/
      * lib/
        * hxcs/
        * hxnodejs/
        * etc...
    * neko-2.0.0-osx/
    * neko-2.0.0-win/
    * std/
    * haxe (osx executable)
    * haxelib (osx executable)
    * haxe.exe (win executable)
    * haxelib.exe (win executable)
    * zlib1.dll (needed this for windows because of how I build haxe)
```

Hope this helps, feel free to ask more in comments!
