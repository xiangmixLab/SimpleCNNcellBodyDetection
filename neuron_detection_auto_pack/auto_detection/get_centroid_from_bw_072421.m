function cen_all=get_centroid_from_bw_072421(PMapt,patch_size,img1,channel_to_do)

pt=imregionalmax(PMapt);
stats=regionprops(logical(PMapt),'Area','Centroid','Image','MajorAxisLength','MinorAxisLength','BoundingBox');
cen_all=[];
patch_area=patch_size(1)*patch_size(2);
se=strel('disk',3);
ctt=1;
for j=1:length(stats)
    if stats(j).MajorAxisLength>4*stats(j).MinorAxisLength
        continue;
    end
    if stats(j).Area>64 && sum(sum(stats(j).Image==0))>0 % not white out; contains high intensity area
        sbb=stats(j).BoundingBox;
        pt=img1(sbb(2):sbb(2)+sbb(4)-1,sbb(1):sbb(1)+sbb(3)-1,channel_to_do);
        pt_size=size(pt);
        pt=imresize(pt,[32,32]);
        pt=adapthisteq(pt);
        pt=imresize(pt,pt_size);
        pt=imadjust(pt);
        pt=imregionalmax(pt);% try to resolve connected neurons
        pt=bwareaopen(pt,16); 
        stats1=regionprops(pt,'Area','Centroid','BoundingBox');
        for k=1:length(stats1)
            if stats1(k).Area>25
                cen_all(ctt,:)=(stats1(k).Centroid-[stats(j).BoundingBox(3)/2,stats(j).BoundingBox(4)/2])+stats(j).Centroid;
                ctt=ctt+1;
            end
        end
    else
        continue;
    end
end