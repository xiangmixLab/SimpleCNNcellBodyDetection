function [score_result]=neuron_PMap_auto_ResNet101_color_072121(net,img,major_slice_area,patch_size)

    %% resize to speed up (no...)
    imgr=img;
    patch_size_r=patch_size;

    %% determine processing pixel idx
    disp('determining process range...');

    imgr1=double(imgr(:,:,1))/max(max(double(imgr(:,:,1))));
    img_peak=imgr1>0.12;
    img_peak=logical(img_peak.*major_slice_area);
    se=strel('disk',2);
    img_peak1=imerode(img_peak,se);
    img_peak1=bwareaopen(img_peak1,3*3);
    [detect_range(:,1),detect_range(:,2)]=find(img_peak1==1);

    detect_range(detect_range(:,1)<=patch_size(2)/2,:)=[];
    detect_range(detect_range(:,1)>=(size(major_slice_area,1)-patch_size(2)/2)-1,:)=[];
    detect_range(detect_range(:,2)<=patch_size(2)/2,:)=[];
    detect_range(detect_range(:,2)>=(size(major_slice_area,2)-patch_size(2)/2)-1,:)=[];
    
    disp('complete')

    %% classifing patches
    disp('processing patches...please wait...');

    tic;
    pix_list_length=size(detect_range,1);
    patch_t_all={};
    for k=1:pix_list_length
        i=detect_range(k,1);
        j=detect_range(k,2);
        patch_t=imgr(i-floor(patch_size_r(2)/2):i+ceil(patch_size_r(2)/2)-1,j-floor(patch_size_r(1)/2):j+ceil(patch_size_r(1)/2)-1,:);
%         patch_t=imresize(patch_t,[36,36]);
        patch_t(:,:,1)=patch_t(:,:,1)/max(max(patch_t(:,:,1)));
        patch_t(:,:,2)=patch_t(:,:,2)/max(max(patch_t(:,:,2)));
        patch_t(:,:,3)=patch_t(:,:,3)/max(max(patch_t(:,:,3)));
        
        patch_t_all{k}=imresize(patch_t,[224 224]);
        patch_t1
        patch_t1=imadjust(patch_t1);
        patch_t1=imgaussfilt(patch_t1,1);
        patch_t1=patch_t1*1/quantile(patch_t1(:),0.95);
        patch_t1(patch_t1>1)=1;
        
    end 
    
    if ~isempty(patch_t_all)
        for k=1:pix_list_length
            [~,score]=classify(net,patch_t_all{k});
            score_result_t(k,1)=score(:,2);
        end
    else
        score_result_t=[];
    end
    
    toc;
    
    disp(['complete']);

    if ~isempty(score_result_t)
        score_result=double(imgr(:,:,1)*0);
        for i=1:size(detect_range,1)
            score_result(detect_range(i,1),detect_range(i,2))=score_result_t(i);
        end
    else
        score_result=double(imgr(:,:,1)*0);
    end

    se=strel('disk',2);
    score_result=imclose(score_result,se);