[tags]: haxe,json
[disqus]: 77106860013

# Using haxe macros as syntax-tolerant, position-aware json parser

Today I came up with an idea I find interesting enough to write a post about. In our game, we use JSON for game configuration and object definition which is convenient, because JSON is a simple text format allowing you to express almost any data one way or another.

However, when writing these files by hand, people often stumble upon strictness of JSON: lack of comments, trailing commas, object key quoting requirement. And if you work with JSON alot, those things are becoming annoying.

On the other hand, Haxe supports both strict JSON format and its own, much more tolerant one for object definition, so the idea is to parse those JSON (or rather HXON?) files with Haxe compiler itself (which is also blazing fast!):

```haxe
static function parseFile(path:String):Expr
{
    var content = sys.io.File.getContent(path);
    var pos = Context.makePosition({min: 0, max: 0, file: path});
    return Context.parseInlineString(content, pos);
}
```

This gives us an untyped haxe expression (`haxe.macro.Expr`) from given JSON-ish file. But right now, it actually can be any valid haxe expression, so we want to restrict that to being only object notation:

```haxe
static function validateExpr(e:Expr):Void
{
    switch (e.expr)
    {
        case EConst(CInt(_) | CFloat(_) | CString(_) | CIdent("true" | "false" | "null")): // constants
        case EBlock([]): // empty object
        case EObjectDecl(fields): for (f in fields) validateExpr(f.expr);
        case EArrayDecl(exprs): for (e in exprs) validateExpr(e);
        default:
            throw new Error("Invalid JSON expression: " + e.toString(), e.pos);
    }
}
```

This recursively validates given expression to ensure that it only contains object notation.

From here you can do different things, like converting to proper JSON, validation, or extracting actual value, as shown below:

```haxe
static function extractValue(e:Expr):Dynamic
{
    switch (e.expr)
    {
        case EConst(c):
            switch (c)
            {
                case CInt(s):
                    var i = Std.parseInt(s);
                    return (i != null) ? i : Std.parseFloat(s); // if the number exceeds standard int return as float
                case CFloat(s):
                    return Std.parseFloat(s);
                case CString(s):
                    return s;
                case CIdent("null"):
                    return null;
                case CIdent("true"):
                    return true;
                case CIdent("false"):
                    return false;
                default:
            }
        case EBlock([]):
            return {};
        case EObjectDecl(fields):
            var object = {};
            for (field in fields)
                Reflect.setField(object, unquoteField(field.field), extractValue(field.expr));
            return object;
        case EArrayDecl(exprs):
            return [for (e in exprs) extractValue(e)];
        default:
    }
    throw new Error("Invalid JSON expression: " + e.toString(), e.pos);
}

// see https://github.com/HaxeFoundation/haxe/issues/2642
static function unquoteField(name:String):String
{
    return (name.indexOf(QUOTED_FIELD_PREFIX) == 0) ? name.substr(QUOTED_FIELD_PREFIX.length) : name;
}
```

This approach has some interesting features. For example, haxe `Expr` objects have the `pos` field that contains actual file position for given expression which can be used to give precise validation errors. Another thing is that you can extend/restrict the format, for example you can allow some function call syntax, or support haxe enums, or disallow `null` in JSON files, like I do in our company's game.

How do we use this? Well, we have a folder of JSON files that are getting parsed, validated and compiled into our application with a `@:build` macro. Our settings guys are quite happy to not care about comments or trailing commas which is very nice.

I'll probably write another post about JSON validation in future, because that's also quite interesting topic, considering that we validate JSON right against Haxe structure definitions that are directly used in game code.

You can check out the full example here: <https://gist.github.com/nadako/9081608>
