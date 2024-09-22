import numpy as np
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
        # Perform the calculation in floating-point
        return ((-1.0) ** sign) * (1.0 + mantissa / 8.0) * (2.0 ** biased_exponent)


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
    

def sparse_coo_matmul_fp8(A_data, A_row, A_col, A_valid, B_data, B_row, B_col, B_valid):
    # Initialize the result matrix C (8x8 for this case) in FP32
    C = np.zeros((8, 8), dtype=np.float32)

    # Perform sparse matrix multiplication in FP32
    for i in range(32):  # Loop over non-zero elements in A
        if A_valid[i]:
            a_fp32 = FP8_E4M3.cast_fp8_to_fp32(A_data[i])
            for j in range(32):  # Loop over non-zero elements in B
                if B_valid[j] and A_col[i] == B_row[j]:
                    b_fp32 = FP8_E4M3.cast_fp8_to_fp32(B_data[j])
                    # Accumulate the result in FP32
                    C[A_row[i]][B_col[j]] += a_fp32 * b_fp32

    return C

def print_sparse_matrix_fp8(name, data, row, col, valid):
    print(f"Sparse Matrix {name}:")
    print("Index | FP8 Value | Row | Column | Valid")
    print("------|-----------|-----|--------|------")
    for i in range(32):
        fp32_value = FP8_E4M3.cast_fp8_to_fp32(data[i]) if valid[i] else 0.0
        print(f"{i:4d}   | {fp32_value:9.4f}   | {row[i]:3d} | {col[i]:6d} | {'Yes' if valid[i] else 'No'}")
    print()

# Example FP8 data encoded using FP8_E4M3 (in binary format) with 32 elements
A_data = np.array([0b00111000, 0b01000000, 0b01001000, 0b01010000, 0b01011000, 0b01100000, 0b01101000, 0b01110000,
                   0b01111000, 0b10000000, 0b10001000, 0b10010000, 0b10011000, 0b10100000, 0b10101000, 0b10110000,
                   0b10111000, 0b11000000, 0b11001000, 0b11010000, 0b11011000, 0b11100000, 0b11101000, 0b11110000,
                   0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000], dtype=np.uint8)
A_row = np.array([0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 
                  3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 
                  6, 7, 7, 7, 0, 1, 2, 3, 4, 5, 
                  6, 7], dtype=np.int32)
A_col = np.array([0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 
                  1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 
                  2, 0, 1, 2, 3, 4, 5, 6, 7, 0, 
                  1, 2], dtype=np.int32)
A_valid = np.array([True, True, True, True, True, True, 
                    True, True, True, True, True, True, 
                    True, True, True, True, True, True, 
                    True, True, True, True, True, True, 
                    False, False, False, False, False, False, 
                    False, False], dtype=np.bool_)

B_data = np.array([0b00111000, 0b01000000, 0b01001000, 0b01010000, 0b01011000, 0b01100000, 0b01101000, 0b01110000,
                   0b01111000, 0b10000000, 0b10001000, 0b10010000, 0b10011000, 0b10100000, 0b10101000, 0b10110000,
                   0b10111000, 0b11000000, 0b11001000, 0b11010000, 0b11011000, 0b11100000, 0b11101000, 0b11110000,
                   0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000, 0b00000000], dtype=np.uint8)
B_row = np.array([0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 
                  2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 
                  4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 
                  6, 7], dtype=np.int32)
B_col = np.array([0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 
                  2, 3, 4, 5, 6, 7, 0, 1, 2, 3, 
                  4, 5, 6, 7, 0, 1, 2, 3, 4, 5, 
                  6, 7], dtype=np.int32)
B_valid = np.array([True, True, True, True, True, True, 
                    True, True, True, True, True, True, 
                    True, True, True, True, True, True, 
                    True, True, True, True, True, True, 
                    False, False, False, False, False, False, 
                    False, False], dtype=np.bool_)

# Print input matrices
print_sparse_matrix_fp8("A", A_data, A_row, A_col, A_valid)
print_sparse_matrix_fp8("B", B_data, B_row, B_col, B_valid)

# Perform multiplication
C_fp32 = sparse_coo_matmul_fp8(A_data, A_row, A_col, A_valid, B_data, B_row, B_col, B_valid)

# Print result
print("Result Matrix C (in FP32):")
for i in range(8):
    for j in range(8):
        print(f"C[{i}][{j}]: {C_fp32[i][j]:.4f}")
