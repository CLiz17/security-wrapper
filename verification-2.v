module ecdsa_with_spongent(clk, r, s,m, out);
input [6:0]r;
input [6:0]s;
input clk;
input [31:0]m;
output reg [1:0]out;
reg [6:0]u1;
reg [6:0]u2;
reg [6:0]w;
reg [6:0]v;
reg [6:0]e;
reg [15:0] u1px,u1py,u2qx,u2qy,X1;
reg [6:0]modmulinv [(2**7)-1:0];
reg [31:0]u1p,u2q,X;
reg [31:0]Fkey;
reg [15:0]g1n,g2n,g1,g2;
integer i;
reg [3:0]test;
reg [6:0]d=7'd02;//privatekey

reg [15:0]inv_values[65519:0];
reg [6:0]a = 7'd02;
reg [6:0]b = 7'd03;
reg [15:0]x = 16'd0003;//generator points (x,y)
reg [15:0]y = 16'hffeb;//x and y
reg [6:0]V;
reg [6:0]n = 7'd83;
reg [15:0] RAM1[(2**14)-1:0];
reg [15:0] RAM2[(2**14)-1:0];
reg [15:0] RAM3[(2**14)-1:0];
reg [15:0] RAM4[(2**14)-1:0];

initial
begin
$readmemh("mod_mul_inv-1.mem",modmulinv);
$readmemh("RAM1.mem",RAM1);
$readmemh("RAM2.mem",RAM2);
$readmemh("RAM3.mem",RAM3);
$readmemh("RAM4.mem",RAM4);
end

function [15:0] RAM;
input [15:0]t;
begin
if (t<16385)
  RAM=RAM1[t];
 else if (16384<t && t<32769)
  RAM=RAM2[t];
  else if (32768<t && t<49153)
  RAM=RAM3[t];
  else 
  RAM=RAM4[t];
 end
endfunction

//function for finding lambda values
function [43:0]lambdafinder;
input [15:0]x1;
input [15:0]y1;
input [15:0]x2;
input [15:0]y2;
reg [15:0]k,g;
reg [43:0]t;
//ROM r1(.addr((2*y1)-65521),.dout(g));
begin
case (x1 || x2 || y1 || y2)
x1==x2 && y1==y2:
  begin
  if(2*y1>65521)
  g= RAM((2*y1)-65521);
  else
  g= RAM(2*y1);
  t=x1**2;
  lambdafinder=((((3*t)+2)*g)%65521);//p=65521,a=2
  end
y1>y2 && x1>x2:
  begin
  k=y1-y2;
  g=x1-x2;
  if(g<=65521)
  lambdafinder=(k*RAM(g))%65521;
  else
  lambdafinder=(k*RAM(g-65521))%65521;
  end
y1>y2 && x1<x2:
  begin
  k=y1-y2;
  g=x2-x1;
  if(g<=65521)
  lambdafinder=65521-((k*RAM(g))%65521);
  else
  lambdafinder=65521-((k*RAM(g-65521))%65521);
  end
y1<y2 && x1>x2:
  begin
  k=y2-y1;
  g=x1-x2;
  if(g<=65521)
  lambdafinder=65521-((k*RAM(g))%65521);
  else
  lambdafinder=65521-((k*RAM(g-65521))%65521);
  end  
y1<y2 && x1<x2:
  begin
  k=y2-y1;
  g=x2-x1;
  if(g<=65521)
  lambdafinder=(k*RAM(g))%65521;
  else
  lambdafinder=(k*RAM(g-65521))%65521;
  end
y2==y1 && x1!=x2:
  lambdafinder=0;
  
endcase
end
endfunction

//function for adding two points
function [31:0]add2p;
input [15:0]x1;
input [15:0]y1;
input [15:0]x2;
input [15:0]y2;
reg [31:0]x3,y3;
reg [15:0]x4,y4;
reg [31:0]lambda;
begin
  lambda=lambdafinder(x1,y1,x2,y2);
  
  if(lambda**2<(x1+x2))
  x3=65521-(((x1+x2)-(lambda**2))%65521);//p=65521
  else
  x3=(((lambda*lambda)-(x1+x2))%65521); //p=65521
  
  if(x1<x3)
  y3=(65521-(((lambda*(x3-x1))+y1)%65521));//p=65521
  else if(y1>(lambda*(x1-x3)))
  y3=(65521-((y1-lambda*(x1-x3))%65521));//p=65521
  else
  y3=(((lambda*(x1-x3))-y1)%65521);//p=65521
  
  x4=x3[15:0];
  y4=y3[15:0];
  add2p={x4,y4};
end
endfunction





always @(posedge clk)
begin
e = m[6:0];
w = modmulinv[s];
u1 = (e*w)%n;
u2 = (r*w)%n;
`define t0 4'h0
`define t1 4'h1
g1n=x;
g2n=y;
g1=x;
g2=y;
test=`t0;
case(test)
    `t0: 
        begin
        if(i<u1)
        begin
          Fkey = add2p(g1n,g2n,g1,g2);
         g1n=Fkey[31:16];
         g2n=Fkey[15:0];
         i=i+1;
         test =`t0;
         end
         end
endcase

u1p=Fkey;
g1n=x;
g2n=y;
g1=x;
g2=y;
test=`t0;
case(test)
    `t0: 
        begin
        if(i<d*u2)
        begin
          Fkey = add2p(g1n,g2n,g1,g2);
         g1n=Fkey[31:16];
         g2n=Fkey[15:0];
         i=i+1;
         test =`t0;
         end
         end
endcase

u2q=Fkey;
u1px=u1p[15:0];
u1py=u1p[31:16];
u2qx=u2q[15:0];
u2qy=u2q[31:16];

//u1P+u2Q
X=add2p(u1px,u1py,u2qx,u2qy);
X1=X[15:0];
//X Generated
v = X1%n;
if (v==r)
  out=1'b1;
else
  out=1'b0;
end
endmodule
