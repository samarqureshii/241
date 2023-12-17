module blinking_timer(Clock_50, Resetn, LED)
    input Clock_50;
    input Resetn;
    output LED;

    wire Enable; //pulse every 1s

    //rate divide

    reg [25:0] downCount; //every cycle 
    reg [6:0] timer; //timer for every 1s, use the pulse Enable signal to determine when we increment the timer 

    always @(posedge ClockIn) begin
        if(downCount == 26'd0 || !Resetn) begin //active low reset
            Enable = 1'b1; //assert the enable signal, remains high during reset 
            downCount <=50000000-1; //count 50MHz cycles
            
        end

        else begin
            downCount<=downCount -1;
            Enable<=1'b0; //enable only pulses if we finish the 50MHz cycles
        end

        if(timer == 7'd0 || !Resetn) begin 
            timer <= 7'd100;
        end

        if(Enable)begin //if we pulse the enable signal, then decrement the timer 
            timer <= timer - 1;
        end

        if(timer > 7'd50 )begin // when timer is from 100s to 50s
            //pulse the LED once every 5 seconds
            if(timer % 3'd5 == 0)begin
                LED <= 1'b1;
            end

            else begin
                LED <= 1'b0
            end
        end

        else begin //when timer is from 50s to 0s
            //pulse the LED once every 1 second 
            if(timer % 2'd2 == 0) begin
                LED <= 1'b1;
            end
            else begin
                LED <= 1'b0;
            end
        end
    end
endmodule

// module RateDivider #(parameter FREQUENCY = 50000000)( //gives us one second timer
//     input ClockIn,
//     input Reset,
//     input speedEn,
//     output reg Enable); //pulse every 1s

// endmodule