module main(input logic clk, reset, output logic [6:0] Display, output logic [7:0] Seg);

    logic [31:0] add_out, add_in, inst, rdata1, rdata2, waddr, wdata, alu_out, se_out,  alu_b, dm_out, m21_pc_in, alu_a, wr_bk, buff_inst, buff_inst_ex, buff_pc_if, buff_pc_ex, buff_alu, buff_rdata2, mux_fsu_a, mux_fsu_b, out;
    logic [3:0] alu_sel, mask, DCM_out;
    logic [2:0] br_type,CS_out;
    logic q1, q2, q3 , q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16, q17;
    logic [1:0] wb_sel, buff_wb_sel;
    logic cs_dm, rd_dm, sel_alu_b, sel_alu_a, br_o, wren, buff_wren, fsu_a, fsu_b, stall_if, stall_ex, flush, buff_br_o, buff_flush;
    logic T;

    assign T = 1;

    TFF tff1 (T, clk, q1);
    TFF tff2 (T, q1, q2);
    TFF tff3 (T, q2, q3);
    TFF tff4 (T, q3, q4);
    TFF tff5 (T, q4, q5);
    TFF tff6 (T, q5, q6);
    TFF tff7 (T, q6, q7);
    TFF tff8 (T, q7, q8);
    TFF tff9 (T, q8, q9);
    TFF tff10 (T, q9, q10);
    TFF tff11 (T, q10, q11);
    TFF tff12 (T, q11, q12);
    TFF tff13 (T, q12, q13);
    TFF tff14 (T, q13, q14);
    TFF tff15 (T, q14, q15);
    TFF tff16 (T, q15, q16);
    TFF tff17 (T, q16, q17);


    inst_mem Inst_Mem ( .mem_in(add_out[31:2]), .mem_out(inst));
    buff_IR buff_IR_1 (.in(inst), .clk(q4), .reset(buff_flush), .en(stall_if),.out(buff_inst));
    buff_IR buff_IR_2 (.in(buff_inst), .clk(q4), .reset(flush), .en(stall_ex), .out(buff_inst_ex));
    adder ADD (.pc_in(add_out), .constant(32'd4), .adder_out(add_in));
    mux21 m21_pc ( .a(add_in), .b(buff_alu), .sel(buff_br_o), .out(m21_pc_in));
    pc PC (.add_in(m21_pc_in), .clk(q4), .reset(reset), .stall(stall_if), .add_out(add_out));
    buff buff_PC_IF (.in(add_out), .clk(q4), .reset(reset), .en(stall_if), .out(buff_pc_if));
    buff buff_PC_Ex (.in(buff_pc_if), .clk(q4), .reset(reset), .en(stall_ex), .out(buff_pc_ex));
    reg_file Reg_File ( .raddr1(buff_inst[19:15]), .raddr2(buff_inst[24:20]), .waddr(buff_inst_ex[11:7]), .wdata(wr_bk), .wren(buff_wren), .clk(q4), .reset(reset),.rdata1(rdata1), .rdata2(rdata2));
    imm_gen IMMG (.inst(buff_inst), .se_out(se_out));
    mux21 m21_alu_fsu_a (.a(buff_alu), .b(rdata1), .sel(fsu_a), .out(mux_fsu_a));
    mux21 m21_alu_a (.a(buff_pc_if), .b(mux_fsu_a), .sel(sel_alu_a), .out(alu_a));
    mux21 m21_alu_fsu_b (.a(buff_alu), .b(rdata2), .sel(fsu_b), .out(mux_fsu_b));
    mux21 m21_alu_b (.a(mux_fsu_b), .b(se_out), .sel(sel_alu_b), .out(alu_b));
    Alu ALU ( .operand_a(alu_a), .operand_b(alu_b), .sel(alu_sel), .alu_out(alu_out));
    buff buff_Alu (.in(alu_out), .clk(q4), .reset(reset), .en(stall_ex), .out(buff_alu));
    LSU lsu ( .inst(buff_inst_ex), .alu_out(buff_alu[1:0]) , .mask(mask), .cs(cs_dm), .rd(rd_dm));
    buff buff_WD (.in(rdata2), .clk(q4), .reset(reset), .en(stall_ex), .out(buff_rdata2));
    data_mem DM ( .addr(buff_alu), .data_wr(buff_rdata2), .cs(cs_dm), .rd(rd_dm), .clk(q4), .reset(reset),.mask(mask), .data_rd(dm_out), .out(out) );
    mux31 m31 ( .a(buff_pc_ex + 32'd4), .b(buff_alu), .c(dm_out), .sel(buff_wb_sel) , .out(wr_bk));
    controller CTRL ( .instruction(buff_inst), .wren(wren), .alu_sel(alu_sel), .alu_b_sel(sel_alu_b), .alu_a_sel(sel_alu_a), .br_type(br_type), .wb_sel(wb_sel));
    buff_1 buff_ctrl_wren ( .in(wren), .clk(q4), .reset(reset), .en(stall_ex), .out(buff_wren));
    buff buff_ctrl_wbsel ( .in(wb_sel), .clk(q4), .reset(reset), .en(stall_ex), .out(buff_wb_sel));
    branch br ( .op_a(rdata1), .op_b(rdata2), .br_type(br_type), .branch_out(br_o));
    buff_1 buff_br ( .in(br_o), .clk(q4), .reset(reset), .en(stall_ex), .out(buff_br_o));
    buff_1 buff_Flush ( .in(flush), .clk(q4), .reset(reset), .en(stall_ex), .out(buff_flush));
    FSU fsu ( .IR_if(buff_inst) , .IR_ex(buff_inst_ex), .buff_wren(buff_wren), .br_taken(br_o),.fsu_a(fsu_a), .fsu_b(fsu_b), .stall_if(stall_if), .stall_ex(stall_ex), .flush(flush));

    counter_sel CS (3'b001, q17 ,CS_out);
    decoder_sel DS (CS_out , Seg);


    always_comb
     begin
          case (CS_out)
          3'b000 : DCM_out = out [3:0];
          3'b001 : DCM_out = out [7:4];
          3'b010 : DCM_out = out [11:8];
          3'b011 : DCM_out = out [15:12];
          
          3'b100 : DCM_out = out [19:16];
          3'b101 : DCM_out = out [23:20];
          3'b110 : DCM_out = out [27:24];
          3'b111 : DCM_out = out [31:28];
          endcase
     end

    always_comb  // Number Decoder
        begin
            case (DCM_out)  // num[3] num [2] num[1] num [0] = Display [6]--- Display[0] 
                               //gfedcba            
            4'b0000 : Display = 7'b100_0000 ;
            4'b0001 : Display = 7'b111_1001 ;
            4'b0010 : Display = 7'b010_0100 ;
            4'b0011 : Display = 7'b011_0000 ;
                               
            4'b0100 : Display = 7'b001_1001 ;
            4'b0101 : Display = 7'b001_0010 ;
            4'b0110 : Display = 7'b000_0010 ;
            4'b0111 : Display = 7'b111_1000 ;
                               
            4'b1000 : Display = 7'b000_0000 ;
            4'b1001 : Display = 7'b001_0000 ;
            4'b1010 : Display = 7'b000_1000 ;
            4'b1011 : Display = 7'b000_0011 ;
                               
            4'b1100 : Display = 7'b100_0110 ;
            4'b1101 : Display = 7'b010_0001 ;
            4'b1110 : Display = 7'b000_0110 ;
            4'b1111 : Display = 7'b000_1110 ;
    
            endcase 
        end

endmodule