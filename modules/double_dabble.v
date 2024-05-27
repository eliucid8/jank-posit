module double_dabble #(
    parameter WIDTH_IN = 16
) (
    output[4*(WIDTH_IN+2)/3 - 1:0] bcd,
    output done,
    input[WIDTH_IN - 1:0] bin,
    input clock,
    input reset
);
    localparam 
        NUM_DIGITS = (WIDTH_IN+2)/3,
        BCD_BITS = NUM_DIGITS * 4,
        SCRATCH_WIDTH = WIDTH_IN + BCD_BITS;

        reg[SCRATCH_WIDTH-1:0] scratch = 0;
    reg[$clog2(WIDTH_IN):0] cycle_count = 0;

    // add3 modules
    wire[BCD_BITS-1:0] next_digits;
    genvar i;
    generate
        for(i = 0; i < NUM_DIGITS; i = i + 1) begin
            add3 a0(.out(next_digits[4*(i+1)-1:4*i]), .in(scratch[WIDTH_IN+4*(i+1)-1:WIDTH_IN+4*i]));
        end
    endgenerate

    always @(posedge clock) begin
        if(reset) begin
            // may take one extra clock cycle to reset
            scratch <= {{BCD_BITS{1'b0}}, bin};
            cycle_count <= 0;
        end else begin
            if(cycle_count < WIDTH_IN) begin
                // shift scratch over but replace bcd section with next_digits
                scratch <= {next_digits[BCD_BITS-2:0], scratch[WIDTH_IN-1:0], 1'b0};
                cycle_count <= cycle_count + 1;
            end
        end
    end

    assign bcd = scratch[SCRATCH_WIDTH-1:WIDTH_IN];
    assign done = cycle_count==WIDTH_IN;
endmodule

module double_dabble16(
    output[19:0] bcd,
    output done,
    input[15:0] bin,
    input clock,
    input reset
);
    localparam 
        WIDTH_IN = 16,
        SCRATCH_WIDTH = 36,
        BCD_BITS = 20,
        NUM_DIGITS = 5;

    reg[SCRATCH_WIDTH-1:0] scratch = 0;
    reg[$clog2(WIDTH_IN):0] cycle_count = 0;

    // add3 modules
    wire[BCD_BITS-1:0] next_digits;
    // add3 a0(.out(next_digits[3 :0 ]), .in(scratch[WIDTH_IN+3 :WIDTH_IN+0 ]));
    // add3 a1(.out(next_digits[7 :4 ]), .in(scratch[WIDTH_IN+7 :WIDTH_IN+4 ]));
    // add3 a2(.out(next_digits[11:8 ]), .in(scratch[WIDTH_IN+11:WIDTH_IN+8 ]));
    // add3 a3(.out(next_digits[15:12]), .in(scratch[WIDTH_IN+15:WIDTH_IN+12]));
    // add3 a4(.out(next_digits[19:16]), .in(scratch[WIDTH_IN+19:WIDTH_IN+16]));
    genvar i;
    generate
        for(i = 0; i < NUM_DIGITS; i = i + 1) begin
            add3 a0(.out(next_digits[4*(i+1)-1:4*i]), .in(scratch[WIDTH_IN+4*(i+1)-1:WIDTH_IN+4*i]));
        end
    endgenerate

    always @(posedge clock) begin
        if(reset) begin
            // may take one extra clock cycle to reset
            scratch <= {{BCD_BITS{1'b0}}, bin};
            cycle_count <= 0;
        end else begin
            if(cycle_count < WIDTH_IN) begin
                // shift scratch over but replace bcd section with next_digits
                scratch <= {next_digits[BCD_BITS-2:0], scratch[WIDTH_IN-1:0], 1'b0};
                cycle_count <= cycle_count + 1;
            end
        end
    end

    assign bcd = scratch[SCRATCH_WIDTH-1:WIDTH_IN];
    assign done = cycle_count==WIDTH_IN;
endmodule

module add3(
    output[3:0] out,
    input[3:0] in
);
    assign out = (in >= 5) ? in + 3 : in;
endmodule