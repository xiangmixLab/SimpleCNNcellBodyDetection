function cen_all=get_centroid_from_bw(PMapt,patch_size,img1,channel_to_do)

PMapt_bin=logical(PMapt);
stats=regionprops(PMapt_bin,'Area','Centroid','Image','MajorAxisLength','MinorAxisLength','BoundingBox');
cen_all=[];
ctt=1;

% all_bounding_box=[];
% for i=1:length(stats)
%     all_bounding_box(i,:)=stats(i).BoundingBox;
% end
% detectedImg = insertObjectAnnotation(img1,'rectangle',all_bounding_box,Area_all);
% test
% for i=1:100
%     subplot(10,10,i)
%     sbb=stats(i).BoundingBox;
%     pt=img1(sbb(2):sbb(2)+sbb(4)-1,sbb(1):sbb(1)+sbb(3)-1,channel_to_do);
%     imagesc(pt);
% end

se1=strel('disk',1);

for j=1:length(stats)
    
    sbb=stats(j).BoundingBox;
    
    if stats(j).Area<2500&&stats(j).Area>64 && sum(sum(stats(j).Image==0))>0 % not white out; contains high intensity area
        %0.65um/pixel
        % 64: ~10um diameter neuron
        % 225:~20um diameter neuron
        % 529:~30um diameter neuron
        pt=img1(sbb(2):sbb(2)+sbb(4)-1,sbb(1):sbb(1)+sbb(3)-1,channel_to_do);
        pt=double(pt)/max(double(pt(:)));
        pt_size=size(pt);
        pt=imgaussfilt(pt,4,'FilterSize',[15,15]); 
        pt=imresize(pt,[255,255]);        
        
        pt=adapthisteq(pt);
        
        
%         pt=imadjust(pt);
        pt=pt.*pt;
        
        pt=pt>max(pt(:))*0.5;
        pt=imfill(pt,'holes');
        
        pt=imresize(pt,pt_size);
%         pt_temp=img1(sbb(2):sbb(2)+sbb(4)-1,sbb(1):sbb(1)+sbb(3)-1,channel_to_do);
%         pt=pt_temp.*uint8(pt);
%         
%         edgeThreshold = 0.4;
%         amount = 0.5;
%         pt=localcontrast(pt,edgeThreshold,amount);
%         pt=pt>max(pt(:))*0.9;
        
        pt=imerode(pt,se1);
        
        stats1=regionprops(pt,'Area','Centroid','BoundingBox','MajorAxisLength','MinorAxisLength');
        for k=1:length(stats1)
            if stats1(k).MajorAxisLength>4*stats1(k).MinorAxisLength
                continue;
            end
            
            area_thres=48;

            if stats1(k).Area>=area_thres                    
                cen_all(ctt,:)=(stats1(k).Centroid-[stats(j).BoundingBox(3)/2,stats(j).BoundingBox(4)/2])+stats(j).Centroid; % replace the local position to global position in the slice
%                 cen_all(ctt,:)=(stats1(k).Centroid-[stats1(k).BoundingBox(3)/2,stats1(k).BoundingBox(4)/2])+stats(j).Centroid;
                ctt=ctt+1;
            end
        end
    else
        continue;
    end
end