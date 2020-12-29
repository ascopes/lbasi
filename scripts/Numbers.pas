BEGIN
    dec_int := 12;
    hex_int := $13;
    oct_int := &12;
    bin_int := %00101101;

    real_without_exp := 3.14;
    real_exp_no_frac_1 := 1E10;
    real_exp_no_frac_2 := 2e10;
    real_exp_no_frac_3 := 3E+10;
    real_exp_no_frac_4 := 4E-10;
    real_exp_no_frac_5 := 5e+10;
    real_exp_no_frac_6 := 6e-10;
    real_exp_frac_1 := 1.14E10;
    real_exp_frac_2 := 2.14e10;
    real_exp_frac_3 := 3.14E+10;
    real_exp_frac_4 := 4.14E-10;
    real_exp_frac_5 := 5.14e+10;
    real_exp_frac_6 := 6.14e-10;
END.