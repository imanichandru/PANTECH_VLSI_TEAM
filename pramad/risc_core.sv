import risc_pkg::*;

module risc_core (
    input logic clk,
    input logic rst_n
);
    // Pipeline Registers
    if_id_t  if_id;
    id_ex_t  id_ex;
    ex_mem_t ex_mem;
    mem_wb_t mem_wb;

    // 64-bit Register File
    logic [63:0] reg_file [0:31];
    
    // Instruction Memory (ROM)
    logic [31:0] inst_mem [0:15];
    
    logic [63:0] pc;

    // -----------------------------------------
    // Stage 1: Instruction Fetch (IF)
    // -----------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 64'd0;
            if_id <= '0;
        end else begin
            if_id.inst <= inst_mem[pc[5:2]]; // Word aligned fetch
            if_id.pc   <= pc;
            pc         <= pc + 4;
        end
    end

    // -----------------------------------------
    // Stage 2: Instruction Decode (ID)
    // -----------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_ex <= '0;
        end else begin
            id_ex.pc       <= if_id.pc;
            id_ex.opcode   <= if_id.inst[6:0];
            id_ex.rd_addr  <= if_id.inst[11:7];
            // Decode RS1 and RS2 (Simplified RISC-V formatting)
            id_ex.rs1_data <= reg_file[if_id.inst[19:15]];
            id_ex.rs2_data <= reg_file[if_id.inst[24:20]];
        end
    end

    // -----------------------------------------
    // Stage 3: Execute (EX) - Instantiated
    // -----------------------------------------
    execute_stage u_ex_stage (
        .clk(clk),
        .id_ex(id_ex),
        .ex_mem(ex_mem)
    );

    // -----------------------------------------
    // Stage 4: Memory (MEM) - Passthrough for ALU
    // -----------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_wb <= '0;
        end else begin
            mem_wb.result    <= ex_mem.alu_result;
            mem_wb.rd_addr   <= ex_mem.rd_addr;
            mem_wb.reg_write <= ex_mem.reg_write;
        end
    end

    // -----------------------------------------
    // Stage 5: Write Back (WB)
    // -----------------------------------------
    always_ff @(posedge clk) begin
        if (mem_wb.reg_write && mem_wb.rd_addr != 5'd0) begin
            reg_file[mem_wb.rd_addr] <= mem_wb.result;
        end
    end

endmodule