n =1:1000;
x = sin(2*pi*n/12)+ cos(2*pi*n/4);
y = sin(2*pi*n/12);
z = 0.1/sqrt(2);
step_size=10^-2;


wn0=zeros(1,1000);wn1=wn0;wn2=wn0;wn3=wn0;wn4=wn0;
wn5=wn0;wn6=wn0;wn7=wn0;wn8=wn0;wn9=wn0;wn10=wn0;
wn11=wn0;wn12=wn0;wn13=wn0;wn14=wn0;

w_0=0;w_1=0;w_2=0;w_3=0;w_4=0;
w_5=0;w_6=0;w_7=0;w_8=0;w_9=0;
w_10=0;w_11=0;w_12=0;w_13=0;w_14=0;


for n=16:1000    %saving past wt
    x_hat(n) = w_0*x(n) + w_1*x(n-1) + w_2*x(n-2) + w_3*x(n-3) + w_4*x(n-4) + w_5*x(n-5) + w_6*x(n-6) + w_7*x(n-7) + w_8*x(n-8) + w_9*x(n-9) + w_10*x(n-10) + w_11*x(n-11) + w_12*x(n-12) + w_13*x(n-13) + w_14*x(n-14);
    e(n) = x(n)-x_hat(n);
		
    %updating past wt
    w_0 = w_0+(step_size)*(e(n)*(x(n)) );
    wn0(n) = w_0;
    w_1 = w_1+(step_size)*(e(n)*(x(n-1)) );
    wn1(n) = w_1;
	w_2 = w_2+(step_size)*(e(n)*(x(n-2)) );
    wn2(n) = w_2;
    w_3 = w_3+(step_size)*(e(n)*(x(n-3)) );
    wn3(n) = w_3;
	w_4 = w_4+(step_size)*(e(n)*(x(n-4)) );
    wn4(n) = w_4;
    w_5 = w_5+(step_size)*(e(n)*(x(n-5)) );
    wn5(n) = w_5;
	w_6 = w_6+(step_size)*(e(n)*(x(n-6)) );
    wn6(n) = w_6;
    w_7 = w_7+(step_size)*(e(n)*(x(n-7)) );
    wn7(n) = w_7;
	w_8 = w_8+(step_size)*(e(n)*(x(n-8)) );
    wn8(n) = w_8;
    w_9 = w_9+(step_size)*(e(n)*(x(n-9)) );
    wn9(n) = w_9;
	w_10 = w_10+(step_size)*(e(n)*(x(n-10)) );
    wn10(n) = w_10;
    w_11 = w_11+(step_size)*(e(n)*(x(n-11)) );
    wn11(n) = w_11;
	w_12 = w_12+(step_size)*(e(n)*(x(n-12)) );
    wn12(n) = w_12;
    w_13 = w_13+(step_size)*(e(n)*(x(n-13)) );
    wn13(n) = w_13;
	w_14 =w_14+(step_size)*(e(n)*(x(n-14)) );
    wn14(n) = w_14;
end

plot(1:length(x),wn0,1:length(x),wn1,1:length(x),wn2,1:length(x),wn3,1:length(x),wn4,1:length(x),wn5);hold on;
plot(1:length(x),wn6,1:length(x),wn7,1:length(x),wn8,1:length(x),wn9,1:length(x),wn10,1:length(x),wn11);hold on;
plot(1:length(x),wn12,1:length(x),wn13,1:length(x),wn14);hold on;
legend('wn0','wn1','wn2','wn3','wn4','wn5','wn6','wn7','wn8','wn9','wn10','wn11','wn12','wn13','wn14');
xlabel('n');
ylabel('Coefficient of weights');

for i=16:986
    E(i)=rms(e(i:i+14));
end
figure;
plot(E);hold on;
xlabel('n');
ylabel('r');

weight64 = [w_0,w_1,w_2,w_3,w_4,w_5,w_6,w_7,w_8,w_9,w_10,w_11,w_12,w_13,w_14,zeros(1,49)];
FFTweight = fft(weight64);
figure;
plot(real(FFTweight));
