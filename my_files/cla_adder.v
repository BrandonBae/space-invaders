module cla_carry(Cout, G, P, Cin);
    input G, P, Cin;
    output Cout;

    wire p_cin;

    and p_and_cin(p_cin, P, Cin);
    or Cout_Calc(Cout, G, p_cin);
endmodule

module eight_bit_cla_block(S, G, P, A, B, Cin);
    input [7:0] A, B;
    input Cin;
    output G, P;
    output [7:0] S;
    wire g0, p0, g1, p1, g2, p2, g3, p3, g4, p4, g5, p5, g6, p6, g7, p7;
    wire c1, c2, c3, c4, c5, c6, c7;
    
    and g0Func(g0, A[0], B[0]);
    and g1Func(g1, A[1], B[1]);
    and g2Func(g2, A[2], B[2]);
    and g3Func(g3, A[3], B[3]);
    and g4Func(g4, A[4], B[4]);
    and g5Func(g5, A[5], B[5]);
    and g6Func(g6, A[6], B[6]);
    and g7Func(g7, A[7], B[7]);

    or p0Func(p0, A[0], B[0]);
    or p1Func(p1, A[1], B[1]);
    or p2Func(p2, A[2], B[2]);
    or p3Func(p3, A[3], B[3]);
    or p4Func(p4, A[4], B[4]);
    or p5Func(p5, A[5], B[5]);
    or p6Func(p6, A[6], B[6]);
    or p7Func(p7, A[7], B[7]);

    //cla_carry c1_calc(c1, g0, p0, Cin);
    wire c1w1;
    and c1And1(c1w1, p0, Cin);
    or c1Res(c1, g0, c1w1);

    //cla_carry c2_calc(c2, g1, p1, C1);
    wire c2w1, c2w2;
    and c2And1(c2w1, p1, g0);
    and c2And2(c2w2, p1, p0, Cin);
    or c2Res(c2, g1, c2w1, c2w2);

    //cla_carry c3_calc(c3, g2, p2, C2);
    wire c3w1, c3w2, c3w3;
    and c3And1(c3w1, p2, g1);
    and c3And2(c3w2, p2, p1, g0);
    and c3And3(c3w3, p2, p1, p0, Cin);
    or c3Res(c3, g2, c3w1, c3w2, c3w3);

    //cla_carry c4_calc(c4, g3, p3, Cin);
    wire c4w1, c4w2, c4w3, c4w4;
    and c4And1(c4w1, p3, g2);
    and c4And2(c4w2, p3, p2, g1);
    and c4And3(c4w3, p3, p2, p1, g0);
    and c4And4(c4w4, p3, p2, p1, p0, Cin);
    or c4Res(c4, g3, c4w1, c4w2, c4w3, c4w4);

    //cla_carry c5_calc(c5, g4, p4, Cin);
    wire c5w1, c5w2, c5w3, c5w4, c5w5;
    and c5And1(c5w1, p4, g3);
    and c5And2(c5w2, p4, p3, g2);
    and c5And3(c5w3, p4, p3, p2, g1);
    and c5And4(c5w4, p4, p3, p2, p1, g0);
    and c5And5(c5w5, p4, p3, p2, p1, p0, Cin);
    or c5Res(c5, g4, c5w1, c5w2, c5w3, c5w4, c5w5);

    //cla_carry c6_calc(c6, g5, p5, Cin);
    wire c6w1, c6w2, c6w3, c6w4, c6w5, c6w6;
    and c6And1(c6w1, p5, g4);
    and c6And2(c6w2, p5, p4, g3);
    and c6And3(c6w3, p5, p4, p3, g2);
    and c6And4(c6w4, p5, p4, p3, p2, g1);
    and c6And5(c6w5, p5, p4, p3, p2, p1, g0);
    and c6And6(c6w6, p5, p4, p3, p2, p1, p0, Cin);
    or c6Res(c6, g5, c6w1, c6w2, c6w3, c6w4, c6w5, c6w6);

    //cla_carry c7_calc(c7, g6, p6, Cin);
    wire c7w1, c7w2, c7w3, c7w4, c7w5, c7w6, c7w7;
    and c7And1(c7w1, p6, g5);
    and c7And2(c7w2, p6, p5, g4);
    and c7And3(c7w3, p6, p5, p4, g3);
    and c7And4(c7w4, p6, p5, p4, p3, g2);
    and c7And5(c7w5, p6, p5, p4, p3, p2, g1);
    and c7And6(c7w6, p6, p5, p4, p3, p2, p1, g0);
    and c7And7(c7w7, p6, p5, p4, p3, p2, p1, p0, Cin);
    or c7Res(c7, g6, c7w1, c7w2, c7w3, c7w4, c7w5, c7w6, c7w7);

    /*
    assign Cout[0] = Cin;
    assign Cout[1] = c1;
    assign Cout[2] = c2;
    assign Cout[3] = c3;
    assign Cout[4] = c4;
    assign Cout[5] = c5;
    assign Cout[6] = c6;
    assign Cout[7] = c7;
    */

    xor s0_calc(S[0], A[0], B[0], Cin);
    xor s1_calc(S[1], A[1], B[1], c1);
    xor s2_calc(S[2], A[2], B[2], c2);
    xor s3_calc(S[3], A[3], B[3], c3);
    xor s4_calc(S[4], A[4], B[4], c4);
    xor s5_calc(S[5], A[5], B[5], c5);
    xor s6_calc(S[6], A[6], B[6], c6);
    xor s7_calc(S[7], A[7], B[7], c7);

    and P_calc(P, p0, p1, p2, p3, p4, p5, p6, p7);

    wire g0And, g1And, g2And, g3And, g4And, g5And, g6And;

    and g6AndCalc(g6And, p7, g6);
    and g5AndCalc(g5And, p7, p6, g5);
    and g4AndCalc(g4And, p7, p6, p5, g4);
    and g3AndCalc(g3And, p7, p6, p5, p4, g3);
    and g2AndCalc(g2And, p7, p6, p5, p4, p3, g2);
    and g1AndCalc(g1And, p7, p6, p5, p4, p3, p2, g1);
    and g0AndCalc(g0And, p7, p6, p5, p4, p3, p2, p1, g0);
    or G_calc(G, g7, g6And, g5And, g4And, g3And, g2And, g1And, g0And);
endmodule

module cla_adder(S, Cout, A, B, Cin);
    input [31:0] A, B;
    input Cin;
    output [31:0] S;
    output Cout;

    wire g0, p0, g1, p1, g2, p2, g3, p3;
    wire c8, c16, c24, c32;

    eight_bit_cla_block block0(S[7:0], g0, p0, A[7:0], B[7:0], Cin);

    wire c8w1;
    and c8And1(c8w1, p0, Cin);
    or c8Res(c8, c8w1, g0);

    eight_bit_cla_block block1(S[15:8], g1, p1, A[15:8], B[15:8], c8);

    wire c16w1, c16w2;
    and c16And1(c16w1, p1, g0);
    and c16And2(c16w2, p1, p0, Cin);
    or c16Res(c16, c16w1, c16w2, g1);

    eight_bit_cla_block block2(S[23:16], g2, p2, A[23:16], B[23:16], c16);

    wire c24w1, c24w2, c24w3;
    and c24And1(c24w1, p2, g1);
    and c24And2(c24w2, p2, p1, g0);
    and c24And3(c24w3, p2, p1, p0, Cin);
    or c24Res(c24, c24w1, c24w2, c24w3, g2);

    eight_bit_cla_block block3(S[31:24], g3, p3, A[31:24], B[31:24], c24);

    wire c32w1, c32w2, c32w3, c32w4;
    and c32And1(c32w1, p3, g2);
    and c32And2(c32w2, p3, p2, g1);
    and c32And3(c32w3, p3, p2, p1, g0);
    and c32And4(c32w4, p3, p2, p1, p0, Cin);
    or c32Res(Cout, c32w1, c32w2, c32w3, c32w4, g3);
endmodule