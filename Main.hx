import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import Markdown;
import markdown.AST;
using StringTools;

typedef Post = {
    var title:String;
    var content:String;
    var tags:Array<String>;
    var date:Date;
    var slug:String;
}

class Main {
    static inline var TEMPLATE_DIR = "templates";
    static inline var POSTS_DIR = "posts";
    static inline var OUT_DIR = "output";
    static inline var ASSETS_DIR = "assets";

    static function main() {
        function getTemplate(name) return File.getContent('$TEMPLATE_DIR/$name.mustache');

        var postTemplate = getTemplate("post");
        var templateContext = new mustache.Context({
            title: "nadako"
        });

        var postsOutDir = OUT_DIR + "/posts";
        FileSystem.createDirectory(postsOutDir);

        for (file in FileSystem.readDirectory(POSTS_DIR)) {
            var path = POSTS_DIR + "/" + file;
            if (Path.extension(path) != "md") continue;
            var post = readPost(path);
            var html = Mustache.render(postTemplate, templateContext.push({
                date: DateTools.format(post.date, "%F"),
                post: post,
                relDir: ".."
            }), getTemplate);
            File.saveContent(postsOutDir + "/" + Path.withoutExtension(file) + ".html", html);
        }

        for (file in FileSystem.readDirectory(ASSETS_DIR)) {
            File.copy(ASSETS_DIR + "/" + file, OUT_DIR + "/" + file);
        }
    }

    static var postFilenameRe = ~/^(\d{4})-(\d{2})-(\d{2})_(.*)\.md$/;

    static function readPost(path:String):Post {
        var filename = Path.withoutDirectory(path);
        if (!postFilenameRe.match(filename))
            throw 'File $path does not conform with required filename pattern';

        inline function i(n) return Std.parseInt(postFilenameRe.matched(n));

        var date = new Date(i(1), i(2), i(3), 0, 0, 0);

        var source = File.getContent(path);
        var document = new Document();
        var lines = ~/(\r\n|\r)/g.replace(source, '\n').split("\n");
        document.parseRefLinks(lines);

        var tagsLink = document.refLinks["tags"];
        var tags = if (tagsLink == null) [] else tagsLink.url.split(",");

        var title = null;
        var blocks = document.parseLines(lines);

        for (i in 0...blocks.length) {
            var el = Std.instance(blocks[i], ElementNode);
            if (el != null && el.tag == "h1" && !el.isEmpty()) {
                title = cast(el.children[0],TextNode).text;
                blocks.splice(i, 1);
                break;
            }
        }

        return {
            title: title,
            content: Markdown.renderHtml(blocks),
            tags: tags,
            date: date,
            slug: postFilenameRe.matched(4)
        };
    }
}
