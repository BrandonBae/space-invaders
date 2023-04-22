module hex_7_seg(sevenOut, currNum);
    input [3:0]currNum;
    output[6:0] sevenOut;

    assign sevenOut[0] = (currNum==4'd2 | currNum==4'd3 | currNum==4'd0 | currNum==4'd5 | currNum==4'd6 | currNum==4'd7 | currNum==4'd8
                            | currNum==4'd9 | currNum==4'd10 | currNum==4'd12 | currNum==4'd14 | currNum==4'd15) ? 1'b0 : 1'b1;
    assign sevenOut[1] = (currNum==4'd1 | currNum==4'd2 | currNum==4'd3 | currNum==4'd4 | currNum==4'd0 | currNum==4'd7 | currNum==4'd8
                            | currNum==4'd9 | currNum==4'd10 | currNum==4'd13) ? 1'b0 : 1'b1;
    assign sevenOut[2] = (currNum==4'd0 | currNum==4'd1 | currNum==4'd3 | currNum==4'd4 | currNum==4'd5 | currNum==4'd6 | currNum==4'd7 
                            | currNum==4'd8 | currNum==4'd9 | currNum==4'd10 | currNum==4'd11 | currNum==4'd13) ? 1'b0 : 1'b1;
    assign sevenOut[3] = (currNum==4'd0 | currNum==4'd2 | currNum==4'd3 | currNum==4'd5 | currNum==4'd6 | currNum==4'd8 | currNum==4'd9
                            | currNum==4'd11 | currNum==4'd12 | currNum==4'd14 | currNum==4'd13) ? 1'b0 : 1'b1;
    assign sevenOut[4] = (currNum==4'd2 | currNum==4'd0 | currNum==4'd6 | currNum==4'd8 | currNum==4'd10 | currNum==4'd11 | currNum==4'd12
                            | currNum==4'd13 | currNum==4'd14 | currNum==4'd15) ? 1'b0 : 1'b1;
    assign sevenOut[5] = (currNum==4'd4 | currNum==4'd0 | currNum==4'd5 | currNum==4'd6 | currNum==4'd8 | currNum==4'd9 | currNum==4'd10
                            | currNum==4'd11 | currNum==4'd12 | currNum==4'd14 | currNum==4'd15) ? 1'b0 : 1'b1;
    assign sevenOut[6] = (currNum==4'd2 | currNum==4'd3 | currNum==3'd4 | currNum==3'd5 | currNum==3'd6 | currNum==4'd8 | currNum==4'd9
                            | currNum==4'd10 | currNum==4'd11 | currNum==4'd13 | currNum==4'd14 | currNum==4'd15) ? 1'b0 : 1'b1;
endmodule
