module player
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	
	wire [7:0] x ;
	wire [6:0] y ;
	wire [2:0] color ;
	
	wire clock_out;
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	XCounter horizon(
	.clock(CLOCK_50),
	.resetn(SW[0]),
	.right(KEY[0]), 
	.left(KEY[3]),
	.x_out(x)
	);
	
	YCounter vert(
	.clock(CLOCK_50),
	.resetn(SW[0]),
	.up(KEY[2]), 
	.down(KEY[3]),
	.y_out(y),
	.clock_out(clock_out)
	);
	
	
	eraser e1(
	.clock(CLOCK_50),
	.colour_erase_enable(KEY[3:0]),
	.colour(color),
	.clock_out(clock_out)
	);
	
	vga_adapter VGA(
			.resetn(SW[4]),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule

module XCounter (clock, resetn, right, left, x_out);
	input clock; // declare clock
	input resetn; // declare resetn
	input right; // enable
	input left; // increase or not
	output [7:0] x_out;
	
	reg [7:0] m; // declare m
	
	reg [7:0] temp = 8'd80;
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (temp == m)
			m <= m + 1;
		else if (temp == m - 1'b1)
			m <= m - 2'b10;
		else if(temp == m + 1'b1)
			m <= m + 1;
		else
			m <= temp;
					
		if (resetn == 1'b0) // when resetn is 0
			m <= 8'd80; // m is set to 0
		else if (left ^ right)
			begin
				if (right == 1'b0)
					begin
						m <= m + 1'b1; // increment m
						temp <= m;
					end
				else
					begin
						m <= m - 1'b1; 
						temp <= m;
					end
			end
	end
	
	assign x_out = m;
endmodule


module YCounter (clock, resetn, up, down, y_out,clock_out);
	input clock; // declare clock
	input resetn; // declare resetn
	output clock_out;
	input up; // enable
	input down; // increase or not
	output [6:0] y_out;
	
	reg [6:0] m = 7'd110; // declare m
	
	reg [6:0] temp = 7'd110;
	
	
	always @(posedge clock) // triggered every time clock rises
	begin
		
		if (temp == m)
			m <= m + 1;
		else if(temp == m - 1'b1)
			m <= m - 1'b1;
		else
			m <= temp;
			
		if (resetn == 1'b0) // when resetn is 0
			m <= 7'd60; // m is set to 0
		else if (up ^ down) 
			begin
				if (down == 1'b0)
					begin
						m <= m + 1'b1; // increment m
						temp <= m;
					end
				else
					begin
						m <= m - 1'b1; // increment m
						temp <= m;
					end
			end
	end
	assign y_out = m;
endmodule

module bullet (y_in,clock, shoot, y_out, clock_out);
	input clock; // declare clock
	input shoot;
	input [6:0] y_in;
	
	output reg clock_out;
	output [6:0] y_out;
	
	reg[23:0] counter;
	reg [6:0] m; // declare m
	initial m = y_in[6:0];
	
	always @(posedge clock)
		begin
			if(!shoot)
				begin
					clock_out <= 1'b0;
					counter<=24'd0;
				end
			else
				begin
					if(counter==24'd10000000)
						begin
							counter<=24'd0;
							m <= m + 1'b1; // increment m
							clock_out <= ~clock_out;
						end
					else
						counter<=counter+1'b1;
				end
		end
	assign y_out = m;
endmodule

module eraser(clock,colour_erase_enable, colour, clock_out);
	input clock; // declare clock
	input clock_out;
	input [3:0] colour_erase_enable;
	
	output reg [2:0] colour;
	
	always @(posedge clock)
	begin
	if (colour_erase_enable[0] & colour_erase_enable[1] & colour_erase_enable[2] & colour_erase_enable[3])
		colour = 3'b011;
	else
		colour = 3'b000;
	end
endmodule
