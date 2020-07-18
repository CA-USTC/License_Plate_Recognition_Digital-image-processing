function [I4] = rectify(img)
I1 = rgb2gray(img);  % 将原始图像转换为灰度图像
I2 = wiener2(I1, [5, 5]);  % 对灰度图像进行维纳滤波
I3 = edge(I2, 'canny');  % 边缘检测
% subplot(132), imshow(I3); 
[m, n] = size(I3);  % compute the size of the image
rho = round(sqrt(m^2 + n^2)); % 获取ρ的最大
theta = 180; % 获取θ的最大值
r = zeros(rho, theta);  % 产生初值为0的计数矩阵
for i = 1 : m
   for j = 1 : n
      if I3(i,j) == 1  % I3是边缘检测得到的图像
          for k = 1 : theta
             ru = round(abs(i*cosd(k) + j*sind(k)));
             r(ru+1, k) = r(ru+1, k) + 1; % 对矩阵计数 
          end
      end
   end
end

r_max = r(1,1); 
for i = 1 : rho
   for j = 1 : theta
       if r(i,j) > r_max
          r_max = r(i,j); 
          c = j; % 把矩阵元素最大值所对应的列坐标送给c
       end
   end
end
if c <= 90
   rot_theta = -c;  % 确定旋转角度
else
    rot_theta = 180 - c; 
end
I4 = imrotate(img, rot_theta, 'crop');  % 对图像进行旋转，校正图像


end

