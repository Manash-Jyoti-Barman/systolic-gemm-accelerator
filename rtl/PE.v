module PE(
    input clk,
    input rst_n,
    input clr_acc,
    input enable,
    input signed [7:0] a_in,
    input signed [7:0] b_in,
    output signed [31:0] acc_out,
    output signed [7:0] a_out,
    output signed [7:0] b_out
    );
    reg signed [7:0] regA, regB;
    reg signed [15:0] prod;
    reg valid;
    reg signed [31:0] ACC;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regA <= 8'sd0;
            regB <= 8'sd0;
            prod <= 16'sd0; 
            valid  <= 1'b0;  
            ACC <= 32'sd0;
        end
        else if (clr_acc) begin
            regA <= 8'sd0;  
            regB <= 8'sd0;
            prod <= 16'sd0; 
            valid  <= 1'b0;  
            ACC <= 32'sd0;
        end
        else begin
            valid <= enable;
            if (enable) begin
                regA <= a_in;
                regB <= b_in;
                prod <= a_in * b_in;
            end
            if (valid) ACC <= ACC + prod;
        end
    end

    assign a_out = regA;
    assign b_out = regB;
    assign acc_out = ACC;
endmodule
