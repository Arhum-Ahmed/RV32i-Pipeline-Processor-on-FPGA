module counter_sel( input [2:0] a, input clk, output reg [2:0]q);
always_ff @ (posedge clk)
        q <= q + a;
endmodule
