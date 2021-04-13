clc
clear all
lena = double(imread('Lenna.dat'));
out = zeros(256,256);
L = 256;
[out_l,out_h] = DWT_row(L,lena);
imshow([out_l,out_h])
[out_ll,out_lh,out_hl,out_hh] = DWT_col(L,out_l,out_h);
out(1:128,129:256) = out_hl;
out(129:256,1:128) = out_lh;
out(129:256,129:256) = out_hh;
d = [out_ll,out_lh,out_hl,out_hh];
imshow(d)
[out_l2,out_h2] = DWT_row(128,out_ll);
[out_ll2,out_lh2,out_hl2,out_hh2] = DWT_col(128,out_l2,out_h2);
out(1:64,65:128) = out_hl2;
out(65:128,1:64) = out_lh2;
out(65:128,65:128) = out_hh2;
c = [out_ll2,out_lh2,out_hl2,out_hh2];
imshow(c)
[out_l3,out_h3] = DWT_row(64,out_ll2);
b = [out_l3,out_h3];
imshow(b)
[out_ll3,out_lh3,out_hl3,out_hh3] = DWT_col(64,out_l3,out_h3);
a = [out_ll3,out_lh3;out_hl3,out_hh3];
imshow(a)
out(1:32,1:32) = out_ll3;
out(1:32,33:64) = out_hl3;
out(33:64,1:32) = out_lh3;
out(33:64,33:64) = out_hh3;
imshow(out)
[out_l00,out_h00] = iDWT_col(64,out_ll3,out_lh3,out_hl3,out_hh3);
[lena0] = iDWT_row(64,out_l00,out_h00);

[out_l01,out_h01] = iDWT_col(128,lena0,out_lh2,out_hl2,out_hh2);
[lena1] = iDWT_row(128,out_l01,out_h01);

[out_l2,out_h2] = iDWT_col(L,lena1,out_lh,out_hl,out_hh);
[lena2] = iDWT_row(L,out_l2,out_h2);
%imshow(lena2)

MSE = 0;
for i =1:256
    for j = 1:256
        MSE = MSE + (double(lena(i,j)) - double(lena2(i,j)))^2;
    end
end
MSE = MSE/(256^2);
PSNR = 10 *log10((255^2)/MSE)

function [out_1,out_h] = DWT_row(L,lena)
 
    w_l(1) = 0.037828455507;
    w_l(2) = -0.023849465020;
    w_l(3) = -0.110624404418;
    w_l(4) = 0.377402855613;
    w_l(5) = 0.852698679009;
    w_l(6:9) = [w_l(4) w_l(3) w_l(2) w_l(1) ];
   
    w_h(1) = -0.064538882629;
    w_h(2) = 0.040689419609;
    w_h(3) = 0.418092273222;
    w_h(4) = -0.788485616406;
    w_h(5:7) = [w_h(3) w_h(2) w_h(1)];

    s1 = zeros(L,L+8);
    s1(:,1:4) = [lena(:,5) lena(:,4) lena(:,3) lena(:,2)];
    s1(:,L+5:L+8) = [lena(:,L-1) lena(:,L-2) lena(:,L-3) lena(:,L-4)];
    s1(:,5:L+4) = lena;

    s2 = zeros(L,L+6);
    s2(:,1:3) = [lena(:,4) lena(:,3) lena(:,2)] ;
    s2(:,L+4:L+6) = [lena(:,L-1) lena(:,L-2) lena(:,L-3)];
    s2(:,4:L+3) = lena;

    for i =1:L
        temp_l = conv(s1(i,:) , w_l);
        out_1(i,:) = temp_l(1,9:2:8+L);

        temp_h = conv(s2(i,:),w_h);
        out_h(i,:) = temp_h(1,7:2:6+L);
    end
end
function [out_ll,out_lh,out_hl,out_hh] = DWT_col(L,in_l,in_h)
    w_l(1) = 0.037828455507;
    w_l(2) = -0.023849465020;
    w_l(3) = -0.110624404418;
    w_l(4) = 0.377402855613;
    w_l(5) = 0.852698679009;
    w_l(6:9) = [w_l(4) w_l(3) w_l(2) w_l(1) ];
   
    w_h(1) = -0.064538882629;
    w_h(2) = 0.040689419609;
    w_h(3) = 0.418092273222;
    w_h(4) = -0.788485616406;
    w_h(5:7) = [w_h(3) w_h(2) w_h(1)];
    
    s1 = zeros(L + 8,L/2);
    s1(1:4,:) = [in_l(5,:) ; in_l(4,:) ; in_l(3,:) ; in_l(2,:)];
    s1(L+5:L+8,:) = [in_l(L-1,:) ; in_l(L-2,:) ; in_l(L-3,:); in_l(L-4,:)];
    s1(5:L+4,:) = in_l;

    s2 = zeros(L + 6,L/2);
    s2(1:3,:) = [ in_l(4,:) ; in_l(3,:) ; in_l(2,:)];
    s2(L+4:L+6,:) = [in_l(L-1,:) ; in_l(L-2,:) ; in_l(L-3,:)];
    s2(4:L+3,:) = in_l;

    s3 = zeros(L + 8,L/2);
    s3(1:4,:) = [in_h(5,:) ; in_h(4,:) ; in_h(3,:) ; in_h(2,:)];
    s3(L+5:L+8,:) = [in_h(L-1,:) ; in_h(L-2,:) ; in_h(L-3,:); in_h(L-4,:)];
    s3(5:L+4,:) = in_h;

    s4 = zeros(L + 6,L/2);
    s4(1:3,:) = [ in_h(4,:) ; in_h(3,:) ; in_h(2,:)];
    s4(L+4:L+6,:) = [in_h(L-1,:) ; in_h(L-2,:) ; in_h(L-3,:)];
    s4(4:L+3,:) = in_h;

    for i =1:L/2
        temp_l2 = conv(s1(:,i) , w_l);
        out_ll(1:L/2,i) = temp_l2(9:2:8+L,1);

        temp_h2 = conv(s2(:,i),w_h);
        out_lh(1:L/2,i) = temp_h2(7:2:6+L,1);
        
        temp_l3 = conv(s3(:,i) , w_l);
        out_hl(1:L/2,i) = temp_l3(9:2:8+L,1);

        temp_h3 = conv(s4(:,i),w_h);
        out_hh(1:L/2,i) = temp_h3(7:2:6+L,1);
    end
end
function [lena] = iDWT_row (L, out_l,out_h)
    w_l(1) = -0.064538882629;
    w_l(2) = 0.040689419609;
    w_l(3) = 0.418092273222;
    w_l(4) = -0.788485616406;
    w_l(5:7) = [w_l(3) w_l(2) w_l(1)];
    
    w_h(1) = 0.037828455507;
    w_h(2) = -0.023849465020;
    w_h(3) = -0.110624404418;
    w_h(4) = 0.377402855613;
    w_h(5) = 0.852698679009;
    w_h(6:9) = [w_h(4) w_h(3) w_h(2) w_h(1) ];
    
    s1 = zeros(L,L+6);
    s1(:,4:2:L+3) = out_l;
    s1(:,1:3) = [s1(:,7) s1(:,6) s1(:,5)];
    s1(:,L+4:L+6) = [s1(:,L+2) s1(:,L+1) s1(:,L)];    

    s2 = zeros(L,L+6);
    s2(:,5:2:L+4) = out_h;
    s2(:,1:4) = [s2(:,9) s2(:,8) s2(:,7) s2(:,6)];
    s2(:,L+5:L+8) = [s2(:,L+3) s2(:,L+2) s2(:,L+1) s2(:,L)];
    
    for i =1:L
        temp_l = conv(s1(i,:) , w_l);
        out_1(i,:) = temp_l(1,7:6+L);

        temp_h = conv(s2(i,:),w_h);
        out_2(i,:) = temp_h(1,9:8+L);
    end
    lena = out_1 + out_2;
end
function [out_l,out_h] = iDWT_col(L,in_ll,in_lh,in_hl,in_hh)
    w_l(1) = -0.064538882629;
    w_l(2) = 0.040689419609;
    w_l(3) = 0.418092273222;
    w_l(4) = -0.788485616406;
    w_l(5:7) = [w_l(3) w_l(2) w_l(1)];
    
    w_h(1) = 0.037828455507;
    w_h(2) = -0.023849465020;
    w_h(3) = -0.110624404418;
    w_h(4) = 0.377402855613;
    w_h(5) = 0.852698679009;
    w_h(6:9) = [w_h(4) w_h(3) w_h(2) w_h(1) ];
    
    s1 = zeros(L+6,L/2);
    s1(4:2:L+3,:) = in_ll;
    s1(1:3,:) = [s1(7,:); s1(6,:); s1(5,:)];
    s1(L+4:L+6,:) = [s1(L+2,:) ;s1(L+1,:) ;s1(L,:)];    

    s2 = zeros(L+8,L/2);
    s2(5:2:L+4,:) = in_lh;
    s2(1:4,:) = [s2(9,:); s2(8,:); s2(7,:); s2(6,:) ];
    s2(L+5:L+8,:) = [s2(L+3,:); s2(L+2,:); s2(L+1,:); s2(L,:)];

    s3 = zeros(L+6,L/2);
    s3(4:2:L+3,:) = in_ll;
    s3(1:3,:) = [s3(7,:); s3(6,:); s3(5,:)];
    s3(L+4:L+6,:) = [s3(L+2,:); s3(L+1,:); s3(L,:)];    

    s4 = zeros(L+8,L/2);
    s4(5:2:L+4,:) = in_lh;
    s4(1:4,:) = [s4(9,:); s4(8,:); s4(7,:); s4(6,:) ];
    s4(L+5:L+8,:) = [s4(L+3,:); s4(L+2,:); s4(L+1,:); s4(L,:)];
    
    for i =1:L/2
        temp_l2 = conv(s1(:,i) , w_l);
        out_ll(1:L,i) = temp_l2(7:6+L,1);

        temp_h2 = conv(s2(:,i),w_h);
        out_lh(1:L,i) = temp_h2(9:8+L,1);
        
        temp_l3 = conv(s3(:,i) , w_l);
        out_hl(1:L,i) = temp_l3(7:6+L,1);

        temp_h3 = conv(s4(:,i),w_h);
        out_hh(1:L,i) = temp_h3(9:8+L,1);        
    end
    out_l = out_ll +out_lh;
    out_h = out_hl +out_hh;
end