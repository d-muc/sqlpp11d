#!/usr/bin/env tdmd
import std.conv : to;

/// sqlpp11dv3 - query builder with some Compile Time Function Evaluation (CTFE)

unittest {
    alias QueryBuilder = QueryBuilderCTFE;

    static assert(
        QueryBuilder
            .select("foo", "bar")
            .from("bazTable")
            .where_equal("foo", "42".to!string)
        == "select foo, bar from bazTable where foo='42'"
    );
    // static asserts are asserts at compile time
    assert(
        QueryBuilder
            .select("foo", "bar")
            .from("bazTable")
            .where_equal("foo", 42.to!int)
        == "select foo, bar from bazTable where foo='42'"
    );
    assert(
        QueryBuilder
            .select("foo", "bar")
            .from("bazTable")
            .where_equal("foo", true.to!bool)
        == "select foo, bar from bazTable where foo='true'"
    );
}

import sqlpp11dv2 : QueryBuilderWithTemplates;

alias QueryBuilderCTFE = QueryBuilderWithTemplates;
