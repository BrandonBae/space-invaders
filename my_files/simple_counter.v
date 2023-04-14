module simple_counter(currCount, clk, enable, rst);
    input clk, enable, rst;
    output[4:0] currCount;

    wire enabledClk;
    assign enabledClk = (clk & enable);

    wire enableOn; 
    assign enableOn = 1'b1;
    tff bit0Tff(.q(currCount[0]), .t(enableOn), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit1Input;
    assign bit1Input = currCount[0];
    tff bit1Tff(.q(currCount[1]), .t(bit1Input), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit2Input;
    and bit2And(bit2Input, currCount[0], currCount[1]);
    tff bit2Tff(.q(currCount[2]), .t(bit2Input), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit3Input;
    and bit3And(bit3Input, currCount[0], currCount[1], currCount[2]);
    tff bit3Tff(.q(currCount[3]), .t(bit3Input), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit4Input;
    and bit4And(bit4Input, currCount[0], currCount[1], currCount[2], currCount[3]);
    tff bit4Tff(.q(currCount[4]), .t(bit4Input), .clk(enabledClk), .en(enableOn), .clr(rst));

endmodule

module simple_5bit_counter(currCount, clk, enable, rst);
    input clk, enable, rst;
    output[5:0] currCount;

    wire enabledClk;
    assign enabledClk = (clk & enable);

    wire enableOn; 
    assign enableOn = 1'b1;
    tff bit0Tff(.q(currCount[0]), .t(enableOn), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit1Input;
    assign bit1Input = currCount[0];
    tff bit1Tff(.q(currCount[1]), .t(bit1Input), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit2Input;
    and bit2And(bit2Input, currCount[0], currCount[1]);
    tff bit2Tff(.q(currCount[2]), .t(bit2Input), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit3Input;
    and bit3And(bit3Input, currCount[0], currCount[1], currCount[2]);
    tff bit3Tff(.q(currCount[3]), .t(bit3Input), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit4Input;
    and bit4And(bit4Input, currCount[0], currCount[1], currCount[2], currCount[3]);
    tff bit4Tff(.q(currCount[4]), .t(bit4Input), .clk(enabledClk), .en(enableOn), .clr(rst));
    wire bit5Input;
    and bit5And(bit5Input, currCount[0], currCount[1], currCount[2], currCount[3], currCount[4]);
    tff bit5Tff(.q(currCount[5]), .t(bit5Input), .clk(enabledClk), .en(enableOn), .clr(rst));

endmodule