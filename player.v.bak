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
	
	wire [7:0] x;
	wire [6:0] y;
	wire [2:0] color;
	
	wire clock_out;
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	XCounter right(
	.clock(KEY[0]),
	.resetn(SW[0]),
	.enable(SW[1]), 
	.increase(1'b1),
	.x_out(x)
	);
	
	XCounter left(
	.clock(KEY[3]),
	.resetn(SW[0]),
	.enable(SW[1]), 
	.increase(1'b0),
	.x_out(x)
	);
	
	YCounter down(
	.clock(KEY[2]),
	.resetn(SW[0]),
	.enable(SW[1]), 
	.increase(1'b1),
	.y_out(y)
	);
	
	YCounter up(
	.clock(KEY[1]),
	.resetn(SW[0]),
	.enable(SW[1]), 
	.increase(1'b0),
	.y_out(y)
	);
	
	playerx sizex(
	.clock(CLOCK_50),
	.move_enable(KEY[3:0]),
	.x_out(x)
	);
	
	playery sizey(
	.clock(CLOCK_50),
	.move_enable(KEY[3:0]),
	.y_out(y)
	);
	
	bullet b(
	.clock(CLOCK_50),
	.shoot(SW[9]),
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

module XCounter (clock, resetn, enable, increase, x_out);
	input clock; // declare clock
	input resetn; // declare resetn
	input enable; // enable
	input increase; // increase or not
	output [7:0] x_out;
	
	reg [7:0] m; // declare m
	always @(posedge clock) // triggered every time clock rises
	begin
		if (resetn == 1'b0) // when resetn is 0
			m <= 0; // m is set to 0
		else if (enable == 1'b1) // increment m only when enable is 1
			begin
				if (increase == 1'b1)
					m <= m + 1'b1; // increment m
				else
					m <= m - 1'b1; // decrement m
			end
	end
	assign x_out = m;
endmodule


module YCounter (clock, resetn, enable, increase, y_out);
	input clock; // declare clock
	input resetn; // declare resetn
	input enable; // enable
	input increase; // increase or not
	output [6:0] y_out;
	
	reg [6:0] m; // declare m
	always @(posedge clock) // triggered every time clock rises
	begin
		if (resetn == 1'b0) // when resetn is 0
			m <= 7'd60; // m is set to 0
		else if (enable == 1'b1) // increment m only when enable is 1
			begin
				if (increase == 1'b1)
					m <= m + 1'b1; // increment m
				else
					m <= m - 1'b1; // decrement m
			end
	end
	assign y_out = m;
endmodule

module playerx (clock, move_enable, x_out);
	input clock; // declare clock
	input [3:0] move_enable;
	output [7:0] x_out;
	
	reg [7:0] m; // declare m
	
	reg [7:0] temp;
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (move_enable[0] & move_enable[1] & move_enable[2] & move_enable[3])
			begin
				if (temp == m)
					m <= m + 1;
				else if (temp == m - 1'b1)
					m <= m - 2'b10;
				else if(temp == m + 1'b1)
					m <= m + 1;
				else
					m <= temp;
			end
		else
			temp <= m;
	end
	assign x_out = m;
endmodule


module playery (clock, move_enable, y_out);
	input clock; // declare clock
	input [3:0] move_enable;
	output [6:0] y_out;
	
	reg [6:0] m; // declare m
	
	reg [6:0] temp;
	
	always @(posedge clock) // triggered every time clock rises
	begin
		if (move_enable[0] & move_enable[1] & move_enable[2] & move_enable[3])
			begin
				if (temp == m)
					m <= m + 1;
				else if(temp == m - 1'b1)
					m <= m - 1'b1;
				else
					m <= temp;
			end
		else
			temp <= m;
	end
	assign y_out = m;
endmodule

module bullet (clock, shoot, y_out, clock_out);
	input clock; // declare clock
	input shoot;
	
	output reg clock_out;
	output [6:0] y_out;
	
	reg[23:0] counter;
	reg [6:0] m; // declare m
	
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

module DelayCounter (clock, resetn, enable, delay_out);
	input clock; // declare clock
	input resetn; // declare resetn
	input enable; // declare enable
	output [19:0] delay_out;
	
	reg [19:0] m; // declare m
	always @(posedge clock) // triggered every time clock rises
	begin
		if (resetn == 1'b0) // when reset n is 0
			m <= 0; // m is set to 0
		else if (enable == 1'b1) // increment m only when enable is 1
			begin
				if (m == 20'd833400)
					m <= 0; // m reset
				else // when m is not the minimum value
				   m <= m + 1'b1; // increase m
			end
	end
	assign delay_out = m;
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
