module tile_accumulator #(
    parameter TN = 4
    )(
    input clk,
    input rst_n,
    input acc_en,
    input acc_first,
    input signed [32*TN*TN-1:0] core_c_out,
    output signed [32*TN*TN-1:0] acc_out
);
    reg signed [31:0] acc [0:TN-1][0:TN-1];
    integer i, j;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < TN; i = i + 1)
                for (j = 0; j < TN; j = j + 1)
                    acc[i][j] <= 32'sd0;
        end
        else if (acc_en) begin
            for (i = 0; i < TN; i = i + 1)
                for (j = 0; j < TN; j = j + 1)
                    acc[i][j] <= acc_first ? core_c_out[32*(i*TN+j) +: 32] : acc[i][j] + core_c_out[32*(i*TN+j) +: 32];
        end
    end

    genvar i_out, j_out;
    generate
        for (i_out = 0; i_out < TN; i_out = i_out + 1)
            for (j_out = 0; j_out < TN; j_out = j_out + 1)
                assign acc_out[32*(i_out*TN+j_out) +: 32] = acc[i_out][j_out];
    endgenerate

endmodule
