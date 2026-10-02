module operand_mem #(
    parameter TN = 4,
    parameter TK = 8,
    parameter MAXM = 16,
    parameter MAXN = 16,
    parameter MAXK = 32
)(
    input clk,

    input wr_a_en,
    input [$clog2(MAXM)-1:0] wr_a_row,
    input [$clog2(MAXK)-1:0] wr_a_col,
    input signed [7:0] wr_a_data,

    input wr_b_en,
    input [$clog2(MAXK)-1:0] wr_b_row,
    input [$clog2(MAXN)-1:0] wr_b_col,
    input signed [7:0] wr_b_data,

    input [$clog2(MAXM+1)-1:0] m_size,
    input [$clog2(MAXN+1)-1:0] n_size,
    input [$clog2(MAXK+1)-1:0] k_size,

    input [$clog2(MAXM+1)-1:0] t_row_idx,
    input [$clog2(MAXN+1)-1:0] t_col_idx,
    input [$clog2(MAXK+1)-1:0] t_k_idx,
    input [((TK>1)?$clog2(TK):1)-1:0] k_pos,

    output reg signed [8*TN-1:0] a_vec,
    output reg signed [8*TN-1:0] b_vec
);
    reg signed [7:0] mem_a [0:MAXM-1][0:MAXK-1];
    reg signed [7:0] mem_b [0:MAXK-1][0:MAXN-1];
    
    wire [$clog2(MAXM)-1:0] row0;
    wire [$clog2(MAXN)-1:0] col0;
    wire [$clog2(MAXK)-1:0] k0;

    always @(posedge clk) begin
        if (wr_a_en) 
            mem_a[wr_a_row][wr_a_col] <= wr_a_data;
        if (wr_b_en) 
            mem_b[wr_b_row][wr_b_col] <= wr_b_data;
    end
    
    assign row0 = t_row_idx * TN;
    assign col0 = t_col_idx * TN;
    assign k0 = t_k_idx * TK + k_pos;

    integer i;
    always @(*) begin
        a_vec = {8*TN{1'b0}};
        b_vec = {8*TN{1'b0}};
        for (i = 0; i < TN; i = i + 1) begin
            if ((row0 + i) < m_size && k0 < k_size) 
                a_vec[8*i +: 8] = mem_a[row0 + i][k0];
            if (k0 < k_size && (col0 + i) < n_size) 
                b_vec[8*i +: 8] = mem_b[k0][col0 + i];
        end
    end
endmodule
