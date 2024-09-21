package sparse_pkg
    typedef struct COO_Entry {
        logic valid;
        reg [3:0] row;
        reg [3:0] col;
        reg [DATA_SIZE-1:0] data;
    } entry;

    typedef struct packed {
        logic valid;
        reg [DATA_SIZE-1:0] a;
        reg [DATA_SIZE-1:0] b;
    } pair;

endpackage