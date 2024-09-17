module decoder_sel(input [2:0] sel, output reg [7:0] seg);
always_comb
    begin
    case (sel)
    3'b000 : seg = 8'b1111_1110 ;
    3'b001 : seg = 8'b1111_1101 ;
    3'b010 : seg = 8'b1111_1011 ;
    3'b011 : seg = 8'b1111_0111 ;
                
    3'b100 : seg = 8'b1110_1111 ;
    3'b101 : seg = 8'b1101_1111 ;
    3'b110 : seg = 8'b1011_1111 ;
    3'b111 : seg = 8'b0111_1111 ;
    default : seg = 8'b0;
    endcase
   end
     
endmodule
