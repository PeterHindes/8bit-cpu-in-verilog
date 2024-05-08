module physical_map(
    input wire mclk, // 100MHz
    input wire [3:0] btn,
    input wire [15:0] sw
);
    wire ignore;
    clock_module clock_module_inst(
        .clk(mclk),
        .manual_clk(btn[0]),
        .select(sw[0]),
        .clk_out(ignore)
    );
endmodule

module clock_module(
    input wire clk,
    input wire manual_clk,
    input wire select,
    output wire clk_out
);
    wire div_clk;
    clock_divider clock_divider_inst(
        .clock_in(clk),
        .DIVISOR(32'd10_000_000), // 100MHz / 10_000_000 = 5Hz
        .ONCYCLES(32'd2_500_000), // 5Hz / 2 = 2.5Hz
        .clock_out1(div_clk)
    );

    // Use mclk to count if the button has been pressed for 1ms before turrning on the manula_clk
    reg manual_clk_debounce;
    reg [15:0] debounce_counter;
    always @(posedge div_clk) begin
        if (manual_clk && ~manual_clk_debounce) begin
            debounce_counter = debounce_counter + 1;
            if (debounce_counter >= 10_000) begin
                manual_clk_debounce = 1;
                debounce_counter = 0;
            end
        end else if (~manual_clk && manual_clk_debounce) begin
            debounce_counter = debounce_counter + 1;
            if (debounce_counter >= 10_000) begin
                manual_clk_debounce = 0;
                debounce_counter = 0;
            end
        end
    end

    assign clk_out = select ? manual_clk_debounce : div_clk;

endmodule

module clock_divider
    #(  parameter STARTDELAY = 0 ) // 10^8 * full cycle * delaytime
    (
         input clock_in
        ,input [31:0] DIVISOR // 10^8 * full cycle time OR 10^8 / frequency
        ,input [31:0] ONCYCLES // 10^8 * on time
        ,output reg clock_out1
    );

    reg[27:0] counter = -1*STARTDELAY;
    
    // The frequency of the output clk_out
    //  = The frequency of the input clk_in divided by DIVISOR
    // For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
    // You will modify the DIVISOR parameter value to 28'd50.000.000
    // Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz
    always @(posedge clock_in)
    begin
        counter <= counter + 28'd1;
        if(counter>=(DIVISOR-1)) begin
            counter <= 28'd0;
        end
        
        clock_out1 <= (counter < ONCYCLES)?1'b1:1'b0;
    end
endmodule