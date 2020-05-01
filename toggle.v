/* 入力信号の立ち上がりで出力信号をトグル */
module toggle ( clk, xres, in, out );
    input clk, xres, in;
    output out;
    
    wire in_tgl;
    reg in_1d, in_2d, out;
    
    always @(posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 ) begin
            in_1d <= 1'b0;
            in_2d <= 1'b0;
        end
        else begin
            in_1d <= in;
            in_2d <= in_1d;
        end
    end
    assign in_tgl = in_1d & !in_2d;
    
    always @(posedge clk or negedge xres )
    begin
        if ( xres == 1'b0 )
            out <= 1'b0;
        else if ( in_tgl == 1'b1 )
            out <= ~out;
        else
            out <= out;
    end        
endmodule
