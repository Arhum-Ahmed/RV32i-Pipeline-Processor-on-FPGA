module FSU (input logic [31:0] IR_if , IR_ex, input logic buff_wren, br_taken, output logic fsu_a, fsu_b, stall_if, stall_ex, flush);

    logic valid_rs1, valid_rs2, check;

    assign valid_rs1 =| IR_if[19:15];
    assign valid_rs2 =| IR_if[24:20];

    always_comb
    begin
        if (IR_ex[6:0] != 7'b0000011)
        begin
            fsu_a = ~((IR_if[19:15] == IR_ex[11:7]) & (buff_wren) & (valid_rs1) );
            fsu_b = ~((IR_if[24:20] == IR_ex[11:7]) & (buff_wren) & (valid_rs2) );
        end
    end
    
    always_comb 
    begin
        if ((IR_ex[6:0] == 7'b0000011) & ((IR_if[19:15] == IR_ex[11:7]) | (IR_if[24:20] == IR_ex[11:7]))  & (buff_wren) & (valid_rs1))
        begin
             stall_if = 1;
             stall_ex = 1;
        end
        
        if (br_taken)
        begin
             flush = 1;
            stall_if = 1;
            stall_ex = 0;
        end

        else
        begin
             flush = 0;
            stall_if = 0;
            stall_ex = 0;
        end
    end


endmodule