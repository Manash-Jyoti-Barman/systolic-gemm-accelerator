module matrix_buffer #( 
    parameter N = 4, 
    parameter K = 8, 
    parameter ADDR_WIDTH = (K > 1) ? $clog2(K) : 1
    )(
    input clk,
    input wr_en,
    input wr_bank,
    input [ADDR_WIDTH-1:0] wr_addr,
    input signed [8*N-1:0] wr_a_data,
    input signed [8*N-1:0] wr_b_data,
    input rd_bank,
    input [ADDR_WIDTH-1:0] rd_addr,
    output reg signed [8*N-1:0] a_data_out,
    output reg signed [8*N-1:0] b_data_out
    );
    localparam DEPTH = 2*K;
    reg signed [8*N-1:0] A_mem [0:DEPTH-1];
    reg signed [8*N-1:0] B_mem [0:DEPTH-1];

    wire [31:0] wr_mem_addr = wr_bank * K + wr_addr;
    wire [31:0] rd_mem_addr = rd_bank * K + rd_addr;

    always @(posedge clk) begin
        if (wr_en) begin
            A_mem[wr_mem_addr] <= wr_a_data;
            B_mem[wr_mem_addr] <= wr_b_data;
        end
    end

    always @(posedge clk) begin
        a_data_out <= A_mem[rd_mem_addr];
        b_data_out <= B_mem[rd_mem_addr];
    end
endmodule
