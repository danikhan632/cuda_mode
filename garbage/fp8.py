import struct

class FP8_E4M3:
    def __init__(self, value):
        self.value = value & 0xFF  # Ensure 8-bit value

    def unpack(self):
        sign = (self.value >> 7) & 1
        exponent = (self.value >> 3) & 0xF
        mantissa = self.value & 0x7
        return sign, exponent, mantissa

    @staticmethod
    def cast_fp8_to_fp32(fp8_value):
        sign, exponent, mantissa = FP8_E4M3(fp8_value).unpack()
        if exponent == 0 and mantissa == 0:
            return 0.0  # Handle zero case
        biased_exponent = exponent - 7  # Adjust for bias
        return ((-1) ** sign) * (1 + mantissa / 8) * (2 ** biased_exponent)

    @staticmethod
    def cast_fp32_to_fp8(fp32_value):
        if fp32_value == 0:
            return FP8_E4M3(0)
        sign = 0 if fp32_value > 0 else 1
        fp32_value = abs(fp32_value)
        exponent = 0
        while fp32_value >= 2:
            fp32_value /= 2
            exponent += 1
        while fp32_value < 1:
            fp32_value *= 2
            exponent -= 1
        mantissa = int((fp32_value - 1) * 8) & 0x7
        biased_exponent = min(max(exponent + 7, 0), 15)  # Clamp to 0-15
        return FP8_E4M3((sign << 7) | (biased_exponent << 3) | mantissa)

    def to_float(self):
        return self.cast_fp8_to_fp32(self.value)

    def __add__(self, other):
        result = self.to_float() + other.to_float()
        return self.cast_fp32_to_fp8(result)

    def __sub__(self, other):
        result = self.to_float() - other.to_float()
        return self.cast_fp32_to_fp8(result)

    def __mul__(self, other):
        result = self.to_float() * other.to_float()
        return self.cast_fp32_to_fp8(result)

    def __truediv__(self, other):
        if other.to_float() == 0:
            raise ValueError("Division by zero")
        result = self.to_float() / other.to_float()
        return self.cast_fp32_to_fp8(result)

    def __repr__(self):
        return f"FP8_E4M3(0b{self.value:08b})"

    def __str__(self):
        return f"{self.to_float()}"
    
# Create FP8 numbers
a = FP8_E4M3(0b01111001)  # 9.0 in FP8
b = FP8_E4M3(0b01001000)  # 3.0 in FP8

# Perform operations
sum_result = a + b
diff_result = a - b
prod_result = a * b
div_result = a / b

print(f"a = {a}")
print(f"b = {b}")
print(f"a + b = {sum_result}")
print(f"a - b = {diff_result}")
print(f"a * b = {prod_result}")
print(f"a / b = {div_result}")