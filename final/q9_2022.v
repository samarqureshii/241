module blinking_timer(Clock_50, Resetn, LED);
    input Clock_50;
    input Resetn;
    output reg LED;

    reg [25:0] downCount = 50000000 - 1; 
    reg [6:0] timer = 7'd100; 
    reg [3:0] LED_counter = 0; 

    always @(posedge Clock_50 or negedge Resetn) begin
        if (!Resetn) begin 
            downCount <= 50000000 - 1;
            timer <= 7'd100;
            LED_counter <= 0;
            LED <= 1'b0;
        end 
        
        else begin
            //1s pulse
            if (downCount == 0) begin
                downCount <= 50000000 - 1; // reload the down counter
                if (timer != 0) 
                    timer <= timer - 1'b1; // decrement the timer if not 0
                else 
                    timer <= 7'd100; // reset the timer if it reaches 0

                if (timer > 7'd50) begin // from 100s to 50s
                    if (LED_counter < 4'd10) begin //0->9
                        LED_counter <= LED_counter + 1'b1;
                    end 
                    
                    else begin
                        LED_counter <= 0;
                    end
                    LED <= (LED_counter < 4'd5); // LED is on for the first 5 seconds
                end 
                
                else begin // from 50s to 0s
                    LED <= !LED; // LED is what its not (toggle)
                end

            end 
            
            else begin
                downCount <= downCount - 1'b1; 
            end
        end
    end
endmodule
