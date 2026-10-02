module result_mem #(
    parameter TN = 4,
    parameter MAXM = 16,
    parameter MAXN = 16
    )(
    input clk,
    input result_wr_en,
    input [$clog2(MAXM+1)-1:0] t_row_idx,
    input [$clog2(MAXN+1)-1:0] t_col_idx,
    input [$clog2(MAXM+1)-1:0] m_size,
    input [$clog2(MAXN+1)-1:0] n_size,
    input signed [32*TN*TN-1:0] acc_in,
    input [$clog2(MAXM)-1:0] rd_row,
    input [$clog2(MAXN)-1:0] rd_col,
    output reg signed [31:0] rd_data
);

    reg signed [31:0] mem_c [0:MAXM-1][0:MAXN-1];
    wire [$clog2(MAXM)-1:0] row0;
    wire [$clog2(MAXN)-1:0] col0;

    assign row0 = t_row_idx * TN;
    assign col0 = t_col_idx * TN;

    integer i, j;
    always @(posedge clk) begin
        if (result_wr_en) begin
            for (i = 0; i < TN; i = i + 1)
                for (j = 0; j < TN; j = j + 1)
                    if (((row0 + i) < m_size) && ((col0 + j) < n_size))
                        mem_c[row0 + i][col0 + j]
                            <= acc_in[32*(i*TN + j) +: 32];
        end
    end

    always @(posedge clk) begin
        rd_data <= mem_c[rd_row][rd_col];
    end

endmodule
