`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/16 15:56:25
// Design Name: 
// Module Name: multi_digits
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


module multi_digits #(
    parameter NUM_VALUES = 2  // 显示2个两位数
)(
    input clk,
    input [9:0] pixel_x,
    input [9:0] pixel_y,
    input [9:0] base_x [NUM_VALUES -1:0], // 基准坐标数组
    input [9:0] base_y [NUM_VALUES -1:0],
    input [7:0] data [NUM_VALUES-1:0],   // 数值数组（0-99）
    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue
);

// 生成十位和个位
localparam NUM_DIGITS = NUM_VALUES * 2;
wire [9:0] pos_x [NUM_DIGITS-1:0];
wire [9:0] pos_y [NUM_DIGITS-1:0];
wire [3:0] digit_val [NUM_DIGITS-1:0];
wire [7:0] original_data [NUM_DIGITS-1:0];

genvar i;
generate
for (i = 0; i < NUM_VALUES; i = i+1) begin : split
    // 十位
    assign pos_x[2*i] = base_x[i];
    assign pos_y[2*i] = base_y[i];
    assign digit_val[2*i] = data[i] / 10;
    assign original_data[2*i] = data[i];
    
    // 个位
    assign pos_x[2*i+1] = base_x[i] + 8; // 水平偏移8像素
    assign pos_y[2*i+1] = base_y[i];
    assign digit_val[2*i+1] = data[i] % 10;
    assign original_data[2*i+1] = data[i];
end
endgenerate

// 实例化所有数字
wire [NUM_DIGITS-1:0] pixel_on;
wire [3:0] red [NUM_DIGITS-1:0];
wire [3:0] green [NUM_DIGITS-1:0];
wire [3:0] blue [NUM_DIGITS-1:0];

genvar j;
generate
for (j = 0; j < NUM_DIGITS; j = j+1) begin : digits
    display_digit digit(
        .clk(clk),
        .pos_x(pos_x[j]),
        .pos_y(pos_y[j]),
        .original_data(original_data[j]),
        .digit_value(digit_val[j]),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_on(pixel_on[j]),
        .red(red[j]),
        .green(green[j]),
        .blue(blue[j])
    );
end
endgenerate

// 合并颜色输出（后写入的覆盖前面的）
reg [3:0] r, g, b;
integer k;
always @(*) begin
    r = 4'h0;
    g = 4'h0;
    b = 4'h0;
    for (k = 0; k < NUM_DIGITS; k = k+1) begin
        if (pixel_on[k]) begin
            r = red[k];
            g = green[k];
            b = blue[k];
        end
    end
end

assign vga_red = r;
assign vga_green = g;
assign vga_blue = b;

endmodule