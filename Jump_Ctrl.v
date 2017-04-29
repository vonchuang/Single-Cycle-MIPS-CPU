// Jump_Ctrl

module Jump_Ctrl( 	Zero,
                  	JumpOP,
			clk,
			opcode,
			pc_control,
			alu_control	
			);

    	input Zero;
	output [1:0] JumpOP;
	
	input        clk;
	input  [3:0] pc_control;
	input  [3:0] alu_control;
	input  [5:0] opcode;
	reg    [1:0] JumpOP;

	localparam C_JUMP			 = 4'b0001;
	localparam C_JUMP_REGISTER		 = 4'b0010;
	localparam C_JUMP_AND_LINK		 = 4'b0011;
	localparam C_JUMP_AND_LINK_REGISTER	 = 4'b0100;
	localparam C_BRANCH_ON_EQUAL		 = 4'b0101;
	localparam C_BRANCH_ON_NOT_EQUAL	 = 4'b0110;

	//Data Transfer
	localparam C_LOAD_WORD                   = 6'b100011;
	localparam C_LOAD_HALFWORD               = 6'b100001;
	localparam C_STORE_WORD                  = 6'b101011;
	localparam C_STORE_HALFWORD              = 6'b101001;	

	always@(*)
	begin
		if(alu_control != 4'b1111)					//R type,addi, andi, ori, slti
			JumpOP = 0;
		if(((pc_control == C_BRANCH_ON_EQUAL) && Zero == 0) || 
		   ((pc_control == C_BRANCH_ON_NOT_EQUAL) && Zero != 0))	//branch
			JumpOP = 1;
		else if((pc_control == C_JUMP_REGISTER) ||
			(pc_control == C_JUMP_AND_LINK_REGISTER))		//jr, jalr
			JumpOP = 2;
		else if((pc_control == C_JUMP) ||
			(pc_control == C_JUMP_AND_LINK) )			//j, jal
			JumpOP = 3;
		else
			JumpOP = 0;

	end



endmodule





