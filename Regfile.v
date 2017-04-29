// Regfile

module Regfile ( clk, 
		 rst,
		 Read_addr_1,
		 Read_addr_2,
		 Read_data_1,
                 Read_data_2,
		 RegWrite,
		 Write_addr,
		 Write_data
		 );
	
	parameter bit_size = 32;
	
	input  			clk, rst;
	input  [4:0] 		Read_addr_1;
	input  [4:0] 		Read_addr_2;
	
	output [bit_size-1:0] 	Read_data_1;
	output [bit_size-1:0] 	Read_data_2;
	
	input  			RegWrite;
	input  [4:0] 		Write_addr;
	input  [bit_size-1:0]	Write_data;
	
	reg    [bit_size-1:0] 	RF[bit_size-1:0];
	
	assign Read_data_1 = (Read_addr_1 == 5'b00000)? 32'h00000000 : RF[Read_addr_1];
	assign Read_data_2 = (Read_addr_2 == 5'b00000)? 32'h00000000 : RF[Read_addr_2];

	integer i;

	always @(posedge clk)
	begin
		if(rst)
		begin
			for (i=0;i<32;i=i+1)
				RF[i] <= 0;
		end
		else
		begin
			if(RegWrite)
				RF[Write_addr] <= Write_data;
		end
	end
endmodule






