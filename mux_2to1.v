//mux_2to1

module mux_2to1(in0,
		in1,
		out,
		select
		);			

	parameter bit_size = 32;	

	input   [bit_size-1:0] in0;
	input   [bit_size-1:0] in1;
	input                  select;
	output  [bit_size-1:0] out;

	assign out = (select == 0)?in0 :in1;


endmodule
		
