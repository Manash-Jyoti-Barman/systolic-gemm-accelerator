module top_systolic #(
    parameter N  = 4,
    parameter K  = 8,
    parameter ADDR_WIDTH = (K > 1) ? $clog2(K) : 1,
    parameter SW = $clog2(N*N)
    )(
    input clk,
    input rst_n,
    input start,
    input wr_en,
    input [ADDR_WIDTH-1:0] wr_addr,
    input signed [8*N-1:0] wr_a_data,
    input signed [8*N-1:0] wr_b_data,
    input [SW-1:0] c_sel,
    output signed [31:0] c_elem,
    output signed [32*N*N-1:0] c_out,      
    output busy,
    output done
    );
    wire signed [8*N-1:0] a_data_out, b_data_out, a_aligned, b_aligned, a_gated, b_gated;
    wire [ADDR_WIDTH-1:0] rd_addr;
    wire data_valid, run_en, clr_acc;

    reg load_bank, rd_bank;
    wire start_acc; 
    assign start_acc = start & ~busy;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin 
            load_bank <= 1'b0; 
            rd_bank <= 1'b0; end
        else if (start_acc) begin 
            rd_bank <= load_bank; 
            load_bank <= ~load_bank; end
    end

    assign a_gated = data_valid ? a_data_out : {8*N{1'b0}};
    assign b_gated = data_valid ? b_data_out : {8*N{1'b0}};
    assign c_elem  = c_out[32*c_sel +: 32];

    controller #(.N(N), .K(K)) u_ctrl(.clk(clk), .rst_n(rst_n), .start(start), .rd_addr(rd_addr), .data_valid(data_valid), .run_en(run_en), .clr_acc(clr_acc), .busy(busy), .done(done));
    matrix_buffer #(.N(N), .K(K)) u_buf(.clk(clk), .wr_en(wr_en), .wr_bank(load_bank), .wr_addr(wr_addr), .wr_a_data(wr_a_data), .wr_b_data(wr_b_data), .rd_bank(rd_bank), .rd_addr(rd_addr), .a_data_out(a_data_out), .b_data_out(b_data_out));
    input_skewer #(.N(N)) u_align(.clk(clk), .rst_n(rst_n), .enable(run_en), .a_in(a_gated), .b_in(b_gated), .a_out(a_aligned), .b_out(b_aligned));
    systolic_array #(.N(N)) u_array(.clk(clk), .rst_n(rst_n), .clr_acc(clr_acc), .enable(run_en), .a_in(a_aligned), .b_in(b_aligned), .c_out(c_out));
endmodule
