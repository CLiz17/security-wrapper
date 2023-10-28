`timescale 1ns / 1ps

module deviceDecrypt(encryptedhead,d,clk,dectxt);

input [127:0]encryptedhead;
input [6:0]d;//private key
input clk;
wire [6:0]r;
wire [6:0]s;
output  [31:0]dectxt;
wire [63:0]C;
assign C = encryptedhead[68:5];
reg [15:0]M1,M2;
reg [31:0]sessionkey; 
wire [1:0]out;
wire [15:0]c11,c12,c21,c22;

assign c11 = C[15:0];
assign c12 = C[31:16];
assign c21 = C[47:32];
assign c22 = C[63:48];

decrypter d1(c11,c12,c21,c22,d,clk,M1,M2);

always @(posedge clk)
begin
sessionkey[15:0] = M1;
sessionkey[31:16] = M2;
end 

wire [31:0]ctxt;
assign ctxt = encryptedhead[100:69];

RC4 R1(ctxt, sessionkey, clk, dectxt);


assign r = dectxt[6:0];
assign s = dectxt[13:7];


ecdsa_with_spongent v1(clk, r, s,sessionkey, out);

endmodule