
module mux_4to1(JumpOP,
		clk,
		jump_addr,
		branch_offset,
		reg_addr,
		add_4_addr,
		pc
		);


	parameter mem_size = 18;
	
	input   [1:0]		JumpOP;
	input     		clk;
	input   [mem_size-1:0] 	jump_addr;
	input   [mem_size-1:0] 	branch_offset;
	input   [mem_size-1:0] 	reg_addr;
	input   [mem_size-1:0] 	add_4_addr;

	output reg [mem_size-1:0] pc;

	localparam c_add_4_addr		= 2'b00;
	localparam c_branch_offset	= 2'b01;
	localparam c_reg_addr		= 2'b10;
	localparam c_jump_addr		= 2'b11;

	always@(*)
	begin
		case(JumpOP)
			c_add_4_addr		: pc = add_4_addr;
			c_branch_offset		: pc = branch_offset;
			c_reg_addr		: pc = reg_addr; 
			c_jump_addr		: pc = jump_addr; 
		endcase
	end



endmodule





