`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2022 14:57:51
// Design Name: 
// Module Name: viterbi_enc
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


module viterbi_enc #(parameter p_size_polinom = 3, parameter p_polinom_0 = 3'b111, parameter p_polinom_1 = 3'b101, parameter p_defoult_state = 3'b000)(
    i_clk,
    i_reset,
    i_data,
    i_valid,
    o_data,
    o_valid
    );

    input                           i_clk;
    input                           i_reset;
    input                           i_data;
    input                           i_valid;
    output  [1:0]                   o_data;
    output                          o_valid;

    reg     [p_size_polinom-1:0]    r_shift = p_defoult_state;
    reg                             r_ovalid = 0;
    reg     [1:0]                   r_odata;

    wire    [p_size_polinom-1:0]    w_shift = {r_shift, i_data};
    wire    [p_size_polinom-1:0]    w_p0 = w_shift & p_polinom_0;
    wire    [p_size_polinom-1:0]    w_p1 = w_shift & p_polinom_1;

    assign  o_data = r_odata;
    assign  o_valid = r_ovalid;

    always @(posedge i_clk) begin : a_reg_shift;
        if(i_reset)         r_shift <= p_defoult_state;
        else if(i_valid)    r_shift <= w_shift;
    end

    always @(posedge i_clk) begin
        r_odata[0] <= ^w_p0;
        r_odata[1] <= ^w_p1;
    end

    always @(posedge i_clk) begin : a_valid
        if(i_reset)         r_ovalid <= 0;
        else                r_ovalid <= i_valid;
    end

    
endmodule
