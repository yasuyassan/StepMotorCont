/* Dividerの分周数を入力信号で制御 */
module divider_cont
#( parameter INIT = 32'd24999999, OUT_MIN = 32'd1, OUT_MAX = 32'hffffffff,
T_STEP = 32'd100, T_REFRESH = 32'd24999999 ) (
clk, xres, in, out );
// INIT: 初期の分周数
// OUT_MIN: 最小の分周数
// OUT_MAX: 最大の分周数
// T_STEP: 分周数の増分
// T_REFRESH: 連続して変化させるときの変更時間間隔
    
    input clk, xres;
    input [1:0] in;     // [10]:分周数増（低速）、[01]:分周数減（高速）。[00][11]は変化させない
    output [31:0] out;  // 分周数
        
    reg [31:0] cnt, out;
    reg [1:0] in_1d, in_2d;
    reg cnt_res;
    
    wire in_tgl;
    
    // 入力変化検出
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 ) begin
            in_1d <= 2'b00;
            in_2d <= 2'b00;
        end
        else begin
            in_1d <= ~in;
            in_2d <= in_1d;
        end
    end
    assign in_tgl = |(in_1d ^ in_2d);
            
    
    // 分周数更新タイミング生成
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            cnt <= T_REFRESH;
        else if ( (in_1d == 2'b00) || (in_1d == 2'b11) )
            cnt <= T_REFRESH;
        else begin
            if ( in_tgl == 1'b1 )
                cnt <= 32'd1;
            else if ( cnt_res == 1'b1 )
                cnt <= T_REFRESH;
            else
                cnt <= cnt - 1'b1;
        end
    end
        
/*     always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            cnt <= T_REFRESH;
        else if ( (in == 2'b00) || (in == 2'b11) )
            cnt <= T_REFRESH;
        else begin
            if ( in_tgl == 1'b1 )
                cnt <= 32'd1;
            else if ( cnt_res == 1'b1 )
                cnt <= T_REFRESH;
            else
                cnt <= cnt - 1'b1;
        end
    end
 */        
    // 分周数変更(cnt=1の時に値更新)
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 ) begin
            out <= INIT;
            cnt_res <= 1'b0;
        end
        else if ( cnt == 32'd1 ) begin
            if ( ( in_1d[0] == 1'b0 ) && ( out <= OUT_MAX - T_STEP ) )
                out <= out + T_STEP;
            else if ( ( in_1d[1] == 1'b0 ) && ( out >= OUT_MIN + T_STEP ) )
                out <= out - T_STEP;
            else
                out <= out;
            cnt_res <= 1'b1;
        end
        else begin
            out <= out;
            cnt_res <= 1'b0;
        end
    end
    
/*     // 分周数変更(cnt=1の時に値更新)
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 ) begin
            out <= INIT;
            cnt_res <= 1'b0;
        end
        else if ( cnt == 32'd1 ) begin
            if ( ( in[0] == 1'b0 ) && ( out <= OUT_MAX - T_STEP ) )
                out <= out + T_STEP;
            else if ( ( in[1] == 1'b0 ) && ( out >= OUT_MIN + T_STEP ) )
                out <= out - T_STEP;
            else
                out <= out;
            cnt_res <= 1'b1;
        end
        else begin
            out <= out;
            cnt_res <= 1'b0;
        end
    end
 */endmodule
