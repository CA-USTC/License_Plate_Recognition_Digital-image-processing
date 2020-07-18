%%
clear;
close all;
clc;
%% 读取图像
tic;
file_path =  'C:\Users\76075\Desktop\大三下课程\车牌识别\MATLAB车牌识别系统设计（二）\test_dataset\test_dataset\Set1\';% 图像文件夹路径  
img_path_list = dir(strcat(file_path,'*.jpg'));%获取该文件夹中所有bmp格式的图像  
img_num = length(img_path_list);%获取图像总数量 
figure(1);
xingtai = zeros(1,img_num);
yanse = zeros(1,img_num);
for j = 1:img_num %逐一读取图像 
    
    image_name = img_path_list(j).name;% 图像名  
    image =  imread(strcat(file_path,image_name));  
    [plate, cnt,xingtai(1,j),yanse(1,j)] = plate_location_top(image);
    if cnt ==1
     imwrite(squeeze(plate), strcat('C:\Users\76075\Desktop\大三下课程\车牌识别\MATLAB车牌识别系统设计（二）\plate_set1\', num2str(j),'.jpg'))
    elseif cnt>1
             for i = 1:cnt
                 imwrite(uint8(squeeze(plate(i,:,:,:))), strcat('C:\Users\76075\Desktop\大三下课程\车牌识别\MATLAB车牌识别系统设计（二）\plate_set1\', num2str(j),'_', num2str(i),'.jpg'))
             end
    else
        fprintf('%d  %s\n',j,'未检测出车牌');
    end
   fprintf('%d %s\n', j, image_name);% 显示正在处理的图像名  
end  


toc

% bar(1:img_num, xingtai);
% bar(1:img_num, yanse);

% figure(1);
% h1 = scatter(1:img_num, xingtai, 'r*'); hold on;
% h2 = scatter(1:img_num, yanse, 'b*'); hold on;
% % 既然只按颜色分，那么只需每类颜色的第一个即可~
% legend([h1(1),h2(1)],'形态通过率', '颜色通过率','location', 'northwest');





