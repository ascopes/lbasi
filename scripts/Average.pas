PROGRAM test;
VAR
    a, b, c, d : INTEGER ;
    sum        : INTEGER;
    average    : REAL ;
BEGIN
    { Values to average: }
    a := 1;
    b := 3;
    c := 5;
    d := 9;

    { Sum the values: }
    sum := a + b + c + d;

    { Take the average: }
    average := sum / 4;

    (* This is an old-style Pascal comment, but we should support this too. *)
END.
