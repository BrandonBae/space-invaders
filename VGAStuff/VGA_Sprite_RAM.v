`timescale 1ns / 1ps
module VGA_Sprite_RAM #( parameter DATA_WIDTH = 8, ADDRESS_WIDTH = 8, DEPTH = 256, MEMFILE = "") (
    input wire                     clk,
    input wire                     wEn,
    input wire [ADDRESS_WIDTH-1:0] addrSprite1, addrSprite2, addrSprite3, addrSprite4, addrSprite5, addrSprite6, addrSprite7, addrSprite8, addrSprite9, addrSprite10,
    input wire [ADDRESS_WIDTH-1:0] addrPlayer,
    input wire [DATA_WIDTH-1:0]    dataIn,
    output reg [DATA_WIDTH-1:0]   outSprite1, outSprite2, outSprite3, outSprite4, outSprite5, outSprite6, outSprite7, outSprite8, outSprite9, outSprite10,
    output reg [DATA_WIDTH-1:0]    outPlayer);
    
    reg[DATA_WIDTH-1:0] MemoryArray[0:DEPTH-1];
    
    initial begin
        if(MEMFILE > 0) begin
            $readmemh(MEMFILE, MemoryArray);
        end
    end
    
    // assign outSprite1 = MemoryArray[addrSprite1];
    // assign outSprite2 = MemoryArray[addrSprite2];
    // assign outSprite3 = MemoryArray[addrSprite3];
    // assign outSprite4 = MemoryArray[addrSprite4];
    // assign outSprite5 = MemoryArray[addrSprite5];
    // assign outSprite6 = MemoryArray[addrSprite6];
    // assign outSprite7 = MemoryArray[addrSprite7];
    // assign outSprite8 = MemoryArray[addrSprite8];
    // assign outSprite9 = MemoryArray[addrSprite9];
    // assign outSprite10 = MemoryArray[addrSprite10];
    // assign outPlayer = MemoryArray[addrPlayer];
    always @(posedge clk) begin
        if(wEn) begin
            MemoryArray[addrPlayer] <= dataIn;
        end else begin
            outSprite1 <= MemoryArray[addrSprite1];
            outSprite2 <= MemoryArray[addrSprite2];
            outSprite3 <= MemoryArray[addrSprite3];
            outSprite4 <= MemoryArray[addrSprite4];
            outSprite5 <= MemoryArray[addrSprite5];
            outSprite6 <= MemoryArray[addrSprite6];
            outSprite7 <= MemoryArray[addrSprite7];
            outSprite8 <= MemoryArray[addrSprite8];
            outSprite9 <= MemoryArray[addrSprite9];
            outSprite10 <= MemoryArray[addrSprite10];

            outPlayer <= MemoryArray[addrPlayer];
        end
    end
endmodule
