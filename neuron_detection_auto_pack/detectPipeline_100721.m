%auto neuron detection pipeline
function [pts,res_loc]=detectPipeline_100721(fname,rotate_angle,save_fld,channel_to_do,net_path)
%% 0: load network
net=load(net_path);
net1=net.net;

patch_size=[56 56 3];
%% 1: high intensity area pre-select

score_result_high={};
major_slice_area={};
tic;

se=strel('disk',50);
for tk=1:length(fname)
    imgp = imread(fname{tk});
    imgp=imrotate(imgp,rotate_angle);
    imgpt_high=imgp(:,:,channel_to_do)>220;
    imgpt_high=bwareaopen(imgpt_high,64);
    score_result_high{tk}=imgpt_high;
    
    % major slice area determine
    imgpt_slice=imgp(:,:,3)>1; % suppose we have DEPI, or change to other bg channels
    imgpt_slice=imopen(imgpt_slice,se);
    imgpt_slice=imfill(imgpt_slice,'holes');
    stats=regionprops(imgpt_slice);
    Areas_all=[stats.Area];
    Areas_all=sort(Areas_all);
    if length(Areas_all)>1&&Areas_all(end)>10*(Areas_all(end-1)) % contains a single very large region and several small region, which should be slice itself
        imgpt_slice=bwareaopen(imgpt_slice,max(Areas_all)-1);
    end
    se=strel('disk',10);
    imgpt_slice=imopen(imgpt_slice,se);
    major_slice_area{tk}=imgpt_slice;
end
toc;
%% 2:PMap generation
all_PMap={};
tic;

for tk=1:length(fname)
    imgp = imread(fname{tk});
    imgp=imrotate(imgp,rotate_angle);
   
    imgpt1=[];
    if channel_to_do==1 % red
        imgpt1(:,:,1)=imgp(:,:,1);
    else
        if channel_to_do==2 % green 
            imgpt1(:,:,1)=imgp(:,:,2);
%              edgeThreshold=0.4; amount=0.6;
%              imgpt1(:,:,1)=localcontrast(squeeze(uint8(imgpt1(:,:,1))),edgeThreshold,amount);
        else % usually we don't do blue but...
            imgpt1(:,:,1)=imgp(:,:,3); 
        end
    end
    imgpt1(:,:,2)=imgpt1(:,:,1)*0;
    imgpt1(:,:,3)=imgp(:,:,1)*0;    
    imgpt1=uint8(imgpt1);
    [score_result]=neuron_PMap_auto_parallel_AlexNet_mono_color_090621(net1,imgpt1,major_slice_area{tk},patch_size,channel_to_do);
%     score_result=score_result+score_result_high{tk};
    score_result=score_result.*major_slice_area{tk};
    all_PMap{tk}=score_result;
    disp('finish');
    toc;
end

%% 3: refine detection results
bbox_all_img={};
PMapt_all={};
tic;
patch_size1=[16 16]
for i=1:length(fname)
    PMapt=all_PMap{i};
    
    PMapt=PMapt*1/max(PMapt(:));

    PMapt=PMapt>0.4;
%     PMapt=bwareaopen(PMapt,64); % (8*8)
    
    imgp = imread(fname{i});
    imgp=imrotate(imgp,rotate_angle);
    
    cen_all=get_centroid_from_bw_022322(PMapt,imgp,channel_to_do);
    cen_all=round(cen_all);
    if ~isempty(cen_all)
        bbox_all=[cen_all(:,1)-floor(patch_size1(1)/2),cen_all(:,2)-floor(patch_size1(2)/2),ones(size(cen_all,1),1)*patch_size1(1),ones(size(cen_all,1),1)*patch_size1(2)];
        bbox_all_img{i}=bbox_all;
    else
        bbox_all_img{i}=[];
    end
    
    PMapt_all{i}=PMapt;
    
    toc;
end


%% 43: merge close patches
ctt=1;
close_patch_all={};
close_patch_dis_all=[];
ctt=1;
for i=1:length(fname)
    close_patch_idx={};
    if size(bbox_all_img{i},1)>1
        for j1=1:size(bbox_all_img{i},1)-1
            close_patch_idx{j1,1}=[j1];
            for j2=j1+1:size(bbox_all_img{i},1)
                bbc1=bbox_all_img{i}(j1,:);
                bbc2=bbox_all_img{i}(j2,:);
                close_patch_dis_all(ctt)=sum((bbc1(1:2)-bbc2(1:2)).^2)^0.5;
                ctt=ctt+1;
                if sum((bbc1(1:2)-bbc2(1:2)).^2)^0.5<10 % 
                    close_patch_idx{j1,1}=[close_patch_idx{j1,1},j2];
                    ctt=ctt+1;
                end
            end
        end
    end
    close_patch_all{i}=close_patch_idx;
end

%% 4: finallize detection result
bbox_all_img_cleared={};
pts={};
for i=1:length(fname)
    bbox_all_img_cleared{i}=bbox_all_img{i};
    
    for j=1:size(close_patch_all{i},1)        
        bbox_all_img_cleared{i}(j,:)=mean(bbox_all_img_cleared{i}(close_patch_all{i}{j},:),1);  
    end
    if ~isempty(close_patch_all{i})
        bbox_all_img_cleared{i}(close_patch_all{i}{j}(2:end),:)=[];
    end
    
    if ~isempty(bbox_all_img_cleared{i})
        pts{i}=bbox_all_img_cleared{i}(:,1:2)+bbox_all_img_cleared{i}(:,3:4)/2;
    end
end

save_channel='red';
if channel_to_do==1
    save_channel='red';
else
    if channel_to_do==2
        save_channel='green';
    else
        save_channel='blue';
    end
end

    
save([save_fld,'\','pts_dat_',save_channel,'.mat'],'pts');
pts_loc=[save_fld,'\','pts_dat_',save_channel,'.mat'];
res_loc=[save_fld,'\','detection_result_dat_info_',save_channel,'.mat'];
save([save_fld,'\','detection_result_dat_info_',save_channel,'.mat'],'pts_loc','bbox_all_img_cleared','fname')

%% save detected imgs
for tk=1:length(fname)
    imgp = imread(fname{tk});
    imgp=imrotate(imgp,rotate_angle);
    
    imgpt2=imgp*0;
    if channel_to_do==1 % red
        imgpt2(:,:,1)=imgp(:,:,1);
    end   
    if channel_to_do==2 % green 
        imgpt2(:,:,2)=imgp(:,:,2);
    end 
    if channel_to_do==3 % % usually we don't do blue but...
        imgpt2(:,:,3)=imgp(:,:,3); 
    end

    
%     score=ones(size(bbox_all_img_cleared{i},1),1);
    detectedImg = insertShape(imgpt2,'rectangle',bbox_all_img_cleared{tk});
    imwrite(detectedImg,[save_fld,'\','detection_result_img_',save_channel,'.tif'])
    
    figure('Position',[0 0 1900 1000]);
    imagesc(imgpt2);
    hold on
    for i=1:size(bbox_all_img_cleared{tk},1)
        rectangle('Position',bbox_all_img_cleared{tk}(i,:),'EdgeColor','yellow');
    end   
    set(gcf,'renderer','painters');
    saveas(gcf,[save_fld,'\','detection_result_img_',save_channel,'.eps'],'epsc');
    close
end
