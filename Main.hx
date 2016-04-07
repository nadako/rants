import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import Markdown;
import markdown.AST;
using StringTools;

@:structInit
class Post {
    public static inline var BASE_URL = "http://nadako.github.io/rants";

    public var title:String;
    public var content:String;
    public var tags:Array<String>;
    public var date:Date;
    public var slug:String;
    public var disqusId:String;
    public var lang:String;

    public function dateStr() return DateTools.format(date, "%F");
    public function disqusUrl() return '$BASE_URL/posts/$slug.html';
}

class Main {
    static inline var TEMPLATE_DIR = "templates";
    static inline var POSTS_DIR = "posts";
    static inline var OUT_DIR = "output";
    static inline var ASSETS_DIR = "assets";

    static function main() {
        function getTemplate(name) return File.getContent('$TEMPLATE_DIR/$name.mustache');

        var postTemplate = getTemplate("post");
        var indexTemplate = getTemplate("index");
        var templateContext = new mustache.Context({
            title: "nadako"
        });

        var postsOutDir = OUT_DIR + "/posts";
        FileSystem.createDirectory(postsOutDir);

        var posts = [];
        for (file in FileSystem.readDirectory(POSTS_DIR)) {
            var path = POSTS_DIR + "/" + file;
            if (Path.extension(path) != "md") continue;
            var post = readPost(path);
            posts.push(post);
            var html = Mustache.render(postTemplate, templateContext.push({
                post: post,
                relDir: ".."
            }), getTemplate);
            File.saveContent(postsOutDir + "/" + Path.withoutExtension(file) + ".html", html);
        }

        posts.sort(function(a, b) return Reflect.compare(b.date.getTime(), a.date.getTime()));

        var index = Mustache.render(indexTemplate, templateContext.push({
            posts: posts,
            relDir: ".",
        }), getTemplate);
        File.saveContent(OUT_DIR + "/index.html", index);

        inline function date(d) {
            return DateTools.format(d, "%Y-%m-%d") + "T" + DateTools.format(d,"%T") + "Z";
        }

        var atom = Mustache.render(getTemplate("feed"), {
            id: "tag:nadako.github.io,2016:/rants",
            title: "nadako's rants",
            url: Post.BASE_URL + "/",
            updated: date(posts[0].date),
            author: {
                name: "Dan Korostelev",
                email: "nadako@gmail.com",
            },
            entries: posts.map(function(p) {
                return {
                    id: "tag:nadako.github.io," + p.dateStr() + ":/rants/" + p.slug + ".html",
                    title: p.title,
                    url: Post.BASE_URL + "/posts/" + p.slug + ".html",
                    updated: date(p.date)
                };
            })
        });
        File.saveContent(OUT_DIR + "/atom.xml", atom);

        for (file in FileSystem.readDirectory(ASSETS_DIR)) {
            copyRec(ASSETS_DIR + "/" + file, OUT_DIR + "/" + file);
        }
    }

    static function copyRec(from:String, to:String):Void {
        if (FileSystem.isDirectory(from)) {
            if (!FileSystem.exists(to))
                FileSystem.createDirectory(to);
            for (file in FileSystem.readDirectory(from))
                copyRec(from + "/" + file, to + "/" + file);
        } else {
            File.copy(from, to);
        }
    }

    static var postFilenameRe = ~/^((\d{4})-(\d{2})-(\d{2})_.*)\.md$/;

    static function readPost(path:String):Post {
        var filename = Path.withoutDirectory(path);
        if (!postFilenameRe.match(filename))
            throw 'File $path does not conform with required filename pattern';

        inline function i(n) return Std.parseInt(postFilenameRe.matched(n));

        var date = new Date(i(2), i(3), i(4), 0, 0, 0);

        var source = File.getContent(path);
        var document = new Document();
        var lines = ~/(\r\n|\r)/g.replace(source, '\n').split("\n");
        document.parseRefLinks(lines);

        inline function meta(name) {
            var link = document.refLinks[name];
            return if (link == null) null else link.url;
        }

        var tags = meta("tags");
        var tags = if (tags == null) [] else tags.split(",");

        var disqusId = meta("disqus");
        if (disqusId == null) throw 'Post at $path doesnt have the [disqus] tag'; // TODO: generate one and save

        var title = null;
        var blocks = document.parseLines(lines);

        for (i in 0...blocks.length) {
            var el = Std.instance(blocks[i], ElementNode);
            if (el != null && el.tag == "h1" && !el.isEmpty()) {
                title = new markdown.HtmlRenderer().render(el.children);
                blocks.splice(i, 1);
                break;
            }
        }

        return {
            title: title,
            content: Markdown.renderHtml(blocks),
            tags: tags,
            date: date,
            slug: postFilenameRe.matched(1),
            disqusId: disqusId,
            lang: meta("lang")
        };
    }
}
