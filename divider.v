/* 入力クロックをDIV_CNTに従って分周 */
module divider ( clk, xres, div_cnt, out );
    input clk, xres;
    input [31:0] div_cnt;
    output out;
    
    wire [31:0] div_cnt;
    reg out;
    reg [31:0] cnt_p;
    
    always @(posedge clk or negedge xres)
    begin
        if ( xres == 1'b0 ) begin
            cnt_p <= div_cnt;
            out <= 1'b0;
        end
        else if ( cnt_p == 32'd0 ) begin
            cnt_p <= div_cnt;
            out <= ~out;
        end
        else begin
            cnt_p <= cnt_p - 1'b1;
            out <= out;
        end
    end
endmodule
