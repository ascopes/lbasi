PROGRAM test;
VAR
    a, b, c, d : REAL ;
    sum        : REAL;
    average    : REAL ;
BEGIN
    { Values to average: }
    a := 1.0;
    b := 3.0;
    c := 5.0;
    d := 9.0;

    { Sum the values: }
    sum := a + b + c + d;

    { Take the average: }
    average := sum DIV 4.5;

    (* This is an old-style Pascal comment, but we should support this too. *)
END.
