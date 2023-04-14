/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	wire nclk = !clock;
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

	/* YOUR CODE STARTS HERE */

    //bypass wires
    wire[1:0] RegAHazardCtrl, RegBHazardCtrl;
    wire StoreMemHazardCtrl;
    wire[31:0] currWriteData;

    //Stall wires
    wire[1:0] InsertStall;
    wire mult_div_on, mult_div_rdy_stall, new_mult, new_div;
    wire notMultDivStall = !mult_div_on & !mult_div_rdy_stall & !new_mult & !new_div;
    wire MultDivStall = mult_div_on | mult_div_rdy_stall | new_mult | new_div;
    wire notInsertStall = !InsertStall[0];

    //Fetch Stage
    wire[31:0] currPC, pcAddOne, pc_input;
    register_32bit pc(.out_data(currPC), .in_data(pc_input), .clock(nclk), 
        .input_enable(notInsertStall & notMultDivStall), .output_enable(1'b1), .clear(reset));
    cla_adder pc_incrementer(.S(pcAddOne), .Cout(), .A(currPC), .B(1), .Cin(1'b0));
    assign address_imem = currPC;

    //F/D Latch
    wire[31:0] fd_pc, fd_insn, fd_latch_in_insn;
    //Make instruction NOP if InsertStall[1] == 1 (branch/jump taken)
    assign fd_latch_in_insn = (InsertStall[1]) ? 0 : q_imem; //branch taken
    fd_latch fd(.out_pc(fd_pc), .out_instruction(fd_insn), .in_pc(pcAddOne), .in_instruction(fd_latch_in_insn), 
        .clock(nclk), .reset(reset), .in_enable(notInsertStall & notMultDivStall));

    //Decode Stage
    wire[4:0] decode_opcode;
    wire[4:0] decode_shamt;
    wire[4:0] decode_rd, decode_rs, decode_rt;
    wire[3:0] decode_alu_op;
    wire[4:0] decode_padded_alu_op = {1'b0, decode_alu_op};
    wire[16:0] decode_immed;
    wire[26:0] decode_addr;
    insn_decoder decode_data_decoder(.opcode(decode_opcode), .shamt(decode_shamt), .rd(decode_rd), .rs(decode_rs), 
        .rt(decode_rt), .alu_op(decode_alu_op), .immed(decode_immed), .addr(decode_addr), .instruction(fd_insn));
    
    wire decode_RWE, decode_BR, decode_ALUinB, decode_DMWE, decode_RTVal, decode_JAL;
    wire[1:0] decode_JP, decode_RWD, decode_RDST, decode_ctrl_RegA, decode_ctrl_RegB;
    ctrl_decoder decode_ctrlsignals(decode_JAL, decode_ctrl_RegA, decode_ctrl_RegB, decode_RWE, decode_BR, decode_JP, 
        decode_RDST, decode_ALUinB, decode_DMWE, decode_RWD, decode_RTVal, decode_opcode, decode_alu_op);
    /*
    wire isJR = (!decode_opcode[0] & !decode_opcode[1] & decode_opcode[2] & !decode_opcode[3] & !decode_opcode[4]);
    assign ctrl_readRegA = isJR ? decode_rd : decode_rs;
    assign ctrl_readRegB = decode_RTVal ? decode_rd : decode_rt; //for load word make sure to read data from rd register value
    */
    wire[4:0] readRegANum, readRegBNum;
    mux4FiveBit regAMux(.out(readRegANum), .select(decode_ctrl_RegA), .in0(decode_rs), .in1(5'b0), 
        .in2(decode_rd), .in3(5'd30));
    mux4FiveBit regBMux(.out(readRegBNum), .select(decode_ctrl_RegB), .in0(decode_rt), .in1(decode_rd), 
        .in2(decode_rs), .in3(5'd0));
    assign ctrl_readRegA = readRegANum;
    assign ctrl_readRegB = readRegBNum;

    //D/X Latch
    wire[31:0] dx_pc, dx_insn, dx_A, dx_B;
    wire[31:0] dx_latch_in_A, dx_latch_in_B, dx_latch_in_Insn;

    wire[1:0] dataRegASelect;
    //zero out all dx latch fields if branch or jump taken
    //Also do stalls whenever Mult_Div is occuring
    assign dataRegASelect[1] = decode_JAL;
    assign dataRegASelect[0] = InsertStall[0] | InsertStall[1] | MultDivStall;
    mux4 dx_latch_data_A_mux(.out(dx_latch_in_A), .select(dataRegASelect), 
        .in0(data_readRegA), .in1(0), .in2(fd_pc), .in3(0));
    assign dx_latch_in_B = InsertStall[0] | InsertStall[1] | MultDivStall ? 0: data_readRegB;
    assign dx_latch_in_Insn = InsertStall[0] | InsertStall[1] | MultDivStall ? 0 : fd_insn;
    dx_latch dx(.out_pc(dx_pc), .out_instruction(dx_insn), .out_A(dx_A), .out_B(dx_B), 
        .in_pc(fd_pc), .in_instruction(dx_latch_in_Insn), .in_A(dx_latch_in_A), .in_B(dx_latch_in_B), 
        .clock(nclk), .reset(reset));

    //Execute Stage
    wire[4:0] execute_opcode;
    wire[4:0] execute_shamt;
    wire[4:0] execute_rd, execute_rs, execute_rt;
    wire[3:0] execute_alu_op;
    wire[4:0] execute_padded_alu_op = {1'b0, execute_alu_op};
    wire[16:0] execute_immed;
    wire[26:0] execute_addr;
    insn_decoder execute_data_decoder(.opcode(execute_opcode), .shamt(execute_shamt), .rd(execute_rd), .rs(execute_rs), 
        .rt(execute_rt), .alu_op(execute_alu_op), .immed(execute_immed), .addr(execute_addr), .instruction(dx_insn));
    
    wire execute_RWE, execute_BR, execute_ALUinB, execute_DMWE, execute_RTVal, execute_JAL;
    wire[1:0] execute_JP, execute_RWD, execute_RDST, exec_ctrl_RegA, exec_ctrl_RegB;
    ctrl_decoder execute_ctrlsignals(execute_JAL, exec_ctrl_RegA, exec_ctrl_RegB, execute_RWE, execute_BR, execute_JP, 
    execute_RDST, execute_ALUinB, execute_DMWE, execute_RWD, execute_RTVal, execute_opcode, execute_alu_op);

    wire[31:0] xm_ALU_out; 

    wire[31:0] hazardResolvedA, hazardResolvedB; // bypass stuff
    mux4 hazardAMux(.out(hazardResolvedA), .select(RegAHazardCtrl), .in0(dx_A), .in1(currWriteData), .in2(xm_ALU_out), .in3(xm_ALU_out)); //maybe consider lw depdnency case
    mux4 hazardBMux(.out(hazardResolvedB), .select(RegBHazardCtrl), .in0(dx_B), .in1(currWriteData), .in2(xm_ALU_out), .in3(xm_ALU_out));

    wire[31:0] aluDataOut;
    wire aluNotEqual, aluLessThan, aluOverflow;
    wire[31:0] aluDataBIn, signExtendedImmed;
    assign signExtendedImmed = {{15{execute_immed[16]}}, execute_immed};
    assign aluDataBIn = execute_ALUinB ? signExtendedImmed : hazardResolvedB;
    alu mainAlu(.data_operandA(hazardResolvedA), .data_operandB(aluDataBIn), .ctrl_ALUopcode(execute_padded_alu_op), .ctrl_shiftamt(execute_shamt), 
    .data_result(aluDataOut), .isNotEqual(aluNotEqual), .isLessThan(aluLessThan), .overflow(aluOverflow));

    wire[31:0] extended_jump_addr, pc_jump_res; // jump stuff
    assign extended_jump_addr[26:0] = execute_addr;
    assign extended_jump_addr[31:27] = 0;

    mux4 jump_mux(.out(pc_jump_res), .select(execute_JP), .in0(dx_pc), .in1(extended_jump_addr), .in2(hazardResolvedA), .in3());

    wire conditionFulfilled; //branch stuff
    mux32OneBit condition_mux(.out(conditionFulfilled), .select(execute_opcode), 
            .in0(), .in1(), .in2(aluNotEqual), .in3(), .in4(), .in5(), .in6(aluLessThan), .in7(),
            .in8(), .in9(), .in10(), .in11(), .in12(), .in13(), .in14(), .in15(),
            .in16(), .in17(), .in18(), .in19(), .in20(), .in21(), .in22(), .in23(),
            .in24(), .in25(), .in26(), .in27(), .in28(), .in29(), .in30(), .in31());
    //assign pc_input = (execute_BR & conditionFulfilled) ? (dx_pc + signExtendedImmed-1) : pc_jump_res;
    
    wire[2:0] pc_selector;
    assign pc_selector[2] = (execute_BR & conditionFulfilled);
    assign pc_selector[1:0] = execute_JP;
    wire[31:0] bex_addr = (aluNotEqual & (execute_opcode == 5'b10110)) ? extended_jump_addr : pcAddOne;
    mux8 pcSelector(.out(pc_input), .select(pc_selector), 
        .in0(pcAddOne), .in1(extended_jump_addr), .in2(hazardResolvedA), .in3(bex_addr), .in4(dx_pc + signExtendedImmed), 
        .in5(), .in6(), .in7());
    
    //mult/div stuff
    wire mult_div_exception, mult_div_rdy;
    assign new_mult = (execute_opcode == 5'b00000) & (execute_alu_op == 4'b0110);
    assign new_div = (execute_opcode == 5'b00000) & (execute_alu_op == 4'b0111);
    wire[31:0] mult_div_A, mult_div_B, mult_div_insn, mult_div_res;
    wire[4:0] mult_div_write_reg;
    wire[3:0] mult_div_aluop;
    //latches on rising edge clock; offset from other processor latches since data dependency with D/X latch
    register_32bit mult_div_A_latch(.out_data(mult_div_A), .in_data(hazardResolvedA), .clock(clock), 
        .input_enable(new_mult | new_div), .output_enable(1'b1), .clear(1'b0));
    register_32bit mult_div_B_latch(.out_data(mult_div_B), .in_data(hazardResolvedB), .clock(clock), 
        .input_enable(new_mult | new_div), .output_enable(1'b1), .clear(1'b0));
    register_32bit mult_div_insn_latch(.out_data(mult_div_insn), .in_data(dx_insn), .clock(clock), 
        .input_enable(new_mult | new_div), .output_enable(1'b1), .clear(1'b0));
    register_32bit mult_div_aluop_latch(.out_data(mult_div_aluop), .in_data(execute_alu_op), .clock(clock), 
        .input_enable(new_mult | new_div), .output_enable(1'b1), .clear(1'b0));
    register_32bit mult_div_write_reg_latch(.out_data(mult_div_write_reg), .in_data(execute_rd), .clock(clock), 
        .input_enable(new_mult | new_div), .output_enable(1'b1), .clear(1'b0));
    
    //clocked on falling edge; offset from its input latches as seen above
    multdiv mult_div_module(
	.data_operandA(mult_div_A), .data_operandB(mult_div_B), 
	.ctrl_MULT(new_mult), .ctrl_DIV(new_div), 
	.clock(nclk), 
	.data_result(mult_div_res), .data_exception(mult_div_exception), .data_resultRDY(mult_div_rdy));

    wire on_latch_input = (mult_div_on==0 & (new_mult | new_div)) | (mult_div_on==1 & !mult_div_rdy)  ? 1 : 0;
    register_32bit mult_div_on_latch(.out_data(mult_div_on), .in_data(on_latch_input), .clock(clock), 
        .input_enable(new_mult | new_div | mult_div_rdy), .output_enable(1'b1), .clear(1'b0)); 
    
    wire mult_div_rdy_latch_input = mult_div_on ? mult_div_rdy : 0;
    wire mult_div_exception_modified = mult_div_on ? mult_div_exception : 0;
    register_32bit mult_div_rdy_latch(.out_data(mult_div_rdy_stall), .in_data(mult_div_rdy_latch_input), .clock(clock), 
        .input_enable(mult_div_on | mult_div_rdy), .output_enable(1'b1), .clear(1'b0)); 
    /*
    wire[31:0] mult_div_res_reg_out;
    register_32bit mult_div_res_latch(.out_data(mult_div_res_reg_out), .in_data(mult_div_res), .clock(clock), 
        .input_enable(mult_div_rdy), .output_enable(1'b1), .clear(1'b0));*/


    //X/M Latch
    wire[31:0] xm_insn, xm_B;
    wire[4:0] xm_ovf_select;
    assign xm_ovf_select[0] = (execute_opcode == 5'b0) & aluOverflow & (execute_alu_op == 4'b0000); //err 1 add ovf
    assign xm_ovf_select[1] = (execute_opcode == 5'b00101) & aluOverflow; // err 2 addi ovf
    assign xm_ovf_select[2] = (execute_opcode == 5'b0) & aluOverflow & (execute_alu_op == 4'b0001); //err 3 sub ovf
    //assign xm_ovf_select[3] = (execute_opcode == 5'b0) & mult_div_exception & (execute_alu_op == 4'b0110); //err 4 mul ovf
    //assign xm_ovf_select[4] = (execute_opcode == 5'b0) & mult_div_exception & (execute_alu_op == 4'b0111); //err 5 div ovf
    assign xm_ovf_select[3] = 0;
    assign xm_ovf_select[4] = 0;
    wire[31:0] xm_in_alu_latch, xm_in1_insn_latch, xm_in2_insn_latch;
    //wire[31:0] alu_out_or_mult_div_out = (mult_div_rdy===1'bx) | (mult_div_rdy==0 & mult_div_rdy_stall==0) ? aluDataOut : mult_div_res;
    //wire[31:0] alu_out_or_mult_div_out = mult_div_rdy==1 ? mult_div_res : aluDataOut;
    wire[31:0] alu_out_or_mult_div_out = aluDataOut;
    mux32 xm_in_alu_mux(.out(xm_in_alu_latch), .select(xm_ovf_select), .in0(alu_out_or_mult_div_out), 
            .in1(1), .in2(2), .in3(), .in4(3), .in5(), .in6(), .in7(),
            .in8(4), .in9(), .in10(), .in11(), .in12(), .in13(), .in14(), .in15(),
            .in16(5), .in17(), .in18(), .in19(), .in20(), .in21(), .in22(), .in23(),
            .in24(), .in25(), .in26(), .in27(), .in28(), .in29(), .in30(), .in31());

    wire[31:0] ovf_setx_insn;
    assign ovf_setx_insn[31:27] = 5'b10101;
    wire isOvfInsn = ((execute_opcode==5'b00000) & 
        (execute_alu_op == 4'b0000 | execute_alu_op == 4'b0001)) | (execute_opcode == 5'b00101);
    // If we have some Overflow and the Current Instruction can have overflow 
    // change the instruction to a setx insn with the appropriate ovf error value
    assign xm_in1_insn_latch = (aluOverflow & isOvfInsn) ? ovf_setx_insn : dx_insn; 
    //assign xm_in2_insn_latch = (mult_div_rdy & mult_div_rdy_stall) ? mult_div_insn : xm_in1_insn_latch;
    //wire[31:0] xm_ALU_out; 
    xm_latch xm(.out_ALU(xm_ALU_out), .out_B(xm_B), .out_instruction(xm_insn), 
        .in_ALU(xm_in_alu_latch), .in_B(dx_B), .in_instruction(xm_in1_insn_latch), .clock(nclk), .reset(reset));

    //Memory Stage
    wire[4:0] mem_opcode;
    wire[4:0] mem_shamt;
    wire[4:0] mem_rd, mem_rs, mem_rt;
    wire[3:0] mem_alu_op;
    wire[4:0] mem_padded_alu_op = {1'b0, mem_alu_op};
    wire[16:0] mem_immed;
    wire[26:0] mem_addr;
    insn_decoder mem_data_decoder(.opcode(mem_opcode), .shamt(mem_shamt), .rd(mem_rd), .rs(mem_rs), 
        .rt(mem_rt), .alu_op(mem_alu_op), .immed(mem_immed), .addr(mem_addr), .instruction(xm_insn));
    
    wire mem_RWE, mem_BR, mem_ALUinB, mem_DMWE, mem_RTVal, mem_JAL;
    wire[1:0] mem_JP, mem_RWD, mem_RDST, mem_ctrl_RegA, mem_ctrl_RegB;
    ctrl_decoder mem_ctrlsignals(mem_JAL, mem_ctrl_RegA, mem_ctrl_RegB, mem_RWE, mem_BR, mem_JP, mem_RDST, mem_ALUinB, mem_DMWE, 
        mem_RWD, mem_RTVal, mem_opcode, mem_alu_op);
    
    assign address_dmem = xm_ALU_out;
    assign data = StoreMemHazardCtrl ? currWriteData : xm_B; //bypass memory write hazard;
    assign wren = mem_DMWE;

    //M/W Latch
    wire[31:0] mw_insn, mw_mem_out, mw_ALU_out;
    mw_latch mw(.out_ALU(mw_ALU_out), .out_Mem(mw_mem_out), .out_instruction(mw_insn), 
        .in_ALU(xm_ALU_out), .in_Mem(q_dmem), .in_instruction(xm_insn), .clock(nclk), .reset(reset));

    //try writing mult out in write stage like normal person can use random signals as rwe which might help
    //Write Stage
    wire[4:0] write_opcode;
    wire[4:0] write_shamt;
    wire[4:0] write_rd, write_rs, write_rt;
    wire[3:0] write_alu_op;
    wire[4:0] write_padded_alu_op = {1'b0, write_alu_op};
    wire[16:0] write_immed;
    wire[26:0] write_addr;
    insn_decoder write_data_decoder(.opcode(write_opcode), .shamt(write_shamt), .rd(write_rd), .rs(write_rs), 
        .rt(write_rt), .alu_op(write_alu_op), .immed(write_immed), .addr(write_addr), .instruction(mw_insn));
    
    wire write_RWE, write_BR, write_ALUinB, write_DMWE, write_RTVal, write_JAL;
    wire[1:0] write_JP, write_RDST, write_RWD, write_ctrl_RegA, write_ctrl_RegB;
    ctrl_decoder write_ctrlsignals(write_JAL, write_ctrl_RegA, write_ctrl_RegB, write_RWE, write_BR, write_JP, write_RDST, write_ALUinB, 
    write_DMWE, write_RWD, write_RTVal, write_opcode, write_alu_op);

    wire[31:0] tempJalWire, emptyWire;
    //wire[31:0] currWriteData;     need to move up for implicit def reasons
    mux4 reg_write_data_mux(.out(currWriteData), .select(write_RWD), 
    .in0(mw_ALU_out), .in1(mw_mem_out), .in2(tempJalWire), .in3(emptyWire)); 
    //assign data_writeReg = mult_div_rdy_latch_input ? mult_div_res : currWriteData; //mult modified
    
    wire[1:0] mult_write_data_mux_select;
    //needed to latch ready signal as it was only lasting for half a clock cycle
    //due to everything being on different clocks
    assign mult_write_data_mux_select[0] = mult_div_rdy_latch_input;
    assign mult_write_data_mux_select[1] = mult_div_exception_modified;

    wire[31:0] mult_div_error_code = (mult_div_aluop == 4'b0110) ? 4 : 5;
    //write mult/div output when ready signal is on
    mux4 mult_write_data_mux(.out(data_writeReg), .select(mult_write_data_mux_select),
        .in0(currWriteData), .in1(mult_div_res), .in2(currWriteData), .in3(mult_div_error_code));
    wire[4:0] write_reg;
    wire isNOP = (!mw_insn[0] & !mw_insn[1] & !mw_insn[2] & !mw_insn[3] & !mw_insn[4] &
                !mw_insn[5] & !mw_insn[6] & !mw_insn[7] & !mw_insn[8] & !mw_insn[9] &
                !mw_insn[10] & !mw_insn[11] & !mw_insn[12] & !mw_insn[13] & !mw_insn[14] &
                !mw_insn[15] & !mw_insn[16] & !mw_insn[17] & !mw_insn[18] & !mw_insn[19] &
                !mw_insn[20] & !mw_insn[21] & !mw_insn[22] & !mw_insn[23] & !mw_insn[24] &
                !mw_insn[25] & !mw_insn[26] & !mw_insn[27] & !mw_insn[28] & !mw_insn[29] &
                !mw_insn[30] & !mw_insn[31]);
    assign ctrl_writeEnable = mult_div_rdy_latch_input ? 1'b1 : write_RWE;
    //assign write_reg = write_RDST ? {5{1'b1}} : write_rd;
    mux4FiveBit write_reg_mux(.out(write_reg), .select(write_RDST), 
        .in0(write_rd), .in1({5{1'b1}}), .in2(5'd30), .in3(5'b0));
    //assign ctrl_writeReg = mult_div_rdy_latch_input ? mult_div_write_reg : write_reg;
    mux4FiveBit mult_write_reg_mux(.out(ctrl_writeReg), .select(mult_write_data_mux_select),
        .in0(write_reg), .in1(mult_div_write_reg), .in2(write_reg), .in3(5'd30));

    //assign bypass wires
    bypass_detector bypass(.RegAHazard(RegAHazardCtrl), .RegBHazard(RegBHazardCtrl), .StoreMemoryHazard(StoreMemHazardCtrl), 
        .bypass_dx_insn(dx_insn), .bypass_xm_insn(xm_insn), .bypass_mw_insn(mw_insn), 
        .xm_RWE(mem_RWE), .xm_write_RDST(mem_RDST), .mw_write_reg(write_reg), .mw_RWE(write_RWE), .mw_opcode(write_opcode));
        
    //assign stall wires
    stall_detector stall(.InsertStall(InsertStall), .jumpTaken(execute_JP != 0), .branchTaken(execute_BR & conditionFulfilled), 
        .stall_dx_insn(dx_insn), .stall_dx_rd(execute_rd), .stall_dx_op(execute_opcode), 
        .stall_fd_insn(fd_insn), .stall_fd_op(decode_opcode), .stall_fd_rs1(readRegANum), .stall_fd_rs2(readRegBNum),
        .mult_div_on(mult_div_on), .clock(clock));
	/* END CODE */

endmodule

module ctrl_decoder(JAL, ctrl_RegA, ctrl_RegB, RWE, BR, JP, RDST, ALUinB, DMWE, RWD, RTVal, opcode, alu_op);
    output RWE, BR, ALUinB, DMWE, RTVal, JAL;
    output [1:0] JP, RWD, RDST, ctrl_RegA, ctrl_RegB;
    input[4:0] opcode;
    input[3:0] alu_op;
    
    wire[31:0] op_wire;
    decoder opcode_decoder(op_wire, opcode, 1'b1);

    wire[4:0] alu_decoder_select;
    wire[31:0] alu_decoder_res;
    assign alu_decoder_select[4] = ~op_wire[0];
    assign alu_decoder_select[3:0] = alu_op;
    decoder alu_decoder(alu_decoder_res, alu_decoder_select, 1'b1);

    wire opcode_zero = (!opcode[0] & !opcode[1] & !opcode[2] & !opcode[3] & !opcode[4]);

    wire add, addi, sub, and_op, or_op, sll, sra, mul, div, sw, lw, j, bne, blt, jal, jr, bex, setx;
    assign add = opcode_zero & alu_decoder_res[0]; //opcode 0 aluop 0
    assign addi = op_wire[5]; //opcode 101
    assign sub = opcode_zero & alu_decoder_res[1];
    assign and_op = opcode_zero & alu_decoder_res[2];
    assign or_op = opcode_zero & alu_decoder_res[3];
    assign sll = opcode_zero & alu_decoder_res[4];
    assign sra = opcode_zero & alu_decoder_res[5];
    assign mul = opcode_zero & alu_decoder_res[6];
    assign div = opcode_zero & alu_decoder_res[7];
    assign sw = op_wire[7]; //opcode 111
    assign lw = op_wire[8]; //opcode 1000
    assign j = op_wire[1]; //opcode 00001
    assign bne = op_wire[2]; //opcode 10
    assign jal = op_wire[3]; //opcode 11
    assign jr = op_wire[4]; //opcode 4
    assign blt = op_wire[6]; //opcode 6
    assign bex = op_wire[22]; //opcode 10110
    assign setx = op_wire[21]; //opcode 00110

    assign RWE = (add | sub | addi | and_op | or_op | sll | sra | lw | jal | setx);
    assign BR = (bne | blt);
    assign JP[0] = (j | jal | bex);
    assign JP[1] = (jr | bex);
    assign RDST[0] = (jal);
    assign RDST[1] = (setx);
    assign ALUinB = (addi | sw | lw | setx );
    assign DMWE = (sw);
    assign RWD[0] = lw;
    assign RWD[1] = 1'b0;

    assign RTVal = (lw | sw);
    // RegAVal: 00=use RS, 01=use $0 for setx, 10=use RD for normal branches and jr, 11=use $30 rstatus for bex
    assign ctrl_RegA[0] = (bex | setx); 
    assign ctrl_RegA[1] = (blt | bne | bex | jr); // might need to make it so that setx uses reg 0 instead
    // RegBVal: 00=use RT, 01=use RD for lw/sw, 10=use RS for branches, 11=use $0 for bex/setx and jal
    assign ctrl_RegB[0] = (lw | sw | bex | setx | jal);
    assign ctrl_RegB[1] = (blt | bne | bex | setx | jal); 
    assign JAL = jal;

endmodule

module insn_decoder(opcode, shamt, rd, rs, rt, alu_op, immed, addr, instruction);
    input[31:0] instruction;
    output[4:0] opcode;
    output[4:0] shamt;
    output[4:0] rd, rs, rt;
    output[3:0] alu_op;
    output[16:0] immed;
    output[26:0] addr;

    assign opcode = instruction[31:27];
    assign rd = instruction[26:22];
    assign rs = instruction[21:17];
    assign rt = instruction[16:12];
    assign shamt = instruction[11:7];

    wire opcode_is_zero;
    nor allZeroNor(opcode_is_zero, opcode[0], opcode[1], opcode[2], opcode[3], opcode[4]);
    assign alu_op = opcode_is_zero ? instruction[6:2] : {4'b0};
    
    assign immed = instruction[16:0];
    assign addr = instruction[26:0];
endmodule

module bypass_detector(RegAHazard, RegBHazard, StoreMemoryHazard, bypass_dx_insn, bypass_xm_insn, bypass_mw_insn, xm_RWE, xm_write_RDST, mw_write_reg, mw_RWE, mw_opcode);
    input[31:0] bypass_dx_insn, bypass_xm_insn, bypass_mw_insn;
    input[4:0] mw_write_reg, mw_opcode;
    input xm_RWE, mw_RWE;
    input[1:0] xm_write_RDST;
    output[1:0] RegAHazard, RegBHazard; //00=no Hazard, 01=write hazard, 10=mem hazard; 
    output StoreMemoryHazard; // 0=no Hazard, 1=write reg is same as reg we are trying to store into memory

    wire[4:0] xm_opcode;
    wire[4:0] xm_shamt;
    wire[4:0] xm_rd, xm_rs, xm_rt;
    wire[3:0] xm_alu_op;
    wire[4:0] xm_padded_alu_op = {1'b0, xm_alu_op};
    wire[16:0] xm_immed;
    wire[26:0] xm_addr;
    insn_decoder xm_data_decoder(.opcode(xm_opcode), .shamt(xm_shamt), .rd(xm_rd), .rs(xm_rs), 
        .rt(xm_rt), .alu_op(xm_alu_op), .immed(xm_immed), .addr(xm_addr), .instruction(bypass_xm_insn));
    wire[4:0] xm_write_reg;
    //assign xm_write_reg = xm_write_RDST ? {5{1'b1}} : xm_rd;
    mux4FiveBit write_reg_mux(.out(xm_write_reg), .select(xm_write_RDST), 
        .in0(xm_rd), .in1({5{1'b1}}), .in2(5'd30), .in3(5'b0));

    wire[4:0] dx_opcode;
    wire[4:0] dx_shamt;
    wire[4:0] dx_rd, dx_rs, dx_rt;
    wire[3:0] dx_alu_op;
    wire[4:0] dx_padded_alu_op = {1'b0, dx_alu_op};
    wire[16:0] dx_immed;
    wire[26:0] dx_addr;
    insn_decoder dx_data_decoder(.opcode(dx_opcode), .shamt(dx_shamt), .rd(dx_rd), .rs(dx_rs), 
        .rt(dx_rt), .alu_op(dx_alu_op), .immed(dx_immed), .addr(dx_addr), .instruction(bypass_dx_insn));

    wire dx_RWE, dx_BR, dx_ALUinB, dx_DMWE, dx_RTVal, dx_JAL;
    wire[1:0] dx_JP, dx_RWD, dx_RDST, dx_ctrl_RegA, dx_ctrl_RegB;
    ctrl_decoder dx_ctrlsignals(dx_JAL, dx_ctrl_RegA, dx_ctrl_RegB, dx_RWE, dx_BR, dx_JP, 
        dx_RDST, dx_ALUinB, dx_DMWE, dx_RWD, dx_RTVal, dx_opcode, dx_alu_op);

    wire [4:0] dx_regA, dx_regB;
    mux4FiveBit bypassregAMux(.out(dx_regA), .select(dx_ctrl_RegA), .in0(dx_rs), .in1(dx_rd), 
        .in2(dx_rd), .in3(5'd30));
    mux4FiveBit bypassregBMux(.out(dx_regB), .select(dx_ctrl_RegB), .in0(dx_rt), .in1(dx_rd), 
        .in2(dx_rs), .in3(5'd0));

    assign StoreMemoryHazard = (mw_write_reg != 5'd0) & (mw_write_reg == xm_rd) & (xm_opcode == 5'b00111) & mw_RWE
         | (mw_opcode==5'b01000) & (xm_opcode==5'b00111) & (mw_write_reg==xm_write_reg);

    assign RegAHazard[0] = (bypass_dx_insn == 0) ? 0 : (mw_write_reg != 5'd0) & (mw_write_reg == dx_regA) & mw_RWE & (bypass_mw_insn != 0);
    assign RegBHazard[0] = (bypass_dx_insn == 0) ? 0 : (mw_write_reg != 5'd0) & (mw_write_reg == dx_regB) & mw_RWE & (bypass_mw_insn !=0);

    assign RegAHazard[1] = (bypass_dx_insn == 0) ? 0 : (xm_write_reg != 5'd0) & (xm_write_reg == dx_regA) & xm_RWE & (bypass_xm_insn != 0);
    assign RegBHazard[1] = (bypass_dx_insn == 0) ? 0 : (xm_write_reg != 5'd0) & (xm_write_reg == dx_regB) & xm_RWE & (bypass_xm_insn != 0);
endmodule

module stall_detector(InsertStall, jumpTaken, branchTaken, stall_dx_insn, stall_dx_rd, stall_dx_op, stall_fd_insn, stall_fd_op, stall_fd_rs1, stall_fd_rs2, mult_div_on, clock);
    input[31:0] stall_dx_insn, stall_fd_insn;
    input[4:0] stall_fd_op, stall_fd_rs1, stall_fd_rs2, stall_dx_op, stall_dx_rd;
    input jumpTaken, branchTaken, mult_div_on, clock;
    wire[1:0] stallRes_in;
    wire[1:0] stallRes_out;
    /*
	always @(posedge clock)
	begin
		stallRes[0] = ((stall_dx_insn!=0 & stall_fd_insn!=0) & ((stall_dx_op==5'b01000) & ((stall_fd_rs1 == stall_dx_rd) 
        | (stall_fd_op!=5'b00111 & stall_fd_rs2==stall_dx_rd & stall_dx_rd != 5'd0))));
        stallRes[1] = (jumpTaken | branchTaken);
	end*/
    assign stallRes_in[0] = ((stall_dx_insn!=0 & stall_fd_insn!=0) & ((stall_dx_op==5'b01000) & ((stall_fd_rs1 == stall_dx_rd) 
        | (stall_fd_op!=5'b00111 & stall_fd_rs2==stall_dx_rd & stall_dx_rd != 5'd0))));
    assign stallRes_in[1] = (jumpTaken | branchTaken);
    register_32bit stall_reg(.out_data(stallRes_out), .in_data(stallRes_in), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(1'b0));
    output[1:0] InsertStall;
    /*
    assign InsertStall[0] = (stall_dx_insn!=0 & stall_fd_insn!=0) & ((stall_dx_op==5'b01000 & stall_fd_rs1 == stall_dx_rd) 
        | (stall_dx_op!=5'b00111 & stall_fd_rs2==stall_dx_rd));
    assign InsertStall[1] = (jumpTaken | branchTaken);
    */
    assign InsertStall[0] = stallRes_out[0];
    assign InsertStall[1] = stallRes_out[1];
endmodule

module fd_latch(out_pc, out_instruction, in_pc, in_instruction, clock, reset, in_enable);
    input[31:0] in_pc, in_instruction;
    input clock, reset, in_enable;
    output[31:0] out_pc, out_instruction;
    register_32bit fd_pc_reg(.out_data(out_pc), .in_data(in_pc), .clock(clock), .input_enable(in_enable), .output_enable(1'b1), .clear(reset));
    register_32bit fd_insn_reg(.out_data(out_instruction), .in_data(in_instruction), .clock(clock), .input_enable(in_enable), .output_enable(1'b1), .clear(reset));
endmodule

module dx_latch(out_pc, out_instruction, out_A, out_B, in_pc, in_instruction, in_A, in_B, clock, reset);
    input[31:0] in_pc, in_instruction, in_A, in_B;
    input clock, reset;
    output[31:0] out_pc, out_instruction, out_A, out_B;

    register_32bit dx_pc_reg(.out_data(out_pc), .in_data(in_pc), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
    register_32bit dx_insn_reg(.out_data(out_instruction), .in_data(in_instruction), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
    register_32bit dx_A_reg(.out_data(out_A), .in_data(in_A), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
    register_32bit dx_B_reg(.out_data(out_B), .in_data(in_B), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
endmodule

module xm_latch(out_ALU, out_B, out_instruction, in_ALU, in_B, in_instruction, clock, reset);
    input[31:0] in_ALU, in_B, in_instruction;
    input clock, reset;
    output[31:0] out_ALU, out_B, out_instruction;

    register_32bit xm_insn_reg(.out_data(out_instruction), .in_data(in_instruction), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
    register_32bit xm_ALU_reg(.out_data(out_ALU), .in_data(in_ALU), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
    register_32bit xm_B_reg(.out_data(out_B), .in_data(in_B), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
endmodule

module mw_latch(out_ALU, out_Mem, out_instruction, in_ALU, in_Mem, in_instruction, clock, reset);
    input[31:0] in_ALU, in_Mem, in_instruction;
    input clock, reset;
    output[31:0] out_ALU, out_Mem, out_instruction;

    register_32bit xm_insn_reg(.out_data(out_instruction), .in_data(in_instruction), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
    register_32bit xm_ALU_reg(.out_data(out_ALU), .in_data(in_ALU), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
    register_32bit xm_B_reg(.out_data(out_Mem), .in_data(in_Mem), .clock(clock), .input_enable(1'b1), .output_enable(1'b1), .clear(reset));
endmodule