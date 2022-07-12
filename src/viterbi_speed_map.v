`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2022 18:20:27
// Design Name: 
// Module Name: viterbi_speed_map
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


module viterbi_speed_map #(parameter p_auto_pol = 0, parameter p_speed_size = 1, parameter p_speed_pol0 = 1'b1, parameter p_speed_pol1 = 1'b1)(
    i_clk,
    i_reset,
    i_data,
    i_valid,
    i_speed,
    o_data,
    o_valid
    );

    // localparam p_speed_size = $clog2(p_speed_size) + 1;
    
    input i_clk;
    input i_reset;
    input [1:0] i_data;
    input i_valid;
    input [7:0] i_speed;
    output [1:0] o_data;
    output [1:0] o_valid;

    generate 
    if((p_speed_size == 1) && (p_auto_pol == 0)) begin : U_speed_1
        assign o_data = i_data;
        assign o_valid = {2{i_valid}};
    end
    else begin : U_multispeed

        reg [7:0] r_counter = 0;
        reg [1:0] r_odata = 0;
        reg [1:0] r_ovalid = 0;
        reg [p_speed_size-1:0] r_speed_pol0 = p_speed_pol0;
        reg [p_speed_size-1:0] r_speed_pol1 = p_speed_pol1;

        reg [1:0] r_speed_pol = 2'b11;
        reg [1:0] r_speed_nepol = 2'b11;

        wire [7:0] w_speed_to;
        wire [1:0] w_speed_pol;

        assign o_data = r_odata;
        assign o_valid = r_ovalid;
        assign w_speed_to = /*i_speed > p_speed_size ? p_speed_size - 1 : */i_speed - 1;
        if(p_auto_pol == 0)
        begin
            assign w_speed_pol = {r_speed_pol1[0], r_speed_pol0[0]};
        end
        else if(p_auto_pol == 1)
        begin
            assign w_speed_pol = r_speed_pol;
        end
        else 
        begin
            assign w_speed_pol = r_speed_nepol;
        end

        always @(posedge i_clk) begin
            if(i_reset)
            begin
                r_odata <= 0;
                r_ovalid <= 0;
            end
            else 
            begin
                if(i_valid)
                begin
                    r_odata <= i_data & w_speed_pol;
                    r_ovalid <= w_speed_pol;
                end
                else 
                begin
                    r_ovalid <= 0;
                end
            end
        end

        always @(posedge i_clk) begin : a_counter
            if(i_reset)
            begin
                r_counter <= 0;
            end
            else
            begin
                if(i_valid)
                begin
                    if(r_counter >= (w_speed_to))       r_counter <= 0;
                    else                                r_counter <= r_counter + 1;
                end
            end
        end

        if(p_auto_pol == 0)
        begin
            always @(posedge i_clk) begin
                if(i_reset)
                begin
                    r_speed_pol0 <= p_speed_pol0;
                    r_speed_pol1 <= p_speed_pol1;
                end
                else
                begin
                    if(i_valid)
                    begin
                        if(r_counter >= (w_speed_to))       r_speed_pol0 <= p_speed_pol0;
                        else                                r_speed_pol0 <= {r_speed_pol0[0], r_speed_pol0[p_speed_size-1:1]};

                        if(r_counter >= (w_speed_to))       r_speed_pol1 <= p_speed_pol1;
                        else                                r_speed_pol1 <= {r_speed_pol1[0], r_speed_pol1[p_speed_size-1:1]};
                    end
                end
            end
        end
        else
        begin
            always @(posedge i_clk) begin
                if(i_reset)
                begin
                    r_speed_pol <= 2'b11;
                    r_speed_nepol <= 2'b11;
                end
                else 
                begin
                    if(i_valid)
                    begin
                        if(r_counter >= (w_speed_to))           r_speed_pol <= 2'b11;
                        else                                    r_speed_pol <= {!r_counter[0], r_counter[0]};
                        if(r_counter >= (w_speed_to))           r_speed_nepol <= 2'b11;
                        else                                    r_speed_nepol <= {r_counter[0], !r_counter[0]};
                    end
                end
            end
        end
    end
    endgenerate

endmodule
