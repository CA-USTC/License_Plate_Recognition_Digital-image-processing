
function [img_out, cnt,p_xingtai,p_yanse] = plate_location_top(img)

cnt_xingtai=0;
cnt_yanse=0;
[p,q,~]=size(img);
%% 自动弹出提示框读取图像
% figure;

% subplot(1,2,1), imshow(img),title('车牌图像');
%% 高斯模糊，滤除过多边缘
G = fspecial('gaussian', [5 5], 6);
img_gaussian = imfilter(img,G,'same');
% subplot(1,2,2), imshow(img_gaussian), title('高斯模糊')
%% 灰度处理
img_gray = rgb2gray(img_gaussian);    % RGB图像转灰度图像
% figure;
% imshow(img_gray);
% title('灰度图像');


%% 边缘提取
img_edge = edge(img_gray, 'Sobel','vertical');
% figure('name','边缘检测');
% imshow(img_edge);
% title('Sobel算子边缘检测');
%% 自适应阈值二值化
k=graythresh(im2double(img_edge));              %得到最优阈值
img_bin=imbinarize(im2double(img_edge),k);  
% figure('name','二值化')
% imshow(img_bin);

%% 闭操作,图像膨胀
se = strel('rectangle', [double(int16(0.012*p)), double(int16(0.025*p))]);
img_close = imclose(img_bin, se);
% figure('name','平滑处理');
% imshow(img_close);
% title('图像闭运算');
%% 腐蚀，隔断细小联系
se=ones(double(int16(0.0025*p)), double(int16(0.0075*p)));
img_erode = imerode(img_close, se);
% figure('name','图像腐蚀');
% imshow(img_erode);
% title('图像腐蚀后的图像');
%% 从图像中删除所有少于1/200像素8邻接的小区域
threshold = p*q/200;
img_del = bwareaopen(img_erode,double( int16(threshold)));
% figure('name', '移除小对象');
% imwrite(img_del,'移除小对象.jpg')
% imshow(img_del);
% title('从图像中移除小对象');
%% 取出所有对象轮廓，并求出外界矩形的长宽比，面积，进行筛选
cnt_xingtai=0;
cnt_yanse=0;
bound = bwboundaries(img_del);
[num, ~] = size(bound); %获取对象个数
rect_area = zeros(1, num);% 存储面积
rect_ratio = zeros(1, num); % 存储长宽比
rect_slope = zeros(1, num); % 存储倾斜角度
for i = 1 : 1 : num %遍历所有对象轮廓
    [rectx,recty,area] = boundrect((bound{i}(:,1)), (bound{i}(:,2)) ,'a'); % 求外接矩形，有坑。这个函数的rectx是竖着的左边，即图形的y
    Length = sqrt( (rectx(1)-rectx(2))^2 + (recty(1)-recty(2))^2 );
    Width = sqrt( (rectx(2)-rectx(3))^2 + (recty(2)-recty(3))^2 );
    rect_area(1, i) = area; % 面积
    if Length/Width >= 1
        rect_ratio(1, i) = Length/Width;
        % 利用较长的边，计算斜率
        rect_slope(1, i) =(rectx(1)-rectx(2)) / (recty(1)-recty(2));
    else
        rect_ratio(1, i) = Width/Length;
        rect_slope(1, i) =(rectx(2)-rectx(3))  /(recty(2)-recty(3));
    end
end
thr_ratio = 4.727272; error = 0.4; % 长宽比条件以及误差
thr_area_min = 0; thr_area_max = p*q/10; %面积范围
thr_slope_min = -atan(pi/6);thr_slope_max = atan(pi/6);
candidate = [];
for j = 1 : 1: num %条件判断
    if (rect_ratio(1,j) > thr_ratio*(1-error) ) && ( rect_ratio(1,j)<  thr_ratio*(1+error)  ) ...
          && (rect_slope(1, j)>= thr_slope_min) && (rect_slope(1, j)<= thr_slope_max)...
         && (  rect_area(1, j) >= thr_area_min) &&( rect_area(1, j) <= thr_area_max )
       
        candidate = [candidate, j];
    else
        cnt_xingtai=cnt_xingtai+1;
    end
end
%% 取出所有候选矩形
% 候选人个数
[~, num_cnd]=size(candidate);
cnt = 0;
[H,W,~] = size(img);

memory = zeros(5, 40 ,130, 3);
% '未进行颜色检测有'
% num_cnd
for k = 1:1:num_cnd

    ndx = candidate(1, k);
    [x,y] = boundrect(bound{ndx}(:,1),  bound{ndx}(:,2)); % 求外接矩形
 
    up = int16(min(x)+1);
    down = int16(max(x)-1);
    left = int16(min(y)+1);
    right = int16(max(y)-1);
    if up <=1
        up =1;
    end
     if down >=H
        down =H;
     end
    if left <=1
        left=1;
    end
    if right >=W
        right = W;
    end
    img_rectify = img(up:down, left:right ,  :); 
    if detection_color(img_rectify) == 1   % 颜色判别通过，为黄色或蓝色
           % 因为前面有腐蚀，因此截取稍大范围

            up=up-10;
            down = down+10;
            left = left-10;
            right = right+10;
            if up <=1
                up =1;
            end
             if down >=H
                down =H;
             end
            if left <=1
                left=1;
            end
            if right >=W
                right = W;
            end
            cnt=cnt+1;
            img_crop_ex = img(up:down, left:right ,  :); 
%             figure();
%             imshow(img_crop_ex),title('未矫正图像');
%             imwrite(imresize(img_crop_ex, [40 130],'bicubic'),strcat('未矫正图像', num2str(cnt), '.jpg'))
            img_rectify=rectify(img_crop_ex);
            
            
            img_rectify= imresize(img_rectify, [40 130],'bicubic');
%             figure('name', strcat('定位剪切图像', num2str(cnt)));
%             imshow(img_rectify);
%             title(strcat('定位剪切图像', num2str(cnt)))
%             imwrite(img_rectify,);
        memory(cnt,: , :, :) = img_rectify;
    else 
        cnt_yanse=cnt_yanse+1;
    end
    img_rectify= imresize(img_rectify, [40 130],'bicubic');
end
if cnt == 1
    img_out = img_rectify;
elseif cnt ==0
        img_out = zeros(130, 280);
else
    img_out = memory;
    
end

p_xingtai=(num-cnt_xingtai)/num;
p_yanse = (num_cnd-cnt_yanse)/num_cnd;


end

