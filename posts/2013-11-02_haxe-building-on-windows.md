[tags]: haxe,ocaml,cygwin
[disqus]: 65800973304

# Building Haxe on Windows

Recently I decided to become a bit better of a programmer and get familiar with OCaml language and Haxe source code, so I can contribute something to my current favorite programming language.

However, it took me some time to setup a development environment, because haxe docs on that topic are either outdated or too complicated, so I decided to share my setup steps here.

**First**, you need to obtain OCaml and Cygwin. Luckily, this guy here (<http://protz.github.io/ocaml-installer/>) prepared one installer for both. It installs ocaml and cygwin with all needed packages already selected.

Download the latest installer which is 4.01.0 at this moment. In the installer, check Ocaml and Cygwin, they are required. Then, when the Cygwin setup launches, add __"mingw64-i686-zlib"__ package in addition to ones preselected by Ocaml installer. The ZLib is required to build haxe.

After that add Cygwin bin path to your PATH variable (C:\cygwin\bin on my machine). If you don't know how to do that, just google it. BTW, hint: press win+pause to access system settings. After that, you will be able to call cygwin tools like make from your cmd or powershell window.

**Second**, download haxe sources from a github repo (<https://github.com/HaxeFoundation/haxe>), cd to it in your console and run __make -f Makefile.win__ to build haxe. This should compile haxe.exe into this directory, and that's all :)

One thing though, you also need to build haxelib which is done by running __make -f Makefile.win haxelib__. However, this didn't work for me becase Cygwin uses unix-style paths while haxe.exe doesn't understand them, because well, it's a windows application :)

I created a pull request for that issue, but at the moment, you can apply changes from my commit here: <https://github.com/nadako/haxe/commit/cd7704a9876fc749365d1382bf0041de31f83c57>
