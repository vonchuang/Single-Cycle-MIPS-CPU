// top

module top (	clk,
            	rst,
		// Instruction Memory
		IM_Address,
             	Instruction,
		// Data Memory
		DM_Address,
		DM_enable,
		DM_Write_Data,
		DM_Read_Data
		);

	parameter data_size = 32;
	parameter mem_size = 16;	

	input  clk, rst;
	
	// Instruction Memory
	output[mem_size-1:0]  IM_Address;	
	input [data_size-1:0] Instruction;

	// Data Memory
	output[mem_size-1:0]  DM_Address;
	output 		      DM_enable;
	output[data_size-1:0] DM_Write_Data;	
        input [data_size-1:0] DM_Read_Data;
	
	parameter addr_size = 18;
	wire [3:0] 	     pc_control_wire;
	wire [addr_size-1:0] jump_to_pc_wire;
	wire [addr_size-1:0] pc_to_addr_wire;
	wire [addr_size-1:0] pc_addr_add_4_wire;
	wire [addr_size-1:0] pc_addr_add_8_wire;
	wire [addr_size-1:0] branch_offset;
	wire [addr_size-1:0] jump_addr_wire;
	wire [addr_size-1:0] PCOut_wire;
	wire [addr_size-1:0] reg_addr_wire;
	wire [data_size-1:0] src0_wire;
	wire [data_size-1:0] reg_file_write_data_wire;
	wire [data_size-1:0] reg_file_write_data_2_wire;
	wire [data_size-1:0] sign_ext_imm_wire;
	wire [data_size-1:0] alu_result_wire;
	wire [data_size-1:0] read_data1_wire;
	wire [data_size-1:0] read_data2_wire;
	wire [data_size-1:0] read_data2_half_wire;
	wire [data_size-1:0] dm_write_data;
	wire [data_size-1:0] dm_data_result;
        wire [data_size-1:0] DM_Read_half_Data;
        wire [data_size-1:0] pc_addr_add_8_ext_wire;
	wire [4:0]	     write_reg_wire;
	wire [4:0]	     write_reg_2_wire;
	wire                 reg_file_write_enable_wire;
	wire		     reg_file_addr_mux_sel;
	wire		     reg_file_data_mux_sel;
	wire		     load_mux_wire;
	wire		     store_mux_wire;
	wire		     jal_mux_wire;
	wire		     alu_mux_sel;
	wire [4:0]	     shamt_wire;
	wire [3:0]	     control_wire;
	wire 		     zero_wire;
	wire		     dm_enable;
	wire 		     overflow_wire;
	wire [1:0]	     jump_op_wire;
	wire [4:0]	     jal_31_wire;

	assign jal_31_wire = 31;

//pc
	PC	cpu_pc 
	(
		.clk				(clk),				//input 
		.rst				(rst),				//input
		.PCin				(jump_to_pc_wire),		//input 
		.PCout				(PCOut_wire)			//output
	);
//add 4 adder
	assign pc_addr_add_4_wire = PCOut_wire + 4;
	assign IM_Address = PCOut_wire[17:2];

//shift and add
	assign branch_offset = pc_addr_add_4_wire + {Instruction[15:0],2'b00};	
	assign jump_addr_wire = Instruction[15:0] << 2;				
	assign reg_addr_wire = read_data1_wire[17:0];				



//mux 4 to 1
	mux_4to1 cpu_mux_4to1
	(
		.JumpOP				(jump_op_wire),			//input	
		.clk				(clk),				//input
		.jump_addr			(jump_addr_wire),		//input
		.branch_offset			(branch_offset),		//input
		.reg_addr			(reg_addr_wire),		//input
		.add_4_addr			(pc_addr_add_4_wire),		//input
		.pc				(jump_to_pc_wire)		//output
	);
//jump control
	Jump_Ctrl cpu_jump_ctrl
	(
		.Zero				(zero_wire),			//input
		.JumpOP				(jump_op_wire),			//output	
		.clk				(clk),				//input
		.pc_control			(pc_control_wire),		//input
		.alu_control			(control_wire),			//input
		.opcode				(Instruction[31:26])		//input
	);


//controller
	Controller  cpu_controller
	( 
		.opcode				(Instruction[31:26]),		//input
		.funct				(Instruction[5:0]),		//input
		.rst				(rst),				//input
		.data_mem_write_enable		(dm_enable),			//output
		.reg_file_write_enable		(reg_file_write_enable_wire),	//output
		.store_half_select		(store_mux_wire),		//output
		.load_half_select		(load_mux_wire),		//output
		.jal_select			(jal_mux_wire),			//output
		.reg_file_write_addr_mux_select	(reg_file_addr_mux_sel),	//output
		.reg_file_write_data_mux_select	(reg_file_data_mux_sel),	//output
		.alu_mux_select			(alu_mux_sel),			//output
		.alu_control			(control_wire),			//output
		.pc_control			(pc_control_wire)		//output
	);

//mux_2to1 Rt&Rd
	mux_2to1_reg cpu_mux_2to1_reg_file
	(
		.in0				(Instruction[20:16]),		//input
		.in1				(Instruction[15:11]),		//input
		.out				(write_reg_wire),		//output
		.select				(reg_file_addr_mux_sel)		//input
	);	

//mux_2to1 31& (Rt&Rd)
	mux_2to1_reg cpu_mux_2to1_31_jal
	(
		.in0				(jal_31_wire),			//input	//jal
		.in1				(write_reg_wire),		//input 
		.out				(write_reg_2_wire),		//output
		.select				(jal_mux_wire)			//input
	);	

//add 8 adder
	assign pc_addr_add_8_wire = pc_addr_add_4_wire + 4;

//sign extension pc_addr_add_8_wire
	sign_extension#(18,32) cpu_sign_extention_pc_addr_add_8_wire
	(
		.in				(pc_addr_add_8_wire),		//input
		.out				(pc_addr_add_8_ext_wire)	//output
	);

//mux_2to1 jal
	mux_2to1 cpu_mux_2to1_jal
	(
		.in0				(pc_addr_add_8_ext_wire),	//input //jal
		.in1				(reg_file_write_data_wire),	//input
		.out				(reg_file_write_data_2_wire),	//output
		.select				(jal_mux_wire)			//input
	);	

//reg file
	Regfile cpu_register_file
	(
		.clk				(clk),				//input 
		.rst				(rst),				//input
		.Read_addr_1			(Instruction[25:21]),		//input
		.Read_addr_2			(Instruction[20:16]),		//input
		.Read_data_1			(read_data1_wire),		//output
                .Read_data_2			(read_data2_wire),		//output
		.RegWrite			(reg_file_write_enable_wire),	//input
		.Write_addr			(write_reg_2_wire),		//input
		.Write_data			(reg_file_write_data_2_wire)	//input
	);


//sign extension imm
	sign_extension cpu_sign_extention_imm
	(
		.in				(Instruction[15:0]),		//input
		.out				(sign_ext_imm_wire)		//output
	);

//mux_2to1 alu
	mux_2to1 cpu_mux_2to1_alu
	(
		.in0				(sign_ext_imm_wire),		//input
		.in1				(read_data2_wire),		//input 
		.out				(src0_wire),			//output
		.select				(alu_mux_sel)			//input
	);	

//ALU
	ALU cpu_alu
	(
		.ALUOp				(control_wire),			//input
		.src1				(read_data1_wire),		//input
		.src2				(src0_wire),			//input
		.shamt				(Instruction[10:6]),		//input
		.ALU_result			(alu_result_wire),		//output
		.Zero				(zero_wire)			//output
	);	


//sign extension store
	sign_extension cpu_sign_extention_store
	(
		.in				(read_data2_wire[15:0]),	//input
		.out				(read_data2_half_wire)		//output
	);

//mux_2to1 store
	mux_2to1 cpu_mux_2to1_store
	(
		.in0				(read_data2_wire),		//input
		.in1				(read_data2_half_wire),		//input
		.out				(dm_write_data),		//output
		.select				(store_mux_wire)		//input
	);	

	assign DM_Address = alu_result_wire[17:2];
	assign DM_enable = dm_enable;
	assign DM_Write_Data = dm_write_data;


//sign extension load
	sign_extension cpu_sign_extention_load
	(
		.in				(DM_Read_Data[15:0]),		//input
		.out				(DM_Read_half_Data)		//output
	);


//mux_2to1 load
	mux_2to1 cpu_mux_2to1_load
	(
		.in0				(DM_Read_Data),			//input
		.in1				(DM_Read_half_Data),		//input
		.out				(dm_data_result),		//output
		.select				(load_mux_wire)			//input
	);		

//mux_2to1 alu&DM
	mux_2to1 cpu_mux_2to1_mem
	(
		.in0				(alu_result_wire),		//input
		.in1				(dm_data_result),		//input
		.out				(reg_file_write_data_wire),	//output
		.select				(reg_file_data_mux_sel)		//input
	);	




endmodule


























