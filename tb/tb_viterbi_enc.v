`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2022 15:24:48
// Design Name: 
// Module Name: tb_viterbi_enc
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


module tb_viterbi();

reg     clk = 0;
always #5 clk = !clk;

reg data = 0;

localparam size = 11;
reg [size-1:0] modData = 11'b11001111010;
reg [size+1:0] polinimError_0 = 13'b00000000000;
reg [size+1:0] polinimError_1 = 13'b00000000000;
// reg [size*2+4:0] polinimError = 28'b0000000000000001001000;
reg [size*2+4:0] polinimError = 28'b0000000000000000100000;
reg valid = 0;
wire validData;
wire [1:0] outData;
reg [1:0] dataDecIn = 0;
reg validDecoderData = 0;

wire dec_valid;
wire dec_data;
wire dec_valid_d1;
wire dec_data_d1;
wire dec_error;

integer i = 0;
initial
begin
    #50;
    valid <= 1;
    for(i = 0; i < size; i = i + 1)
    begin
        data = modData[i];
        #10;
    end
    data = 0;
    #10;

    #10;
    valid <= 0;
end

viterbi_enc #(.p_size_polinom(7), .p_polinom_0(7'b1001111), .p_polinom_1(7'b1101101), .p_defoult_state(7'b0000000)) enc(
    .i_clk(clk),
    .i_reset(1'b0),
    .i_data(data),
    .i_valid(valid),
    .o_data(outData),
    .o_valid(validData)
);


integer j;
initial
begin
    #60;
    validDecoderData = 1;
    for(j = 0; j <= size + 1; j = j + 1)
    begin
        // dataDecIn = outData ^ {polinimError_1[j], polinimError_0[j]};
        dataDecIn = outData ^ {polinimError[j*2+1], polinimError[j*2]};
        #10;
    end
    validDecoderData = 0;
    dataDecIn = 0;
    #10;dataDecIn = 0;
end


viterbi_dec #(.p_size_polinom(7), .p_polinom_0(7'b1001111), .p_polinom_1(7'b1101101), .p_defoult_state(7'b0000000)) dec(
    .i_clk(clk),
    .i_reset(1'b0),
    .i_data(/*outData*/dataDecIn),
    .i_valid({validDecoderData, validDecoderData}),
    .o_data({dec_data_d1, dec_data}),
    .o_valid({dec_valid_d1, dec_valid}),
    .o_error(dec_error)
    // .o_data_d1(dec_data_d1),
    // .o_valid_d1(dec_valid_d1)
);

reg [size+1:0] resData = 0;
reg [4:0] counter = 0;

always @(posedge clk) 
begin
    if(dec_valid_d1)
    begin
        counter <= counter + 2;
        resData[counter+1] <= dec_data;
        resData[counter] <= dec_data_d1;
    end
    else if(dec_valid)
    begin
        counter <= counter + 1;
        resData[counter] <= dec_data;
    end
end


wire [1:0] speed_data;
wire [1:0] speed_valid;

viterbi_speed_map #(.p_auto_pol(1), .p_speed_size(3), .p_speed_pol0(3'b101), .p_speed_pol1(3'b011)) map (
    .i_clk(clk),
    .i_reset(1'b0),
    .i_data(/*outData*/dataDecIn),
    .i_valid(validData),
    .i_speed(2),
    .o_data(speed_data),
    .o_valid(speed_valid)
);

wire [6:0] dec_valid2;
wire [6:0] dec_data2;
wire dec_valid_d12;
wire dec_data_d12;
wire dec_error2;


viterbi_dec #(.p_size_polinom(7), .p_polinom_0(7'b1001111), .p_polinom_1(7'b1101101), .p_defoult_state(7'b0000000)) dec2(
    .i_clk(clk),
    .i_reset(1'b0),
    .i_data(speed_data),
    .i_valid(speed_valid),
    .o_data(dec_data2),
    .o_valid(dec_valid2),
    .o_error(dec_error2)
);

reg [size+1:0] resData2 = 0;
reg [4:0] counter2 = 0;

always @(posedge clk) 
begin
    if(dec_valid2[3])
    begin
        counter2 <= counter2 + 4;
        resData2[counter2+3] <= dec_data2[0];
        resData2[counter2+2] <= dec_data2[1];
        resData2[counter2+1] <= dec_data2[2];
        resData2[counter2+0] <= dec_data2[3];
    end
    else if(dec_valid2[2])
    begin
        counter2 <= counter2 + 3;
        resData2[counter2+2] <= dec_data2[0];
        resData2[counter2+1] <= dec_data2[1];
        resData2[counter2+0] <= dec_data2[2];
    end
    else if(dec_valid2[1])
    begin
        counter2 <= counter2 + 2;
        resData2[counter2+1] <= dec_data2[0];
        resData2[counter2+0] <= dec_data2[1];
    end
    else if(dec_valid2[0])
    begin
        counter2 <= counter2 + 1;
        resData2[counter2+0] <= dec_data2[0];
    end
end




endmodule
