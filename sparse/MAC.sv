import sparse_pkg::*;

module MAC #(
    parameter N = 4
) (
    input logic clk,
    input [] pair buffer,
    output []
);
int i;
logic selected = 0;
wire a;
always_ff @( posedge clk ) begin
    for (i = 0; i < N; i++)
        if (buffer[i].valid && !selected) begin
            buffer[i].valid = 0;
            selected = 1;
            a = buffer[i].a;
            b = buffer[i].b;
        end
    
end
    
endmodule