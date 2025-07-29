`timescale 1ns / 1ps

module pipeline_processor_tb;

    reg clk, reset;

    pipeline_processor uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, pipeline_processor_tb);

        clk = 0; reset = 1;
        #10 reset = 0;

        // Run for a few clock cycles
        #100 $finish;
    end

    always #5 clk = ~clk; // 10ns clock

endmodule
