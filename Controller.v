// Controller

module Controller (	opcode,
			funct,
			rst,
			data_mem_write_enable,
			reg_file_write_enable,
			store_half_select,
			load_half_select,
			jal_select,
			reg_file_write_addr_mux_select,
			reg_file_write_data_mux_select,
			alu_mux_select,
			alu_control,
			pc_control
			);

	input        [5:0] opcode;
    	input        [5:0] funct;

	input		   rst;
	
	output reg	   data_mem_write_enable;
	output reg         reg_file_write_enable;
	output reg	   store_half_select;
	output reg         load_half_select;
	output reg         jal_select;
	output reg         reg_file_write_addr_mux_select;
	output reg         reg_file_write_data_mux_select;
	output reg         alu_mux_select;
	output reg   [3:0] alu_control;
	output reg   [3:0] pc_control;
	
	
	//Instruction Types
	localparam R_TYPE                          = 6'b000000;
	localparam J_TYPE                          = 6'b00001x;

	//Arithmetics
	localparam C_ADD                           = 6'b100000;
	localparam C_SUBTRACT                      = 6'b100010;
	localparam C_ADD_IMMEDIATE                 = 6'b001000;

	//Logical
	localparam C_AND                           = 6'b100100;
	localparam C_AND_IMMEDIATE                 = 6'b001100;
	localparam C_OR                            = 6'b100101;
	localparam C_OR_IMMEDIATE                  = 6'b001101;
	localparam C_XOR                           = 6'b100110;
	localparam C_NOR                           = 6'b100111;
	localparam C_SET_ON_LESS_THAN              = 6'b101010;
	localparam C_SET_ON_LESS_THAN_IMMEDIATE    = 6'b001010;
	
	//Data Transfer
	localparam C_LOAD_WORD                     = 6'b100011;
	localparam C_LOAD_HALFWORD                 = 6'b100001;
	localparam C_STORE_WORD                    = 6'b101011;
	localparam C_STORE_HALFWORD                = 6'b101001;

	//Shift
	localparam C_SHIFT_LEFT_LOGICAL            = 6'b000000;
	localparam C_SHIFT_RIGHT_LOGICAL           = 6'b000010;

	//Conditional Branch
	localparam C_BRANCH_ON_EQUAL               = 6'b000100;
	localparam C_BRANCH_ON_NOT_EQUAL           = 6'b000101;

	//Unconditional Jumps
	localparam C_JUMP                          = 6'b000010;
	localparam C_JUMP_REGISTER                 = 6'b001000;
	localparam C_JUMP_AND_LINK                 = 6'b000011;
	localparam C_JUMP_AND_LINK_REGISTER        = 6'b001001;

	always@(*)
	begin
		//Data Memory Write Enable
		case(opcode)
				C_STORE_WORD			: data_mem_write_enable = 1'b1;
				C_STORE_HALFWORD		: data_mem_write_enable = 1'b1;
			default          			: data_mem_write_enable = 1'b0;
		endcase
			
		//Reg File Write Enable
		case(opcode)
				R_TYPE				: reg_file_write_enable = 1'b1;
				C_AND_IMMEDIATE			: reg_file_write_enable = 1'b1;
				C_OR_IMMEDIATE			: reg_file_write_enable = 1'b1;
				C_ADD_IMMEDIATE			: reg_file_write_enable = 1'b1;
				C_SET_ON_LESS_THAN_IMMEDIATE	: reg_file_write_enable = 1'b1;
				C_LOAD_WORD			: reg_file_write_enable = 1'b1;
				C_LOAD_HALFWORD			: reg_file_write_enable = 1'b1;
				C_JUMP_AND_LINK			: reg_file_write_enable = 1'b1;
				C_JUMP_AND_LINK_REGISTER	: reg_file_write_enable = 1'b1;
			
			default          			: reg_file_write_enable = 1'b0;
		endcase


		//mux_2to1 load & load half select
		case(opcode)
			C_LOAD_WORD				: load_half_select = 1'b0;
			C_LOAD_HALFWORD          		: load_half_select = 1'b1;
			default					: load_half_select = 1'b0;
		endcase		

		//mux_2to1 store & store half select
		case(opcode)
			C_STORE_WORD				: store_half_select = 1'b0;
			C_STORE_HALFWORD          		: store_half_select = 1'b1;
			default					: store_half_select = 1'b0;
		endcase		


		//jal_select
		case(opcode)
				C_JUMP_AND_LINK			: jal_select = 1'b0;
				C_JUMP_AND_LINK_REGISTER	: jal_select = 1'b0;
			default          			: jal_select = 1'b1;
		endcase	

		//mux_2to1_mem
		case(opcode)
				R_TYPE				: reg_file_write_data_mux_select = 1'b0;
				C_AND_IMMEDIATE			: reg_file_write_data_mux_select = 1'b0;
				C_OR_IMMEDIATE			: reg_file_write_data_mux_select = 1'b0;
				C_ADD_IMMEDIATE			: reg_file_write_data_mux_select = 1'b0;
				C_SET_ON_LESS_THAN_IMMEDIATE	: reg_file_write_data_mux_select = 1'b0;
			default          			: reg_file_write_data_mux_select = 1'b1;
		endcase			

		//mux_2to1 Rt & Rd
		case(opcode)
				R_TYPE				: reg_file_write_addr_mux_select = 1'b1;
				C_BRANCH_ON_EQUAL		: reg_file_write_addr_mux_select = 1'b1;
				C_BRANCH_ON_NOT_EQUAL		: reg_file_write_addr_mux_select = 1'b1;
			default          			: reg_file_write_addr_mux_select = 1'b0;
		endcase		

		//ALU Multiplexer
		case(opcode)
				R_TYPE				: alu_mux_select = 1'b1;
				C_BRANCH_ON_EQUAL		: alu_mux_select = 1'b1;
				C_BRANCH_ON_NOT_EQUAL		: alu_mux_select = 1'b1;
			default          			: alu_mux_select = 1'b0;
		endcase

		//ALU Control
		case(opcode)
			R_TYPE	:
				case(funct)
					C_ADD	             	: alu_control = 4'b0000;	
					C_SUBTRACT		: alu_control = 4'b0001;
					C_AND			: alu_control = 4'b0010;
					C_OR			: alu_control = 4'b0011;
					C_XOR			: alu_control = 4'b0100;
					C_NOR			: alu_control = 4'b0101;
					C_SET_ON_LESS_THAN    	: alu_control = 4'b0110;
					C_SHIFT_LEFT_LOGICAL	: alu_control = 4'b0111;
					C_SHIFT_RIGHT_LOGICAL	: alu_control = 4'b1000;	
					default          	: alu_control = 4'b1111;
				endcase

			C_ADD_IMMEDIATE				: alu_control = 4'b0000;	
			C_AND_IMMEDIATE				: alu_control = 4'b0010;	
			C_SET_ON_LESS_THAN_IMMEDIATE		: alu_control = 4'b0110;	


	
			//BRANCH
			C_BRANCH_ON_EQUAL			: alu_control = 4'b0110;  //SUBTRACT 
			C_BRANCH_ON_NOT_EQUAL			: alu_control = 4'b0110;  //SUBTRACT 

			default					: alu_control = 4'b0100;  //ADD 
		endcase

		//Program Counter Control
		case(opcode)
			R_TYPE					:
				case(funct)
					C_JUMP_REGISTER			: pc_control = 4'b0010;
					C_JUMP_AND_LINK_REGISTER	: pc_control = 4'b0100;
					default				: pc_control = 4'b0000;
				endcase
			C_JUMP					: pc_control = 4'b0001;
			C_JUMP_AND_LINK				: pc_control = 4'b0011;
			C_BRANCH_ON_EQUAL			: pc_control = 4'b0101;
			C_BRANCH_ON_NOT_EQUAL			: pc_control = 4'b0110;
			default					: pc_control = 4'b0000;
		endcase
	end



endmodule




