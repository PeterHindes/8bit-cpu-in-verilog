`include "clock_module.v"
`timescale 1ns/1ns

module tb_clock_module;
    // Test bench for clock_module

    reg clk;
    reg manual_clk;
    reg select;

    wire clk_out;

    clock_module clock_module_inst(
        .clk(clk),
        .manual_clk(manual_clk),
        .select(select),
        .clk_out(clk_out)
    );

    initial begin
        // Dump all vars
        $dumpfile("tb_clock_module.vcd");
        $dumpvars(1);
        // Monitor the clock, and the inputs
        $monitor("clk_out=%b manual_clk=%b select=%b", clk_out, manual_clk, select);

        manual_clk = 0;
        select = 0;
        // Clock generation
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end

        // Test 1: normal clock, wait for enoguh time to have 3 cycles (3*10_000_000)
        select = 0;
        #30000000;

        // Test 2: manual clock
        select = 1;
        manual_clk = 0;
        // Press the button for 2ms
        manual_clk = 1;
        #2000000;
        manual_clk = 0;
        #2000000;

        // Test 3: manual clock with bounce
        select = 1;
        manual_clk = 0;
        // Press the button for 2ms
        manual_clk = 1;
        // bounce
        #30 manual_clk = 0;
        #50 manual_clk = 1;
        #60 manual_clk = 0;
        #80 manual_clk = 1;
        #1999780;
        manual_clk = 0;
        // bounce
        #50 manual_clk = 1;
        #60 manual_clk = 0;
        #80 manual_clk = 1;
        #30 manual_clk = 0;
        #1999780;



    end
endmodule