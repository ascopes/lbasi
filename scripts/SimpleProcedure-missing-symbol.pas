PROGRAM Part12;
VAR
   a : INTEGER;

PROCEDURE P1;
VAR
   a : REAL;
   k : INTEGER;

   PROCEDURE P2;
   VAR
      a, z : INTEGER;
   BEGIN {P2}
      z := 777;
   END;  {P2}

BEGIN {P1}

END;  {P1}

PROCEDURE P3(foo : INTEGER);
VAR
   a : REAL;
   k : INTEGER;
BEGIN {P3}
END;  {P3}

PROCEDURE P4(foo : INTEGER; bar, baz: REAL);
VAR
   a : REAL;
   k : INTEGER;
BEGIN {P4}
END;  {P4}

BEGIN {Part12}
   a := P5;
END.  {Part12}
