#!/usr/bin/env tdmd
import std.conv : to;
import std.format : format;
import std.string : replace;
import std.algorithm : canFind, startsWith;

/// sqlpp11dv5-beta - SQL read and passed as template parameter ...

unittest {
    enum string foo = "42";

    static assert(
        mixin(QueryBuilderSqlTemplate!"select foo, bar from bazTable where foo='{foo}'")
        == "select foo, bar from bazTable where foo='42'"
    );
}

auto QueryBuilderSqlTemplate(string input)() {
    return format!`"%s"`(
        input
            .replace("{", `" ~ (`)
            .replace("}", `).to!string ~ "`));
}

/// sqlpp11dv5 - SQL read and checked for syntax at compile time

unittest {
    const string foo = "42";

    // Eponymous templates - "alias-this for templates"
    // https://p0nce.github.io/d-idioms/#Eponymous-templates
    const ok(string query) = __traits(compiles, mixin(QueryBuilderSqlTemplateAndConstrains!query));
    
    static assert(ok!"select foo, bar from bazTable where foo='{foo}'");
    static assert(!ok!"foo, bar from bazTable where foo='{foo}'");

    // ok is shorthand for okay
    template okay(string query) {
        import std.traits;

        enum bool okay = __traits(compiles, mixin(QueryBuilderSqlTemplateAndConstrains!query));
    }
    static assert(okay!"select foo, bar from bazTable where foo='{foo}'");
    static assert(!okay!"foo, bar from bazTable where foo='{foo}'");
}

void ensureSelect(string input)() {
    static if (!input.startsWith("select")) {
        static assert(0, "no select used");
    }
}
void ensureFrom(string input)() {
    static if (!input.canFind("from")) {
        static assert(0, "no from clause used");
    }
}

auto QueryBuilderSqlTemplateAndConstrains(string input)() {
    ensureSelect!input;
    ensureFrom!input;

    return format!`"%s"`(
        input
            .replace("{", `" ~ (`).replace("}", `).to!string ~ "`));
}
