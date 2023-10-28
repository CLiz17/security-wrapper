module decrypter(c11,c12,c21,c22,d,clk,M1,M2);
input [15:0]c11;
input [15:0]c12;
input [15:0]c21;
input [15:0]c22;
input [6:0]d;
input clk;
output reg [15:0]M1;
output reg [15:0]M2;
reg [15:0]v1n;
reg [15:0]v2n;
reg [15:0]v1;
reg [15:0]v2;
reg [15:0]nv2n;
reg [31:0]nc1;
reg [3:0]test;
reg [3:0]i=1;
`define t0 4'h0
`define t1 4'h1
reg [31:0] M;
reg [15:0] RAM1[(2**14)-1:0];
reg [15:0] RAM2[(2**14)-1:0];
reg [15:0] RAM3[(2**14)-1:0];
reg [15:0] RAM4[(2**14)-1:0];
initial 
begin
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
  RAM=RAM2[t-16385];
  else if (32768<t && t<49153)
  RAM=RAM3[t-32769];
  else 
  RAM=RAM4[t-49153];
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
y1>y2 && x1>x2 || y1<y2 && x1<x2:
  begin
  if(y1>y2 && x1>x2)
  begin
  k=y1-y2;
  g=x1-x2;
  end
  else
  begin
   k=y2-y1;
  g=x2-x1;
  end
  if(g<=65521)
  lambdafinder=(k*RAM(g))%65521;
  else
  lambdafinder=(k*RAM(g-65521))%65521;
  end
y1>y2 && x1<x2 || y1<y2 && x1>x2 :
  begin
  if(y1>y2 && x1<x2)
  begin
  k=y1-y2;
  g=x2-x1;
  end
  else
  begin
  k=y2-y1;
  g=x1-x2;
  end
  if(g<=65521)
  lambdafinder=65521-((k*RAM(g))%65521);
  else
  lambdafinder=65521-((k*RAM(g-65521))%65521);
  end

default:
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
v1=c11;
v2=c12;
v1n=v1;
v2n=v2;
test = `t0;
case(test)
`t0:
  begin
  if(i<d)
  begin
  nc1=add2p(v1n,v2n,v1,v2);
  v1n=nc1[31:16];
  v2n=nc1[15:0];
  i=i+1;
  test=`t0;
  end
  end

endcase

nv2n=11-(v2n%11);
M=add2p(c21,c22,v1n,nv2n);
M1=M[31:16];
M2=M[15:0];
end

endmodule