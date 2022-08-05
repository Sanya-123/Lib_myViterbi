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
    o_error
    );

    localparam p_defoult_in_0_0 = ^({p_defoult_state, 1'b0} & p_polinom_0);
    localparam p_defoult_in_0_1 = ^({p_defoult_state, 1'b0} & p_polinom_1);
    localparam p_defoult_in_1_0 = ^({p_defoult_state, 1'b1} & p_polinom_0);
    localparam p_defoult_in_1_1 = ^({p_defoult_state, 1'b1} & p_polinom_1);

    input i_clk;
    input i_reset;
    input [1:0] i_data;
    input [1:0] i_valid;
    output [p_size_polinom-1:0] o_data;
    output [p_size_polinom-1:0] o_valid;
    output o_error;


    /********************************************************************************/
    /* Regs and wires */
    /********************************************************************************/
     
    wire    [1:0]                   w_idata = i_data & i_valid;
    reg     [p_size_polinom-1:0]    r_odata = 0;
    reg     [p_size_polinom-1:0]    r_valid = 0;

    //data decoding after find error
    reg     [p_size_polinom-1:0]    r_shift_in = p_defoult_state;

    // code data if input 0 and 1
    reg     [1:0]                   r_mod_in_0 = {p_defoult_in_0_1, p_defoult_in_0_0};
    reg     [1:0]                   r_mod_in_1 = {p_defoult_in_1_1, p_defoult_in_1_0};

    // shift data if input 0 and 1
    wire    [p_size_polinom-1:0]    w_shift_in_0 = {r_shift_in, 1'b0};
    wire    [p_size_polinom-1:0]    w_shift_in_1 = {r_shift_in, 1'b1};
    wire    [p_size_polinom-1:0]    w_shift_in_xx   [3:0];

    //fix erro reg
    reg     [p_size_polinom-1:0]    r_flag_error = 0;
    // code data if input 00 01 10 11
    // reg     [1:0]                   r_mod_in_xx     [3:0];

    // shift data if input 000 to 111
    // wire    [p_size_polinom-1:0]    w_shift_in_xxx  [7:0];

    //TODO
    reg     [p_size_polinom*2-1:0]  r_mod_in_0d0;
    reg     [p_size_polinom*2-1:0]  r_mod_in_0d1;
    reg     [p_size_polinom*2-1:0]  r_mod_in_1d0;
    reg     [p_size_polinom*2-1:0]  r_mod_in_1d1;

    reg     [p_size_polinom*2-1:0]  r_in_data_old;
    reg     [p_size_polinom*2-1:0]  r_in_data_mask;
    wire    [p_size_polinom*2-1:0]  w_in_data_shift = {r_in_data_old, w_idata};
    wire    [p_size_polinom*2-1:0]  w_in_mask_shift = {r_in_data_mask, i_valid};

    reg     [p_size_polinom-1:0]    r_decod_in_0dx;
    reg     [p_size_polinom-1:0]    r_decod_in_1dx;

    reg     [p_size_polinom-1:0]    r_shift_in_0dx = p_defoult_state;
    reg     [p_size_polinom-1:0]    r_shift_in_1dx = p_defoult_state;
    wire    [p_size_polinom-1:0]    w_shift_in_xdx  [3:0];
    wire    [p_size_polinom-1:0]    w_shift_in_xdxx [7:0];

    /********************************************************************************/
    /* END Regs and wires */
    /********************************************************************************/

    /********************************************************************************/
    /* Assign */
    /********************************************************************************/
     
    assign o_data           = r_odata;
    assign o_valid          = r_valid;
    assign o_error          = r_flag_error;

    genvar i_xx, i_xxx, i_xdxx;
    generate 
    for(i_xx = 0 ; i_xx < 4; i_xx = i_xx + 1) begin : U_wire_xx
        assign w_shift_in_xx[i_xx] = {r_shift_in, i_xx[1:0]};
    end
    // for(i_xxx = 0 ; i_xxx < 8; i_xxx = i_xxx + 1) begin : U_wire_xxx
    //     assign w_shift_in_xxx[i_xxx] = {r_shift_in, i_xxx[2:0]};
    // end
    for(i_xdxx = 0 ; i_xdxx < 4; i_xdxx = i_xdxx + 1) begin : U_wire_xdxx
        assign w_shift_in_xdxx[i_xdxx] = {r_shift_in_0dx, i_xdxx[1:0]};
        assign w_shift_in_xdxx[i_xdxx + 4] = {r_shift_in_1dx, i_xdxx[1:0]};
    end
    endgenerate

    assign w_shift_in_xdx[2'b00] = {r_shift_in_0dx, 1'b0};
    assign w_shift_in_xdx[2'b01] = {r_shift_in_0dx, 1'b1};
    assign w_shift_in_xdx[2'b10] = {r_shift_in_1dx, 1'b0};
    assign w_shift_in_xdx[2'b11] = {r_shift_in_1dx, 1'b1};

    /********************************************************************************/
    /* END Assign */
    /********************************************************************************/

    /********************************************************************************/
    /* Process decoding */
    /********************************************************************************/

    always @(posedge i_clk) begin
        if(i_reset)
        begin
            r_mod_in_0 <= {p_defoult_in_0_1, p_defoult_in_0_0};
            r_mod_in_1 <= {p_defoult_in_1_1, p_defoult_in_1_0};
            r_flag_error <= 0;
            r_shift_in <= p_defoult_state;
            r_shift_in_0dx <= p_defoult_state;
            r_shift_in_1dx <= p_defoult_state;
        end
        else
        begin
            if(i_valid && !r_flag_error)
            begin : _defoult_decoding
                if(w_idata == (r_mod_in_1 & i_valid))
                begin
                    r_shift_in <= w_shift_in_1;
                    r_mod_in_0[0] <= ^(w_shift_in_xx[2'b10] & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_xx[2'b10] & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_xx[2'b11] & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_xx[2'b11] & p_polinom_1);
                    r_odata[0] <= 1;
                end
                else if(w_idata == (r_mod_in_0 & i_valid))
                begin
                    r_shift_in <= w_shift_in_0;
                    r_mod_in_0[0] <= ^(w_shift_in_xx[2'b00] & p_polinom_0);
                    r_mod_in_0[1] <= ^(w_shift_in_xx[2'b00] & p_polinom_1);
                    r_mod_in_1[0] <= ^(w_shift_in_xx[2'b01] & p_polinom_0);
                    r_mod_in_1[1] <= ^(w_shift_in_xx[2'b01] & p_polinom_1);
                    r_odata[0] <= 0;
                end
                else 
                begin : _find_error
                    r_flag_error <= 1;

                    r_shift_in_0dx <= w_shift_in_0;
                    r_shift_in_1dx <= w_shift_in_1;

                    r_mod_in_0d0 <= {0, ^(w_shift_in_xx[2'b00] & p_polinom_1), ^(w_shift_in_xx[2'b00] & p_polinom_0)};
                    r_mod_in_0d1 <= {0, ^(w_shift_in_xx[2'b01] & p_polinom_1), ^(w_shift_in_xx[2'b01] & p_polinom_0)};
                    r_mod_in_1d0 <= {0, ^(w_shift_in_xx[2'b10] & p_polinom_1), ^(w_shift_in_xx[2'b10] & p_polinom_0)};
                    r_mod_in_1d1 <= {0, ^(w_shift_in_xx[2'b11] & p_polinom_1), ^(w_shift_in_xx[2'b11] & p_polinom_0)};

                    r_decod_in_0dx <= 0;
                    r_decod_in_1dx <= 1;

                    r_in_data_old <= 0;
                    r_in_data_mask <= 0;
                end
            end
            else if(i_valid && r_flag_error)
            begin : _fix_error
                if(i_valid == 2'b11)//if come 2 bytes so i can fix error
                begin
                    r_flag_error <= 0;
                    if(w_in_data_shift == (r_mod_in_1d1 & w_in_mask_shift))
                    begin
                        r_shift_in <= w_shift_in_xdx[2'b11];
                        r_odata <= {r_decod_in_1dx, 1'b1};
                        r_mod_in_0[0] <= ^(w_shift_in_xdxx[3'b110] & p_polinom_0);
                        r_mod_in_0[1] <= ^(w_shift_in_xdxx[3'b110] & p_polinom_1);
                        r_mod_in_1[0] <= ^(w_shift_in_xdxx[3'b111] & p_polinom_0);
                        r_mod_in_1[1] <= ^(w_shift_in_xdxx[3'b111] & p_polinom_1);
                    end
                    else if(w_in_data_shift == (r_mod_in_1d0 & w_in_mask_shift))
                    begin
                        r_shift_in <= w_shift_in_xdx[2'b10];
                        r_odata <= {r_decod_in_1dx, 1'b0};
                        r_mod_in_0[0] <= ^(w_shift_in_xdxx[3'b100] & p_polinom_0);
                        r_mod_in_0[1] <= ^(w_shift_in_xdxx[3'b100] & p_polinom_1);
                        r_mod_in_1[0] <= ^(w_shift_in_xdxx[3'b101] & p_polinom_0);
                        r_mod_in_1[1] <= ^(w_shift_in_xdxx[3'b101] & p_polinom_1);
                    end
                    else if(w_in_data_shift == (r_mod_in_0d1 & w_in_mask_shift))
                    begin
                        r_shift_in <= w_shift_in_xdx[2'b01];
                        r_odata <= {r_decod_in_0dx, 1'b1};
                        r_mod_in_0[0] <= ^(w_shift_in_xdxx[3'b010] & p_polinom_0);
                        r_mod_in_0[1] <= ^(w_shift_in_xdxx[3'b010] & p_polinom_1);
                        r_mod_in_1[0] <= ^(w_shift_in_xdxx[3'b011] & p_polinom_0);
                        r_mod_in_1[1] <= ^(w_shift_in_xdxx[3'b011] & p_polinom_1);
                    end
                    else
                    begin
                        r_shift_in <= w_shift_in_xdx[2'b00];
                        r_odata <= {r_decod_in_0dx, 1'b0};
                        r_mod_in_0[0] <= ^(w_shift_in_xdxx[3'b000] & p_polinom_0);
                        r_mod_in_0[1] <= ^(w_shift_in_xdxx[3'b000] & p_polinom_1);
                        r_mod_in_1[0] <= ^(w_shift_in_xdxx[3'b001] & p_polinom_0);
                        r_mod_in_1[1] <= ^(w_shift_in_xdxx[3'b001] & p_polinom_1);
                    end
                end
                else //if come 1 bytes(speed more than 1/2) so I can't fix error and add in data to posible byffer and analize then
                begin
                    // TODO
                    r_flag_error <= {r_flag_error, 1'b1};
                    
                    r_in_data_old <= {r_in_data_old, w_idata};
                    r_in_data_mask <= {r_in_data_mask, i_valid};


                    // //next posible data
                    if(w_idata == (r_mod_in_0d1 & i_valid))         
                        r_mod_in_0d0 <= {r_mod_in_0d0, /*r_mod_in_0d1[1:0],*/ ^(w_shift_in_xdxx[3'b010] & p_polinom_1), ^(w_shift_in_xdxx[3'b010] & p_polinom_0)};
                    else                                            
                        r_mod_in_0d0 <= {r_mod_in_0d0, ^(w_shift_in_xdxx[3'b000] & p_polinom_1), ^(w_shift_in_xdxx[3'b000] & p_polinom_0)};

                    if(w_idata == (r_mod_in_0d1 & i_valid))         
                        r_mod_in_0d1 <= {r_mod_in_0d1, ^(w_shift_in_xdxx[3'b011] & p_polinom_1), ^(w_shift_in_xdxx[3'b011] & p_polinom_0)};
                    else                                            
                        r_mod_in_0d1 <= {r_mod_in_0d1, /*r_mod_in_0d0[1:0],*/ ^(w_shift_in_xdxx[3'b001] & p_polinom_1), ^(w_shift_in_xdxx[3'b001] & p_polinom_0)};

                    if(w_idata == (r_mod_in_1d1 & i_valid))         
                        r_mod_in_1d0 <= {r_mod_in_1d0, /*r_mod_in_1d1[1:0],*/ ^(w_shift_in_xdxx[3'b110] & p_polinom_1), ^(w_shift_in_xdxx[3'b110] & p_polinom_0)};
                    else                                            
                        r_mod_in_1d0 <= {r_mod_in_1d0, ^(w_shift_in_xdxx[3'b100] & p_polinom_1), ^(w_shift_in_xdxx[3'b100] & p_polinom_0)};

                    if(w_idata == (r_mod_in_1d1 & i_valid))         
                        r_mod_in_1d1 <= {r_mod_in_1d1, ^(w_shift_in_xdxx[3'b111] & p_polinom_1), ^(w_shift_in_xdxx[3'b111] & p_polinom_0)};
                    else                                            
                        r_mod_in_1d1 <= {r_mod_in_1d1, /*r_mod_in_1d0[1:0],*/ ^(w_shift_in_xdxx[3'b101] & p_polinom_1), ^(w_shift_in_xdxx[3'b101] & p_polinom_0)};


                    //decod shift
                    if(w_idata == (r_mod_in_0d1 & i_valid))         r_shift_in_0dx <= {r_shift_in_0dx, 1'b1};
                    else                                            r_shift_in_0dx <= {r_shift_in_0dx, 1'b0};

                    if(w_idata == (r_mod_in_1d1 & i_valid))         r_shift_in_1dx <= {r_shift_in_1dx, 1'b1};
                    else                                            r_shift_in_1dx <= {r_shift_in_1dx, 1'b0};


                    //decod val
                    if(w_idata == (r_mod_in_0d1 & i_valid))         r_decod_in_0dx <= {r_decod_in_0dx, 1'b1};
                    else                                            r_decod_in_0dx <= {r_decod_in_0dx, 1'b0};

                    if(w_idata == (r_mod_in_1d1 & i_valid))         r_decod_in_1dx <= {r_decod_in_1dx, 1'b1};
                    else                                            r_decod_in_1dx <= {r_decod_in_1dx, 1'b0};

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
                if(r_flag_error && i_valid[0] && i_valid[1])        r_valid <= {r_flag_error, 1'b1};
                else if(w_idata == (r_mod_in_0 & i_valid))          r_valid <= !r_flag_error;
                else if(w_idata == (r_mod_in_1 & i_valid))          r_valid <= !r_flag_error;
                else                                                r_valid <= 0;
            end
            else    r_valid <= 0;
        end
    end

    /********************************************************************************/
    /* END Process decoding */
    /********************************************************************************/

endmodule
