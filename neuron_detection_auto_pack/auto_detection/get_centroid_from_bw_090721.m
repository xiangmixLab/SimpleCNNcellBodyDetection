function cen_all=get_centroid_from_bw(PMapt,patch_size,img1,channel_to_do)

stats=regionprops(logical(PMapt),'Area','Centroid','Image','MajorAxisLength','MinorAxisLength','BoundingBox');
cen_all=[];
se=strel('disk',4);
ctt=1;

% test
% for i=1:81
%     subplot(9,9,i)
%     sbb=stats(i+81).BoundingBox;
%     pt=img1(sbb(2):sbb(2)+sbb(4)-1,sbb(1):sbb(1)+sbb(3)-1,channel_to_do);
%     imagesc(pt);
% end

for j=1:length(stats)

    if stats(j).Area>200 && sum(sum(stats(j).Image==0))>0 % not white out; contains high intensity area
        %0.65um/pixel
        % 64: ~10um diameter neuron
        % 225:~20um diameter neuron
        % 529:~30um diameter neuron
        sbb=stats(j).BoundingBox;
        pt=img1(sbb(2):sbb(2)+sbb(4)-1,sbb(1):sbb(1)+sbb(3)-1,channel_to_do);
        pt_size=size(pt);
        pt=imresize(pt,[255,255]);
        pt=adapthisteq(pt);
        pt=imgaussfilt(pt,15); 
        pt=imregionalmax(pt);
        pt=imdilate(pt,se);
        pt=imresize(pt,pt_size);
        
        stats1=regionprops(pt,'Area','Centroid','BoundingBox');
        for k=1:length(stats1)
            if stats(j).MajorAxisLength>5*stats(j).MinorAxisLength
                continue;
            end
%             if stats1(k).Area>25
            cen_all(ctt,:)=(stats1(k).Centroid-[stats(j).BoundingBox(3)/2,stats(j).BoundingBox(4)/2])+stats(j).Centroid;
            ctt=ctt+1;
%             end
        end
    else
        continue;
    end
end