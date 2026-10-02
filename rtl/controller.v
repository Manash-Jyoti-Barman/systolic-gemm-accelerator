module controller #(
    parameter N = 4,
    parameter K = 8,
    parameter ADDR_WIDTH = (K > 1) ? $clog2(K) : 1
    )(
    input clk,
    input rst_n,
    input start,
    output [ADDR_WIDTH-1:0] rd_addr,
    output reg data_valid,
    output reg run_en,   
    output clr_acc,
    output busy,
    output reg done
    );
    localparam TOTAL = K + 2*N;
    localparam COUNT_WIDTH = $clog2(TOTAL + 1);
    localparam IDLE = 2'd0, CLEAR = 2'd1, RUN = 2'd2;

    reg [1:0] PS, NS;
    reg [COUNT_WIDTH-1:0] count;
	
    wire read_request, run_window;
    
    always @(posedge clk or negedge rst_n)
        if (!rst_n) 
            PS <= IDLE; 
        else 
            PS <= NS;

    always @(*) begin
        case (PS)
            IDLE:
                NS = start ? CLEAR : IDLE;
            CLEAR:
                NS = RUN;
            RUN:
                NS = (count == TOTAL-1) ? IDLE : RUN;
            default:
                NS = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            count <= {COUNT_WIDTH{1'b0}};
        else if (PS == RUN && count != TOTAL-1)
            count <= count + 1'b1;
        else
            count <= {COUNT_WIDTH{1'b0}};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_valid <= 1'b0;
            run_en <= 1'b0;
            done <= 1'b0;
        end else begin
            data_valid <= read_request;
            run_en<= run_window;
            if (PS == IDLE && start)
                done <= 1'b0;
            else if (PS == RUN && count == TOTAL-1)
                done <= 1'b1;
        end
    end
    assign read_request = (PS == RUN) && (count < K);
    assign run_window = (PS == RUN) && (count < K + 2*N - 2);
    assign clr_acc = (PS == CLEAR);
    assign busy = (PS != IDLE);
    assign rd_addr = count[ADDR_WIDTH-1:0];
endmodule
