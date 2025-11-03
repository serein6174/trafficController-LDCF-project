module traffic(
input clk,                     // 时钟信号
    input reset,                   // 重置信号
    input [4:0] east_vehicles,     // 东路段车辆数
    input [4:0] west_vehicles,     // 西路段车辆数
    input [4:0] north_vehicles,    // 南路段车辆数
    input [4:0] south_vehicles,    // 北路段车辆数

    
    output reg NS_status           // 南北方向通行状态
);
    reg direction_east_west; // 水平方向控制（东西方向）
    reg direction_north_south; // 竖直方向控制（南北方向）
    reg [4:0] timer_east_west; // 东西方向红绿灯计时器
    reg [4:0] timer_north_south; // 南北方向红绿灯计时器
// 状态定义
reg EW_status;           // 东西方向通行状态
parameter CLEAR = 5'd15;        // 畅通时的时间（15秒）
parameter MODERATE = 5'd20;     // 拥堵时的时间（20秒）
parameter SEVERE = 5'd30;       // 严重拥堵时的时间（30秒）
parameter MAX_VEHICLES = 20;    // 最大车辆数（即严重拥堵状态）

// 内部信号：记录最拥堵的路段车辆数
wire [4:0] max_vehicles;
reg [4:0] prev_max_vehicles = 0;  // 记录上一个周期的最大车辆数
reg [4:0] prev_timer_east_west = 0; // 记录上一个周期的东西方向红绿灯时长
reg [4:0] prev_timer_north_south = 0; // 记录上一个周期的南北方向红绿灯时长
reg [31:0] cnt;
reg clk_1;
// 计算四个路段中的最大车辆数
assign max_vehicles = (east_vehicles > west_vehicles) ? (east_vehicles > north_vehicles ? (east_vehicles > south_vehicles ? east_vehicles : south_vehicles) : (north_vehicles > south_vehicles ? north_vehicles : south_vehicles)) :
                      (west_vehicles > north_vehicles ? (west_vehicles > south_vehicles ? west_vehicles : south_vehicles) : (north_vehicles > south_vehicles ? north_vehicles : south_vehicles));

// 动态调整红绿灯时长
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // 初始化状态
        direction_east_west <= 0;
        direction_north_south <= 1;
        timer_east_west <= CLEAR;
        timer_north_south <= CLEAR;
        prev_max_vehicles <= 0;
        prev_timer_east_west <= CLEAR;
        prev_timer_north_south <= CLEAR;
        EW_status <= 0;
        NS_status <= 1;
        cnt<=0;
    end
    else begin
        // 判断是否需要动态调整红绿灯时长
        cnt<=cnt+1;
        if (max_vehicles > MAX_VEHICLES) begin
            // 严重拥堵，增加红绿灯时长
            if (prev_max_vehicles != max_vehicles) begin
                timer_east_west <= SEVERE;
                timer_north_south <= SEVERE;
            end
        end
        else if (max_vehicles > MAX_VEHICLES / 2) begin
            // 拥堵，设置为适中的红绿灯时长
            if (prev_max_vehicles != max_vehicles) begin
                timer_east_west <= MODERATE;
                timer_north_south <= MODERATE;
            end
        end
        else begin
            // 畅通，恢复为最低红绿灯时长
            if (prev_max_vehicles != max_vehicles) begin
                timer_east_west <= CLEAR;
                timer_north_south <= CLEAR;
            end
        end

        // 根据车流量变化动态调整红绿灯时间
        if (direction_east_west == 1 && timer_east_west > prev_timer_east_west) begin
            // 东西方向红绿灯时长延长
            if (east_vehicles > prev_max_vehicles && east_vehicles <= MAX_VEHICLES) begin
                timer_east_west <= timer_east_west + 5;
            end
            else if (east_vehicles > MAX_VEHICLES) begin
                timer_east_west <= timer_east_west + 10;
            end
        end
        else if (direction_north_south == 1 && timer_north_south > prev_timer_north_south) begin
            // 南北方向红绿灯时长延长
            if (north_vehicles > prev_max_vehicles && north_vehicles <= MAX_VEHICLES) begin
                timer_north_south <= timer_north_south + 5;
            end
            else if (north_vehicles > MAX_VEHICLES) begin
                timer_north_south <= timer_north_south + 10;
            end
        end

        // 更新状态
        prev_max_vehicles <= max_vehicles;
        prev_timer_east_west <= timer_east_west;
        prev_timer_north_south <= timer_north_south;
        if (cnt<100_000_000) begin 
           cnt <= cnt+1'b1;
           clk_1<=0;
        end else begin
           clk_1 <= 1;
           cnt <= 0;
       end
        // 每秒减少计时器
        if ((timer_east_west > 0) && (clk_1)) begin
            timer_east_west <= timer_east_west - 1;
        end
        if ((timer_north_south > 0)&& (clk_1)) begin
            timer_north_south <= timer_north_south - 1;
        end

        // 每个周期结束后切换方向
        if (timer_east_west == 0 && timer_north_south == 0) begin
            direction_east_west <= ~direction_east_west;
            direction_north_south <= ~direction_north_south;
        end

        // 更新东西方向和南北方向的通行状态
        EW_status <= (direction_east_west == 1) ? 1 : 0;
        NS_status <= (direction_north_south == 1) ? 1 : 0;
    end
end

endmodule
