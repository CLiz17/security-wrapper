`timescale 1ns / 1ps
//`include "encryption ecc.v"
//`include "ecdsa_sign_gen.v"

module encryption(privatekey,sessionkey,headflit,encryptedhead,clk);
input [7:0]privatekey;
input [31:0]sessionkey;
input [127:0]headflit;
input clk;
output [127:0]encryptedhead;

wire [15:0]s1,s2;
wire [31:0]C1,C2;
wire [63:0]C;
wire [1:0]FT;
wire [2:0]VCID;
wire [5:0]SA,DA;
wire [7:0]PID;
wire [3:0]SEQN;
wire [31:0]ptxt;
wire [6:0]r,s;
wire [31:0]ctxt;

assign s1=sessionkey[15:0];
assign s2=sessionkey[31:16];
assign FT = headflit[1:0];
assign VCID = headflit[4:2];
assign SA = headflit[10:5];
assign DA = headflit[16:11];
assign PID = headflit[24:17];
assign SEQN = headflit[28:25];


ecdsa_with_spongent ec1(clk, sessionkey, privatekey, r, s);

assign ptxt[6:0]=r;
assign ptxt[13:7]=s;
assign ptxt[19:14]=SA;
assign ptxt[27:20]=PID;
assign ptxt[31:28]=SEQN;





encrypter E1(s1,s2,privatekey,clk,C1,C2);

assign C[31:0]=C1;
assign C[63:32]=C2;

RC4 r1(ptxt,sessionkey,clk,ctxt);

//assign ctxt=RC4(ptxt,sessionkey);
assign encryptedhead[1:0]=FT;
assign encryptedhead[4:2]=VCID;
assign encryptedhead[68:5]=C;
assign encryptedhead[100:69]=ctxt;
assign encryptedhead[106:101]=DA;


endmodule

