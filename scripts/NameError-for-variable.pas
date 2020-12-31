PROGRAM test;
VAR
    foo, bar, baz : INTEGER;
BEGIN
    { Invalid name, should fail during symbolic analysis. }
    bork := foo + bar;
END.
