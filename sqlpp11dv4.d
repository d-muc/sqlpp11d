#!/usr/bin/env tdmd
import std.conv : to;
import std.format : format;
import std.string : replace;
import std.algorithm : canFind, startsWith;

/// sqlpp11dv4 - SQL read at Compile Time

unittest {
    string foo = "42";

    assert(
        mixin("select foo, bar from bazTable where foo='{foo}'".QueryBuilderSql)
        == "select foo, bar from bazTable where foo='42'"
    );
}

unittest {
    int foo = 42;

    assert(
        mixin("select foo, bar from bazTable where foo='{foo / 2 + 2}'".QueryBuilderSql)
        == "select foo, bar from bazTable where foo='23'"
    );
}

unittest {
    bool foo = true;

    assert(
        mixin("select foo, bar from bazTable where foo='{foo}'".QueryBuilderSql)
        == "select foo, bar from bazTable where foo='true'"
    );
}

unittest {
    enum string foo = "42";

    // compile time asserts with compile time templates
    static assert(
        mixin("select foo, bar from bazTable where foo='{foo}'".QueryBuilderSql)
        == "select foo, bar from bazTable where foo='42'"
    );
}

auto QueryBuilderSql(string input) {
    return format!`"%s"`(
        input
            .replace("{", `" ~ (`).replace("}", `).to!string ~ "`));
}

/+
for other approaches could check out interp
  Output: The number 21 doubled is 42!

int num = 21;
writeln( mixin(interp!"The number ${num} doubled is ${num * 2}!") );

https://github.com/Abscissa/scriptlike/blob/4350eb745531720764861c82e0c4e689861bb17e/src/scriptlike/core.d#L114
+/
