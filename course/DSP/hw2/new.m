clc;clear;
image = double(importdata('Lenna.dat'));

LoD = [0.037828455507 -0.023849465020 -0.110624404418 0.377402855613 0.852698679009 0.377402855613 -0.110624404418 -0.023849465020 0.037828455507];
HiD = [-0.064538882629 0.040689417609 0.418092273222 -0.788485616406 0.418092273222 0.040689417609 -0.064538882629];
LoR = [-0.064538882629 -0.040689417609 0.418092273222 0.788485616406 0.418092273222 -0.040689417609 -0.064538882629];
HiR = [-0.037828455507 -0.023849465020 0.110624404418 0.377402855613 -0.852698679009 0.377402855613 0.110624404418 -0.023849465020 -0.037828455507];

colormap gray;

[cA_1,cH_1,cV_1,cD_1] = dwt2(image,LoD,HiD,'mode','symw');
[cA_2,cH_2,cV_2,cD_2] = dwt2(cA_1,LoD,HiD,'mode','symw');
[cA_3,cH_3,cV_3,cD_3] = dwt2(cA_2,LoD,HiD,'mode','symw');
    
LL3 = uint8(cA_3) ; HL3 = uint8(cV_3) ; LH3 = uint8(cH_3) ; HH3 = uint8(cD_3) ;
HL2 = uint8(cV_2) ; LH2 = uint8(cH_2) ; HH2 = uint8(cD_2) ; LL2 = uint8(cA_2);
HL1 = uint8(cV_1) ; LH1 = uint8(cH_1) ; HH1 = uint8(cD_1) ; LL1 = uint8(cA_1);



s1 = size(image);
img = idwt2(cA_1,cH_1,cV_1,cD_1,LoR,HiR,s1,'mode','symw');
% img = idwt2(LL1,LH1,HL1,HH1,LoR,HiR,s1);
imshow(img)
[peaksnr, snr] = psnr(img, image,255);
fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
subplot(3,4,1)  
imshow(LL3);
title('Level3 LL');

subplot(3,4,2)  
imshow(HL3);
title('Level3 HL');

subplot(3,4,3)  
imshow(LH3);
title('Level3 LH');

subplot(3,4,4)  
imshow(HH3);
title('Level3 HH');

subplot(3,4,5)  
imshow(LL2);
title('Level2 LL');

subplot(3,4,6)  
imshow(HL2);
title('Level2 HL');

subplot(3,4,7)  
imshow(LH2);
title('Level2 LH');

subplot(3,4,8)  
imshow(HH2);
title('Level2 HH');

subplot(3,4,9)  
imshow(LL1);
title('Level1 LL');

subplot(3,4,10)  
imshow(HL1);
title('Level1 HL');

subplot(3,4,11)  
imshow(LH1);
title('Level1 LH');

subplot(3,4,12)  
imshow(HH1);
title('Level1 HH');