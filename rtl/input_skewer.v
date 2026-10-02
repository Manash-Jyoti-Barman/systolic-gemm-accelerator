module input_skewer #(parameter N=4)(
    input clk,
    input rst_n,
    input enable,
    input signed [8*N-1:0] a_in,
    input signed [8*N-1:0] b_in,
    output signed [8*N-1:0] a_out,
    output signed [8*N-1:0] b_out
    );
    wire signed [7:0] a_vec[0:N-1];
    wire signed [7:0] b_vec[0:N-1];
    
    reg signed [7:0] delay_A[0:N-1][0:N-1];
    reg signed [7:0] delay_B[0:N-1][0:N-1];
    
    genvar k;
    generate
        for(k=0; k<N; k=k+1) begin : INPUT
            assign a_vec[k] = a_in[8*k+:8];
            assign b_vec[k] = b_in[8*k+:8];
        end
    endgenerate
    
    genvar i,j;
    generate
        for(i=0; i<N; i=i+1) begin : A_LANE
            if(i==0)
                assign a_out[8*i+:8] = a_vec[i];
            else begin
                    for(j=0; j<i; j=j+1) begin : A_STAGE
                        if(j==0) begin
                            always@(posedge clk or negedge rst_n) begin
                                if(!rst_n)
                                    delay_A[i][j] <= 8'sd0;
                                else if(enable)
                                    delay_A[i][j] <= a_vec[i];
                            end
                        end
                        else begin
                            always@(posedge clk or negedge rst_n) begin
                                if(!rst_n)
                                    delay_A[i][j] <= 8'sd0;
                                else if(enable)
                                    delay_A[i][j] <= delay_A[i][j-1];
                            end
                        end
                    end
                assign a_out[8*i+:8] = delay_A[i][i-1];
            end  
        end
    endgenerate
    
    genvar m,n;
    generate
        for(m=0; m<N; m=m+1) begin : B_LANE
            if(m==0)
                assign b_out[8*m+:8] = b_vec[m];
            else begin
                    for(n=0; n<m; n=n+1) begin : B_STAGE
                        if(n==0) begin
                            always@(posedge clk or negedge rst_n) begin
                                if(!rst_n)
                                    delay_B[m][n] <= 8'sd0;
                                else if(enable)
                                    delay_B[m][n] <= b_vec[m];
                            end
                        end
                        else begin
                            always@(posedge clk or negedge rst_n) begin
                                if(!rst_n)
                                    delay_B[m][n] <= 8'sd0;
                                else if(enable)
                                    delay_B[m][n] <= delay_B[m][n-1];
                            end
                        end
                    end
                assign b_out[8*m+:8] = delay_B[m][m-1];
            end 
        end
    endgenerate
endmodule
