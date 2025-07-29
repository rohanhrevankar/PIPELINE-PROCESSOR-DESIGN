`timescale 1ns / 1ps

module pipeline_processor (
    input clk,
    input reset
);
    // Instruction opcodes
    localparam ADD  = 4'b0001;
    localparam SUB  = 4'b0010;
    localparam LOAD = 4'b0011;

    // Registers
    reg [15:0] instruction_mem [0:15];
    reg [7:0] register_file [0:15];

    // Pipeline registers
    reg [15:0] IF_ID;
    reg [15:0] ID_EX;
    reg [7:0]  EX_WB_result;
    reg [3:0]  EX_WB_dest;

    // Instruction Fetch
    reg [3:0] PC;
    wire [15:0] instruction = instruction_mem[PC];

    // Decode
    wire [3:0] opcode = IF_ID[15:12];
    wire [3:0] rd     = IF_ID[11:8];
    wire [3:0] rs1    = IF_ID[7:4];
    wire [3:0] rs2    = IF_ID[3:0];
    wire [7:0] reg_data1 = register_file[rs1];
    wire [7:0] reg_data2 = register_file[rs2];

    // Execute
    reg [7:0] alu_result;

    // Writeback
    always @(posedge clk) begin
        if (reset) begin
            PC <= 0;
        end else begin
            // IF Stage
            IF_ID <= instruction;
            PC <= PC + 1;

            // ID to EX Stage
            ID_EX <= IF_ID;

            // EX Stage
            case (ID_EX[15:12])
                ADD:  alu_result <= register_file[ID_EX[7:4]] + register_file[ID_EX[3:0]];
                SUB:  alu_result <= register_file[ID_EX[7:4]] - register_file[ID_EX[3:0]];
                LOAD: alu_result <= {4'b0000, ID_EX[3:0]}; // immediate
                default: alu_result <= 8'h00;
            endcase

            EX_WB_result <= alu_result;
            EX_WB_dest   <= ID_EX[11:8];

            // WB Stage
            register_file[EX_WB_dest] <= EX_WB_result;
        end
    end

    // Initialize instruction memory and registers
    integer i;
    initial begin
        // Preload instructions
        instruction_mem[0] = {ADD, 4'd1, 4'd2, 4'd3};   // R1 = R2 + R3
        instruction_mem[1] = {SUB, 4'd4, 4'd1, 4'd2};   // R4 = R1 - R2
        instruction_mem[2] = {LOAD, 4'd5, 4'd0, 4'd9};  // R5 = 9
        instruction_mem[3] = {ADD, 4'd6, 4'd5, 4'd5};   // R6 = R5 + R5

        for (i = 0; i < 16; i = i + 1) begin
            register_file[i] = i;
        end
    end

endmodule
