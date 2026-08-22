`timescale 1ns/1ps

module mac_unit_tb();
    reg clk;
    reg rst_n;
    reg clear;
    reg en;
    reg signed [7:0] weight;
    reg signed [7:0] in1;
    wire signed [31:0] out;

    mac_unit dut(
        .clk(clk),
        .rst_n(rst_n),
        .clear(clear),
        .en(en),
        .weight(weight),
        .in1(in1),
        .out(out)
    );

    always #5 clk = !clk;
    
    task apply_test(input [7:0] tw, input [7:0] tin);
    begin
        weight = tw;
        in1 = tin;
        en = 1;
        #10;
        $display("Time = %0t | weight = %d in1 = %d => output = %d", $time, weight, in1, out);
        en = 0;
    end 
    endtask

    initial begin
        $dumpfile("mac_unit.vcd");
        $dumpvars(0, mac_unit_tb);
        clk = 0;
        rst_n = 0;
        clear = 0;
        en = 0;
        weight = 0;
        in1 = 0;
        
        @(posedge clk);
        @(posedge clk);
        rst_n = 1;
        #1;
        apply_test(8'd127, 8'd126);
        apply_test(8'd100, 8'd111);
        apply_test(8'd1, 8'd100);
        $finish;
    end
endmodule