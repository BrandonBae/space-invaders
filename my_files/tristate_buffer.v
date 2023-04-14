module tristate_buffer_1bit(out_data, in_data, enable);
    input in_data;
    input enable;
    output out_data;
    assign out_data = enable? in_data : 1'bz;
endmodule

module tristate_buffer_32bit(out_data, in_data, enable);
    input [31:0] in_data;
    input enable;
    output [31:0] out_data;
    assign out_data = enable? in_data : {(32){1'bz}};
endmodule

module tristate_buffer_64bit(out_data, in_data, enable);
    input [63:0] in_data;
    input enable;
    output [63:0] out_data;
    assign out_data = enable? in_data : {(64){1'bz}};
endmodule