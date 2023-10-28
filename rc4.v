`timescale 1ns / 1ps

module RC4(ptxt,key,clk,ctxt);
input [31:0]ptxt;
input [31:0]key;
input clk;
output reg [31:0]ctxt;
reg [31:0]ltxt;
integer n=0;
integer i=0;
integer j=0;
integer k=0;
integer l=0;
integer m=0;
integer a=0;
integer b=0;
reg [7:0]S[0:255];
reg [7:0]K[0:255];
reg [7:0]y[0:7];
reg [63:0]dectxt;
reg [7:0]key1,key2,key3,key4,temp,t;
`define t0 4'h0
`define t1 4'h1
`define t2 4'h2
`define t3 4'h3
`define t4 4'h4
`define t5 4'h5
reg [3:0] test=`t0;
always@(posedge clk)
begin
key1=key[7:0];
key2=key[15:8];
key3=key[23:16];
key4=key[31:24];
case(test)
        `t0: 
        begin
        if(i==256)
        test <= `t1;
        else
        begin
        S[i]=i;
        test <= `t0;
        i=i+1;
        end
        end
        `t1:
        begin
        if(k==256)
        test <= `t2;
        else
        begin
        K[k]=key1;
        K[k+1]=key2;
        K[k+2]=key3;
        K[k+3]=key4;
        k=k+4;
        end
        end
        `t2:
        begin
        if(l==256)
        test <= `t3;
        else
        begin
        m=(m+S[l]+K[l])%256;
        temp=S[l];
        S[l]=S[m];
        S[m]=temp;
        l=l+1;
        end
        end
        `t3:
        begin
        if(n==4)
        test=`t4;
        else
        begin
        a=(a+1);
        b=(b+S[a])%256;
        temp=S[a];
        S[a]=S[b];
        S[b]=temp;
        t=(S[a]+S[b])%256;
        y[n]=S[t];
        n=n+1;
        end
        end
        `t4:
        begin
        ctxt[7:0]=y[0]^ptxt[7:0];
        ctxt[15:8]=y[1]^ptxt[15:8];
        ctxt[23:16]=y[2]^ptxt[23:16];
        ctxt[31:24]=y[3]^ptxt[31:24];
      
        end
        
    endcase
    
    end
    endmodule


        
        
