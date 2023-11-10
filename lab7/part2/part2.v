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
            oX, //outputs carry the current x and y pixel coordinates to the VGA adapter, indicating where to draw on the screen
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

   //instantiate Control and Datapath modules 
   wire loadX, loadYC, loadD, loadB, plot;
   wire [7:0] blackX;
   wire [6:0] blackY;
   wire [3:0] counter;
   // wire [7:0] x_wire;
   // wire [6:0] y_wire;
   // wire [2:0] colour;
   
   Control C1 (
   .Clock(iClock),
   .ResetN(iResetn),
   .iLoadX(iLoadX),
   .iPlotBox(iPlotBox),
   .iBlack(iBlack),
   .counter(counter), 
   .blackX(blackX),   
   .blackY(blackY),   
   .loadX(loadX),
   .loadYC(loadYC),
   .loadD(loadD),
   .loadB(loadB),
   .done(oDone),
   .plot(oPlot));

// Instantiate Datapath module
Datapath D1 (
   .Clock(iClock),
   .ResetN(iResetn),
   .init_coord(iXY_Coord),
   .Colour(iColour),
   .ControlX(loadX),
   .ControlYC(loadYC),
   .ControlD(loadD),
   .ControlB(loadB),
   .oX(oX),
   .oY(oY),
   .oC(oColour),
   .counter(counter),
   .blackX(blackX),
   .blackY(blackY));

endmodule // part2


//FSM to control which state we need to be in and assert the control signal to datapath 
module Control(
   input Clock,
   input ResetN,
   input iLoadX,
   input iPlotBox,
   input iBlack,
   input [3:0] counter, //4 bit counter
   input [7:0] blackX,
   input [6:0] blackY,

   //outputs to datapath and VGA
   output reg loadX, //load the X register
   output reg loadYC, //load the Y and colour registers
   output reg loadD, //start drawing
   output reg loadB, //clear the screen
   output reg done, //must be high until we pulse iPlotBox or iBlack
   output reg plot; //output to VGA
   );

   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   // internal registers for current and next states. must be 3 bits wide because we have 7 different states in the FSM
   reg [2:0] current;
   reg [2:0] next;

   //state parameters. need to also account for waiting time in between each state.
   localparam S_LOAD_X = 3'd0,
               S_WAIT_X = 3'd1,
               S_LOAD_YC = 3'd2,
               S_WAIT_YC = 3'd3,
               S_DRAW = 3'd4,
               S_DRAW_WAIT = 3'd5,
               S_CLEAR = 3'd6;


   always @ (posedge Clock) begin
    if(!ResetN) begin // active low reset
    //need to b in known state
      current <= S_LOAD_X; //back 2 start
      loadX <= 0;
      loadYC <= 0;
      loadD <= 0;
      loadB <= 0;
      done <= 0;
      plot <= 0;
    end 
    
    else begin
        current <= next; 
    end
   end

   always @ (*) begin //state table 
      case(current)
         S_LOAD_X:
            next = iLoadX ? S_WAIT_X : current; //keep waiting until we load x
            //datapath control
            loadX = 1;
            plot = 0;

         S_WAIT_X: //once load x goes low, we can load x and start waiting for y and colour to be loaded
            next = iLoadX ? current : S_LOAD_YC; //once iLoadX goes to false, then we can load Y and colour
         
         S_LOAD_YC:
            next = iPlotBox ? S_WAIT_YC : current; //once iPlotBox goes high, then we can now load y and colour
            //datapath control
            loadYC = 1;
            plot = 0;

         S_WAIT_YC:
            next = iPlotBox ? current : S_DRAW; //once iPlotBox goes low, then we can now draw
         
         S_DRAW: //if counter hits 1111, then we know we are done drawing the box
            next = (counter == 4'b1111) ? S_DRAW_WAIT : current;
            //datapath control
            loadD = 1;
            plot = 1;
         
         S_DRAW_WAIT: //either after we have draw or clear the screen, we have to wait for the x to be loaded again
            next = S_LOADX;
         
         S_CLEAR: // if we are done clearing the screen, we now wait
            next = ((blackX == X_SCREEN_PIXELS-1) && (blackY == Y_SCREEN_PIXELS-1)) ? S_DRAW_WAIT: current;
            //datapath control
            loadB = 1;
            plot = 1;

         default:
            next = S_LOAD_X;
      endcase 
   end

endmodule


module Datapath(
   input Clock,
   input ResetN,
   input [6:0] init_coord, // initial X and then Y coord
   input [2:0] Colour,

   input ControlX, // control when to load the x register
   input ControlYC, // control when to load the y register and colour register
   input ControlD, // control when to draw and output the x/y registers
   input ControlB, // control when we want to clear the screen

   //outputs to the VGA adapater 
   output reg [7:0] oX; //x coord
   output reg [6:0] oY; //y coord
   output reg [2:0] oC; //colour

   //storage of the current black X and Y, needs to be outputted into Control module so we know which state we're in
   output reg [7:0] blackX;
   output reg [6:0] blackY; 
   output reg [3:0] counter; //internal counter
);

   //internal storage the current x, y and colour (when we are drawing normally)
   reg [7:0] x_init; //from 0 to 159
   reg [6:0] y_init; //from 0 to 119
   reg [2:0] colour; // 001, 010, 100


  //load the registers based on control signals
  always@(posedge Clock) begin
   if(!ResetN) begin
      x_init<= 8'b00000000;
      y_init<= 7'b0000000;
      colour<= 3'b000;
   end
   //if it is time to load the x register (iLoadX goes high)
   else if(ControlX)begin
      x_init<=init_coord;
   end

   //if it is time to load the y register and the colour (iLoadX goes low)
   else if(ControlYC)begin
      y_init<= init_coord;
      colour<= Colour;
   end

   //if it is time to draw normally (iPlotBox)
   else if(ControlD)begin
      //load the output registers
      oX <= x_init + counter[1:0]; //add LSB current counter value to the initial x position
      oY <= y_init + counter[3:2]; //add MSB current counter value to the intiial y position 
      oC <= colour;
   end

   //if it is time to draw black (iBlack)
   else if(ControlB)begin
      colour <= 3'b000; //set the colour to black
      oX <= blackX;
      oY <= blackY;
      oC <= colour;
   end

  end

  //increment the counter
   always @(posedge Clock) begin
      if (!ResetN || counter == 4'b1111) begin//active low reset or counter has finished 
         counter <= 4'b0000;
      end

      else if(counter < 4'b1111) begin //if counter has not finished, keep drawing the box 
         counter <= counter + 4'b0001;
      end

   end

   //now handle the iBlack control signal
   always @(posedge Clock)begin
      if(!ResetN || (blackX == X_SCREEN_PIXELS-1 && blackY == Y_SCREEN_PIXELS-1))begin //active low reset, or we finished clearing the entire screen
         blackX <= 8'b00000000;
         blackY <= 7'b0000000;
         //colour <= 3'b000;
      end

      else if(ControlB)begin //keep incrementing the X because we haven't hit the end of the row 
         blackX <= blackX + 8'b00000001;
      end

      else if(blackX == X_SCREEN_PIXELS-1 && blackY < Y_SCREEN_PIXELS-1)begin //move onto the next row by incrementing Y, and blackX goes back to 0
         blackX <=  8'b00000000;
         blackY <= blackY + 7'b0000001;
      end

   end

endmodule
