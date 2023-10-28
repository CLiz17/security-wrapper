
//`include "ram module.v"

module encrypter(m1,m2,Privatekey,clk,c1,c2);
//input [15:0]g1;
//input [15:0]g2;
input [15:0]m1;
input [15:0]m2;
input [7:0]Privatekey;
input clk;
output reg [31:0]c1;
output reg [31:0]c2;
reg [15:0]g1=16'h0003;
reg [15:0]g2=16'hffeb;
reg [31:0]pubkey,newpkey;
reg [15:0]pu1,pu2,pu1n,pu2n,g1n,g2n,K;

//reg [15:0] RAM1[1:10000];
//reg [15:0] RAM2[10001:20000];
///reg [15:0] RAM3[20001:30000];
//reg [15:0] RAM4[30001:40000];
//reg [15:0] RAM5[40001:50000];
//reg [15:0] RAM6[50001:60000];
//reg [15:0] RAM7[60001:65600];
reg [15:0] RAM1[(2**14)-1:0];
reg [15:0] RAM2[(2**14)-1:0];
reg [15:0] RAM3[(2**14)-1:0];
reg [15:0] RAM4[(2**14)-1:0];
//reg [15:0] RAM5[(2**13)-1:0];
//reg [15:0] RAM6[(2**13)-1:0];
//reg [15:0] RAM7[(2**13)-1:0];
//reg [15:0] RAM8[(2**13)-1:0];
initial 
begin

$readmemh("RAM1.mem",RAM1);
$readmemh("RAM2.mem",RAM2);
$readmemh("RAM3.mem",RAM3);
$readmemh("RAM4.mem",RAM4);
//$readmemh("RAM5.mem",RAM5);
//$readmemh("RAM6.mem",RAM6);
//$readmemh("RAM7.mem",RAM7);
//$readmemh("RAM8.mem",RAM8);
end


function [15:0]RAM;
input [15:0]t;

begin
 if (t<16385)
  RAM=RAM1[t];
 else if (16384<t && t<32769)
  RAM=RAM2[t-16384];
  else if (32768<t && t<49153)
  RAM=RAM3[t-32769];
  else 
  RAM=RAM4[t-49153];
end
endfunction
 
 
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
default:
  lambdafinder=0;
  
endcase
end
endfunction




//function for adding two points
task add2p;
input [15:0]x1;
input [15:0]y1;
input [15:0]x2;
input [15:0]y2;
output [31:0]out;
reg [31:0]x3,y3,y;
reg [15:0]x4,y4;
reg [31:0]lambda;
begin
 lambda =lambdafinder(x1,y1,x2,y2);
  
  if(lambda**2<(x1+x2))
  begin
  y=x1+x2;
  x3=65521-((y-(lambda**2))%65521);//p=65521
  end
  else
  begin
  y=x1+x2;
  x3=(((lambda*lambda)-y)%65521); //p=65521
  end
  if(x1<x3)
  y3=(65521-(((lambda*(x3-x1))+y1)%65521));//p=65521
  else if(y1>(lambda*(x1-x3)))
  y3=(65521-((y1-lambda*(x1-x3))%65521));//p=65521
  else
  y3=(((lambda*(x1-x3))-y1)%65521);//p=65521
  
  x4=x3[15:0];
  y4=y3[15:0];
  out={x4,y4};
end
endtask


task Publickeygenerator;
input [15:0]g1;//generator points
input [15:0]g2;
input [7:0]Privatekey;
output [31:0]pu;
integer i;

reg [31:0]Fkey;
reg [15:0]g1n,g2n;
reg [3:0] test;
begin
i=1;
g1n=g1;
g2n=g2;
`define t0 4'h0
`define t1 4'h1

test=`t0;
case(test)
    `t0: 
        begin
        if(i<Privatekey)
        begin
         add2p(g1n,g2n,g1,g2,Fkey);
         g1n=Fkey[31:16];
         g2n=Fkey[15:0];
         i=i+1;
         test <=`t0;
        end
        end
endcase
pu=Fkey;
end
endtask

always @(posedge clk)
begin
K=2;
g1n=g1;
g2n=g2;


case(K)//K can have 3 different values 2,3,4
  2:
   begin
    add2p(g1n,g2n,g1,g2,c1);
   end
  3:
   begin
    add2p(g1n,g2n,g1,g2,c1);
    g1n=c1[31:16];
    g2n=c1[15:0];
    add2p(g1n,g2n,g1,g2,c1);
   end 
   4:
    begin
    add2p(g1n,g2n,g1,g2,c1);
    g1n=c1[31:16];
    g2n=c1[15:0];
    add2p(g1n,g2n,g1,g2,c1);
    g1n=c1[31:16];
    g2n=c1[15:0];
    add2p(g1n,g2n,g1,g2,c1);
    
   end
   default:
   begin
   g1n=g1;
   g2n=g2;
   c1={g1,g2};
   end
endcase


Publickeygenerator(g1,g2,Privatekey,pubkey);
pu1=pubkey[31:16];
pu2=pubkey[15:0];
pu1n=pu1;
pu2n=pu2;
case(K)
  2:
    begin
    add2p(pu1n,pu2n,pu1,pu2,newpkey);
    pu1n=newpkey[31:16];
    pu2n=newpkey[15:0];
    end
  3:
    begin
    add2p(pu1n,pu2n,pu1,pu2,newpkey);
    pu1n=newpkey[31:16];
    pu2n=newpkey[15:0];
    add2p(pu1n,pu2n,pu1,pu2,newpkey);
    pu1n=newpkey[31:16];
    pu2n=newpkey[15:0];
    end
  4:
    begin
    add2p(pu1n,pu2n,pu1,pu2,newpkey);
    pu1n=newpkey[31:16];
    pu2n=newpkey[15:0];
    add2p(pu1n,pu2n,pu1,pu2,newpkey);
    pu1n=newpkey[31:16];
    pu2n=newpkey[15:0];
    add2p(pu1n,pu2n,pu1,pu2,newpkey);
    pu1n=newpkey[31:16];
    pu2n=newpkey[15:0];
    end
endcase
add2p(m1,m2,pu1n,pu2n,c2);
end 
endmodule



