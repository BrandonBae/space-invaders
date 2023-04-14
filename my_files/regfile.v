/*
module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB
);

	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;

	wire [31:0] rdDecoderOutput, rs1DecoderOutput, rs2DecoderOutput;
	decoder decodeRd(.out(rdDecoderOutput), .select(ctrl_writeReg), .enable(1'b1));
	decoder decodeRs1(.out(rs1DecoderOutput), .select(ctrl_readRegA), .enable(1'b1));
	decoder decodeRs2(.out(rs2DecoderOutput), .select(ctrl_readRegB), .enable(1'b1));

	//zero register
	wire[31:0] toTristate0;
	wire canWrite0;
	assign canWrite0 = 0;
	register_32bit register0(.out_data(toTristate0), .in_data(data_writeReg), .clock(clock), .input_enable(canWrite0), .output_enable(1'b1), .clear(ctrl_reset));
	tristate_buffer_32bit rs1Buffer(.out_data(data_readRegA), .in_data(toTristate0), .enable(rs1DecoderOutput[0]));
	tristate_buffer_32bit rs2Buffer(.out_data(data_readRegB), .in_data(toTristate0), .enable(rs2DecoderOutput[0]));

	genvar i;
	generate
        for(i=1; i<32; i=i+1) begin: loop1
            wire[31:0] toTristate;
			wire canWrite;
			and andWE(canWrite, rdDecoderOutput[i], ctrl_writeEnable);
            register_32bit register(.out_data(toTristate), .in_data(data_writeReg), .clock(clock), .input_enable(canWrite), .output_enable(1'b1), .clear(ctrl_reset));
			tristate_buffer_32bit rs1Buffer(.out_data(data_readRegA), .in_data(toTristate), .enable(rs1DecoderOutput[i]));
			tristate_buffer_32bit rs2Buffer(.out_data(data_readRegB), .in_data(toTristate), .enable(rs2DecoderOutput[i]));
        end
    endgenerate
	// add your code here

endmodule*/
module regfile(
	clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA,
	data_readRegB);
	
	input clock, ctrl_writeEnable, ctrl_reset;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;
	output [31:0] data_readRegA, data_readRegB;

	reg[31:0] registers[31:0];

	integer count;
	initial begin
		for (count=0; count<32; count=count+1)
			registers[count] <= 0;
	end

	integer i;
	always @(posedge clock or posedge ctrl_reset)
	begin
		if(ctrl_reset)
			begin
				for(i = 0; i < 32; i = i + 1)
					begin
						registers[i] <= 32'd0;
					end
			end
		else
			if(ctrl_writeEnable && ctrl_writeReg != 5'd0)
				registers[ctrl_writeReg] <= data_writeReg;
	end
	
	assign data_readRegA = registers[ctrl_readRegA];
	assign data_readRegB = registers[ctrl_readRegB];
	
endmodule
