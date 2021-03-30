A=[1,-1,3,6;2,0,2,1;3,-2,1,4;-2,1,-1,-1;1,3,6,5;0,-1,-2,5];
x=[2;5;0;-3];
n=[1;-1;-1;1;1;-1];
b=(A*x)+n;
%*********1.(a)*********
xhat_a = inv(A.'*A)*A.'*b;
norm_a = norm(x-xhat_a);
%*********1.(b)*********
[Q,R] = qr(A);
b_tilde = Q.'*b;
bhat =  b_tilde(1:4);
xhat_b = inv(R(1:4,1:4))*bhat;
norm2_ls = norm(x - xhat_b);
%*********1.(c)*********

cos = A(1,1)/(sqrt(A(1,1)^2 + A(2,1)^2));
sin = A(2,1)/(sqrt(A(1,1)^2 + A(2,1)^2));
Q1 = [cos,sin,0,0 ; -sin,cos,0,0 ; 0,0,1,0 ; 0,0,0,1];
R_given = Q1*A(1:4,:);
b_given = Q1*b(1:4,:);
x_hat_given = inv(R_given)*b_given
norm2_given = norm(x - x_hat_given)

fid=fopen(['/Users/chiaohu/Documents/NCHU/DSP/hw1','b.txt'],'w');%寫入檔案路徑
[r,c]=size(b);            % 得到矩陣的行數和列數
 for i=1:r
  for j=1:c
  fprintf(fid,'%f\t',b(i,j));
  end
  fprintf(fid,'\r\n');
 end
fclose(fid);