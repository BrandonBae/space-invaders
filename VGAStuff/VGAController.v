`timescale 1 ns/ 100 ps
 
module VGAController(    
	input[9:0] sprite1X, sprite2X, sprite3X, sprite4X, sprite5X, sprite6X, sprite7X, sprite8X, sprite9X, sprite10X, 
	input[8:0] sprite1Y, sprite2Y, sprite3Y, sprite4Y, sprite5Y, sprite6Y, sprite7Y, sprite8Y, sprite9Y, sprite10Y,
     input[9:0] playerX,
     input[8:0] playerY,
     input laser,
     input clk,     // 100 MHz System Clock
     input reset,      // Reset Signal
     output hSync,  // H Sync Signal
     output vSync,      // Veritcal Sync Signal
     output[3:0] VGA_R,  // Red Signal Bits
     output[3:0] VGA_G,  // Green Signal Bits
     output[3:0] VGA_B  // Blue Signal Bits
);
    
     //wire [7:0] rx_data;
     //wire read_data, busy, err;
    
     //Ps2Interface ps2(.ps2_clk(ps2_clk), .ps2_data(ps2_data),.clk(clk),.rst(reset), .tx_data(0), .write_data(0),.rx_data(rx_data), .read_data(read_data), .busy(busy), .err(err));
    
    
     // Lab Memory Files Location
     localparam FILES_PATH = "C:/Users/bkunj/ECE350/processor/processor/VGAStuff/";
 
     // Clock divider 100 MHz -> 25 MHz
     wire clk25; // 25MHz clock
   
    reg[11:0] counter;
     reg[1:0] pixCounter = 0;      // Pixel counter to divide the clock
    assign clk25 = pixCounter[1]; // Set the clock high whenever the second bit (2) is high
     always @(posedge clk) begin
          pixCounter <= pixCounter + 1; // Since the reg is only 3 bits, it will reset every 8 cycles
     end
 
     // VGA Timing Generation for a Standard VGA Screen
     localparam
          VIDEO_WIDTH = 640,  // Standard VGA Width
          VIDEO_HEIGHT = 480; // Standard VGA Height
 
     wire active, screenEnd;
    
     wire[9:0] x;
     wire[8:0] y;
    
     reg[9:0] playerXCoord, sprite1XCoord, sprite2XCoord, sprite3XCoord, sprite4XCoord, sprite5XCoord, sprite6XCoord, sprite7XCoord, sprite8XCoord, sprite9XCoord, sprite10XCoord;
     reg[8:0] playerYCoord, sprite1YCoord, sprite2YCoord, sprite3YCoord, sprite4YCoord, sprite5YCoord, sprite6YCoord, sprite7YCoord, sprite8YCoord, sprite9YCoord, sprite10YCoord;
    
     always @(posedge screenEnd) begin
          playerXCoord<=playerX;
          playerYCoord<=playerY;

          sprite1XCoord<=sprite1X;
		sprite1YCoord<=sprite1Y;

          sprite2XCoord<=sprite2X;
		sprite2YCoord<=sprite2Y;

          sprite3XCoord<=sprite3X;
		sprite3YCoord<=sprite3Y;

          sprite4XCoord<=sprite4X;
		sprite4YCoord<=sprite4Y;

          sprite5XCoord<=sprite5X;
		sprite5YCoord<=sprite5Y;

          sprite6XCoord<=sprite6X;
		sprite6YCoord<=sprite6Y;

          sprite7XCoord<=sprite7X;
		sprite7YCoord<=sprite7Y;

          sprite8XCoord<=sprite8X;
		sprite8YCoord<=sprite8Y;
          
          sprite9XCoord<=sprite9X;
		sprite9YCoord<=sprite9Y;

          sprite10XCoord<=sprite10X;
		sprite10YCoord<=sprite10Y;
     end                 // Y Coordinate (from top)    
 
     wire[15:0] insquareArr;
     wire[3:0] muxSelect;
    
     //wire in_x= x> xcoord && x<xcoord+50;
     //wire in_y=y>ycoord && y<ycoord+50;
     assign insquareArr[11]= (x > playerXCoord && x<playerXCoord+50) && (y>playerYCoord && y<playerYCoord+50);
     assign insquareArr[10]= (x > sprite10XCoord && x<sprite10XCoord+50) && (y>sprite10YCoord && y<sprite10YCoord+50);
     assign insquareArr[9]= (x > sprite9XCoord && x<sprite9XCoord+50) && (y>sprite9YCoord && y<sprite9YCoord+50);
     assign insquareArr[8]= (x > sprite8XCoord && x<sprite8XCoord+50) && (y>sprite8YCoord && y<sprite8YCoord+50);
     assign insquareArr[7]= (x > sprite7XCoord && x<sprite7XCoord+50) && (y>sprite7YCoord && y<sprite7YCoord+50);
     assign insquareArr[6]= (x > sprite6XCoord && x<sprite6XCoord+50) && (y>sprite6YCoord && y<sprite6YCoord+50);
     assign insquareArr[5]= (x > sprite5XCoord && x<sprite5XCoord+50) && (y>sprite5YCoord && y<sprite5YCoord+50);
     assign insquareArr[4]= (x > sprite4XCoord && x<sprite4XCoord+50) && (y>sprite4YCoord && y<sprite4YCoord+50);
     assign insquareArr[3]= (x > sprite3XCoord && x<sprite3XCoord+50) && (y>sprite3YCoord && y<sprite3YCoord+50);
     assign insquareArr[2]= (x > sprite2XCoord && x<sprite2XCoord+50) && (y>sprite2YCoord && y<sprite2YCoord+50);
     assign insquareArr[1]= (x > sprite1XCoord && x<sprite1XCoord+50) && (y>sprite1YCoord && y<sprite1YCoord+50);

     //priorityencoder_16_4 get_mux_select_bits(.en(1'b1),.i(insquareArr),.y(muxSelect));
    
     VGATimingGenerator #(
          .HEIGHT(VIDEO_HEIGHT), // Use the standard VGA Values
          .WIDTH(VIDEO_WIDTH))
     Display(
          .clk25(clk25),     // 25MHz Pixel Clock
          .reset(reset),           // Reset Signal
          .screenEnd(screenEnd), // High for one cycle when between two frames
          .active(active),         // High when drawing pixels
          .hSync(hSync),          // Set Generated H Signal
          .vSync(vSync),        // Set Generated V Signal
          .x(x),                      // X Coordinate (from left)
          .y(y));
 
     // Image Data to Map Pixel Location to Color Address
     localparam
          PIXEL_COUNT = VIDEO_WIDTH*VIDEO_HEIGHT,          // Number of pixels on the screen
          PIXEL_ADDRESS_WIDTH = $clog2(PIXEL_COUNT) + 1,         // Use built in log2 command
          BITS_PER_COLOR = 12,                                            // Nexys A7 uses 12 bits/color
          PALETTE_COLOR_COUNT = 256,                                    // Number of Colors available
          PALETTE_ADDRESS_WIDTH = $clog2(PALETTE_COLOR_COUNT) + 1; // Use built in log2 Command
 
     wire[PIXEL_ADDRESS_WIDTH-1:0] imgAddress;     // Image address for the image data
     wire[PALETTE_ADDRESS_WIDTH-1:0] colorAddr;        // Color address for the color palette
     assign imgAddress = x + 640*y;                 // Address calculated coordinate
 
    VGA_RAM #(        
          .DEPTH(PIXEL_COUNT),                       // SetVGA_RAM depth to contain every pixel
          .DATA_WIDTH(PALETTE_ADDRESS_WIDTH),      // Set data width according to the color palette
          .ADDRESS_WIDTH(PIXEL_ADDRESS_WIDTH),     // Set address with according to the pixel count
          .MEMFILE({FILES_PATH, "image.mem"})) // Memory initialization
     ImageData(
          .clk(clk),                            // Falling edge of the 100 MHz clk
          .addr(imgAddress),                      // Image data address
          .dataOut(colorAddr),                // Color palette address
          .wEn(1'b0));                           // We're always reading
 
     // Color Palette to Map Color Address to 12-Bit Color
     wire[BITS_PER_COLOR-1:0] colorData; // 12-bit color data at current pixel
 
    VGA_RAM #(
          .DEPTH(PALETTE_COLOR_COUNT),             // Set depth to contain every color      
          .DATA_WIDTH(BITS_PER_COLOR),              // Set data width according to the bits per color
          .ADDRESS_WIDTH(PALETTE_ADDRESS_WIDTH),     // Set address width according to the color count
          .MEMFILE({FILES_PATH, "colors.mem"}))  // Memory initialization
     ColorPalette(
          .clk(clk),                                        // Rising edge of the 100 MHz clk
          .addr(colorAddr),                         // Address from the ImageDataVGA_RAM
          .dataOut(colorData),                     // Color at current pixel
          .wEn(1'b0));                               // We're always reading
 
      /*
     wire[ASCII_ADDRESS_WIDTH-1:0] asciiAddr;  // address for the ascii palette
     wire[BITS_PER_ASCII-1:0] asciiData;
     assign asciiAddr = rx_data;
 
     // Ascii mem
     localparam
          BITS_PER_ASCII = 7,                                          // Nexys A7 uses 12 bits/color
          ASCII_COUNT = 256,                                    // Number of Colors available
          ASCII_ADDRESS_WIDTH = $clog2(ASCII_COUNT) + 1; // Use built in log2 Command
    VGA_RAM #(
          .DEPTH(ASCII_COUNT),              // Set depth to contain every color     
          .DATA_WIDTH(BITS_PER_ASCII),               // Set data width according to the bits per color
          .ADDRESS_WIDTH(ASCII_ADDRESS_WIDTH),     // Set address width according to the color count
          .MEMFILE({FILES_PATH, "ascii.mem"}))  // Memory initialization
     AsciiData(
          .clk(clk),                                         // Rising edge of the 100 MHz clk
          .addr(asciiAddr),                           // Address from the ImageDataVGA_RAM
          .dataOut(asciiData),                      // Color at current pixel
          .wEn(1'b0));                               // We're always reading
 */
 
     // Sprite mem

     wire[SPRITE_ADDRESS_WIDTH-1:0] addrSprite1, addrSprite2, addrSprite3, addrSprite4, addrSprite5, addrSprite6, addrSprite7, addrSprite8, addrSprite9, addrSprite10, addrPlayer;       // address for the ascii palette
     assign addrSprite1 = insquareArr[1] ? (1)*2500 + ((y - sprite1YCoord) * 50 + (x - sprite1XCoord)) : 32'b0;
     assign addrSprite2 = insquareArr[2] ?  (1)*2500 + ((y - sprite2YCoord) * 50 + (x - sprite2XCoord)) : 32'b0;
     assign addrSprite3 = insquareArr[3] ? (1)*2500 + ((y - sprite3YCoord) * 50 + (x - sprite3XCoord)) : 32'b0;
     assign addrSprite4 = insquareArr[4] ? (1)*2500 + ((y - sprite4YCoord) * 50 + (x - sprite4XCoord)) : 32'b0;
     assign addrSprite5 = insquareArr[5] ? (1)*2500 + ((y - sprite5YCoord) * 50 + (x - sprite5XCoord)) : 32'b0;
     assign addrSprite6 = insquareArr[6] ? (1)*2500 + ((y - sprite6YCoord) * 50 + (x - sprite6XCoord)) : 32'b0;
     assign addrSprite7 = insquareArr[7] ? (1)*2500 + ((y - sprite7YCoord) * 50 + (x - sprite7XCoord)) : 32'b0;
     assign addrSprite8 = insquareArr[8] ? (1)*2500 + ((y - sprite8YCoord) * 50 + (x - sprite8XCoord)) : 32'b0;
     assign addrSprite9 = insquareArr[9] ? (1)*2500 + ((y - sprite9YCoord) * 50 + (x - sprite9XCoord)) : 32'b0;
     assign addrSprite10 = insquareArr[10] ? (1)*2500 + ((y - sprite10YCoord) * 50 + (x - sprite10XCoord)) : 32'b0;
     assign addrPlayer = insquareArr[11] ? (0)*2500 + ((y - playerYCoord) * 50 + (x - playerXCoord)) : 32'b0;
     wire sprite1Data, sprite2Data, sprite3Data, sprite4Data, sprite5Data, sprite6Data, sprite7Data, sprite8Data, sprite9Data, sprite10Data, playerData;
 

     localparam
          BITS_PER_SPRITE = 1,                                             // Nexys A7 uses 12 bits/color
          SPRITE_COUNT = 1 * 2500,                                   // Number of Colors available
          SPRITE_ADDRESS_WIDTH = $clog2(SPRITE_COUNT) + 1; // Use built in log2 Command
     VGA_Sprite_RAM #(
          .DEPTH(2500),            // Set depth to contain every color        
          .DATA_WIDTH(BITS_PER_SPRITE),              // Set data width according to the bits per color
          .ADDRESS_WIDTH(SPRITE_ADDRESS_WIDTH),     // Set address width according to the color count
          .MEMFILE({FILES_PATH, "ship_sprites.mem"}))  // Memory initialization
     SpriteData(
          .clk(clk),                                        // Rising edge of the 100 MHz clk
          .addrSprite1(addrSprite1), .addrSprite2(addrSprite2), .addrSprite3(addrSprite3), .addrSprite4(addrSprite4), .addrSprite5(addrSprite5), .addrSprite6(addrSprite6), .addrSprite7(addrSprite7), .addrSprite8(addrSprite8), .addrSprite9(addrSprite9), .addrSprite10(addrSprite10),
          .addrPlayer(addrPlayer),
          .outSprite1(sprite1Data), .outSprite2(sprite2Data), .outSprite3(sprite3Data), .outSprite4(sprite4Data), .outSprite5(sprite5Data), .outSprite6(sprite6Data), .outSprite7(sprite7Data), .outSprite8(sprite8Data), .outSprite9(sprite9Data), .outSprite10(sprite10Data),
          .outPlayer(playerData),
          .wEn(1'b0));                               // We're always reading
     
         
     /*
     always @(posedge screenEnd) begin
         if(inSquareArr[0] || inSquareArr[1] ) begin
            counter = counter +1;
          end
          if(counter==2500) begin
          counter=0;
          end
     end
     */
     
     wire[15:0] priorityEncoderInput;
     assign priorityEncoderInput[11] = playerData & insquareArr[11];
     assign priorityEncoderInput[10] = sprite10Data & insquareArr[10];
     assign priorityEncoderInput[9] = sprite9Data & insquareArr[9];
     assign priorityEncoderInput[8] = sprite8Data & insquareArr[8];
     assign priorityEncoderInput[7] = sprite7Data & insquareArr[7];
     assign priorityEncoderInput[6] = sprite6Data & insquareArr[6];
     assign priorityEncoderInput[5] = sprite5Data & insquareArr[5];
     assign priorityEncoderInput[4] = sprite4Data & insquareArr[4];
     assign priorityEncoderInput[3] = sprite3Data & insquareArr[3];
     assign priorityEncoderInput[2] = sprite2Data & insquareArr[2];
     assign priorityEncoderInput[1] = sprite1Data & insquareArr[1];

     priorityencoder_16_4 get_mux_select_bits(.en(1'b1),.i(priorityEncoderInput),.y(muxSelect));
     
     wire[BITS_PER_COLOR-1:0] tempColorOut;  

     wire[BITS_PER_COLOR-1:0] colorOut;                // Output color
     
     wire in_square = insquareArr[11] || insquareArr[10] || insquareArr[9] || insquareArr[8] || insquareArr[7] || insquareArr[6] ||
          insquareArr[5] || insquareArr[4] || insquareArr[3] || insquareArr[2] || insquareArr[1];
     wire spriteData = playerData || sprite1Data || sprite2Data || sprite3Data || sprite4Data || sprite5Data || sprite6Data || sprite7Data
                         || sprite8Data || sprite9Data || sprite10Data;
     
     //wire in_square = insquareArr[11] || insquareArr[2] || insquareArr[1];
     //wire spriteData = playerData || sprite1Data || sprite2Data;
     assign finalcolor=in_square ? 12'b0 : colorData;

     //mux16 colorMux(.out(tempColorOut), .select(muxSelect), .in0(finalcolor), .in1(12'hc77), .in2(12'hc77), .in3(12'hc77), .in4(12'hc77), .in5(12'hc77), .in6(12'hc77), 
     //.in7(12'hc77), .in8(12'hc77), .in9(12'hc77), .in10(12'hc77), .in11(12'hc77), .in12(12'hc77), .in13(), .in14(), .in15());

     // Assign to output color from register if active
     //wire[BITS_PER_COLOR-1:0] finalcolor;
     wire inLaser = (playerXCoord+23 < x) & (playerXCoord+27 > x) & (y < playerYCoord) & laser;
     //if we want breadboard change from 12'h000 to finalcolor
     assign colorOut = active ? (inLaser ? 12'hfff : ((spriteData & in_square) ? 12'hfff : 12'h000)) : 12'b0; // When not active, output black
     //assign colorOut = active ? tempColorOut : 12'b0;
     // Quickly assign the output colors to their channels using concatenation
     assign {VGA_R, VGA_G, VGA_B} = colorOut;
endmodule
