module double_dabble_tb;

    initial begin
        $dumpfile("double_dabble.vcd");
        $dumpvars(0, double_dabble_tb);
    end

    reg clock, reset;
    wire[31:0] bin = 32'd1234567;
    integer i;
    wire[39:0] bcd;
    wire done;

    double_dabble #(32) dd(.bcd(bcd), .done(done), .bin(bin), .clock(clock), .reset(reset));

    initial begin
        clock <= 0;
        reset <= 1;
        #1;
        clock <= 1;
        #1;
        clock <= 0;
        reset <= 0; 
        for (i = 0; i < 256; i = i + 1) begin
            #1
            clock = ~clock;
            $display("%d, %h", i/2, bcd);
        end
        $finish;
    end
endmodule