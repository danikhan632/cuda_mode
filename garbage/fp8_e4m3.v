module FP8_E4M3(
    input [7:0] value,
    output reg [31:0] fp32_value
);

    wire sign = value[7];
    wire [3:0] exponent = value[6:3];
    wire [2:0] mantissa = value[2:0];

    reg signed [31:0] biased_exponent;
    reg [31:0] result;

    always @(*) begin
        if (exponent == 0 && mantissa == 0) begin
            fp32_value = 32'b0; // Handle zero case
        end else begin
            biased_exponent = exponent - 4'd7;
            result = (1 << 23) + (mantissa << 20);  // FP32 format mantissa
            fp32_value = {sign, (biased_exponent + 8'd127), result[22:0]};
        end
    end
endmodule
