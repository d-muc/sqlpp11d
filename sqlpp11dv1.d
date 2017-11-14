#!/usr/bin/env tdmd
import std.array : join;
import std.conv : to;
import std.format : format;
import std.algorithm : canFind, startsWith;
import std.exception : assertThrown, enforce;

/// sqlpp11dv1 - query builder without templates but with some compile time checks

unittest {
    alias QueryBuilder = QueryBuilderWithoutTemplates;
    // alias is the first template in this template free Query Builder

    /* AliasDeclarations create a symbol that is an alias for another type, and can be used anywhere that other type may appear. */

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
    // conv.to! template '42.to!int' instead of 'cast(int) 42'
    // short form of '42.to!(int)'
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

struct QueryBuilderWithoutTemplates {
    static auto select(string[] fields...) {
        // format! is a template that formats the string and at compile time complains about e.g. missing parameters
        return typeof(this)(format!"select %s"(fields.join(", ")));
    }
    auto from(string table) {
        enforce(this.query.startsWith("select"), "select not called");
        return append(format!" from %s"(table));
    }

    auto where_equal(string field, string value) {
        enforce(this.query.canFind("from"), format!"from clause missing in '%s'"(this.query));
        return append(format!" where %s='%s'"(field, value));
    }
    auto where_equal(string field, int value) {
        enforce(this.query.canFind("from"), format!"from clause missing in '%s'"(this.query));
        return append(format!" where %s='%s'"(field, value.to!string));
    }
    auto where_equal(string field, bool value) {
        enforce(this.query.canFind("from"), format!"from clause missing in '%s'"(this.query));
        return append(format!" where %s='%s'"(field, value ? "true" : "false"));
    }
    
    // private stuff
    immutable query = "";
    @disable this();
    private this(string query) { this.query = query; }
    // every method not defined in QueryBuilderWithoutTemplates will be forwarded to query
    alias query this;
    private auto append(string newStuff) {
        return typeof(this)(this.query ~ newStuff);
    }
}
