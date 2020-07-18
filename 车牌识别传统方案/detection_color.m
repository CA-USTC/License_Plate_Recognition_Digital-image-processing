

function [pass] = detection_color(img)
hsi = rgb2hsi(img);
    [n,m,~]=size(hsi);
    blue = 0;
    yellow=0;
    for i = 1:n
        for j = 1:m
            % 检测蓝色或者黄色
            if (   hsi(i,j,1) >= 200/360 ) &&  (   hsi(i,j,1) <= 280/360 ) &&(hsi(i,j,2) >= 50/255)&&(hsi(i,j,3)>=50/255)% 蓝色
                blue=blue+1;
            elseif  (   hsi(i,j,1) >= 20/360 ) &&  (   hsi(i,j,1) <= 100/360 ) &&(hsi(i,j,2) >=160/255 )&&(hsi(i,j,3)>=50/255)% 黄色
                yellow = yellow+1;
            end
        end
    end
if ((blue)/(n*m) >=0.4)|| (yellow/(n*m) >=0.4)
    pass = 1;
else
    pass = 0;
end
end


