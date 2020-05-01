module IIS_SteppingMotor(
clk, xres, cw, mode, speed, out_ap, out_bp, out_an, out_bn );
    // clk ... 入力クロック(50MHz), xres ... リセット
    // cw ... 回転方向（Hi->Lo検出で回転方向反転）　1:clock-wise, 0:counter clock-wise
    // mode... 励磁モード([00]:2相励磁)
    // speed... 回転速度([0]:速度ダウン, [1]:速度アップ)
    // モータ制御信号出力（A相+、B相+、A相-、B相-）
    input clk, xres, cw;
    input [1:0] mode, speed;
    output out_ap, out_bp, out_an, out_bn;
    
    // Wireとreg設定
    wire div_clk, cw_d, out_ap, out_bp, out_an, out_bn;     // cw_dはcwのフィルタ後信号
    wire [1:0] mode_d, speed_d;                             // フィルタ後の各信号
    wire [31:0] div_cnt;                                    // 1ステップパルスの分周数
    wire cw_out, cw_out_inv;                                // 回転方向制御用（反転）
    
    /* 設定パラメータ（全部原振クロック基準のクロック数） */
    parameter CNT_FLT = 16'd20;     // 外部入力信号フィルタ設定(12800clk/50MHz = 256usec, 20/50MHz=400nsec for test)
    parameter INIT = 32'd300;        // 分周数（回転速度）初期値
    parameter OUT_MIN = 32'd100;     // 分周数最小値（最高速）
    parameter OUT_MAX = 32'd800;    // 分周数最大値（最低速）
    parameter T_STEP = 32'd100;      // 分周数増分
    parameter T_REFRESH = 32'd15000;   // 分周数ボタン押しっぱなし時、連続して変化させるときの変更時間間隔
    
    /* 入力信号フィルタ */
    // 駆動モード（DIP-SW）
    filter #( .WIDTH( 2'd2 ), .INIT( 2'b00 ), .CNT_FLT( CNT_FLT ) ) mode_fil_ins(
     .clk(clk), .xres(xres), .sigin(mode), .sigout(mode_d) );
    // 回転方向（PushButton）
    filter #( .WIDTH( 1'd1 ), .INIT( 1'b1 ), .CNT_FLT( CNT_FLT ) ) cw_fil_ins(
     .clk(clk), .xres(xres), .sigin(cw), .sigout(cw_d) );
    // 回転速度（PushButton[1:0]）
    filter #( .WIDTH( 2'd2 ), .INIT( 2'b11 ), .CNT_FLT( CNT_FLT ) ) speed_fil_ins(
     .clk(clk), .xres(xres), .sigin(speed), .sigout(speed_d) );
                
    /* clk分周（1ステップパルス生成）                             */
    /*   Tstep = (div_cnt+1) / fclk = (div_cnt+1) / 50e6     */
    /* (d24999999 = 0.5sec, d20 = 400nsec for test)            */
    // 分周数（回転速度）制御
    divider_cont #( .INIT(INIT), .OUT_MIN(OUT_MIN), .OUT_MAX(OUT_MAX), .T_STEP(T_STEP), .T_REFRESH(T_REFRESH) ) div_cont_ins
    ( .clk(clk), .xres(xres), .in(speed_d), .out(div_cnt) );
    // ディバイダ
    divider div_ins( .clk(clk), .xres(xres), .div_cnt(div_cnt), .out(div_clk) );
    
    /* 回転方向トグル */
    toggle cw_tgl_ins( .clk(clk), .xres(xres), .in(~cw_d), .out(cw_out) );
    assign cw_out_inv = ~cw_out;
 
    /* モータ制御 */
    MotorCont mcont_ins( 
     .clk(clk), .xres(xres), .cnt_clk(div_clk), .cw(cw_out_inv), .mode(mode_d),
     .out_ap(out_ap), .out_bp(out_bp), .out_an(out_an), .out_bn(out_bn) );
    
endmodule
