module mult(mult_ready, mult_exception, mult_result, data_operandA, data_operandB, clk, rst);
    input clk, rst;
    wire notClk = ~clk;
    input [31:0] data_operandA, data_operandB;
    output mult_ready, mult_exception;
    output [31:0] mult_result;

    wire notMultReady;
    assign mult_ready = (~currCount[0] & ~currCount[1] & ~currCount[2] & ~currCount[3] & currCount[4]);
    wire[4:0] currCount;
    wire enable_bit;
    assign enable_bit = 1'b1;
    simple_counter counter(.currCount(currCount), .clk(clk), .enable(notMultReady), .rst(rst)); //enable should be notmult
    //(currCount, clk, enable, rst)
    assign notMultReady = ~mult_ready;

    wire[31:0] shiftedA = data_operandA<<1;

    wire[2:0] select;
    wire thirdSelectBitInput;
    assign thirdSelectBitInput = rst ? 0:select[2]; 
    assign select[2:1] = currProduct[1:0];
    dffe_ref thirdSelectBit(select[0], thirdSelectBitInput, clk, 1'b1, rst);
    
    wire[31:0] thingToAdd;
    wire[31:0] notThingToAdd = ~thingToAdd;
    wire subOrAdd;
    mux8 thingToAddMux(thingToAdd, select, 0, data_operandA, data_operandA, shiftedA, shiftedA, data_operandA, data_operandA, 0);
    mux8OneBit subOrAddMux(subOrAdd, select, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b0);

    /*
    wire[63:0] product;
    wire[63:0] shiftedProduct = product>>2;
    register_64bit productRegister(product, shiftedProduct, clk, notMultReady, 1'b1, rst);
    cla_adder(S, Cout, product[63:32], thingToAdd, subOrAdd);
    */
    wire Cout; //temp Cout wire to handle adder carryout
    wire[63:0] initialProduct;
    wire[31:0] currUpper32Bits;
    assign initialProduct[31:0] = data_operandB;
    assign initialProduct[63:32] = 0;
    wire[63:0] postAdd;
    assign postAdd[31:0] = currProduct[31:0];

    wire[31:0] adderInput = subOrAdd ? notThingToAdd:thingToAdd;
    cla_adder adder(postAdd[63:32], Cout, currUpper32Bits, adderInput, subOrAdd);

    wire[63:0] shiftedProduct;
    wire[63:0] shiftedPostAdd = postAdd >>> 2;
    assign shiftedProduct = rst ? initialProduct:$signed($signed(postAdd) >>> 2); 
    wire[63:0] currProduct;
    register_64bit productRegister(currProduct, shiftedProduct, clk, notMultReady, 1'b1, 1'b0);
    assign currUpper32Bits = currProduct[63:32];
    //register_32bit currUpper32BitsReg(currUpper32Bits, currProduct[63:32], notClk, 1'b1, 1'b1, rst);

    wire negPosChoose = currProduct[63];
    wire[31:0] zeroOvf = ({(32){1'b0}} ~^ currProduct[63:32]);
    wire[31:0] oneOvf = ({(32){1'b1}} ~^ currProduct[63:32]);
    wire zeroAnd, oneAnd;
    and andZeroOvf(zeroAnd, zeroOvf[31], zeroOvf[30], zeroOvf[29], zeroOvf[28],
                zeroOvf[27], zeroOvf[26], zeroOvf[25], zeroOvf[24],
                zeroOvf[23], zeroOvf[22], zeroOvf[21], zeroOvf[20],
                zeroOvf[19], zeroOvf[18], zeroOvf[17], zeroOvf[16],
                zeroOvf[15], zeroOvf[14], zeroOvf[13], zeroOvf[12],
                zeroOvf[11], zeroOvf[10], zeroOvf[9], zeroOvf[8],
                zeroOvf[7], zeroOvf[6], zeroOvf[5], zeroOvf[4],
                zeroOvf[3], zeroOvf[2], zeroOvf[1], zeroOvf[0]);
    and andOneOvf(oneAnd, oneOvf[31], oneOvf[30], oneOvf[29], oneOvf[28],
                oneOvf[27], oneOvf[26], oneOvf[25], oneOvf[24],
                oneOvf[23], oneOvf[22], oneOvf[21], oneOvf[20],
                oneOvf[19], oneOvf[18], oneOvf[17], oneOvf[16],
                oneOvf[15], oneOvf[14], oneOvf[13], oneOvf[12],
                oneOvf[11], oneOvf[10], oneOvf[9], oneOvf[8],
                oneOvf[7], oneOvf[6], oneOvf[5], oneOvf[4],
                oneOvf[3], oneOvf[2], oneOvf[1], oneOvf[0]);
    wire signCheck;
    xnor signCheckXnor(signCheck, data_operandA[31], data_operandB[31], currProduct[31]);
    wire[31:0] aXorZero = ({(32){1'b0}} ~^ data_operandA);
    wire aIsZero;
    and andAIsZero(aIsZero, aXorZero[31], aXorZero[30], aXorZero[29], aXorZero[28],
                aXorZero[27], aXorZero[26], aXorZero[25], aXorZero[24],
                aXorZero[23], aXorZero[22], aXorZero[21], aXorZero[20],
                aXorZero[19], aXorZero[18], aXorZero[17], aXorZero[16],
                aXorZero[15], aXorZero[14], aXorZero[13], aXorZero[12],
                aXorZero[11], aXorZero[10], aXorZero[9], aXorZero[8],
                aXorZero[7], aXorZero[6], aXorZero[5], aXorZero[4],
                aXorZero[3], aXorZero[2], aXorZero[1], aXorZero[0]);
    wire[31:0] bXorZero = ({(32){1'b0}} ~^ data_operandB);
    wire bIsZero;
    and andBIsZero(bIsZero, bXorZero[31], bXorZero[30], bXorZero[29], bXorZero[28],
                bXorZero[27], bXorZero[26], bXorZero[25], bXorZero[24],
                bXorZero[23], bXorZero[22], bXorZero[21], bXorZero[20],
                bXorZero[19], bXorZero[18], bXorZero[17], bXorZero[16],
                bXorZero[15], bXorZero[14], bXorZero[13], bXorZero[12],
                bXorZero[11], bXorZero[10], bXorZero[9], bXorZero[8],
                bXorZero[7], bXorZero[6], bXorZero[5], bXorZero[4],
                bXorZero[3], bXorZero[2], bXorZero[1], bXorZero[0]);
    wire signCheck_AccountForZero = (aIsZero | bIsZero) ? 1 : signCheck;
    wire[31:0] multiplierXorZero = ({(32){1'b0}} ~^ data_operandB);
    assign mult_exception = (negPosChoose ? ~oneAnd : ~zeroAnd) | ~signCheck_AccountForZero | negPosChoose^currProduct[31];
    assign mult_result = currProduct[31:0];
endmodule

module unsigned_div(div_ready, div_exception, div_result, data_operandA, data_operandB, clk, rst);
    input clk, rst;
    wire notClk = ~clk;
    input [31:0] data_operandA, data_operandB;
    output div_ready, div_exception;
    output [31:0] div_result;

    wire notDivReady;
    assign div_ready = (currCount[5]);
    /*
    wire[4:0] currCount;
    wire enable_bit;
    assign enable_bit = 1'b1;
    simple_counter counter(.currCount(currCount), .clk(clk), .enable(notDivReady), .rst(rst)); //enable should be notmult
    */
    wire[5:0] currCount;
    wire enable_bit;
    assign enable_bit = 1'b1;
    simple_5bit_counter counter(.currCount(currCount), .clk(clk), .enable(notDivReady), .rst(rst)); //enable should be notmult
    //(currCount, clk, enable, rst)
    assign notDivReady = ~div_ready;

    wire[63:0] currQuotient;

    wire Cout; //temp Cout wire to handle adder carryout
    wire[63:0] initialQuotient;
    wire[31:0] currUpper32Bits;
    assign initialQuotient[31:0] = data_operandA;
    assign initialQuotient[63:32] = 0;

    wire[63:0] postAdd;
    assign postAdd[31:1] = shiftedQuotient[31:1];
    assign postAdd[0] = ~postAdd[63];
    wire subOrAdd;
    assign subOrAdd = ~currQuotient[63];
    wire[31:0] adderInput = subOrAdd ? ~data_operandB : data_operandB;
    cla_adder adder(postAdd[63:32], Cout, currShiftedUpper32Bits, adderInput, subOrAdd);

    wire[63:0] shiftedQuotient = currQuotient << 1;
    wire[63:0] registerInput;
    assign registerInput = rst ? initialQuotient:postAdd; 
    wire[63:0] currProduct;
    register_64bit quotientRegister(currQuotient, registerInput, clk, notDivReady, 1'b1, 1'b0);
    //assign currUpper32Bits = currProduct[63:32];
    wire[31:0] currShiftedUpper32Bits;
    assign currShiftedUpper32Bits = shiftedQuotient[63:32];
    //register_32bit currUpper32BitsReg(currUpper32Bits, currProduct[63:32], notClk, 1'b1, 1'b1, rst);

    /*
    wire negPosChoose = currProduct[63];
    wire[31:0] zeroOvf = ({(32){1'b0}} ~^ currProduct[63:32]);
    wire[31:0] oneOvf = ({(32){1'b1}} ~^ currProduct[63:32]);
    wire zeroAnd, oneAnd;
    and andZeroOvf(zeroAnd, zeroOvf[31], zeroOvf[30], zeroOvf[29], zeroOvf[28],
                zeroOvf[27], zeroOvf[26], zeroOvf[25], zeroOvf[24],
                zeroOvf[23], zeroOvf[22], zeroOvf[21], zeroOvf[20],
                zeroOvf[19], zeroOvf[18], zeroOvf[17], zeroOvf[16],
                zeroOvf[15], zeroOvf[14], zeroOvf[13], zeroOvf[12],
                zeroOvf[11], zeroOvf[10], zeroOvf[9], zeroOvf[8],
                zeroOvf[7], zeroOvf[6], zeroOvf[5], zeroOvf[4],
                zeroOvf[3], zeroOvf[2], zeroOvf[1], zeroOvf[0]);
    and andOneOvf(oneAnd, oneOvf[31], oneOvf[30], oneOvf[29], oneOvf[28],
                oneOvf[27], oneOvf[26], oneOvf[25], oneOvf[24],
                oneOvf[23], oneOvf[22], oneOvf[21], oneOvf[20],
                oneOvf[19], oneOvf[18], oneOvf[17], oneOvf[16],
                oneOvf[15], oneOvf[14], oneOvf[13], oneOvf[12],
                oneOvf[11], oneOvf[10], oneOvf[9], oneOvf[8],
                oneOvf[7], oneOvf[6], oneOvf[5], oneOvf[4],
                oneOvf[3], oneOvf[2], oneOvf[1], oneOvf[0]);
    wire signCheck;
    xnor signCheckXnor(signCheck, data_operandA[31], data_operandB[31], currProduct[31]);
    wire[31:0] aXorZero = ({(32){1'b0}} ~^ data_operandA);
    wire aIsZero;
    and andAIsZero(aIsZero, aXorZero[31], aXorZero[30], aXorZero[29], aXorZero[28],
                aXorZero[27], aXorZero[26], aXorZero[25], aXorZero[24],
                aXorZero[23], aXorZero[22], aXorZero[21], aXorZero[20],
                aXorZero[19], aXorZero[18], aXorZero[17], aXorZero[16],
                aXorZero[15], aXorZero[14], aXorZero[13], aXorZero[12],
                aXorZero[11], aXorZero[10], aXorZero[9], aXorZero[8],
                aXorZero[7], aXorZero[6], aXorZero[5], aXorZero[4],
                aXorZero[3], aXorZero[2], aXorZero[1], aXorZero[0]);
    wire[31:0] bXorZero = ({(32){1'b0}} ~^ data_operandB);
    wire bIsZero;
    and andBIsZero(bIsZero, bXorZero[31], bXorZero[30], bXorZero[29], bXorZero[28],
                bXorZero[27], bXorZero[26], bXorZero[25], bXorZero[24],
                bXorZero[23], bXorZero[22], bXorZero[21], bXorZero[20],
                bXorZero[19], bXorZero[18], bXorZero[17], bXorZero[16],
                bXorZero[15], bXorZero[14], bXorZero[13], bXorZero[12],
                bXorZero[11], bXorZero[10], bXorZero[9], bXorZero[8],
                bXorZero[7], bXorZero[6], bXorZero[5], bXorZero[4],
                bXorZero[3], bXorZero[2], bXorZero[1], bXorZero[0]);
    wire signCheck_AccountForZero = (aIsZero | bIsZero) ? 1 : signCheck;
    wire[31:0] multiplierXorZero = ({(32){1'b0}} ~^ data_operandB);*/
    //assign mult_exception = (negPosChoose ? ~oneAnd : ~zeroAnd) | ~signCheck_AccountForZero | negPosChoose^currProduct[31];
    /*
    wire tempCout2;
    wire[63:0] restoredRes;
    cla_adder restoreAdder(S, tempCout2, currQuotient, data_operandB, 1'b0)
    */
    and exceptionAnd(div_exception, ~data_operandB[0], ~data_operandB[1], ~data_operandB[2], ~data_operandB[3],
                                ~data_operandB[27], ~data_operandB[26], ~data_operandB[25], ~data_operandB[24],
                                ~data_operandB[23], ~data_operandB[22], ~data_operandB[21], ~data_operandB[20],
                                ~data_operandB[19], ~data_operandB[18], ~data_operandB[17], ~data_operandB[16],
                                ~data_operandB[15], ~data_operandB[14], ~data_operandB[13], ~data_operandB[12],
                                ~data_operandB[11], ~data_operandB[10], ~data_operandB[9], ~data_operandB[8],
                                ~data_operandB[7], ~data_operandB[6], ~data_operandB[5], ~data_operandB[4],
                                ~data_operandB[3], ~data_operandB[2], ~data_operandB[1], ~data_operandB[0]);
    assign div_result = currQuotient[31:0];
endmodule

module multdiv(
	data_operandA, data_operandB, 
	ctrl_MULT, ctrl_DIV, 
	clock, 
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    wire isMult, isDiv;
    sr_latch opTypeLatch(isMult, isDiv, ctrl_MULT, ctrl_DIV);

    
    wire mult_ready, div_ready, mult_exception, div_module_exception, div_exception;
    wire[31:0] mult_result, div_result;

    //start of mult stuff
    mult multiplier(.mult_ready(mult_ready), .mult_exception(mult_exception), .mult_result(mult_result), .data_operandA(data_operandA), .data_operandB(data_operandB), .clk(clock), .rst(ctrl_MULT));
    //end of mult stuff

    //start of div stuff
    wire tempCout0, tempCout1, tempCout2;
    wire [31:0] div_inputA, div_inputB, raw_div_output;
    wire[31:0] complementA, complementB;
    cla_adder positiveAAdder(complementA, tempCout0, ~data_operandA, 1, 1'b0);
    cla_adder positiveBAdder(complementB, tempCout1, ~data_operandB, 1, 1'b0);

    assign div_inputA = data_operandA[31] ? complementA:data_operandA;
    assign div_inputB = data_operandB[31] ? complementB:data_operandB;
    unsigned_div divider(.div_ready(div_ready), .div_exception(div_module_exception), .div_result(raw_div_output), .data_operandA(div_inputA), .data_operandB(div_inputB), .clk(clock), .rst(ctrl_DIV));
    
    wire[31:0] raw_div_output_complement;
    cla_adder outputComplement(raw_div_output_complement, tempCout2, ~raw_div_output, 1, 1'b0);

    assign div_result = data_operandA[31] ^ data_operandB[31] ? raw_div_output_complement:raw_div_output;

    wire divSignException, resIsZero;
    and exceptionAnd(resIsZero, ~div_result[0], ~div_result[1], ~div_result[2], ~div_result[3],
                                ~div_result[27], ~div_result[26], ~div_result[25], ~div_result[24], 
                                ~div_result[23], ~div_result[22], ~div_result[21], ~div_result[20],
                                ~div_result[19], ~div_result[18], ~div_result[17], ~div_result[16],
                                ~div_result[15], ~div_result[14], ~div_result[13], ~div_result[12],
                                ~div_result[11], ~div_result[10], ~div_result[9], ~div_result[8],
                                ~div_result[7], ~div_result[6], ~div_result[5], ~div_result[4],
                                ~div_result[3], ~div_result[2], ~div_result[1], ~div_result[0]);
    assign divSignException = (div_result[31] ^ data_operandA[31] ^ data_operandB[31]) & ~resIsZero;
    assign div_exception = divSignException | div_module_exception;
    //end of Div Stuff

    output [31:0] data_result;
    output data_exception, data_resultRDY;
    assign data_resultRDY = isMult ? mult_ready : div_ready;
    assign data_result = isMult ? mult_result : div_result;
    assign data_exception = isMult ? mult_exception : div_exception;

    // add your code here

endmodule