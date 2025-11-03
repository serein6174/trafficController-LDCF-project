`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/23 16:42:57
// Design Name: 
// Module Name: Trafficsection
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

module TrafficIntersection (
    input clk,
    input reset,
    input [6:0] east_vehicles,
    input [6:0] west_vehicles,
    input [6:0] north_vehicles,
    input [6:0] south_vehicles,
    output reg NS_go ,   //当前路口南北方向是否通行（只保留了南北方向）
    output reg [6:0] max_vehicle
);

    parameter CLEAR = 6'd15, MODERATE = 6'd20, SEVERE = 6'd30, MAX_EXTEND = 6'd60;
    reg direction;
    reg [5:0] green_timer, extension;
    reg [1:0] prev_level;

    reg [26:0] clk_cnt;
    reg clk_1hz;
    always @(posedge clk or posedge reset) begin
        if (reset) begin clk_cnt <= 0; clk_1hz <= 0; end
        else if (clk_cnt < 100_000_000 / 2 - 1)
            clk_cnt <= clk_cnt + 1;
        else begin clk_cnt <= 0; clk_1hz <= ~clk_1hz; end
    end

    wire [6:0] veh[3:0];
    assign veh[0] = east_vehicles;
    assign veh[1] = west_vehicles;
    assign veh[2] = north_vehicles;
    assign veh[3] = south_vehicles;

    integer i;
    always @(*) begin
        max_vehicle = veh[0];
        for (i = 1; i < 4; i = i + 1)
            if (veh[i] > max_vehicle)
                max_vehicle = veh[i];
    end

    function [1:0] get_level;
        input [6:0] v;
        begin
            if (v >= 20) get_level = 2;
            else if (v >= 10) get_level = 1;
            else get_level = 0;
        end
    endfunction

    function [5:0] get_initial_time;
        input [6:0] v;
        begin
            if (v <= 10) get_initial_time = CLEAR;
            else if (v <= 20) get_initial_time = MODERATE;
            else get_initial_time = SEVERE;
        end
    endfunction

    always @(posedge clk_1hz or posedge reset) begin
        if (reset) begin
            direction <= 0;
            green_timer <= get_initial_time(max_vehicle);
            prev_level <= get_level(max_vehicle);
            extension <= 0;
        end else begin
            if (green_timer > 0) begin
                green_timer <= green_timer - 1;
                if (get_level(max_vehicle) > prev_level) begin
                    case ({prev_level, get_level(max_vehicle)})
                        4'b0001: extension <= extension + 5;
                        4'b0010: extension <= extension + 15;
                        4'b0100: extension <= extension + 10;
                    endcase
                    prev_level <= get_level(max_vehicle);
                end
                if (extension > 0) begin
                    if (green_timer + extension <= MAX_EXTEND)
                        green_timer <= green_timer + extension;
                    else
                        green_timer <= MAX_EXTEND;
                    extension <= 0;
                end
            end else begin
                direction <= ~direction;
                green_timer <= get_initial_time(max_vehicle);
                prev_level <= get_level(max_vehicle);
                extension <= 0;
            end
        end
    end
    always @(*) begin
        NS_go = (direction == 0) ? 0 : 1;
    end
endmodule
