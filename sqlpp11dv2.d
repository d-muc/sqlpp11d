#!/usr/bin/env tdmd
import std.array : join;
import std.conv : to;
import std.format : format;
import std.algorithm : canFind, startsWith;
import std.exception : assertThrown, enforce;

/// sqlpp11dv2 - query builder with some templates

unittest {
    // same unittest as before
    alias QueryBuilder = QueryBuilderWithTemplates;

    assert(
        QueryBuilder
            .select("foo", "bar")
            .from("bazTable")
            .where_equal("foo", "42".to!string)
        == "select foo, bar from bazTable where foo='42'"
    );
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
    assertThrown!Exception(
        QueryBuilder
            .select("foo", "bar")
            .where_equal("foo", "abc")
        == "select foo, bar from bazTable where foo='true'"
    );
}

struct QueryBuilderWithTemplates {
    static auto select(string[] fields...) {
        return typeof(this)(format!"select %s"(fields.join(", ")));
    }
    auto from(string table) {
        return append(format!" from %s"(table));
    }
    // could even check if T has some features like to!string-able
    auto where_equal(T)(string field, T value) {
        enforce(this.query.canFind("from"), format!"from clause missing in '%s'"(this.query));
        return append(format!" where %s='%s'"(field, value));
    }
    
    // private stuff
    const query = "";
    @disable this();
    this(string query) { this.query = query; }
    alias query this;
    private typeof(this) append(string newStuff) {
        return typeof(this)(this.query ~ newStuff);
    }
}
