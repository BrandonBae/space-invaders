`timescale 1ns / 1ps
//originally depth was 4096
module RAM #( parameter DATA_WIDTH = 32, ADDRESS_WIDTH = 12, DEPTH = 2048) (
    input wire                     clk,
    input wire                     wEn,
    input wire [ADDRESS_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0]    dataIn,
    input wire                     moveRight,
    input wire                     moveLeft,
    input wire                     laserOn,
    output reg [DATA_WIDTH-1:0]    dataOut = 0,
    output wire [31:0] sprite1X, sprite1Y,
    output wire [31:0] sprite2X, sprite2Y,
    output wire [31:0] sprite3X, sprite3Y,
    output wire [31:0] sprite4X, sprite4Y,
    output wire [31:0] sprite5X, sprite5Y,
    output wire [31:0] sprite6X, sprite6Y,
    output wire [31:0] sprite7X, sprite7Y,
    output wire [31:0] sprite8X, sprite8Y,
    output wire [31:0] sprite9X, sprite9Y,
    output wire [31:0] sprite10X, sprite10Y,
    output wire [31:0] laser, playerLives, playerScore,
    output wire[31:0] playerX, playerY);
    
    reg[DATA_WIDTH-1:0] MemoryArray[0:DEPTH-1];
    
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            MemoryArray[i] <= 0;
        end
        // if(MEMFILE > 0) begin
        //     $readmemh(MEMFILE, MemoryArray);
        // end
    end
    
    //assign temp1 = MemoryArray[1234];   
    assign playerX = MemoryArray[2000];
    assign playerY = MemoryArray[2001];

    assign sprite1X = MemoryArray[1010];
    assign sprite1Y = MemoryArray[1011];

    assign sprite2X = MemoryArray[1020];
    assign sprite2Y = MemoryArray[1021];

    assign sprite3X = MemoryArray[1030];
    assign sprite3Y = MemoryArray[1031];

    assign sprite4X = MemoryArray[1040];
    assign sprite4Y = MemoryArray[1041];

    assign sprite5X = MemoryArray[1050];
    assign sprite5Y = MemoryArray[1051];

    assign sprite6X = MemoryArray[1060];
    assign sprite6Y = MemoryArray[1061];
    
    assign sprite7X = MemoryArray[1070];
    assign sprite7Y = MemoryArray[1071];

    assign sprite8X = MemoryArray[1080];
    assign sprite8Y = MemoryArray[1081];

    assign sprite9X = MemoryArray[1090];
    assign sprite9Y = MemoryArray[1091];

    assign sprite10X = MemoryArray[1100];
    assign sprite10Y = MemoryArray[1101];

    assign laser = MemoryArray[1200];
    assign playerLives = MemoryArray[1250];
    assign playerScore = MemoryArray[1300];
    
    always @(posedge clk) begin
        MemoryArray[400] <= moveLeft;
        MemoryArray[800] <= moveRight;
        MemoryArray[1200] <= laserOn;
        if(wEn) begin
            MemoryArray[addr] <= dataIn;
        end else begin
            dataOut <= MemoryArray[addr];
        end
    end
endmodule
