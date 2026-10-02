module gemm_sequencer #(
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
    input core_busy,
    input core_done,
    output reg core_start,
    output core_wr_en,
    output [((TK>1)?$clog2(TK):1)-1:0] core_wr_addr,
    output reg [$clog2(MAXM+1)-1:0] m_size,
    output reg [$clog2(MAXN+1)-1:0] n_size,
    output reg [$clog2(MAXK+1)-1:0] k_size,
    output reg [$clog2(MAXM+1)-1:0] t_row_idx,
    output reg [$clog2(MAXN+1)-1:0] t_col_idx,
    output reg [$clog2(MAXK+1)-1:0] t_k_idx,
    output reg [((TK>1)?$clog2(TK):1)-1:0] k_pos,
    output reg acc_en,
    output acc_first,
    output reg result_wr_en,
    output busy,
    output reg done
);

    localparam K_POS_WIDTH = (TK > 1) ? $clog2(TK) : 1;

    localparam IDLE = 3'd0;
    localparam LOAD = 3'd1;
    localparam START = 3'd2;
    localparam WAITBUSY = 3'd3;
    localparam WAIT = 3'd4;
    localparam ACCUM = 3'd5;
    localparam WRITEC = 3'd6;

    reg [2:0] PS, NS;

    reg [$clog2(MAXM+1)-1:0] num_tm;
    reg [$clog2(MAXN+1)-1:0] num_tn;
    reg [$clog2(MAXK+1)-1:0] num_tk;

    assign busy = (PS != IDLE);
    assign core_wr_addr = k_pos;
    assign core_wr_en   = (PS == LOAD);
    assign acc_first = (t_k_idx == 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PS <= IDLE;
        else
            PS <= NS;
    end

    always @(*) begin
        NS = PS;
        case (PS)
            IDLE: begin
                if (config_start)
                    NS = LOAD;
            end

            LOAD: begin
                if (k_pos == TK-1)
                    NS = START;
            end

            START: begin
                NS = WAITBUSY;
            end

            WAITBUSY: begin
                if (core_busy)
                    NS = WAIT;
            end

            WAIT: begin
                if (core_done)
                    NS = ACCUM;
            end

            ACCUM: begin
                if (t_k_idx == num_tk-1)
                    NS = WRITEC;
                else
                    NS = LOAD;
            end

            WRITEC: begin
                if (t_col_idx == num_tn-1) begin
                    if (t_row_idx == num_tm-1)
                        NS = IDLE;
                    else
                        NS = LOAD;
                end
                else begin
                    NS = LOAD;
                end
            end

            default: begin
                NS = IDLE;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            core_start <= 1'b0;
            acc_en <= 1'b0;
            result_wr_en <= 1'b0;
            m_size <= 'b0;
            n_size <= 'b0;
            k_size <= 'b0;
            t_row_idx <= 'b0;
            t_col_idx <= 'b0;
            t_k_idx <= 'b0;
            k_pos <= 'b0;
            num_tm <= 'b0;
            num_tn <= 'b0;
            num_tk <= 'b0;
            done <= 1'b0;
        end
        else begin
            core_start <= 1'b0;
            acc_en <= 1'b0;
            result_wr_en <= 1'b0;
            case (PS)

                IDLE: begin
                    if (config_start) begin
                        m_size <= config_m;
                        n_size <= config_n;
                        k_size <= config_k;
                        num_tm <= (config_m + TN - 1) / TN;
                        num_tn <= (config_n + TN - 1) / TN;
                        num_tk <= (config_k + TK - 1) / TK;
                        t_row_idx <= 'b0;
                        t_col_idx <= 'b0;
                        t_k_idx <= 'b0;
                        k_pos <= 'b0;
                        done <= 1'b0;
                    end
                end

                LOAD: begin
                    if (k_pos != TK-1)
                        k_pos <= k_pos + 1'b1;
                end

                START: begin
                    core_start <= 1'b1;
                end

                WAITBUSY: begin
                end

                WAIT: begin
                    if (core_done)
                        acc_en <= 1'b1;
                end

                ACCUM: begin
                    if (t_k_idx == num_tk-1) begin
                        result_wr_en <= 1'b1;
                    end
                    else begin
                        t_k_idx <= t_k_idx + 1'b1;
                        k_pos <= 'b0;
                    end
                end

                WRITEC: begin
                    t_k_idx <= 'b0;
                    k_pos <= 'b0;

                    if (t_col_idx == num_tn-1) begin
                        t_col_idx <= 'b0;

                        if (t_row_idx == num_tm-1) begin
                            done <= 1'b1;
                        end
                        else begin
                            t_row_idx <= t_row_idx + 1'b1;
                        end
                    end
                    else begin
                        t_col_idx <= t_col_idx + 1'b1;
                    end
                end
                default: begin
                end

            endcase
        end
    end
endmodule
