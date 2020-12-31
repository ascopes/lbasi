PROGRAM test;
VAR
    { Invalid type, should fail during symbolic analysis. }
    foo, bar, baz : POTATO;
BEGIN
    foo := 12;
END.
