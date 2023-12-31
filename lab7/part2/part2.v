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
   wire [4:0] counter;
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
   input [4:0] counter, //5 bit counter
   input [7:0] blackX,
   input [6:0] blackY,

   //outputs to datapath and VGA
   output reg loadX, //load the X register
   output reg loadYC, //load the Y and colour registers
   output reg loadD, //start drawing
   output reg loadB, //clear the screen
   output reg done, //must be high until we pulse iPlotBox or iBlack
   output reg plot //output to VGA
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
   if (!ResetN) begin // active low reset
      current <= S_LOAD_X; // back to start
      loadX <= 0;
      loadYC <= 0;
      loadD <= 0;
      loadB <= 0;
      done <= 0;
      plot <= 0;
   end 

   else if(loadB) begin
      current <= S_CLEAR;
   end

   else begin
      current <= next; 
   end
   end

   always @ (*) begin // State table 
      // reset all control signals at the beginning of each state transition so they dont stay high
      loadX = 0;
      loadYC = 0;
      loadD = 0;
      loadB = 0;
      plot = 0;
      
      case (current)
         S_LOAD_X: begin
            next = iLoadX ? S_WAIT_X : current; // keep waiting until we load x
            loadX = 1; // assert loadX to load the X coordinate
         end

         S_WAIT_X: begin // once load x goes low, we can load x and start waiting for y and color to be loaded
            next = !iLoadX ? S_LOAD_YC : current; // move to the next state when iLoadX is deasserted
            // deassert all control signals here
         end

         S_LOAD_YC: begin
            next = iPlotBox ? S_WAIT_YC : current; // Once iPlotBox goes high, then we can load y and color
            loadYC = 1; // Assert loadYC to load the Y coordinate and color
         end

         S_WAIT_YC: begin
            next = !iPlotBox ? S_DRAW : current; //iPlotBox is deasserted, we move to the drawing state
            // deassert all control signals here
         end
         
         S_DRAW: begin // if counter hits 1111, then we know we are done drawing the box
            loadD = 1; // assert loadD to start drawing
            plot = 1; // assert plot to enable drawing on VGA
            next = (counter == 5'b10000) ? S_DRAW_WAIT : current;
         end

         S_DRAW_WAIT: begin // either after we have drawn or cleared the screen, we have to wait for the x to be loaded again
            done = 1; // assert done to indicate completion
            next = (iLoadX || iBlack) ? S_LOAD_X : current; // move to load X only if iLoadX or iBlack is pulsed
         end

         S_CLEAR: begin // if we are done clearing the screen, we now wait
            loadB = 1; // assert loadB to clear the screen
            plot = 1; // assert plot to enable drawing on VGA
            next = ((blackX == X_SCREEN_PIXELS-1) && (blackY == Y_SCREEN_PIXELS-1)) ? S_DRAW_WAIT : current;
            if (next == S_DRAW_WAIT) done = 1; // Assert done after clearing is complete
         end

         default: begin
            next = S_LOAD_X;
         end
      endcase 
   end
endmodule



// Datapath module to handle drawing and clearing operations
module Datapath(
    input Clock,
    input ResetN,
    input [6:0] init_coord, // initial X and Y coord
    input [2:0] Colour,
    input ControlX, // control when to load the x register
    input ControlYC, // control when to load the y register and colour register
    input ControlD, // control when to draw and output the x/y registers
    input ControlB, // control when we want to clear the screen
    output reg [7:0] oX, //x coord
    output reg [6:0] oY, //y coord
    output reg [2:0] oC, //colour
    output reg [7:0] blackX,
    output reg [6:0] blackY,
    output reg [4:0] counter //internal counter
);

    reg [7:0] x_init; //from 0 to 159
    reg [6:0] y_init; //from 0 to 119
    reg [2:0] colour; // 001, 010, 100

    parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    always @(posedge Clock) begin
        if (!ResetN) begin
            // Reset logic
            x_init <= 8'b0;
            y_init <= 7'b0;
            colour <= 3'b0;
            counter <= 5'b0;
            oX <= 8'b0;
            oY <= 7'b0;
            oC <= 3'b0;
            blackX <= 8'b0;
            blackY <= 7'b0;
        end 
        else begin
            if (ControlX) begin
                x_init <= {1'b0, init_coord};
            end 
            if (ControlYC) begin
                y_init <= init_coord;
                colour <= Colour;
            end
            if (ControlD) begin
                // Draw the pixel based on the current count
                oX <= x_init + counter[1:0]; // Add LSBs of counter to x_init
                oY <= y_init + counter[3:2]; // Add MSBs of counter to y_init
                oC <= colour; // Keep the colour until the pixel is drawn
                if (counter < 5'b10000) begin
                    counter <= counter + 1'b1;
                end
            end 
            else if (ControlB) begin
                // Clearing logic
                oX <= blackX;
                oY <= blackY;
                oC <= 3'b0; // Set colour to black
                if (blackX < X_SCREEN_PIXELS - 1) begin
                    blackX <= blackX + 1'b1;
                end else if (blackY < Y_SCREEN_PIXELS - 1) begin
                    blackY <= blackY + 1'b1;
                    blackX <= 8'b0;
                end else begin
                    // Reset to starting position after the screen is cleared
                    blackX <= 8'b0;
                    blackY <= 7'b0;
                end
            end 
            else begin
                counter <= 5'b0;
            end
        end
    end
endmodule
