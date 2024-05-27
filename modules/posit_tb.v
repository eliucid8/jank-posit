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

    reg[15:0] pos;
    wire sign;
    wire[4:0] regime;
    wire exponent;
    wire[11:0] mantissa;
    decompose_posit dec(sign, regime, exponent, mantissa, pos);

    initial begin
        $display("POSIT_NBITS: %d", POSIT_NBITS);
        $display("POSIT_ES: %d", POSIT_ES);
        $display("POSIT_NPAT: %d", POSIT_NPAT);
        $display("POSIT_USEED: %d", POSIT_USEED);

        pos = 0;
        #1;
        $display("%b, s: %b, r: %d, e: %d, m: %d", pos, sign, regime, exponent, mantissa);
        for(pos = 1; pos < (1<<15); pos = pos * 7 - 2) begin
            #1;
            $display("%b, s: %b, r: %d, e: %d, m: %d", pos, sign, regime, exponent, mantissa);
        end
        $finish;
    end
endmodule

module decompose_posit #(
    parameter NBITS = 16,
    parameter ES = 1
) (
    output sign,
    output[$clog2(NBITS):0] regime, // + 1 so we can get both positives and negatives.
    output[ES-1:0] exponent,
    output[NBITS-4-ES:0] mantissa, // -1 by default, -1 for sign, -2 for minimum regime length
    input[NBITS-1:0] posit
);
    assign sign = posit[NBITS-1];
    // use 2s complement of posit if sign bit is 1.
    wire[NBITS-2:0] posit_comp = sign ? ~posit[NBITS-2:0] + 1 : posit[NBITS-2:0];

    wire[$clog2(NBITS) - 1:0] leading_zeroes, leading_ones, leading;
    clz15 clz(.leading_zeroes(leading_zeroes), .num(posit[NBITS-2:0]));
    clo15 clo(.leading_ones(leading_ones), .num(posit[NBITS-2:0]));

    // 2s complement number giving the regime value.
    assign regime = leading_ones != 0 ? leading_ones - 1: ~leading_zeroes + 1;
    wire[$clog2(NBITS)-1:0] regime_length = leading_ones != 0 ? leading_ones + 1 : leading_zeroes + 1;

    wire[NBITS-2:0] exp_remaining = posit_comp << regime_length;
    assign exponent = exp_remaining[NBITS-2:NBITS-1-ES];
    assign mantissa = exp_remaining[NBITS-2-ES:2];
endmodule