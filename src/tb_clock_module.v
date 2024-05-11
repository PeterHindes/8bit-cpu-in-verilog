`include "clock_module.v"
`timescale 100us/100us

module tb_clock_module;
    // Test bench for clock_module

    parameter virtual_clk = 100;

    reg clk = 0;
    always #1 clk = ~clk;

    reg manual_clk =0;
    reg select =0;

    wire clk_out;

    clock_module #(
        .source_clk(virtual_clk),
        .target_clk(virtual_clk/2),
        .debounce_cycles_to_wait(10) // 1000 cycles per div_clk /4
    )
    clock_module_inst
    (
        .clk(clk),
        .manual_clk(manual_clk),
        .select(select),
        .clk_out(clk_out)
    );

    initial begin
        // Dump all vars
        $dumpfile("tb_clock_module.vcd");
        $dumpvars;
        // Monitor the clock, and the inputs
        $monitor("clk_out=%b manual_clk=%b select=%b", clk_out, manual_clk, select);

        // Test 1: normal clock, wait for enoguh time to have 3 cycles (3*virtual_clk)
        // select = 0;
        // #30_000;

        // Test 2: manual clock
        #10;
        select = 1;
        // Press the button for 2ms
        manual_clk = 1;
        #20;
        manual_clk = 0;
        #20;

        // Test 3: manual clock with bounce
        select = 1;
        manual_clk = 0;
        // Press the button for 2ms
        manual_clk = 1;
        // bounce
        #1 manual_clk = 0;
        #2 manual_clk = 1;
        #2 manual_clk = 0;
        #4 manual_clk = 1;
        #11; // 20-9
        manual_clk = 0;
        // bounce
        #2 manual_clk = 1;
        #2 manual_clk = 0;
        #3 manual_clk = 1;
        #1 manual_clk = 0;
        #13;

        // #1000;
        $finish;
    end
endmodule


