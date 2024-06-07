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
    clz15 clz(.leading_zeroes(leading_zeroes), .num(posit_comp[NBITS-2:0]));
    clo15 clo(.leading_ones(leading_ones), .num(posit_comp[NBITS-2:0]));

    // 2s complement number giving the regime value.
    assign regime = leading_ones != 0 ? leading_ones - 1: ~leading_zeroes + 1;
    wire[$clog2(NBITS)-1:0] regime_length = leading_ones != 0 ? leading_ones + 1 : leading_zeroes + 1;

    wire[NBITS-2:0] exp_remaining = posit_comp << regime_length;
    assign exponent = exp_remaining[NBITS-2:NBITS-1-ES];
    assign mantissa = exp_remaining[NBITS-2-ES:2];
endmodule

module split_radix_point #(
    parameter NBITS = 16,
    parameter ES = 1
) (
    output[(1<<ES)*(NBITS-1)-1:0] whole,
    output[(1<<ES)*(NBITS-1)-1:0] fraction,
    input[$clog2(NBITS):0] regime,
    input[ES-1:0] exponent,
    input[NBITS-4-ES:0] mantissa
);
    localparam 
        USEED = 1<<(1<<ES),
        OUTPUT_WIDTH = (1<<ES)*(NBITS-1),
        MANTISSA_WIDTH = NBITS-3-ES,
        REGIME_INPUT_WIDTH = $clog2(NBITS)+1;

    wire[2*OUTPUT_WIDTH-1:0] pre_shift, post_shift;
    assign pre_shift = {{(OUTPUT_WIDTH-1){1'b0}}, 1'b1, mantissa, {(OUTPUT_WIDTH-MANTISSA_WIDTH){1'b0}}};

    wire shift_left = ~regime[REGIME_INPUT_WIDTH-1];
    wire[REGIME_INPUT_WIDTH:0] lshamt = (regime<<ES)+exponent;
    wire[REGIME_INPUT_WIDTH:0] rshamt = -lshamt;
    assign post_shift = 
        shift_left ? 
        pre_shift << lshamt :
        pre_shift >> rshamt;
    
    assign whole = post_shift[2*OUTPUT_WIDTH-1:OUTPUT_WIDTH];
    assign fraction = post_shift[OUTPUT_WIDTH-1:0];
endmodule

module display_posit16 (
    output[39:0] whole_bcd, frac_bcd,
    input[15:0] posit,
    input clock,
    input reset
);
    localparam
        NBITS = 16,
        ES = 1,
        MANTISSA_WIDTH = 12,
        REGIME_WIDTH = 5,
        SPLIT_WIDTH = (1<<ES)*(NBITS-1),
        FRAC_ADD_CYCLES = SPLIT_WIDTH;

    wire sign;
    wire[4:0] regime;
    wire exponent;
    wire[11:0] mantissa;
    decompose_posit #(.NBITS(16), .ES(1)) dec_pos(
        .sign(sign), .regime(regime), .exponent(exponent), .mantissa(mantissa),
        .posit(posit));

    wire[SPLIT_WIDTH-1:0] whole, frac;
    split_radix_point #(.NBITS(NBITS), .ES(ES)) srp(
        .whole(whole), .fraction(frac),
        .regime(regime), .exponent(exponent), .mantissa(mantissa));

    wire frac_add_done;
    double_dabble #(SPLIT_WIDTH) whole_dd(
        .bcd(whole_bcd),
        .bin(whole), .clock(clock), .reset(reset));

    reg[32:0] frac_dec_lut [29:0]; // lookup table for decimal representations of fractional values
    reg[5:0] dec_lut_index;
    reg[33:0] frac_accumulator;

    initial begin
        dec_lut_index <= 0;
        frac_accumulator <= 0;
        $readmemh("memfiles/decimal.mem", frac_dec_lut, 0, 29);
    end

    always @(posedge clock) begin
        if(reset) begin
            dec_lut_index <= 0;
            frac_accumulator <= 0;
            // $display("  %b  %b", whole, frac);
        end else begin
            if(dec_lut_index <= FRAC_ADD_CYCLES) begin // basically building edge detector in.
                if(dec_lut_index != FRAC_ADD_CYCLES && frac[29 - dec_lut_index]) begin
                    frac_accumulator <= frac_accumulator + frac_dec_lut[dec_lut_index];
                end
                dec_lut_index <= dec_lut_index + 1;
            end
        end
    end
    assign frac_add_done = (dec_lut_index == FRAC_ADD_CYCLES);

    double_dabble #(33) frac_dd(
        .bcd(frac_bcd),
        .bin(frac_accumulator), .clock(clock), .reset(frac_add_done || reset)
    );

endmodule