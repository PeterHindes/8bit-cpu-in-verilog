// module physical_map(
//     input wire mclk, // 100MHz
//     input wire [3:0] btn,
//     input wire [15:0] sw
// );
//     wire ignore;
//     clock_module clock_module_inst(
//         .clk(mclk),
//         .manual_clk(btn[0]),
//         .select(sw[0]),
//         .clk_out(ignore)
//     );
// endmodule

module clock_module
#(  
     parameter source_clk = 100_000_000
    ,parameter target_clk = 5
    ,parameter debounce_cycles_to_wait = 10_000 // time = 10_000 / 100MHz = 0.1ms
)
(
     input wire clk
    ,input wire manual_clk
    ,input wire select
    ,output wire clk_out
);
    wire div_clk;
    clock_divider clock_divider_inst(
        .clock_in(clk),
        .DIVISOR(source_clk/target_clk), // 100MHz / 5Hz = 20_000_000
        .ONCYCLES(source_clk/target_clk/2), // on half the time
        .clock_out1(div_clk)
    );

    // Divisor
    initial begin
        $display("Divisor: %d", source_clk/target_clk);
    end

    // Use mclk to count if the button has been pressed for 1ms before turrning on the manula_clk
    wire manual_clk_debounce = 0;
    debounce debounce_instance (manual_clk,clk,manual_clk_debounce);

    assign clk_out = select ? manual_clk_debounce : div_clk;

endmodule

module debounce
    #(
         parameter CLOCK_SPEED = 100_000_000
        ,parameter MIN_HOLD_TIME = 1 // ms
    )
    (
         input btn, clk
        ,output reg btn_db
    );
    wire hclk;
    clock_divider cinst (clk,
        CLOCK_SPEED/(MIN_HOLD_TIME*10^-3),
        CLOCK_SPEED/(MIN_HOLD_TIME*10^-3)/2,
        hclk);
    always @(posedge hclk) begin
        btn_db = btn;
    end
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