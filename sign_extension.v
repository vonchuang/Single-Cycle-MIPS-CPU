//sign_extension

module sign_extension(	in,
			out
			);


	parameter INPUT_SIZE  = 16;
	parameter OUTPUT_SIZE = 32;

	input   [INPUT_SIZE-1:0]  in;
	output  [OUTPUT_SIZE-1:0] out;

	localparam SIGN_BIT_LOCATION	      = INPUT_SIZE - 1;
	localparam SIGN_BIT_REPLICATION_COUNT = OUTPUT_SIZE - INPUT_SIZE;

	assign out = {{SIGN_BIT_REPLICATION_COUNT{in[SIGN_BIT_LOCATION]}}, in[INPUT_SIZE-1:0]};


endmodule

