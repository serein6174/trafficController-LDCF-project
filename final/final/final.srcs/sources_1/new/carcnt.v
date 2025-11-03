`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/19 16:35:46
// Design Name: 
// Module Name: car_cnt
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


module carcnt (
    input wire clk,          // 时钟信号
    input wire rst,        // 复位信号（高电平有效）
    input wire [7:0] sw,
    input wire light1,
    input wire light2,
    input wire light3,
    input wire light4,
    output reg [7:0] cnt1, 
    output reg [7:0] cnt2,
    output reg [7:0] cnt3, 
    output reg [7:0] cnt4,
    output reg [7:0] cnt5, 
    output reg [7:0] cnt6,
    output reg [7:0] cnt7, 
    output reg [7:0] cnt8,
    output reg [7:0] cnt9, 
    output reg [7:0] cnt10,
    output reg [7:0] cnt11, 
    output reg [7:0] cnt12,
    output reg [7:0] cnt13, 
    output reg [7:0] cnt14,
    output reg [7:0] cnt15, 
    output reg [7:0] cnt16,
    output reg [7:0] cnt17, 
    output reg [7:0] cnt18,
    output reg [7:0] cnt19, 
    output reg [7:0] cnt20,
    output reg [7:0] cnt21, 
    output reg [7:0] cnt22,
    output reg [7:0] cnt23,
    output reg [7:0] cnt24);

// 1秒定时器（50MHz时钟）
reg [26:0] timer_count;
reg one_sec_pulse;
reg two_sec_pulse;
reg [7:0] switch_prev;
reg clk_1,clk_2;
reg [31:0] cnt;
reg [31:0] cnt_2;
integer seed;
reg [7:0]  latecnt1,latecnt2, latecnt3,latecnt4, latecnt5, latecnt6, latecnt7,latecnt8, latecnt9, latecnt10, latecnt11,latecnt12, latecnt13, latecnt14, latecnt15,latecnt16, latecnt17, latecnt18, latecnt19,latecnt20, latecnt21, latecnt22, latecnt23,latecnt24;
reg [7:0] switch;
reg [3:0] randnum;
reg [15:0]lfsr_8;
wire feedback = lfsr_8[15]^lfsr_8[13]^lfsr_8[12]^lfsr_8[10];
reg [2:0] randcnt;
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        // 初始化所有计数器和状态
        lfsr_8<=16'hACE1;
        timer_count <= 0;
        switch_prev <= 4'b0;
        switch<=4'b0;
        seed<=2;
        cnt<=0;cnt_2<=0;
        { cnt1, cnt2, cnt3,cnt4, cnt5, cnt6, cnt7,cnt8, cnt9, cnt10, cnt11,cnt12, cnt13,
         cnt14, cnt15,cnt16, cnt17, cnt18, cnt19,cnt20, cnt21, cnt22, cnt23,cnt24} <= 0;
        { latecnt1, latecnt2, latecnt3,latecnt4, latecnt5, latecnt6, latecnt7,latecnt8, 
        latecnt9, latecnt10, latecnt11,latecnt12, latecnt13, latecnt14, latecnt15,latecnt16,
         latecnt17, latecnt18, latecnt19,latecnt20, latecnt21, latecnt22, latecnt23,latecnt24}<=0;
    end else begin
        
        if (cnt_2<200_000_000) begin 
           cnt_2 <= cnt_2+1'b1;
           clk_2<=0;
        end else begin
           clk_2 <= 1;
           cnt_2 <= 0;
       end
       if (cnt<100_000_000) begin //时钟分频，按秒刷新车辆
           cnt <= cnt+1'b1;
           clk_1<=0;
        end else begin
           clk_1 <= 1;
           cnt <= 0;
       end
       //根据拨键在制定路口增加车辆
        switch_prev<=sw;
        switch<= sw & ~switch_prev;//用位运算判断是否处于拨键的上升沿

            if (switch[0]) cnt1<=cnt1+8'd1;
            if (switch[1]) cnt4<=cnt4+8'd1;
            if (switch[2]) cnt7<=cnt7+8'd1;
            if (switch[3]) cnt9<=cnt9+8'd1;
            if (switch[4]) cnt16<=cnt16+8'd1;
            if (switch[5]) cnt22<=cnt22+8'd1;
            if (switch[6]) cnt19<=cnt19+8'd1;
            if (switch[7]) cnt24<=cnt24+8'd1;
    //为尽量贴近实际情况，规定每辆车通过一段路的时间为2s
    if(clk_2) begin//记录两秒前各路口车辆
        latecnt1<=cnt1;latecnt2<=cnt2;latecnt3<=cnt3;latecnt4<=cnt4;
        latecnt5<=cnt5;latecnt6<=cnt6;latecnt7<=cnt7;latecnt8<=cnt8;
        latecnt9<=cnt9;latecnt10<=cnt10;latecnt11<=cnt11;latecnt12<=cnt12;
        latecnt13<=cnt13;latecnt14<=cnt14;latecnt15<=cnt15;latecnt16<=cnt16;
        latecnt17<=cnt17;latecnt18<=cnt18;latecnt19<=cnt19;latecnt20<=cnt20;
        latecnt21<=cnt21;latecnt22<=cnt22;latecnt23<=cnt23;latecnt24<=cnt24;
    end
    if(clk_1) begin
    //使用lfsr实现随机数模块，实现随机路口车辆的进入
        lfsr_8<={lfsr_8[14:0],feedback};
        randnum={lfsr_8[3:0]}%10;
        randcnt <= {lfsr_8[4:2]}%3+1;
        cnt2 <= cnt2>0?cnt2-1:0;
        cnt8 <= cnt8>0?cnt8-1:0;
        cnt3 <= cnt3>0?cnt3-1:0;
        cnt10 <= cnt10>0?cnt10-1:0;
        cnt15 <= cnt15>0?cnt15-1:0;
        cnt20 <= cnt20>0?cnt20-1:0;
        cnt21 <= cnt21>0?cnt21-1:0;
        cnt23 <= cnt23>0?cnt23-1:0;
        
        //结合各路口的交通信号灯状态控制车辆的流入流出
        if(cnt1>0&&latecnt1>0&&light1) begin
            cnt1<=cnt1-1;cnt11<=cnt11+1;
        end
        if(cnt11>0&&latecnt11>0&&light3) begin
            cnt11<=cnt11-1;cnt21<=cnt21+1;
        end
        if(cnt12>0&&latecnt12>0&&light1) begin
            cnt12<=cnt12-1;cnt2<=cnt2+1;
        end
        if(cnt22>0&&latecnt22>0&&light3) begin
            cnt22<=cnt22-1;cnt12<=cnt12+1;
        end
        if(cnt7>0&&latecnt7>0&&light2) begin
            cnt7<=cnt7-1;cnt13<=cnt13+1;
        end
        if(cnt13>0&&latecnt13>0&&light4) begin
            cnt13<=cnt13-1;cnt23<=cnt23+1;
        end
        if(cnt14>0&&latecnt14>0&&light2) begin
            cnt14<=cnt14-1;cnt8<=cnt8+1;
        end
        if(cnt24>0&&latecnt24>0&&light4) begin
            cnt24<=cnt24-1;cnt14<=cnt14+1;
        end
        
         if(cnt4>0&&latecnt4>0&&!light1) begin
            cnt4<=cnt4-1;cnt6<=cnt6+1;
        end
        if(cnt16>0&&latecnt16>0&&!light3) begin
            cnt16<=cnt16-1;cnt18<=cnt18+1;
        end
        if(cnt5>0&&latecnt5>0&&!light1) begin
            cnt5<=cnt5-1;cnt3<=cnt3+1;
        end
        if(cnt17>0&&latecnt17>0&&!light3) begin
            cnt17<=cnt17-1;cnt15<=cnt15+1;
        end
        if(cnt6>0&&latecnt6>0&&!light2) begin
            cnt6<=cnt6-1;cnt10<=cnt10+1;
        end
        if(cnt18>0&&latecnt18>0&&!light4) begin
            cnt18<=cnt18-1;cnt20<=cnt20+1;
        end
        if(cnt9>0&&latecnt9>0&&!light2) begin
            cnt9<=cnt9-1;cnt5<=cnt5+1;
        end
        if(cnt19>0&&latecnt19>0&&!light4) begin
            cnt19<=cnt19-1;cnt17<=cnt17+1;
        end
        case (randnum)
            4'd0: cnt1<=cnt1+randcnt;
            4'd1: cnt4<=cnt4+randcnt;
            4'd2: cnt7<=cnt7+randcnt;
            4'd3: cnt9<=cnt9+randcnt;
            4'd4: cnt16<=cnt16+randcnt;
            4'd5: cnt22<=cnt22+randcnt;
            4'd6: cnt7<=cnt7+randcnt;
            4'd7: cnt19<=cnt19+randcnt;              
        endcase
    end
    end
end

endmodule