import sparse_pkg::*;

module MAC #(
    parameter DATA_SIZE = 16,
    parameter N = 4
) (
    input logic clk,
    input pair [N-1:0] buffer,
    output [DATA_SIZE-1:0] out_data,
    output done
);
int i;
logic selected = 0;
logic empty_queue = 0;
wire [DATA_SIZE-1:0] a;
wire [DATA_SIZE-1:0] b;
wire [DATA_SIZE-1:0] c = '0;

always_ff @( posedge clk ) begin
    for (i = 0; i < N; i++)
        if (buffer[i].valid && !selected) begin
            buffer[i].valid <= 0;
            selected <= 1;
            a <= buffer[i].a;
            b <= buffer[i].b;
        end
    
    c <= a * b;
end

assign out = c;
    
endmodule