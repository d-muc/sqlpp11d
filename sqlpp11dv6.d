#!/usr/bin/env tdmd

/// sqlpp11dv6 - Compile Time Reading of CreateTable.sql for Type Checking

unittest {
    auto table = Table!`CREATE TABLE foo (
        id bigint,
        name varchar(50),
        hasFun bool
    );`();
    // for production code could write:
    //    const tableDefinition = import("database/createTable.sql")
    //    const table = Table!tableDefinition;
    assert(table.query!"select * from examples" == ["foo", "bar"]);
}


struct Table(string definition) {
    string[] query(string input)() {
        return ["foo", "bar"];
    }
    
    void parseDefinition() {
        // here check which fields, which types, ...
    }
}
