/* フィルタ */
module filter 
#( parameter WIDTH = 1'b1, INIT = 1'b0, CNT_FLT = 16'd12800 )
( clk, xres, sigin, sigout );
// フィルタ設定(default: 12800clk/50MHz = 256usec)

    input clk, xres;
    input [WIDTH-1:0] sigin;
    output [WIDTH-1:0] sigout;
    
    reg [WIDTH-1:0] sigout, sigin_1d, sigin_2d;
    reg [15:0] cnt;
    wire sig_tgl;
        
    // sigin変化検出
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 ) begin
            sigin_1d <= INIT;
            sigin_2d <= INIT;
        end
        else begin
            sigin_1d <= sigin;
            sigin_2d <= sigin_1d;
        end
    end
    assign sig_tgl = |(sigin_1d ^ sigin_2d);
    
    // カウント
    always @ ( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            cnt <= 1'd0;
        else if ( sig_tgl == 1'b1 )
            cnt <= CNT_FLT;
        else if ( cnt != 1'd0 )
            cnt <= cnt - 1'd1;
        else
            cnt <= cnt;
    end
    
    // 出力
    always @ ( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            sigout <= INIT;
        else if ( cnt == 1'd0 )
            sigout <= sigin_2d;
        else
            sigout <= sigout;
    end
endmodule
            
                
                
