module posit_tb();
    localparam 
        POSIT_NBITS = 16,
        POSIT_ES = 1,
        POSIT_NPAT = 1 << POSIT_NBITS,
        POSIT_USEED = 1 << (1 << POSIT_ES);

    initial begin
        $dumpfile("posit.vcd");
        $dumpvars(0, posit_tb);
    end

    reg clock, reset;

    reg[15:0] pos;
    wire sign;
    wire[4:0] regime;
    wire exponent;
    wire[11:0] mantissa;
    decompose_posit dec(sign, regime, exponent, mantissa, pos);
    // wire[29:0] whole, fract;
    // split_radix_point split(.whole(whole), .fraction(fract), .regime(regime), .exponent(exponent), .mantissa(mantissa));

    wire[39:0] whole, frac;
    display_posit16 pos_disp(
        .whole_bcd(whole), .frac_bcd(frac),
        .posit(pos), .clock(clock), .reset(reset));

    localparam 
        NUM_TESTS = 7;

    wire[15:0] test_vals[NUM_TESTS-1:0];
    assign test_vals[0] = 16'h3000; // 0.5
    assign test_vals[1] = 16'h4800; // 1.5
    assign test_vals[2] = 16'h5000; // 2.0
    assign test_vals[3] = 16'h5922; // 3.14159265...
    assign test_vals[4] = 16'h782c; // 69.420
    assign test_vals[5] = 16'h2cfd; // 69.420
    assign test_vals[6] = 16'hd305; // 69.420

    wire[63:0] real_vals[NUM_TESTS-1:0];
    assign real_vals[0] = "0.5";
    assign real_vals[1] = "1.5";
    assign real_vals[2] = "2.0";
    assign real_vals[3] = "3.141593";
    assign real_vals[4] = "69.420";
    assign real_vals[5] = "+.452930";
    assign real_vals[6] = "-.452930";
    
    integer i,j;

    initial begin
        $display("POSIT_NBITS: %d", POSIT_NBITS);
        $display("POSIT_ES: %d", POSIT_ES);
        $display("POSIT_NPAT: %d", POSIT_NPAT);
        $display("POSIT_USEED: %d", POSIT_USEED);

        // pos = 0;
        // #1;
        // $display("%b, s: %b, r: %d, e: %d, m: %d", pos, sign, regime, exponent, mantissa);
        // for(pos = 1; pos < (1<<15); pos = pos * 7 - 2) begin
        //     #1;
        //     $display("%b, s: %b, r: %d, e: %d, m: %d", pos, sign, regime, exponent, mantissa);
        //     $display("    %b     %b", whole, fract);
        // end
        i = 0;
        clock = 0;
        reset = 0;
        j = 0;
        #1;
        for(i = 0; i < NUM_TESTS; i = i + 1) begin
            pos = test_vals[i];
            #1;
            clock <= 0;
            reset <= 1;
            #1;
            clock <= 1;
            #1;
            clock <= 0;
            reset <= 0; 
            #1;
            $display("%s", real_vals[i]);
            $display("%b, s: %b, r: %d, e: %d, m: %d", pos, sign, regime, exponent, mantissa);
            for (j = 0; j < 130; j = j + 1) begin
                #1;
                clock = ~clock;
            end
            $write("%s", sign ? "-" : "");
            $display("%h.%h", whole, frac);
        end
    end
endmodule