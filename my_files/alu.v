module not32bit(notRes, a);
    input [31:0] a;
    output [31:0] notRes;
    not not0(notRes[0], a[0]);
    not not1(notRes[1], a[1]);
    not not2(notRes[2], a[2]);
    not not3(notRes[3], a[3]);
    not not4(notRes[4], a[4]);
    not not5(notRes[5], a[5]);
    not not6(notRes[6], a[6]);
    not not7(notRes[7], a[7]);
    not not8(notRes[8], a[8]);
    not not9(notRes[9], a[9]);
    not not10(notRes[10], a[10]);
    not not11(notRes[11], a[11]);
    not not12(notRes[12], a[12]);
    not not13(notRes[13], a[13]);
    not not14(notRes[14], a[14]);
    not not15(notRes[15], a[15]);
    not not16(notRes[16], a[16]);
    not not17(notRes[17], a[17]);
    not not18(notRes[18], a[18]);
    not not19(notRes[19], a[19]);
    not not20(notRes[20], a[20]);
    not not21(notRes[21], a[21]);
    not not22(notRes[22], a[22]);
    not not23(notRes[23], a[23]);
    not not24(notRes[24], a[24]);
    not not25(notRes[25], a[25]);
    not not26(notRes[26], a[26]);
    not not27(notRes[27], a[27]);
    not not28(notRes[28], a[28]);
    not not29(notRes[29], a[29]);
    not not30(notRes[30], a[30]);
    not not31(notRes[31], a[31]);
endmodule

module or32bit(orRes, a, b);
    input [31:0] a, b;
    output [31:0] orRes;
    or or0(orRes[0], a[0], b[0]);
    or or1(orRes[1], a[1], b[1]);
    or or2(orRes[2], a[2], b[2]);
    or or3(orRes[3], a[3], b[3]);
    or or4(orRes[4], a[4], b[4]);
    or or5(orRes[5], a[5], b[5]);
    or or6(orRes[6], a[6], b[6]);
    or or7(orRes[7], a[7], b[7]);
    or or8(orRes[8], a[8], b[8]);
    or or9(orRes[9], a[9], b[9]);
    or or10(orRes[10], a[10], b[10]);
    or or11(orRes[11], a[11], b[11]);
    or or12(orRes[12], a[12], b[12]);
    or or13(orRes[13], a[13], b[13]);
    or or14(orRes[14], a[14], b[14]);
    or or15(orRes[15], a[15], b[15]);
    or or16(orRes[16], a[16], b[16]);
    or or17(orRes[17], a[17], b[17]);
    or or18(orRes[18], a[18], b[18]);
    or or19(orRes[19], a[19], b[19]);
    or or20(orRes[20], a[20], b[20]);
    or or21(orRes[21], a[21], b[21]);
    or or22(orRes[22], a[22], b[22]);
    or or23(orRes[23], a[23], b[23]);
    or or24(orRes[24], a[24], b[24]);
    or or25(orRes[25], a[25], b[25]);
    or or26(orRes[26], a[26], b[26]);
    or or27(orRes[27], a[27], b[27]);
    or or28(orRes[28], a[28], b[28]);
    or or29(orRes[29], a[29], b[29]);
    or or30(orRes[30], a[30], b[30]);
    or or31(orRes[31], a[31], b[31]);
endmodule

module and32bit(andRes, a, b);
    input [31:0] a, b;
    output [31:0] andRes;
    and and0(andRes[0], a[0], b[0]);
    and and1(andRes[1], a[1], b[1]);
    and and2(andRes[2], a[2], b[2]);
    and and3(andRes[3], a[3], b[3]);
    and and4(andRes[4], a[4], b[4]);
    and and5(andRes[5], a[5], b[5]);
    and and6(andRes[6], a[6], b[6]);
    and and7(andRes[7], a[7], b[7]);
    and and8(andRes[8], a[8], b[8]);
    and and9(andRes[9], a[9], b[9]);
    and and10(andRes[10], a[10], b[10]);
    and and11(andRes[11], a[11], b[11]);
    and and12(andRes[12], a[12], b[12]);
    and and13(andRes[13], a[13], b[13]);
    and and14(andRes[14], a[14], b[14]);
    and and15(andRes[15], a[15], b[15]);
    and and16(andRes[16], a[16], b[16]);
    and and17(andRes[17], a[17], b[17]);
    and and18(andRes[18], a[18], b[18]);
    and and19(andRes[19], a[19], b[19]);
    and and20(andRes[20], a[20], b[20]);
    and and21(andRes[21], a[21], b[21]);
    and and22(andRes[22], a[22], b[22]);
    and and23(andRes[23], a[23], b[23]);
    and and24(andRes[24], a[24], b[24]);
    and and25(andRes[25], a[25], b[25]);
    and and26(andRes[26], a[26], b[26]);
    and and27(andRes[27], a[27], b[27]);
    and and28(andRes[28], a[28], b[28]);
    and and29(andRes[29], a[29], b[29]);
    and and30(andRes[30], a[30], b[30]);
    and and31(andRes[31], a[31], b[31]);
endmodule

module alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, overflow);
        
    input [31:0] data_operandA, data_operandB;
    input [4:0] ctrl_ALUopcode, ctrl_shiftamt;

    output [31:0] data_result;
    output isNotEqual, isLessThan, overflow;


    wire[31:0] andRes, orRes, addRes, subRes, sllRes, sraRes;

    and32bit andOp(andRes, data_operandA, data_operandB);
    or32bit orOp(orRes, data_operandA, data_operandB);

    wire addIn, subIn, addCout, subCout, subOverflow, addOverflow;
    assign addIn = 0;
    assign subIn = 1;
    cla_adder addOp(addRes, addCout, data_operandA, data_operandB, addIn);

    wire[31:0] subDataB;
    not32bit notDataB(subDataB, data_operandB);
    cla_adder subOp(subRes, subCout, data_operandA, subDataB, subIn);
    
    wire sumOperandsHaveSameSign, sumVsOperandDiffSign;
    xnor sumSameSignDetector(sumOperandsHaveSameSign, data_operandA[31], data_operandB[31]);
    xor sumVsOperand(sumVsOperandDiffSign, data_operandB[31], data_result[31]);
    and sunOverflowRes(addOverflow, sumVsOperandDiffSign, sumOperandsHaveSameSign);

    wire subOperandsHaveSameSign, subVsOperandDiffSign;
    xnor subSameSignDetector(subOperandsHaveSameSign, data_operandA[31], subDataB[31]);
    xor subVsOperand(subVsOperandDiffSign, subDataB[31], data_result[31]);
    and subOverflowRes(subOverflow, subVsOperandDiffSign, subOperandsHaveSameSign);
    
    assign overflow = ctrl_ALUopcode[0] ? subOverflow : addOverflow;

    right_shifter sraOp(sraRes, ctrl_shiftamt, data_operandA);
    left_shifter sllOp(sllRes, ctrl_shiftamt, data_operandA);

    wire aAndNotBSign;
    and ltAnd(aAndNotBSign, data_operandA[31], subDataB[31]);
    //or ltRes(isLessThan, subRes[31], aAndNotBSign);
    //assign isLessThan = subRes[31];
    assign isLessThan = overflow? aAndNotBSign : subRes[31];
    or notEqual(isNotEqual, subRes[31], subRes[30], subRes[29], subRes[28], subRes[27], subRes[26], 
    subRes[25], subRes[24], subRes[23], subRes[22], subRes[21], subRes[20], subRes[19], subRes[18], subRes[17], subRes[16], 
    subRes[15], subRes[14], subRes[13], subRes[12], subRes[11], subRes[10],subRes[9], subRes[8], subRes[7], subRes[6], 
    subRes[5], subRes[4], subRes[3], subRes[2], subRes[1], subRes[0]);

    wire[31:0] nop;
    assign nop = 0;

    mux32 resMux(.out(data_result), .select(ctrl_ALUopcode), .in0(addRes), .in1(subRes), .in2(andRes), .in3(orRes), .in4(sllRes), .in5(sraRes));
    // add your code here:

endmodule