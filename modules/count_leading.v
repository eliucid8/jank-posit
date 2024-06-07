// We only need to count up to 31 leading zeroes bc highest bit is sign bit and thus not counted.
// Binary searches for the number of leading zeroes.
// Should be tested...
module clz31(
    output[4:0] leading_zeroes,
    input[30:0] num 
);
    wire lz4 = ~|{num[30:15]};          // If top 16 bits are all 0, add 16 (set 4th bit of leading_zeroes to 1s)
    wire[30:0] num4 = lz4 ? num << 16 : num;  // and then shift input over by 16
    wire lz3 = ~|{num4[30:23]};
    wire[30:0] num3 = lz3 ? num4 << 8 : num4;
    wire lz2 = ~|{num3[30:27]};
    wire[30:0] num2 = lz2 ? num3 << 4 : num3;
    wire lz1 = ~|{num2[30:29]};
    wire[30:0] num1 = lz1 ? num2 << 2 : num2;
    wire lz0 = ~num1[30];
    assign leading_zeroes = {lz4, lz3, lz2, lz1, lz0};
endmodule

// replaced all the nors with ands.
module clo31(
    output[4:0] leading_ones,
    input[30:0] num 
);
    wire lz4 = &{num[30:15]};          // If top 16 bits are all 0, add 16 (set 4th bit of leading_zeroes to 1s)
    wire[30:0] num4 = lz4 ? num << 16 : num;  // and then shift input over by 16
    wire lz3 = &{num4[30:23]};
    wire[30:0] num3 = lz3 ? num4 << 8 : num4;
    wire lz2 = &{num3[30:27]};
    wire[30:0] num2 = lz2 ? num3 << 4 : num3;
    wire lz1 = &{num2[30:29]};
    wire[30:0] num1 = lz1 ? num2 << 2 : num2;
    wire lz0 = num1[30];
    assign leading_ones = {lz4, lz3, lz2, lz1, lz0};
endmodule

module clz15(
    output[3:0] leading_zeroes,
    input[14:0] num 
);
    wire lz3 = ~|{num[14:7]};
    wire[14:0] num3 = lz3 ? num << 8 : num;
    wire lz2 = ~|{num3[14:11]};
    wire[14:0] num2 = lz2 ? num3 << 4 : num3;
    wire lz1 = ~|{num2[14:13]};
    wire[14:0] num1 = lz1 ? num2 << 2 : num2;
    wire lz0 = ~num1[14];
    assign leading_zeroes = {lz3, lz2, lz1, lz0};
endmodule

// replaced all the nors with ands.
module clo15(
    output[3:0] leading_ones,
    input[14:0] num 
);
    wire lz3 = &{num[14:7]};
    wire[14:0] num3 = lz3 ? num << 8 : num;
    wire lz2 = &{num3[14:11]};
    wire[14:0] num2 = lz2 ? num3 << 4 : num3;
    wire lz1 = &{num2[14:13]};
    wire[14:0] num1 = lz1 ? num2 << 2 : num2;
    wire lz0 = num1[14];
    assign leading_ones = {lz3, lz2, lz1, lz0};
endmodule

// module clo31_tb();
//     reg[30:0] i = 0;
//     wire[4:0] leading;
//     clo31 clo(.leading_ones(leading), .num(i));
//     integer j;

//     initial begin
//         #1;
//         $display("%b: %d", i, leading);
//         i = (1 << 30);
//         for(j = 0; j < 32; j = j + 1) begin
//             #1;
//             $display("%b: %d", i, leading);
//             i = {i[30], i[30:1]};
//         end
//         $finish;
//     end
// endmodule

// module clz31_tb();
//     reg[30:0] i = 0;
//     wire[4:0] leading_zeroes;
//     clz31 clz(.leading_zeroes(leading_zeroes), .num(i));

//     initial begin
//         #1;
//         $display("%b: %d", i, leading_zeroes);

//         for(i = 1; i != 0; i = i << 1) begin
//             #1;
//             $display("%b: %d", i, leading_zeroes);
//         end

//         for(i = 17; i != 0; i = i << 1) begin
//             #1;
//             $display("%b: %d", i, leading_zeroes);
//         end

//         $finish;
//     end
// endmodule