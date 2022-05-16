function cen_all=get_centroid_from_bw_022322(PMapt,img1,channel_to_do,net2)

PMapt_bin=logical(PMapt);

PMapt_bin=bwareaopen(PMapt_bin,100);

se1=strel('disk',3);
PMapt_bin1=imopen(PMapt_bin,se1);
PMapt_bin1=bwareaopen(PMapt_bin1,36);

stats=regionprops(PMapt_bin1,'Area','Centroid','Image','MajorAxisLength','MinorAxisLength','BoundingBox');

all_pt_classify=[];
all_pt_classify_idx=[];
pt_all={};
ctt=1;
for j=1:length(stats)
    
    sbb=stats(j).BoundingBox;
       
    if stats(j).Area<5000 &&stats(j).Area>100 % not white out; contains high intensity area
        pt=img1(sbb(2)-5:sbb(2)+sbb(4)-1+5,sbb(1)-5:sbb(1)+sbb(3)-1+5,channel_to_do);
        pt=imresize(pt,[255,255]);
        all_pt_classify(:,:,1,ctt)=pt;
        all_pt_classify_idx(ctt)=j;
        pt_all{ctt}=pt;
        ctt=ctt+1;
    end
end


% [YPred,score] = classify(net2,all_pt_classify);
if length(all_pt_classify_idx)==0
    YPred=[];
else
    YPred=ones(size(all_pt_classify,4),1);
end
process_list=find(double(YPred)==max(double(YPred)));

cen_all=[];
pt_all={};
ctt=1;
for idx=1:length(process_list)
    %0.65um/pixel
    % 64: ~10um diameter neuron
    % 225:~20um diameter neuron
    % 529:~30um diameter neuron
    j=process_list(idx);
    sbb=stats(all_pt_classify_idx(j)).BoundingBox;
    pt=img1(sbb(2):sbb(2)+sbb(4)-1,sbb(1):sbb(1)+sbb(3)-1,channel_to_do);
    
    pt=double(pt)/max(double(pt(:)));
    pt_size=size(pt);
    pt=imgaussfilt(pt,2,'FilterSize',[15,15]); 
    pt=imresize(pt,[255,255]);        

    pt=adapthisteq(pt);

    pt=pt.*pt;

    pt=pt>max(pt(:))*0.5;
    pt=imfill(pt,'holes');

    pt=imresize(pt,pt_size);
     
    pt_all{idx}=pt;
    stats1=regionprops(pt,'Area','Centroid','BoundingBox','MajorAxisLength','MinorAxisLength');
    
    % fix two large neuron connected like a eclipse problem
    if length(stats1)>0
        if stats1(1).Area>0.20*size(pt,1)*size(pt,2)&&stats1(1).MajorAxisLength>2*stats1(1).MinorAxisLength
            pt(round(stats1(1).Centroid(2)),:)=0;
            stats1=regionprops(pt,'Area','Centroid','BoundingBox','MajorAxisLength','MinorAxisLength');
        end  
    end
    
    for k=1:length(stats1)
%         if stats1(k).MajorAxisLength>2*stats1(k).MinorAxisLength
%             continue;
%         end

        area_thres=9;

        if stats1(k).Area>=area_thres&&stats1(k).Area<size(pt,1)*size(pt,2)             
%             cen_all(ctt,:)=(stats1(k).Centroid-[stats(all_pt_classify_idx(j)).BoundingBox(3)/2,stats(all_pt_classify_idx(j)).BoundingBox(4)/2])+stats(all_pt_classify_idx(j)).Centroid; % replace the local position to global position in the slice
%                 cen_all(ctt,:)=(stats1(k).Centroid-[stats1(k).BoundingBox(3)/2,stats1(k).BoundingBox(4)/2])+stats(j).Centroid;
            cen_all(ctt,:)=stats1(k).Centroid+stats(all_pt_classify_idx(j)).BoundingBox(1:2); % replace the local position to global position in the slice            
            ctt=ctt+1;
        end
    end
end

%% check 1
% for i=1:100
%     subplot(10,10,i)
%     imagesc(pt_all{i});
% end
% % 
% %% check 2
% figure;
% imgpt2=squeeze(img1(:,:,channel_to_do));
% bbox=[];
% for i=1:length(pt_all)
%     idxx=1032;
%     bbox(i,:)=stats(idxx).BoundingBox;
% end   
% detectedImg = insertShape(imgpt2,'rectangle',bbox);
% imagesc(detectedImg)