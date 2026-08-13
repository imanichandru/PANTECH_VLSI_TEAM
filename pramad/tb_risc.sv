`timescale 1ns/1ps
import risc_pkg::*;

module tb_risc;
    logic clk;
    logic rst_n;

    // Instantiate core
    risc_core dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize Registers
        for(int i=0; i<32; i++) dut.reg_file[i] = i * 10;
        
        // Load Machine Code (Simplified RISC-V formatting)
        // format: func7 (7) | rs2 (5) | rs1 (5) | func3 (3) | rd (5) | opcode (7)
        
        // Inst 0: Integer ADD (R3 = R1 + R2) -> 10 + 20 = 30
        dut.inst_mem[0] = {7'd0, 5'd2, 5'd1, 3'd0, 5'd3, OPC_ALU};
        
        // Inst 1: FPU Op (R4 = R1 fpu_op R2) 
        dut.inst_mem[1] = {7'd0, 5'd2, 5'd1, 3'd0, 5'd4, OPC_FPU};
        
        // Inst 2: NOP
        dut.inst_mem[2] = {32'd0};

        // Reset Sequence
        rst_n = 0;
        #20 rst_n = 1;

        // Wait for pipeline to flush
        #100;

        // Display Results
        $display("--- Execution Results ---");
        $display("R1 (Input 1): %0d", dut.reg_file[1]);
        $display("R2 (Input 2): %0d", dut.reg_file[2]);
        $display("R3 (ALU Out) : %0d (Expected 30)", dut.reg_file[3]);
        $display("R4 (FPU Out) : %0d", dut.reg_file[4]);
        $display("-------------------------");
        
        $finish;
    end
endmodule