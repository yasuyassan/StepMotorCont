module MotorCont(
clk, xres, cnt_clk, cw, mode, out_ap, out_bp, out_an, out_bn );

    input clk, xres, cnt_clk, cw;    // cnt_clk ... ステップクロック, cw ... 1:時計回り, 0:反時計回り
    input [1:0] mode;        // 励磁モード([00]:2相、[01]:1-2相)
    output out_ap, out_bp, out_an, out_bn;
    
    wire cw, trg;
    reg cnt_clk_1d, out_ap, out_bp, out_an, out_bn;
    reg [7:0] count;    // 励磁モード変更カウンタ
    
    /******************************/
    /* 励磁モード毎のカウンタ     */
    /******************************/
    // cnt_clk 立ち上がりエッジ検出
    always @(posedge clk or negedge xres)
    begin
        if ( xres == 1'b0 )
            cnt_clk_1d <= 1'b0;
        else
            cnt_clk_1d <= cnt_clk;
    end
    assign trg = cnt_clk & !cnt_clk_1d;
    
    // カウンタ（カウントダウンしていくので、例えば2相の場合、3-2-1-0-3-2-...）
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            count <= 8'd0;
        else if ( trg == 1'b1 ) begin
            if ( count == 8'd0 )begin
                if ( mode == 2'b00 )
                    count <= 8'd3;
                else
                    count <= 8'd7;
            end
            else
                count <= count - 1'd1;
        end
        else
            count <= count;
    end                
        
    /*************************/
    /* A+相                  */
    /*************************/
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            out_ap <= 1'b0;
        else if ( mode == 2'b00) begin  // 2相励磁モード
            case( count[1:0] )
                2'd0:   out_ap <= (!cw) ? 1'b1 : 1'b1;
                2'd1:   out_ap <= (!cw) ? 1'b1 : 1'b0;
                2'd2:   out_ap <= (!cw) ? 1'b0 : 1'b0;
                2'd3:   out_ap <= (!cw) ? 1'b0 : 1'b1;
                default:    out_ap <= 1'b0;
            endcase
        end
        else if ( mode == 2'b01 ) begin // 1-2相励磁モード
            case( count[2:0] )
                3'd0:   out_ap <= (!cw) ? 1'b1 : 1'b0;
                3'd1:   out_ap <= (!cw) ? 1'b1 : 1'b0;
                3'd2:   out_ap <= (!cw) ? 1'b0 : 1'b0;
                3'd3:   out_ap <= (!cw) ? 1'b0 : 1'b0;
                3'd4:   out_ap <= (!cw) ? 1'b0 : 1'b0;
                3'd5:   out_ap <= (!cw) ? 1'b0 : 1'b1;
                3'd6:   out_ap <= (!cw) ? 1'b0 : 1'b1;
                3'd7:   out_ap <= (!cw) ? 1'b1 : 1'b1;
                default:    out_ap <= 1'b0;
            endcase
        end
        else
            out_ap <= 1'b0;
    end
    
    /*************************/
    /* B+相                  */
    /*************************/
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            out_bp <= 1'b0;
        else if ( mode == 2'b00 ) begin // 2相励磁モード
            case( count[1:0] )
                2'd0:   out_bp <= (!cw) ? 1'b0 : 1'b0;
                2'd1:   out_bp <= (!cw) ? 1'b1 : 1'b0;
                2'd2:   out_bp <= (!cw) ? 1'b1 : 1'b1;
                2'd3:   out_bp <= (!cw) ? 1'b0 : 1'b1;
                default:    out_bp <= 1'b0;
            endcase
        end
        else if ( mode == 2'b01 ) begin // 1-2相励磁モード
            case( count[2:0] )
                3'd0:   out_bp <= (!cw) ? 1'b0 : 1'b0;
                3'd1:   out_bp <= (!cw) ? 1'b1 : 1'b0;
                3'd2:   out_bp <= (!cw) ? 1'b1 : 1'b0;
                3'd3:   out_bp <= (!cw) ? 1'b1 : 1'b1;
                3'd4:   out_bp <= (!cw) ? 1'b0 : 1'b1;
                3'd5:   out_bp <= (!cw) ? 1'b0 : 1'b1;
                3'd6:   out_bp <= (!cw) ? 1'b0 : 1'b0;
                3'd7:   out_bp <= (!cw) ? 1'b0 : 1'b0;
                default:    out_bp <= 1'b0;
            endcase
        end
        else
            out_bp <= 1'b0;
    end
    
    /*************************/
    /* A-相                  */
    /*************************/
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            out_an <= 1'b0;
        else if ( mode == 2'b00 ) begin // 2相励磁モード
            case( count[1:0] )
                2'd0:   out_an <= (!cw) ? 1'b0 : 1'b0;
                2'd1:   out_an <= (!cw) ? 1'b0 : 1'b1;
                2'd2:   out_an <= (!cw) ? 1'b1 : 1'b1;
                2'd3:   out_an <= (!cw) ? 1'b1 : 1'b0;
                default:    out_an <= 1'b0;
            endcase
        end
        else if ( mode == 2'b01 ) begin // 1-2相励磁モード
            case( count[2:0] )
                3'd0:   out_an <= (!cw) ? 1'b0 : 1'b0;
                3'd1:   out_an <= (!cw) ? 1'b0 : 1'b1;
                3'd2:   out_an <= (!cw) ? 1'b0 : 1'b1;
                3'd3:   out_an <= (!cw) ? 1'b1 : 1'b1;
                3'd4:   out_an <= (!cw) ? 1'b1 : 1'b0;
                3'd5:   out_an <= (!cw) ? 1'b1 : 1'b0;
                3'd6:   out_an <= (!cw) ? 1'b0 : 1'b0;
                3'd7:   out_an <= (!cw) ? 1'b0 : 1'b0;
                default:    out_an <= 1'b0;
            endcase
        end
        else
            out_an <= 1'b0;
    end
    
    /*************************/
    /* B-相                  */
    /*************************/
    always @( posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            out_bn <= 1'b0;
        else if ( mode == 2'b00 ) begin // 2相励磁モード
            case( count[1:0] )
                2'd0:   out_bn <= (!cw) ? 1'b1 : 1'b1;
                2'd1:   out_bn <= (!cw) ? 1'b0 : 1'b1;
                2'd2:   out_bn <= (!cw) ? 1'b0 : 1'b0;
                2'd3:   out_bn <= (!cw) ? 1'b1 : 1'b0;
                default:    out_bn <= 1'b0;
            endcase
        end
        else if ( mode == 2'b01 ) begin // 1-2相励磁モード
            case( count[2:0] )
                3'd0:   out_bn <= (!cw) ? 1'b0 : 1'b1;
                3'd1:   out_bn <= (!cw) ? 1'b0 : 1'b1;
                3'd2:   out_bn <= (!cw) ? 1'b0 : 1'b0;
                3'd3:   out_bn <= (!cw) ? 1'b0 : 1'b0;
                3'd4:   out_bn <= (!cw) ? 1'b0 : 1'b0;
                3'd5:   out_bn <= (!cw) ? 1'b1 : 1'b0;
                3'd6:   out_bn <= (!cw) ? 1'b1 : 1'b0;
                3'd7:   out_bn <= (!cw) ? 1'b1 : 1'b1;
                default:    out_bn <= 1'b0;
            endcase
        end
        else
            out_bn <= 1'b0;
    end                
endmodule
