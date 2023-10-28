`timescale 1ns / 1ps

module ecdsa_with_spongent(clk, m, d, r, s);
   
input clk;
input [6:0]d;//private key
input [31:0]m;
	
output reg [6:0]r;
output reg [6:0]s;
reg [6:0]e;//hashed value


reg [6:0]ninv_values[126:0];

always @(posedge clk)
begin
$readmemh("ninv_values.mem",ninv_values);
end

reg [6:0]a = 7'd02;
reg [6:0]b = 7'd03;
reg [6:0]x = 7'd03;//generator points (x,y)
reg [15:0]y = 16'hffeb;//x and y
reg [6:0]lambda_num;
reg [6:0]lambda_deno;
reg [6:0]lambda_denom;
reg [6:0]lambda;
reg [6:0]s_num;
reg [6:0]s_deno;
reg [6:0]x3;
reg [6:0]y3;
reg [6:0]n = 7'd80;//taking order of the subgroup as 80
reg [15:0] RAM1[(2**14)-1:0];
reg [15:0] RAM2[(2**14)-1:0];
reg [15:0] RAM3[(2**14)-1:0];
reg [15:0] RAM4[(2**14)-1:0];
//reg [15:0] RAM[1:21];
//ROM r1(.addr(address),.dout(data));

initial
begin
$readmemh("RAM1.mem",RAM1);
$readmemh("RAM2.mem",RAM2);
$readmemh("RAM3.mem",RAM3);
$readmemh("RAM4.mem",RAM4);
end

function [15:0]RAM;
input [15:0]t;

begin
 if (t<16385)
  RAM=RAM1[t];
 else if (16384<t && t<32769)
  RAM=RAM2[t-16385];
  else if (32768<t && t<49153)
  RAM=RAM3[t-32769];
  else 
  RAM=RAM4[t-49153];
  //else if (40000<t && t<50001)
  //RAM=RAM5[t];
  //else if (50000<t && t<60001)
  //RAM=RAM6[t];
  //else //if (60000<t && t<70001)
  //RAM=RAM7[t];
  //else if (56000<t && t<64001)
  //RAM=RAM8[t]; 
  
  //if (t<8001)
 // rom=RAM1[t];
 //else if (8000<t && t<16001)
 // rom=RAM2[t];
 // else if (16000<t && t<24001)
  //rom=RAM3[t];
  //else if (24000<t && t<32001)
  //rom=RAM4[t];
  //else if (32000<t && t<40001)
  //rom=RAM5[t];
  //else if (40000<t && t<48001)
  //rom=RAM6[t];
  //else if (48000<t && t<56001)
  //rom=RAM7[t];
  //else if (56000<t && t<64001)
  //rom=RAM8[t]; 

end
endfunction
 
//step 1 starts  
  
//2G  
always @(posedge clk)
begin
    lambda_num <= ((3*(x**2))+(a));
    lambda_deno <= (2*y);
    lambda_denom <= RAM(lambda_deno);
    lambda <= (lambda_num*lambda_deno)%65521;
    x3 <= ((lambda**2)-x-x)%65521;
    y3 = ((lambda*(x-x3))-y)%65521;    
end

//finished step 1
// (x3,y3) is x1 and y1

//step 2 starts
always @(posedge clk)
begin
    r <= (x3%n);
end
//step 2 ends
always @(posedge clk)
begin
e <= m[6:0];//truncated message to 7 bits
end

//step 5 starts
always @(posedge clk)
begin
    s_num <= (e+(d*r));
    s_deno <= ((ninv_values[2])%n);   
    s <= (s_num/s_deno)%n;  
end
//step 5 ends		
endmodule

