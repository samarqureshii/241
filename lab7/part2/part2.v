//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(
            /*************INPUTS************/
            iResetn, //active low synchronous reset 
            iPlotBox, //When pulsed (goes high then low), it triggers the circuit to start drawing the square with the specified colour at the specified coordinates 
            iBlack, //Control signal to clear the screen. If pulsed, entire screen is set to black (000)
            iColour, //colour that the square will be (001, 010, or 100 for RGB)
            iLoadX, //control signal used to load the X coodinate into a register 
            //when high, the value present on iXY_Coord is loaded into the x coordinate register, 
            //if it stays high, the value on iXY_Coord will continue to be laoded into the X register with every clock cycle
            iXY_Coord, //Specify the X and Y coordinates where the 4 by 4 pixel square will be drawn on the display
            iClock, //clock input

            /*************OUTPUTS************/
            oX, //ouputs carry the current x and y pixel coordinates to the VGA adapter, indicating where to draw on the screen
            oY,
            oColour, //output provides the colour value for the current pixel to be drawn and is sent to the VGA adapter 
            oPlot, //control signal that acts as a write enable. when High, the VGA adapter will draw the pixel at the coordinate (oX, oY)
            oDone); //output signal that indicates that the circuit has completed the task 
               //set high after the circuit has finished drawing a box or clearing the screen. remains high until iPlotBox or iBlack is pulsed again 
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire 	    iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame

   //
   // Your code goes here
   //

   //instantiate Control and Datapath modules 

endmodule // part2

module Control(); //FSM

//control which state we need to be in and assert the control signal to datapath 

endmodule


module Datapath(); 
   //Registers to hold the current x and current y
   //4 bit counter to sweep across
   input Clock;
   input ResetN;
   input [7:0] X_SCREEN_PIXELS;
   input [6:0] Y_SCREEN_PIXELS;
   input [2:0] Colour;
   input [6:0] init_coord; //initial X and then Y coord
   input ControlX, ControlD, ControlB; //control signals so we know when to load each of the registers

   //internal storage the current x, y and colour (when we are drawing normally)
   reg currX [7:0]; //from 0 to 159
   reg currY [6:0]; //from 0 to 119
   reg colour [2:0]; // 001, 010, 100

   //internal storage of the current black X and Y
   reg blackX [7:0];
   reg blackY [6:0]; 

   //outputs to the VGA adapater 
   output reg [7:0] oX; //x coord
   output reg [6:0] oY; //y coord
   output reg [3:0] oC; //colour

   //internal counter
   output reg [3:0] counter;

  //load the registers based on control signals
  always@(posedge Clock) begin
   if(!ResetN) begin
      currX>= 8'b00000000;
      currY>= 7'b0000000;
      colour>=3'b000;
   end

   else begin

      //if it is time to load the x register (iLoadX goes high)
      if(ControlX)begin
         currX>=init_coord;
      end

      //if it is time to load the y register and the colour (iLoadX goes low)
      else if(!ControlX)begin
         currY>=init_coord;
         colour>=Colour;
      end

      //if it is time to draw normally (iPlotBox)
      else if(ControlD)begin
         //load the output registers
         oX >= currX;
         oY >= currY;
         oC >= colour;
      end

      //if it is time to draw black (iBlack)
      else if(ControlB)begin
         oX >= blackX;
         oY >= blackY;
         oC >= colour;
      end
   
   end

  end
   
   //Update the x and y positions based on counter 
   always@(*) begin 
      currX = init_X + counter[1:0]; //add LSB current counter value to the initial x position
      currY = init_Y + counter[3:2]; //add MSB current counter value to the intiial y position 
   end

  //increment the counter
   always @(posedge Clock) begin
      if (!ResetN) begin//active low reset 
         currX >= 8'b00000000;
         currY >= 7'b0000000;
         colour >= 3'b000;
      end

      else if() begin //if counter has not finished, keep drawing the box 
         counter <= counter + 4'b0001;
      end
      else if(counter = 4'b1111) begin //counter has finished
      end

   end

   //now handle the iBlack control signal
   always @(posedge Clock)begin
      if(!ResetN)begin
         blackX >= 8'b00000000;
         blackY >= 7'b0000000;
         colour >= 3'b000;
      end

      else begin
         if()begin
         end
      end


   end

endmodule
