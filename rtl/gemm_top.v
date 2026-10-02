module gemm_top #(
    parameter TN = 4,
    parameter TK = 8,
    parameter MAXM = 16,
    parameter MAXN = 16,
    parameter MAXK = 32
)(
    input clk,
    input rst_n,
    input config_start,
    input [$clog2(MAXM+1)-1:0] config_m,
    input [$clog2(MAXN+1)-1:0] config_n,
    input [$clog2(MAXK+1)-1:0] config_k,

    input wr_a_en,
    input [$clog2(MAXM)-1:0] wr_a_row,
    input [$clog2(MAXK)-1:0] wr_a_col,
    input signed [7:0] wr_a_data,

    input wr_b_en,
    input [$clog2(MAXK)-1:0] wr_b_row,
    input [$clog2(MAXN)-1:0] wr_b_col,
    input signed [7:0] wr_b_data,

    input [$clog2(MAXM)-1:0] rd_c_row,
    input [$clog2(MAXN)-1:0] rd_c_col,
    output signed [31:0] rd_c_data,
    output busy,
    output done
);

    localparam K_POS_WIDTH = (TK > 1) ? $clog2(TK) : 1;
    localparam CORE_SEL_WIDTH = (TN*TN > 1) ? $clog2(TN*TN) : 1;
    
    wire [$clog2(MAXM+1)-1:0] m_size;
    wire [$clog2(MAXN+1)-1:0] n_size;
    wire [$clog2(MAXK+1)-1:0] k_size;
    wire [$clog2(MAXM+1)-1:0] t_row_idx;
    wire [$clog2(MAXN+1)-1:0] t_col_idx;
    wire [$clog2(MAXK+1)-1:0] t_k_idx;
    wire [K_POS_WIDTH-1:0] k_pos;
    wire acc_en;
    wire acc_first;
    wire result_wr_en;
    wire core_start;
    wire core_wr_en;
    wire core_busy;
    wire core_done;
    wire [K_POS_WIDTH-1:0] core_wr_addr;
    wire signed [8*TN-1:0] a_vec;
    wire signed [8*TN-1:0] b_vec;
    wire signed [32*TN*TN-1:0] core_c_out;
    wire signed [32*TN*TN-1:0] acc_out;

    gemm_sequencer #(.TN(TN), .TK(TK), .MAXM(MAXM), .MAXN(MAXN), .MAXK(MAXK)) u_sequencer (.clk(clk), .rst_n(rst_n), .config_start(config_start), .config_m(config_m), .config_n(config_n), .config_k(config_k), .core_busy(core_busy), .core_done(core_done), .core_start(core_start), .core_wr_en(core_wr_en), .core_wr_addr(core_wr_addr), .m_size(m_size), .n_size(n_size), .k_size(k_size), .t_row_idx(t_row_idx), .t_col_idx(t_col_idx), .t_k_idx(t_k_idx), .k_pos(k_pos), .acc_en(acc_en), .acc_first(acc_first), .result_wr_en(result_wr_en), .busy(busy), .done(done));

    operand_mem #(.TN(TN), .TK(TK), .MAXM(MAXM), .MAXN(MAXN), .MAXK(MAXK)) u_operand_mem (.clk(clk), .wr_a_en(wr_a_en), .wr_a_row(wr_a_row), .wr_a_col(wr_a_col), .wr_a_data(wr_a_data), .wr_b_en(wr_b_en), .wr_b_row(wr_b_row), .wr_b_col(wr_b_col), .wr_b_data(wr_b_data), .m_size(m_size), .n_size(n_size), .k_size(k_size), .t_row_idx(t_row_idx), .t_col_idx(t_col_idx), .t_k_idx(t_k_idx), .k_pos(k_pos), .a_vec(a_vec), .b_vec(b_vec));

    top_systolic #(.N(TN), .K(TK)) u_core (.clk(clk), .rst_n(rst_n), .start(core_start), .wr_en(core_wr_en), .wr_addr(core_wr_addr), .wr_a_data(a_vec), .wr_b_data(b_vec), .c_sel({CORE_SEL_WIDTH{1'b0}}), .c_elem(), .c_out(core_c_out), .busy(core_busy), .done(core_done));

    tile_accumulator #(.TN(TN)) u_tile_accumulator (.clk(clk), .rst_n(rst_n), .acc_en(acc_en), .acc_first(acc_first), .core_c_out(core_c_out), .acc_out(acc_out));

    result_mem #(.TN(TN), .MAXM(MAXM), .MAXN(MAXN)) u_result_mem (.clk(clk), .result_wr_en(result_wr_en), .t_row_idx(t_row_idx), .t_col_idx(t_col_idx), .m_size(m_size), .n_size(n_size), .acc_in(acc_out), .rd_row(rd_c_row), .rd_col(rd_c_col), .rd_data(rd_c_data));

endmodule
