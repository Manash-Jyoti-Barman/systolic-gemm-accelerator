`timescale 1ns / 1ps

module tb_gemm_top;
    parameter TN = 4;
    parameter TK = 8;
    parameter MAXM = 16;
    parameter MAXN = 16;
    parameter MAXK = 32;

    reg clk;
    reg rst_n;
    reg config_start;
    reg [$clog2(MAXM+1)-1:0] config_m;
    reg [$clog2(MAXN+1)-1:0] config_n;
    reg [$clog2(MAXK+1)-1:0] config_k;
    reg wr_a_en;
    reg [$clog2(MAXM)-1:0] wr_a_row;
    reg [$clog2(MAXK)-1:0] wr_a_col;
    reg signed [7:0] wr_a_data;
    reg wr_b_en;
    reg [$clog2(MAXK)-1:0] wr_b_row;
    reg [$clog2(MAXN)-1:0] wr_b_col;
    reg signed [7:0] wr_b_data;
    reg [$clog2(MAXM)-1:0] rd_c_row;
    reg [$clog2(MAXN)-1:0] rd_c_col;
    wire signed [31:0] rd_c_data;
    wire busy;
    wire done;

    reg signed [7:0] A [0:10][0:8];
    reg signed [7:0] B [0:8][0:13];
    reg signed [31:0] C_expected [0:10][0:13];
    integer i, j, k;
    integer error_count;
    integer pass_count;

    gemm_top #(.TN(TN), .TK(TK), .MAXM(MAXM), .MAXN(MAXN), .MAXK(MAXK)) dut (.clk(clk), .rst_n(rst_n), .config_start(config_start), .config_m(config_m), .config_n(config_n), .config_k(config_k), .wr_a_en(wr_a_en), .wr_a_row(wr_a_row), .wr_a_col(wr_a_col), .wr_a_data(wr_a_data), .wr_b_en(wr_b_en), .wr_b_row(wr_b_row), .wr_b_col(wr_b_col), .wr_b_data(wr_b_data), .rd_c_row(rd_c_row), .rd_c_col(rd_c_col), .rd_c_data(rd_c_data), .busy(busy), .done(done));

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;

        config_start = 1'b0;
        config_m = 5'd0;
        config_n = 5'd0;
        config_k = 6'd0;

        wr_a_en = 1'b0;
        wr_a_row = 4'd0;
        wr_a_col = 4'd0;
        wr_a_data = 8'sd0;

        wr_b_en = 1'b0;
        wr_b_row = 4'd0;
        wr_b_col = 4'd0;
        wr_b_data = 8'sd0;

        rd_c_row = 4'd0;
        rd_c_col = 4'd0;

        error_count = 0;
        pass_count = 0;

        A[0][0] = 2;  A[0][1] = 1;  A[0][2] = 0;  A[0][3] = -1; A[0][4] = -2; A[0][5] = 2;  A[0][6] = 1;  A[0][7] = 0;  A[0][8] = -1;
        A[1][0] = -1; A[1][1] = 1;  A[1][2] = 2;  A[1][3] = 0;  A[1][4] = -1; A[1][5] = 1;  A[1][6] = 2;  A[1][7] = 0;  A[1][8] = -1;
        A[2][0] = 0;  A[2][1] = -2; A[2][2] = 1;  A[2][3] = 2;  A[2][4] = 0;  A[2][5] = -2; A[2][6] = 1;  A[2][7] = 2;  A[2][8] = 0;
        A[3][0] = 1;  A[3][1] = 0;  A[3][2] = -2; A[3][3] = 1; A[3][4] = 2;  A[3][5] = 1;  A[3][6] = 0;  A[3][7] = -2; A[3][8] = 1;
        A[4][0] = 2;  A[4][1] = 1;  A[4][2] = 0;  A[4][3] = -1; A[4][4] = -2; A[4][5] = 2;  A[4][6] = 1;  A[4][7] = 0;  A[4][8] = -1;
        A[5][0] = -1; A[5][1] = 1;  A[5][2] = 2;  A[5][3] = 0;  A[5][4] = -1; A[5][5] = 1;  A[5][6] = 2;  A[5][7] = 0;  A[5][8] = -1;
        A[6][0] = 0;  A[6][1] = -2; A[6][2] = 1;  A[6][3] = 2;  A[6][4] = 0;  A[6][5] = -2; A[6][6] = 1;  A[6][7] = 2;  A[6][8] = 0;
        A[7][0] = 1;  A[7][1] = 0;  A[7][2] = -2; A[7][3] = 1; A[7][4] = 2;  A[7][5] = 1;  A[7][6] = 0;  A[7][7] = -2; A[7][8] = 1;
        A[8][0] = 2;  A[8][1] = 1;  A[8][2] = 0;  A[8][3] = -1; A[8][4] = -2; A[8][5] = 2;  A[8][6] = 1;  A[8][7] = 0;  A[8][8] = -1;
        A[9][0] = -1; A[9][1] = 1;  A[9][2] = 2;  A[9][3] = 0;  A[9][4] = -1; A[9][5] = 1;  A[9][6] = 2;  A[9][7] = 0;  A[9][8] = -1;
        A[10][0] = 0; A[10][1] = -2; A[10][2] = 1; A[10][3] = 2; A[10][4] = 0; A[10][5] = -2; A[10][6] = 1; A[10][7] = 2; A[10][8] = 0;

        B[0][0] = 1;  B[0][1] = -1; B[0][2] = 0;  B[0][3] = 1;  B[0][4] = 2;  B[0][5] = 1;  B[0][6] = -1; B[0][7] = 0;  B[0][8] = 1;  B[0][9] = 2;  B[0][10] = 1;  B[0][11] = -1; B[0][12] = 0;  B[0][13] = 1;
        B[1][0] = -2; B[1][1] = 0;  B[1][2] = 1;  B[1][3] = 2;  B[1][4] = -1; B[1][5] = -2; B[1][6] = 0;  B[1][7] = 1;  B[1][8] = 2;  B[1][9] = -1; B[1][10] = -2; B[1][11] = 0;  B[1][12] = 1;  B[1][13] = 2;
        B[2][0] = 0;  B[2][1] = 1;  B[2][2] = 2;  B[2][3] = -1; B[2][4] = -2; B[2][5] = 0;  B[2][6] = 1;  B[2][7] = 2;  B[2][8] = -1; B[2][9] = -2; B[2][10] = 0;  B[2][11] = 1;  B[2][12] = 2;  B[2][13] = -1;
        B[3][0] = 2;  B[3][1] = -1; B[3][2] = -2; B[3][3] = 0;  B[3][4] = 1;  B[3][5] = 2;  B[3][6] = -1; B[3][7] = -2; B[3][8] = 0;  B[3][9] = 1;  B[3][10] = 2;  B[3][11] = -1; B[3][12] = -2; B[3][13] = 0;
        B[4][0] = 1;  B[4][1] = 2;  B[4][2] = -1; B[4][3] = -2; B[4][4] = 0;  B[4][5] = 1;  B[4][6] = 2;  B[4][7] = -1; B[4][8] = -2; B[4][9] = 0;  B[4][10] = 1;  B[4][11] = 2;  B[4][12] = -1; B[4][13] = -2;
        B[5][0] = -1; B[5][1] = -2; B[5][2] = 0;  B[5][3] = 1;  B[5][4] = 2;  B[5][5] = -1; B[5][6] = -2; B[5][7] = 0;  B[5][8] = 1;  B[5][9] = 2;  B[5][10] = -1; B[5][11] = -2; B[5][12] = 0;  B[5][13] = 1;
        B[6][0] = 2;  B[6][1] = 0;  B[6][2] = 1;  B[6][3] = 2;  B[6][4] = -1; B[6][5] = -2; B[6][6] = 0;  B[6][7] = 1;  B[6][8] = 2;  B[6][9] = -1; B[6][10] = -2; B[6][11] = 0;  B[6][12] = 1;  B[6][13] = 2;
        B[7][0] = -1; B[7][1] = 0;  B[7][2] = 1;  B[7][3] = 2;  B[7][4] = -1; B[7][5] = -1; B[7][6] = 0;  B[7][7] = 1;  B[7][8] = 2;  B[7][9] = -1; B[7][10] = -1; B[7][11] = 0;  B[7][12] = 1;  B[7][13] = 2;
        B[8][0] = 0;  B[8][1] = 1;  B[8][2] = -1; B[8][3] = 2;  B[8][4] = 0;  B[8][5] = 1;  B[8][6] = -1; B[8][7] = 2;  B[8][8] = 0;  B[8][9] = 1;  B[8][10] = -1; B[8][11] = 2;  B[8][12] = 0;  B[8][13] = 1;

        for (i = 0; i < 11; i = i + 1)
            for (j = 0; j < 14; j = j + 1) begin
                C_expected[i][j] = 0;
                for (k = 0; k < 9; k = k + 1)
                    C_expected[i][j] = C_expected[i][j] + A[i][k] * B[k][j];
            end

        #10 rst_n = 1'b1;

        #2;

        wr_a_en = 1'b1;

        for (i = 0; i < 11; i = i + 1) begin
            for (j = 0; j < 9; j = j + 1) begin
                wr_a_row = i;
                wr_a_col = j;
                wr_a_data = A[i][j];
                #10;
            end
        end

        wr_a_en = 1'b0;

        wr_b_en = 1'b1;

        for (i = 0; i < 9; i = i + 1) begin
            for (j = 0; j < 14; j = j + 1) begin
                wr_b_row = i;
                wr_b_col = j;
                wr_b_data = B[i][j];
                #10;
            end
        end

        wr_b_en = 1'b0;
        config_m = 5'd11;
        config_n = 5'd14;
        config_k = 6'd9;

        #10;
        config_start = 1'b1;

        #10;
        config_start = 1'b0;

        wait(done);

        #20;

        for (i = 0; i < 11; i = i + 1) begin
            for (j = 0; j < 14; j = j + 1) begin
                rd_c_row = i;
                rd_c_col = j;

                #10;

                if (rd_c_data !== C_expected[i][j]) begin
                    error_count = error_count + 1;
                    $display("ERROR C%0d%0d = %0d, expected %0d", i, j, rd_c_data, C_expected[i][j]);
                end
                else begin
                    pass_count = pass_count + 1;
                    $display("C%0d%0d = %0d", i, j, rd_c_data);
                end
            end
        end

        $display("======================================");
        $display("TOTAL TESTS = %0d", pass_count + error_count);
        $display("PASSED      = %0d", pass_count);
        $display("FAILED      = %0d", error_count);
        $display("======================================");

        if (error_count == 0)
            $display("GEMM TEST PASSED");
        else
            $display("GEMM TEST FAILED");

        #20;
        $finish;
    end

    always #5 clk = ~clk;

endmodule
