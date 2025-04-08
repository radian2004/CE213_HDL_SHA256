/*!
* @file compression.v
* @brief SHA256 Message Compression Module
* @author LDFranck
* @date February 2023
* @version v1
*
* @details
*  SHA256 message compression module implementation in Verilog.
*  The module outputs the compression function working variables
*  in a 256-bits bus 'hash'. The message slices generated through
*  the message expansion module must be fed into 'msg'. Compression
*  constants K must be stored in an auxiliary module and be available
*  at 'k' input as needed. External control logic is necessary.
*/

module compression(hash, msg, k, clk, rst_n, soc, eoc);

	localparam Ha_0 = 32'h6a09e667;
	localparam Hb_0 = 32'hbb67ae85;
	localparam Hc_0 = 32'h3c6ef372;
	localparam Hd_0 = 32'ha54ff53a;
	localparam He_0 = 32'h510e527f;
	localparam Hf_0 = 32'h9b05688c;
	localparam Hg_0 = 32'h1f83d9ab;
	localparam Hh_0 = 32'h5be0cd19;

	input  clk, rst_n, soc, eoc;
	input  [31:0]  msg, k;
	output [255:0] hash;

	wire [31:0] A, B, C, D, E, F, G, H;
	wire [31:0] Ha, Hb, Hc, Hd, He, Hf, Hg, Hh;
	
	wire [31:0] addMsg, addE, addA;
	wire [31:0] us0, us1, maj, ch;
	
	wvar 	 uA(Ha, A, addA, Ha_0, clk, rst_n, soc, eoc);
	wvar 	 uB(Hb, B,    A, Hb_0, clk, rst_n, soc, eoc);
	wvar 	 uC(Hc, C,    B, Hc_0, clk, rst_n, soc, eoc);
	wvar 	 uD(Hd, D,    C, Hd_0, clk, rst_n, soc, eoc);
	wvar 	 uE(He, E, addE, He_0, clk, rst_n, soc, eoc);
	wvar 	 uF(Hf, F,    E, Hf_0, clk, rst_n, soc, eoc);
	wvar 	 uG(Hg, G,    F, Hg_0, clk, rst_n, soc, eoc);
	wvar 	 uH(Hh, H,    G, Hh_0, clk, rst_n, soc, eoc);

	usigma #(2, 12, 22)  u0(us1, E);
	choice	 u1(ch, E, F, G);

	assign addMsg = msg + k + us1 + ch + H;

	assign addE = addMsg + D;

	usigma #(6, 11, 25)	 u4(us0, A);
	majority u5(maj, A, B, C);

	assign addA = us0 + maj + addMsg;	

	assign hash = {Ha, Hb, Hc, Hd, He, Hf, Hg, Hh};

endmodule
