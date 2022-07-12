`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2022 14:57:51
// Design Name: 
// Module Name: viterbi_dec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module viterbi_dec #(parameter p_size_polinom = 3, parameter p_polinom_0 = 3'b111, parameter p_polinom_1 = 3'b101, parameter p_defoult_state = 3'b000)(
    i_clk,
    i_reset,
    i_data,
    i_valid,
    o_data,
    o_valid,
    o_error,
    o_data_d1,
    o_valid_d1
    );

    input i_clk;
    input i_reset;
    input [1:0] i_data;
    input [1:0] i_valid;
    output o_data;
    output o_valid;
    output o_error;
    output o_data_d1;
    output o_valid_d1;


    localparam p_defoult_in_0_0 = ^({p_defoult_state, 1'b0} & p_polinom_0);
    localparam p_defoult_in_0_1 = ^({p_defoult_state, 1'b0} & p_polinom_1);
    localparam p_defoult_in_1_0 = ^({p_defoult_state, 1'b1} & p_polinom_0);
    localparam p_defoult_in_1_1 = ^({p_defoult_state, 1'b1} & p_polinom_1);

    localparam p_defoult_in_00_0 = ^({p_defoult_state, 1'b00} & p_polinom_0);
    localparam p_defoult_in_00_1 = ^({p_defoult_state, 1'b00} & p_polinom_1);
    localparam p_defoult_in_01_0 = ^({p_defoult_state, 1'b01} & p_polinom_0);
    localparam p_defoult_in_01_1 = ^({p_defoult_state, 1'b01} & p_polinom_1);
    localparam p_defoult_in_10_0 = ^({p_defoult_state, 1'b10} & p_polinom_0);
    localparam p_defoult_in_10_1 = ^({p_defoult_state, 1'b10} & p_polinom_1);
    localparam p_defoult_in_11_0 = ^({p_defoult_state, 1'b11} & p_polinom_0);
    localparam p_defoult_in_11_1 = ^({p_defoult_state, 1'b11} & p_polinom_1);


    wire    [1:0]                   w_idata = i_data & i_valid;
    reg                             r_odata = 1'b0;
    reg                             r_valid = 1'b0;

    //data decoding after find error
    reg                             r_odata_d1 = 1'b0;
    reg                             r_valid_d1 = 1'b0;
    reg     [p_size_polinom-1:0]    r_shift_in = p_defoult_state;

    // code data if input 0 and 1
    reg     [1:0]                   r_mod_in_0 = {p_defoult_in_0_1, p_defoult_in_0_0};
    reg     [1:0]                   r_mod_in_1 = {p_defoult_in_1_1, p_defoult_in_1_0};

    // shift data if input 0 and 1
    wire    [p_size_polinom-1:0]    w_shift_in_0 = {r_shift_in, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_1 = {r_shift_in, 1'b1};
    wire    [p_size_polinom-1:0]    w_shift_in_00 = {r_shift_in, 1'b0, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_01 = {r_shift_in, 1'b0, 1'b1};
    wire    [p_size_polinom-1:0]    w_shift_in_10 = {r_shift_in, 1'b1, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_11 = {r_shift_in, 1'b1, 1'b1};

    //fix erro reg
    reg                             r_flag_error = 0;
    // code data if input 00 01 10 11
    reg     [1:0]                   r_mod_in_00 = {p_defoult_in_00_1, p_defoult_in_00_0};
    reg     [1:0]                   r_mod_in_01 = {p_defoult_in_01_1, p_defoult_in_01_0};
    reg     [1:0]                   r_mod_in_10 = {p_defoult_in_10_1, p_defoult_in_10_0};
    reg     [1:0]                   r_mod_in_11 = {p_defoult_in_11_1, p_defoult_in_11_0};

    // shift data if input 000 to 111
    wire    [p_size_polinom-1:0]    w_shift_in_000 = {r_shift_in, 1'b0, 1'b0, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_001 = {r_shift_in, 1'b0, 1'b0, 1'b1};
    wire    [p_size_polinom-1:0]    w_shift_in_010 = {r_shift_in, 1'b0, 1'b1, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_011 = {r_shift_in, 1'b0, 1'b1, 1'b1};
    wire    [p_size_polinom-1:0]    w_shift_in_100 = {r_shift_in, 1'b1, 1'b0, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_101 = {r_shift_in, 1'b1, 1'b0, 1'b1};
    wire    [p_size_polinom-1:0]    w_shift_in_110 = {r_shift_in, 1'b1, 1'b1, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_111 = {r_shift_in, 1'b1, 1'b1, 1'b1};


    /********************************************************************************/
    /* Assign */
    /********************************************************************************/
     
    assign o_data           = r_odata;
    assign o_valid          = r_valid;
    assign o_data_d1        = r_odata_d1;
    assign o_valid_d1       = r_valid_d1;
    assign o_error          = r_flag_error;

    /********************************************************************************/
    /* END Assign */
    /********************************************************************************/

    always @(posedge i_clk) begin
        if(i_reset)
        begin
            r_mod_in_0 <= {p_defoult_in_0_1, p_defoult_in_0_0};
            r_mod_in_1 <= {p_defoult_in_1_1, p_defoult_in_1_0};
        end
        else
        begin
            if(i_valid && !r_flag_error)
            begin
                if(w_idata == (r_mod_in_1 & i_valid))
                begin
                    r_shift_in <= w_shift_in_1;
                    r_mod_in_0[0] <= ^(w_shift_in_10 & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_10 & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_11 & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_11 & p_polinom_1);
                    r_odata <= 1;
                end
                else if(w_idata == (r_mod_in_0 & i_valid))
                begin
                    r_shift_in <= w_shift_in_0;
                    r_mod_in_0[0] <= ^(w_shift_in_00 & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_00 & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_01 & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_01 & p_polinom_1);
                    r_odata <= 0;
                end
                else 
                begin : _find_error
                    r_flag_error <= 1'b1;
                    r_mod_in_00[0] <= ^(w_shift_in_00 & p_polinom_0);
                    r_mod_in_00[1] <= ^(w_shift_in_00 & p_polinom_1);
                    r_mod_in_01[0] <= ^(w_shift_in_01 & p_polinom_0);
                    r_mod_in_01[1] <= ^(w_shift_in_01 & p_polinom_1);
                    r_mod_in_10[0] <= ^(w_shift_in_10 & p_polinom_0);
                    r_mod_in_10[1] <= ^(w_shift_in_10 & p_polinom_1);
                    r_mod_in_11[0] <= ^(w_shift_in_11 & p_polinom_0);
                    r_mod_in_11[1] <= ^(w_shift_in_11 & p_polinom_1);
                end
            end
            else if(i_valid && r_flag_error)
            begin : _fix_error
                r_flag_error <= 1'b0;
                if(w_idata == (r_mod_in_11 & i_valid))
                begin
                    r_shift_in <= w_shift_in_11;
                    r_odata <= 1;
                    r_odata_d1 <= 1;
                    r_mod_in_0[0] <= ^(w_shift_in_110 & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_110 & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_111 & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_111 & p_polinom_1);
                end
                else if(w_idata == (r_mod_in_10 & i_valid))
                begin
                    r_shift_in <= w_shift_in_10;
                    r_odata <= 0;
                    r_odata_d1 <= 1;
                    r_mod_in_0[0] <= ^(w_shift_in_100 & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_100 & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_101 & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_101 & p_polinom_1);
                end
                else if(w_idata == (r_mod_in_01 & i_valid))
                begin
                    r_shift_in <= w_shift_in_01;
                    r_odata <= 1;
                    r_odata_d1 <= 0;
                    r_mod_in_0[0] <= ^(w_shift_in_010 & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_010 & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_011 & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_011 & p_polinom_1);
                end
                else
                begin
                    r_shift_in <= w_shift_in_00;
                    r_odata <= 0;
                    r_odata_d1 <= 0;
                    r_mod_in_0[0] <= ^(w_shift_in_000 & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_000 & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_001 & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_001 & p_polinom_1);
                end
            end
        end
    end

    always @(posedge i_clk) begin
        if(i_reset)
        begin
            r_valid <= 0;
        end
        else
        begin
            if(i_valid)
            begin
                if(w_idata == (r_mod_in_0 & i_valid))           r_valid <= 1;
                else if(w_idata == (r_mod_in_1 & i_valid))      r_valid <= 1;
                else if(r_flag_error)                           r_valid <= 1;
                else                                            r_valid <= 0;
            end
            else    r_valid <= 0;
        end
    end

    always @(posedge i_clk) begin
        if(i_reset)                                 r_valid_d1 <= 0;
        else if(i_valid && r_flag_error)            r_valid_d1 <= 1;    
             else                                   r_valid_d1 <= 0;
    end




endmodule
