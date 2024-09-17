`timescale 1ps/1ps

module TB;


    logic clk, reset;
    logic [7:0] Seg;
    logic [6:0] Display;

    main DUT (.clk(clk), .reset(reset), .Display(Display), .Seg(Seg));
    
    initial 
	begin 
		clk = 0;
		forever 
			#5 clk = ~clk;
			
    end

    initial 
    begin
       
    DUT.add_out = 0; DUT.add_in = 0; DUT.rdata1 = 0; DUT.rdata2 = 0;
    DUT.waddr = 0; DUT.wdata = 0; DUT.wren = 0; DUT.alu_out = 0; DUT.alu_sel = 0;
    DUT.se_out = 0; DUT.CS.q=0; DUT.tff1.Q = 0;
    
    reset = 1;
    @(posedge clk);
    reset = 0;
    DUT.Reg_File.memory[0] = 0;
    DUT.DM.data_register[0] = 0;
    @(posedge clk);
 
    repeat(500) @(posedge clk);
 
    $stop;


    end


endmodule

