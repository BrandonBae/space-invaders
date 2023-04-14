module register_64bit(out_data, in_data, clock, input_enable, output_enable, clear);
    input [63:0] in_data;
    input clock, input_enable, output_enable, clear;
    output[63:0] out_data;

    wire writeEnable;
    and writeAnd(writeEnable,clock, input_enable);

    wire [63:0] dffOutputs;
    genvar i;
    generate
        for(i=0; i<64; i=i+1) begin: loop1
            wire toTristate;
            dffe_ref dff(.q(dffOutputs[i]), .d(in_data[i]), .clk(writeEnable), .clr(clear), .en(input_enable));

        end
    endgenerate
    tristate_buffer_64bit outputBuffer(.out_data(out_data), .in_data(dffOutputs), .enable(output_enable));
endmodule