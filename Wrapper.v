`timescale 1ns / 1ps
/**
 * 
 * READ THIS DESCRIPTION:
 *
 * This is the Wrapper module that will serve as the header file combining your processor, 
 * RegFile and Memory elements together.
 *
 * This file will be used to generate the bitstream to upload to the FPGA.
 * We have provided a sibling file, Wrapper_tb.v so that you can test your processor's functionality.
 * 
 * We will be using our own separate Wrapper_tb.v to test your code. You are allowed to make changes to the Wrapper files 
 * for your own individual testing, but we expect your final processor.v and memory modules to work with the 
 * provided Wrapper interface.
 * 
 * Refer to Lab 5 documents for detailed instructions on how to interface 
 * with the memory elements. Each imem and dmem modules will take 12-bit 
 * addresses and will allow for storing of 32-bit values at each address. 
 * Each memory module should receive a single clock. At which edges, is 
 * purely a design choice (and thereby up to you). 
 * 
 * You must change line 36 to add the memory file of the test you created using the assembler
 * For example, you would add sample inside of the quotes on line 38 after assembling sample.s
 *
 **/

module Wrapper (CLK100MHZ, BTNL, LED, VGA_R, VGA_G, VGA_B, hSync, vSync);
	input CLK100MHZ, BTNL;
	output[15:0] LED;
	wire rwe, mwe;
	wire[4:0] rd, rs1, rs2;
	wire[31:0] instAddr, instData, 
		rData, regA, regB,
		memAddr, memDataIn, memDataOut;
	wire [31:0] spriteXArr [9:0];
	wire [31:0] spriteYArr [9:0];
	wire [31:0] bulletXArr [4:0];
	wire [31:0] bulletYArr [4:0];
	wire[31:0] playerX, playerY;


	// ADD YOUR MEMORY FILE HERE
	//localparam INSTR_FILE = "final-project";
	localparam INSTR_FILE = "sprite_test";

	reg clk1Hz = 0;
	reg[27:0] counter = 0;
	wire [26:0] CounterLimit;
	assign CounterLimit = 27'd9999999;
	always @(posedge CLK100MHZ) begin
		if(counter < CounterLimit)
			counter <= counter + 1;
		else begin
			counter <= 0;
			clk1Hz <= ~clk1Hz;
		end
	end
	
	output [3:0] VGA_R, VGA_G, VGA_B;
	output hSync, vSync;
	VGAController displayOutput(
	.sprite1X(spriteXArr[0]), .sprite2X(spriteXArr[1]), .sprite3X(spriteXArr[2]), .sprite4X(spriteXArr[3]), .sprite5X(spriteXArr[4]), .sprite6X(spriteXArr[5]), .sprite7X(spriteXArr[6]), .sprite8X(spriteXArr[7]), .sprite9X(spriteXArr[8]), .sprite10X(spriteXArr[9]), 
	.sprite1Y(spriteYArr[0]), .sprite2Y(spriteYArr[1]), .sprite3Y(spriteYArr[2]), .sprite4Y(spriteYArr[3]), .sprite5Y(spriteYArr[4]), .sprite6Y(spriteYArr[5]), .sprite7Y(spriteYArr[6]), .sprite8Y(spriteYArr[7]), .sprite9Y(spriteYArr[8]), .sprite10Y(spriteYArr[9]),
    .playerX(playerX),
	.playerY(playerY),
    .bullet1X(bulletXArr[0]), .bullet2X(bulletXArr[1]), .bullet3X(bulletXArr[2]), .bullet4X(bulletXArr[3]), .bullet5X(bulletXArr[4]),
    .bullet1Y(bulletYArr[0]), .bullet2Y(bulletYArr[1]), .bullet3Y(bulletYArr[2]), .bullet4Y(bulletYArr[3]), .bullet5Y(bulletYArr[4]),
    .clk(CLK100MHZ),     // 100 MHz System Clock
    .reset(BTNL),      // Reset Signal
    .hSync(hSync),  // H Sync Signal
    .vSync(vSync),      // Veritcal Sync Signal
    .VGA_R(VGA_R),  // Red Signal Bits
    .VGA_G(VGA_G),  // Green Signal Bits
    .VGA_B(VGA_B)  // Blue Signal Bits);
	);
	// Main Processing Unit
	processor CPU(.clock(clk1Hz), .reset(BTNL), 
								
		// ROM
		.address_imem(instAddr), .q_imem(instData),
									
		// Regfile
		.ctrl_writeEnable(rwe),     .ctrl_writeReg(rd),
		.ctrl_readRegA(rs1),     .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB),
									
		// RAM
		.wren(mwe), .address_dmem(memAddr), 
		.data(memDataIn), .q_dmem(memDataOut)); 
	
	// Instruction Memory (ROM)
	ROM #(.MEMFILE({INSTR_FILE, ".mem"}))
	InstMem(.clk(clk1Hz), 
		.addr(instAddr[11:0]), 
		.dataOut(instData));
	
	// Register File
	regfile RegisterFile(.clock(clk1Hz), 
		.ctrl_writeEnable(rwe), .ctrl_reset(BTNL), 
		.ctrl_writeReg(rd),
		.ctrl_readRegA(rs1), .ctrl_readRegB(rs2), 
		.data_writeReg(rData), .data_readRegA(regA), .data_readRegB(regB));
					
	// Processor Memory (RAM)
	RAM ProcMem(.clk(clk1Hz), 
		.wEn(mwe), 
		.addr(memAddr[11:0]), 
		.dataIn(memDataIn), 
		.dataOut(memDataOut),
		.sprite1X(spriteXArr[0]), .sprite1Y(spriteYArr[0]),
    	.sprite2X(spriteXArr[1]), .sprite2Y(spriteYArr[1]),
    	.sprite3X(spriteXArr[2]), .sprite3Y(spriteYArr[2]),
    	.sprite4X(spriteXArr[3]), .sprite4Y(spriteYArr[3]),
    	.sprite5X(spriteXArr[4]), .sprite5Y(spriteYArr[4]),
    	.sprite6X(spriteXArr[5]), .sprite6Y(spriteYArr[5]),
    	.sprite7X(spriteXArr[6]), .sprite7Y(spriteYArr[6]),
    	.sprite8X(spriteXArr[7]), .sprite8Y(spriteYArr[7]),
    	.sprite9X(spriteXArr[8]), .sprite9Y(spriteYArr[8]),
    	.sprite10X(spriteXArr[9]), .sprite10Y(spriteYArr[9]),
    	.bullet1X(bulletXArr[0]), .bullet1Y(bulletYArr[0]),
    	.bullet2X(bulletXArr[1]), .bullet2Y(bulletYArr[1]),
    	.bullet3X(bulletXArr[2]), .bullet3Y(bulletYArr[2]),
    	.bullet4X(bulletXArr[3]), .bullet4Y(bulletYArr[3]),
    	.bullet5X(bulletXArr[4]), .bullet5Y(bulletYArr[4]),
    	.playerX(playerX), .playerY(playerY));
	//assign LED = temp1Val[15:0];

endmodule