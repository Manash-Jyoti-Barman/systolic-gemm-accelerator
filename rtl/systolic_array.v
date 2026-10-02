module systolic_array #(parameter N = 4) (
    input clk,
    input rst_n,
    input clr_acc,
    input enable,
    input signed [8*N-1:0] a_in,
    input signed [8*N-1:0] b_in,
    output signed [32*N*N-1:0] c_out
    );  
    wire signed [7:0] a_vec[0:N-1];
    wire signed [7:0] b_vec[0:N-1];
    
    wire signed [7:0] a_pipe[0:(N*N)-1], b_pipe[0:(N*N)-1];
    wire signed [7:0] pe_a_in[0:(N*N)-1], pe_b_in[0:(N*N)-1];
    
    genvar k;
    generate
        for(k=0; k<N; k=k+1) begin : INPUT
            assign a_vec[k] = a_in[8*k+:8];
            assign b_vec[k] = b_in[8*k+:8];
        end
    endgenerate
    
    genvar i, j;
    generate
        for(i=0; i<N; i=i+1) begin : ROW
            for(j=0; j<N; j=j+1) begin :COL
                //B input routing
                if(i==0) begin
                    assign pe_b_in[i*N + j] = b_vec[j];
                end
                else begin
                    assign pe_b_in[i*N + j] = b_pipe[(i-1)*N + j];
                end  
                //A input routing    
                if(j==0) begin
                    assign pe_a_in[i*N + j] = a_vec[i];
                end
                else begin
                    assign pe_a_in[i*N + j] = a_pipe[i*N + (j-1)];
                end 
                //PE instantiation    
                PE u_pe(.clk(clk), .rst_n(rst_n), .clr_acc(clr_acc), .enable(enable), .a_in(pe_a_in[i*N + j]), .b_in(pe_b_in[i*N + j]), .a_out(a_pipe[i*N + j]), .b_out(b_pipe[i*N + j]), .acc_out(c_out[32*(i*N+j) +: 32]));
            end
        end
    endgenerate
endmodule
