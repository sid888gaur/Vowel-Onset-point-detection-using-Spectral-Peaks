clc;
clear all;

%%%% Input %%%%
[a, fs] = audioread('sample.m4a');
len = length(a)/fs;
sample_len = floor(((len*1000) - 10)/10);
sp = zeros(sample_len,1);
sound(a,fs);
subplot(321)
plot(a);
title("Signal");

%% 10 maximum values and spectral peak calculation %%
for i = 2:sample_len
    a_test = a(fs*(i-1)*0.01 : fs*(i+1)*0.01);
    a_test_fft  = fft(a_test,256);
    a_test_fft2 = a_test_fft(1:128);
    [sortedX,sortingIndices] = sort(a_test_fft2,'descend');
    maxValues = sortedX(1:10);
    for j=1:10
        sp(i,1) = sp(i) + abs(maxValues(j));
    end
end
subplot(322);
plot(sp);
title("10 peaks");

%% Enhancing the signal by using the normalization technique
k = length(sp);
refrence = sp(2);
refrence_index = 2;
sp = smooth(sp);
subplot(323);
plot(sp);
title("Smoothened signal");
slp_pt = 34;
flag=0;
i=0;
sp_enh = zeros(k,1);
while(i<k)
    if(flag==0)
        if(slp_pt<k-1)
            while(sp(slp_pt)<sp(slp_pt+1))
                slp_pt = slp_pt+1;
                if(slp_pt==k)
                    break;
                end
            end
            if(sp(slp_pt) - sp(refrence_index) <= 10)
                for j = refrence_index:slp_pt
                    if(j>=k)
                        break;
                    end
                    if(j<k)
                        sp_enh(j,1) = (sp_enh(refrence_index-1));
                    end
                end

            else
                for j = refrence_index:slp_pt
                    if(j>=k)
                        break;
                    end
                    if(j<k)
                        sp_enh(j,1) = (sp(j) - sp(refrence_index))/(sp(slp_pt) - sp(refrence_index));
                    end
                end
            end
            refrence_index = slp_pt +1;
            i = slp_pt +1;
            flag=1;
        end
    end
    
    if(flag==1)
        if(slp_pt<k-1)
            while(sp(slp_pt)>sp(slp_pt+1))
                slp_pt = slp_pt+1;
                if(slp_pt==k)
                    break;
                end
            end
            if(sp(slp_pt) - sp(refrence_index) >= -10)
                for j = refrence_index:slp_pt
                    if(j>=k)
                        break;
                    end
                    if(j<k)
                        sp_enh(j,1) = (sp_enh(refrence_index- 1));
                    end
                end

            else
                for j = refrence_index:slp_pt
                    if(j>=k)
                        break;
                    end
                    if(j<k)
                        sp_enh(j,1) = (sp(j) - sp(slp_pt))/(sp(refrence_index) - sp(slp_pt));
                    end
                end
            end
            refrence_index = slp_pt +1;
            i = slp_pt +1;
            flag=0;
        end
    end
end
subplot(324);
plot(sp_enh);
title("Enhanced by FOD");

%% Finding Evidence plot

sp_enh = smooth(sp_enh);
g = gausswin(5); % 5 = window width / 2
g = diff(g);
y = conv(g,sp_enh);
%figure;
subplot(325);
plot(y);
title("Spectral peaks: FOGD");

gi = hamming(5);
gi = diff(gi);
z = conv(gi,sp_enh);
subplot(326);
plot(z);
title("Spectral peaks: Hamming");