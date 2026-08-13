import risc_pkg::*;

module execute_stage (
    input  logic       clk,
    input  id_ex_t     id_ex,
    output ex_mem_t    ex_mem
);
    logic [63:0] int_result;
    logic [63:0] fpu_result;
    
    // LOW POWER: Operand Isolation Signals
    logic [63:0] fpu_rs1_iso, fpu_rs2_iso;
    logic [63:0] int_rs1_iso, int_rs2_iso;
    
    logic is_fpu, is_int;
    
    assign is_fpu = (id_ex.opcode == OPC_FPU);
    assign is_int = (id_ex.opcode == OPC_ALU);

    // Isolate operands to prevent switching activity when block is inactive
    assign fpu_rs1_iso = is_fpu ? id_ex.rs1_data : 64'd0;
    assign fpu_rs2_iso = is_fpu ? id_ex.rs2_data : 64'd0;
    
    assign int_rs1_iso = is_int ? id_ex.rs1_data : 64'd0;
    assign int_rs2_iso = is_int ? id_ex.rs2_data : 64'd0;

    // Basic Integer ALU (Addition only for demo)
    always_comb begin
        int_result = int_rs1_iso + int_rs2_iso; 
    end

    // Behavioral Dummy FPU (Floating Point Addition)
    // In a full project, this would be a multi-stage IEEE-754 adder
    always_comb begin
        if (is_fpu) begin
            // Simplified floating point mock operation for simulation visibility
            fpu_result = fpu_rs1_iso ^ fpu_rs2_iso; // XOR used as placeholder
        end else begin
            fpu_result = 64'd0;
        end
    end

    // Pipeline Register Write
    always_ff @(posedge clk) begin
        ex_mem.rd_addr   <= id_ex.rd_addr;
        ex_mem.reg_write <= (is_int || is_fpu);
        ex_mem.alu_result <= is_fpu ? fpu_result : int_result;
    end
endmodule