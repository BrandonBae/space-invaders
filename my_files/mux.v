module mux2OneBit(out, select, in0, in1);
    input select;
    input in0, in1;
    output out;
    assign out = select? in1 : in0;
endmodule

module mux4OneBit(out, select, in0, in1, in2, in3);
    input[1:0] select;
    input in0, in1, in2, in3;
    output out;
    wire w1, w2;

    mux2OneBit first2(w1, select[0], in0, in1);
    mux2OneBit last2(w2, select[0], in2, in3);

    mux2OneBit second(out, select[1], w1, w2);
endmodule

module mux8OneBit(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input[2:0] select;
    input in0, in1, in2, in3, in4, in5, in6, in7;
    output out;
    wire w1, w2;

    mux4OneBit first4(w1, select[1:0], in0, in1, in2, in3);
    mux4OneBit last4(w2, select[1:0], in4, in5, in6, in7);

    mux2OneBit second(out, select[2], w1, w2);
endmodule

module mux16OneBit(out, select, in0, in1, in2, in3, in4, in5, in6, in7,
            in8, in9, in10, in11, in12, in13, in14, in15);
    input[3:0] select;
    input in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
    output out;
    wire w1, w2;

    mux8OneBit first8(w1, select[2:0], in0, in1, in2, in3, in4, in5, in6, in7);
    mux8OneBit last8(w2, select[2:0], in8, in9, in10, in11, in12, in13, in14, in15);

    mux2OneBit second(out, select[3], w1, w2);
endmodule

module mux32OneBit(out, select, in0, in1, in2, in3, in4, in5, in6, in7,
            in8, in9, in10, in11, in12, in13, in14, in15,
            in16, in17, in18, in19, in20, in21, in22, in23,
            in24, in25, in26, in27, in28, in29, in30, in31);
    input[4:0] select;
    input in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15,
                in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31;
    output out;
    wire w1, w2;

    mux16OneBit first16(w1, select[3:0], in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15);
    mux16OneBit last16(w2, select[3:0], in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31);

    mux2OneBit second(out, select[4], w1, w2);
endmodule

module mux2FiveBit(out, select, in0, in1);
    input select;
    input [4:0] in0, in1;
    output[4:0] out;
    assign out = select? in1 : in0;
endmodule

module mux4FiveBit(out, select, in0, in1, in2, in3);
    input[1:0] select;
    input[4:0] in0, in1, in2, in3;
    output[4:0] out;
    wire[4:0] w1, w2;

    mux2FiveBit first2(w1, select[0], in0, in1);
    mux2FiveBit last2(w2, select[0], in2, in3);

    mux2FiveBit second(out, select[1], w1, w2);
endmodule

module mux2(out, select, in0, in1);
    input select;
    input [31:0] in0, in1;
    output[31:0] out;
    assign out = select? in1 : in0;
endmodule

module mux4(out, select, in0, in1, in2, in3);
    input[1:0] select;
    input[31:0] in0, in1, in2, in3;
    output[31:0] out;
    wire[31:0] w1, w2;

    mux2 first2(w1, select[0], in0, in1);
    mux2 last2(w2, select[0], in2, in3);

    mux2 second(out, select[1], w1, w2);
endmodule

module mux8(out, select, in0, in1, in2, in3, in4, in5, in6, in7);
    input[2:0] select;
    input[31:0] in0, in1, in2, in3, in4, in5, in6, in7;
    output[31:0] out;
    wire[31:0] w1, w2;

    mux4 first4(w1, select[1:0], in0, in1, in2, in3);
    mux4 last4(w2, select[1:0], in4, in5, in6, in7);

    mux2 second(out, select[2], w1, w2);
endmodule

module mux16(out, select, in0, in1, in2, in3, in4, in5, in6, in7,
            in8, in9, in10, in11, in12, in13, in14, in15);
    input[3:0] select;
    input[31:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15;
    output[31:0] out;
    wire[31:0] w1, w2;

    mux8 first8(w1, select[2:0], in0, in1, in2, in3, in4, in5, in6, in7);
    mux8 last8(w2, select[2:0], in8, in9, in10, in11, in12, in13, in14, in15);

    mux2 second(out, select[3], w1, w2);
endmodule

module mux32(out, select, in0, in1, in2, in3, in4, in5, in6, in7,
            in8, in9, in10, in11, in12, in13, in14, in15,
            in16, in17, in18, in19, in20, in21, in22, in23,
            in24, in25, in26, in27, in28, in29, in30, in31);
    input[4:0] select;
    input[31:0] in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15,
                in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31;
    output[31:0] out;
    wire[31:0] w1, w2;

    mux16 first16(w1, select[3:0], in0, in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, in13, in14, in15);
    mux16 last16(w2, select[3:0], in16, in17, in18, in19, in20, in21, in22, in23, in24, in25, in26, in27, in28, in29, in30, in31);

    mux2 second(out, select[4], w1, w2);
endmodule